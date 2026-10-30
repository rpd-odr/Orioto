import Foundation
#if canImport(FoundationNetworking)
// Off Apple, URLSession and the rest of the URL loading system live in their
// own module rather than in Foundation. The HTTP stream below is portable
// logic — it is the desktop shells that reach it — so it has to import them
// where they actually are.
import FoundationNetworking
#endif
import MozzAudioEngine

/// Reads a track from a file on disk.
///
/// The simple case, and the one downloads use. Kept separate from the HTTP
/// stream rather than folded into it, because a local file needs none of the
/// range requests, retries or buffering that a network stream does, and a
/// single class doing both would carry that machinery into the path that has
/// no use for it.
public final class FileStream: AudioEngine.Stream {
    private let handle: FileHandle
    private var closed = false

    public init?(url: URL) {
        guard let handle = try? FileHandle(forReadingFrom: url) else { return nil }
        self.handle = handle
    }

    public func read(into buffer: UnsafeMutablePointer<UInt8>, count: Int) -> Int {
        guard !closed, count > 0 else { return 0 }
        guard let data = try? handle.read(upToCount: count), !data.isEmpty else { return 0 }
        data.copyBytes(to: buffer, count: data.count)
        return data.count
    }

    public func seek(offset: Int64, origin: Int32) -> Int64 {
        guard !closed else { return -1 }

        // Read the current position BEFORE asking for the size, because
        // seekToEnd moves the file offset. Doing it the other way round makes
        // every seek-from-current behave as a seek-from-end, which a decoder
        // probing a container reads as a file that keeps ending early.
        let current = Int64((try? handle.offset()) ?? 0)
        let size = Int64((try? handle.seekToEnd()) ?? 0)

        let base: Int64
        switch origin {
        case 1: base = current
        case 2: base = size
        default: base = 0
        }
        let target = UInt64(max(0, min(base + offset, size)))
        do {
            try handle.seek(toOffset: target)
        } catch {
            return -1
        }
        return Int64(target)
    }

    public func close() {
        guard !closed else { return }
        closed = true
        try? handle.close()
    }
}

/// Persistent range cache for streamed tracks. The default is three tracks;
/// apps can expose these controls in Settings. Only hashed request identities
/// are stored on disk, never URLs or authorization headers.
public enum HTTPStreamCache {
    private static let store = HTTPStreamDiskCache()
    public static func configure(enabled: Bool, maximumTracks: Int) {
        store.configure(enabled: enabled, maximumTracks: maximumTracks)
    }
    public static func clear() { store.clear() }
    public static var cachedTrackCount: Int { store.cachedTrackCount }
    fileprivate static func read(key: String, offset: Int64) -> (start: Int64, data: Data)? {
        store.read(key: key, offset: offset)
    }
    fileprivate static func write(key: String, offset: Int64, data: Data) {
        store.write(key: key, offset: offset, data: data)
    }
}

private final class HTTPStreamDiskCache: @unchecked Sendable {
    private let lock = NSLock()
    private var enabled = true
    private var maximumTracks = 3
    private let fileManager = FileManager.default
    private let directory: URL

    init() {
        let defaults = UserDefaults.standard
        enabled = defaults.object(forKey: "audioTrackCacheEnabled") as? Bool ?? true
        let savedLimit = defaults.object(forKey: "audioTrackCacheMaximumTracks") as? Int ?? 3
        maximumTracks = min(10, max(1, savedLimit))
        let root = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first
            ?? fileManager.temporaryDirectory
        directory = root.appendingPathComponent("MozzAudioTrackCache", isDirectory: true)
        try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    func configure(enabled: Bool, maximumTracks: Int) {
        lock.lock()
        self.enabled = enabled
        self.maximumTracks = min(10, max(1, maximumTracks))
        UserDefaults.standard.set(enabled, forKey: "audioTrackCacheEnabled")
        UserDefaults.standard.set(self.maximumTracks, forKey: "audioTrackCacheMaximumTracks")
        lock.unlock()
        if enabled { evictIfNeeded() }
    }

    var cachedTrackCount: Int {
        lock.lock()
        defer { lock.unlock() }
        let names = (try? fileManager.contentsOfDirectory(atPath: directory.path)) ?? []
        return Set(names.compactMap { $0.split(separator: "-").first.map(String.init) }).count
    }

    func clear() {
        lock.lock()
        defer { lock.unlock() }
        try? fileManager.removeItem(at: directory)
        try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    func read(key: String, offset: Int64) -> (start: Int64, data: Data)? {
        lock.lock()
        defer { lock.unlock() }
        guard enabled else { return nil }
        let prefix = key + "-"
        let urls = (try? fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)) ?? []
        for url in urls where url.lastPathComponent.hasPrefix(prefix) && url.pathExtension == "bin" {
            let suffix = String(url.lastPathComponent.dropFirst(prefix.count).dropLast(4))
            guard let start = Int64(suffix), offset >= start,
                  let data = try? Data(contentsFrom: url),
                  offset < start + Int64(data.count) else { continue }
            try? fileManager.setAttributes([.modificationDate: Date()], ofItemAtPath: url.path)
            return (start, data)
        }
        return nil
    }

    func write(key: String, offset: Int64, data: Data) {
        lock.lock()
        guard enabled else { lock.unlock(); return }
        let url = directory.appendingPathComponent("\(key)-\(offset).bin")
        do {
            try data.write(to: url, options: .atomic)
        } catch {
            lock.unlock()
            return
        }
        lock.unlock()
        evictIfNeeded()
    }

    private func evictIfNeeded() {
        lock.lock()
        defer { lock.unlock() }
        guard enabled else { return }
        let urls = (try? fileManager.contentsOfDirectory(
            at: directory, includingPropertiesForKeys: [.contentModificationDateKey]
        )) ?? []
        var newestByTrack: [String: Date] = [:]
        for url in urls {
            guard let prefix = url.lastPathComponent.split(separator: "-").first.map(String.init) else { continue }
            let date = (try? url.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? .distantPast
            newestByTrack[prefix] = max(newestByTrack[prefix] ?? .distantPast, date)
        }
        let stale = newestByTrack.sorted { $0.value > $1.value }
            .dropFirst(maximumTracks).map(\.key)
        for url in urls where stale.contains(where: { url.lastPathComponent.hasPrefix($0 + "-") }) {
            try? fileManager.removeItem(at: url)
        }
    }
}

/// Reads a track from a media server over HTTP, with the caller's credentials.
///
/// `AVQueuePlayer` did this invisibly, which is most of why it was worth
/// keeping for so long. Doing it here is the price of one engine instead of
/// three, and it buys something back: the same streaming behaviour on every
/// platform, rather than whatever each OS media framework happens to do.
///
/// ## Blocking is correct here
///
/// Every method blocks the calling thread. That looks alarming and is exactly
/// right: the engine only ever calls these from its decode thread, never from
/// the audio callback, and that thread's whole job is to get ahead of playback.
/// A decode thread that blocks for 200ms on a slow server is a decode thread
/// doing its job; the ring it feeds is what protects the sound.
///
/// ## Seeking
///
/// Seeks are served by a fresh ranged request rather than by buffering the
/// whole file. A range that the server ignores - some return 200 and the whole
/// body instead of 206 - is detected and treated as a failure rather than
/// silently producing audio from the wrong offset, which would sound like a
/// corrupt file.
public final class HTTPStream: AudioEngine.Stream {
    private let request: URLRequest
    private let session: URLSession
    private let timeout: TimeInterval
    private let diagnostics: (@Sendable (String) -> Void)?

    /// Bytes already delivered, which is also the offset the next request needs.
    private var position: Int64 = 0
    /// Total length, once the server has told us. Nil until the first response.
    private var totalLength: Int64?
    /// Whatever the last response delivered that has not been read yet.
    private var buffered = Data()
    /// Absolute offset the buffer starts at.
    private var bufferStart: Int64 = 0
    private var closed = false
    private var loggedResponse = false

    /// How much to ask for at a time.
    ///
    /// Large enough that a track is a handful of requests rather than hundreds,
    /// small enough that a seek does not first wait for megabytes nobody wants.
    private let chunkSize: Int
    /// Stable one-way identity; raw URLs and credentials are never persisted.
    private let cacheKey: String

    public init(
        request: URLRequest,
        session: URLSession = .shared,
        chunkSize: Int = 512 * 1024,
        timeout: TimeInterval = 30,
        diagnostics: (@Sendable (String) -> Void)? = nil
    ) {
        self.request = request
        self.session = session
        self.chunkSize = chunkSize
        self.timeout = timeout
        self.diagnostics = diagnostics
        self.cacheKey = Self.makeCacheKey(request)
    }

    public func read(into buffer: UnsafeMutablePointer<UInt8>, count: Int) -> Int {
        guard !closed, count > 0 else { return 0 }

        if let totalLength, position >= totalLength {
            return 0
        }

        if !bufferCovers(position) {
            guard fetch(from: position) else { return -1 }
        }

        let offsetInBuffer = Int(position - bufferStart)
        guard offsetInBuffer >= 0, offsetInBuffer < buffered.count else { return 0 }

        let take = min(count, buffered.count - offsetInBuffer)
        buffered.withUnsafeBytes { raw in
            guard let base = raw.baseAddress else { return }
            buffer.update(from: base.advanced(by: offsetInBuffer).assumingMemoryBound(to: UInt8.self), count: take)
        }
        position += Int64(take)
        return take
    }

    public func seek(offset: Int64, origin: Int32) -> Int64 {
        guard !closed else { return -1 }

        let base: Int64
        switch origin {
        case 1:
            base = position
        case 2:
            // Seeking from the end needs the length, and the length only
            // arrives with a response. Ask for one byte rather than the file.
            if totalLength == nil, !fetch(from: 0, length: 1) { return -1 }
            base = totalLength ?? 0
        default:
            base = 0
        }

        var target = base + offset
        if target < 0 { target = 0 }
        if let totalLength, target > totalLength { target = totalLength }
        position = target
        return target
    }

    public func close() {
        guard !closed else { return }
        closed = true
        buffered = Data()
    }

    private func bufferCovers(_ offset: Int64) -> Bool {
        guard !buffered.isEmpty else { return false }
        return offset >= bufferStart && offset < bufferStart + Int64(buffered.count)
    }

    /// Fetch a range synchronously, replacing the buffer.
    private func fetch(from offset: Int64, length: Int? = nil) -> Bool {
        if length == nil, let cached = HTTPStreamCache.read(key: cacheKey, offset: offset) {
            bufferStart = cached.start
            buffered = cached.data
            return true
        }
        var ranged = request
        let want = length ?? chunkSize
        let end = offset + Int64(want) - 1
        ranged.setValue("bytes=\(offset)-\(end)", forHTTPHeaderField: "Range")
        ranged.timeoutInterval = timeout

        // A semaphore rather than async/await because the engine's decode
        // thread calls this synchronously and has nowhere to suspend to.
        let gate = DispatchSemaphore(value: 0)
        var payload: Data?
        var response: HTTPURLResponse?
        let diagnostics = self.diagnostics

        let task = session.dataTask(with: ranged) { data, urlResponse, error in
            payload = data
            response = urlResponse as? HTTPURLResponse
            if let error = error as NSError? {
                NSLog("Mozz audio request failed: domain=%@ code=%ld", error.domain, error.code)
                diagnostics?("audio request failed: domain=\(error.domain) code=\(error.code)")
            }
            gate.signal()
        }
        task.resume()

        if gate.wait(timeout: .now() + timeout + 5) == .timedOut {
            task.cancel()
            NSLog("Mozz audio request timed out")
            diagnostics?("audio request timed out")
            return false
        }

        guard let response, let payload else { return false }
        if !loggedResponse || !(200...299).contains(response.statusCode) {
            NSLog("Mozz audio response: status=%ld type=%@ bytes=%ld offset=%lld",
                  response.statusCode, response.mimeType ?? "unknown", payload.count, offset)
            diagnostics?("audio response: status=\(response.statusCode) type=\(response.mimeType ?? "unknown") bytes=\(payload.count) offset=\(offset)")
            loggedResponse = true
        }

        switch response.statusCode {
        case 206:
            // A proper partial response. Content-Range carries the true total,
            // which is the only reliable place to learn it.
            if let contentRange = response.value(forHTTPHeaderField: "Content-Range"),
                let total = contentRange.split(separator: "/").last,
                let parsed = Int64(total)
            {
                totalLength = parsed
            }
            bufferStart = offset
            buffered = payload
            if length == nil { HTTPStreamCache.write(key: cacheKey, offset: offset, data: payload) }
            return true

        case 200:
            // The server ignored the range and sent the whole body. Honest for
            // offset zero and wrong for anything else - accepting it there
            // would decode from the start while claiming to be elsewhere, which
            // sounds like a corrupt file rather than a bug.
            guard offset == 0 else { return false }
            totalLength = Int64(payload.count)
            bufferStart = 0
            buffered = payload
            HTTPStreamCache.write(key: cacheKey, offset: 0, data: payload)
            return true

        case 416:
            // Asked past the end. Not a failure: it is how a stream ends when
            // the length was never announced.
            totalLength = offset
            buffered = Data()
            return true

        default:
            return false
        }
    }

    /// Stable one-way identity; raw URLs and credentials are never persisted.
    private static func makeCacheKey(_ request: URLRequest) -> String {
        let headers = (request.allHTTPHeaderFields ?? [:]).sorted { $0.key < $1.key }
            .map { "\($0.key.lowercased()):\($0.value)" }
        let material = ([request.url?.absoluteString ?? ""] + headers).joined(separator: "\n")
        var hash: UInt64 = 0xcbf29ce484222325
        for byte in material.utf8 {
            hash ^= UInt64(byte)
            hash &*= 0x100000001b3
        }
        return String(hash, radix: 16)
    }
}
