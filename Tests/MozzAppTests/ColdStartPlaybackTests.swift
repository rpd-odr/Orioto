/// Records which tracks were resolved.
    private final class CountingResolver: TrackURLResolver, @unchecked Sendable {
        private let lock = NSLock()
        private var ids: [String] = []
        let url: URL
        init(url: URL) { self.url = url }
        var resolved: [String] { lock.withLock { ids } }
        func resolve(_ track: Track) async throws -> ResolvedTrackURL {
            lock.withLock { ids.append(track.id) }
            return ResolvedTrackURL(url: url, isLocal: true)
        }
    }
