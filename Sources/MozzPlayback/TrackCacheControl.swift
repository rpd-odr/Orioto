import Foundation
import MozzAudioEngine

/// The shell-facing controls for the local track cache: whether it is on, how
/// many tracks it keeps, how many it holds right now, and how to empty it.
///
/// These forward to `MozzAudioEngine.HTTPStreamCache`. They live here so that
/// `MozzApp` never imports `MozzAudioEngine` — `tools/check-shell-imports.sh`
/// fails the build on that import specifically, and ADR-0016 says audio is the
/// module that must never appear in the app's direct-import surface at all.
/// The cache is a playback-level policy (what to keep on disk while playing a
/// stream), so it belongs to the layer that already owns playback and already
/// depends on the engine.
///
/// A non-Apple shell reaches the same controls through this module's other
/// doorways, which is the point: a Settings toggle here is not an iOS-only
/// capability.
public enum TrackCacheControl {
    /// Enable or disable the cache and set how many tracks it keeps
    /// (clamped to 1...10 inside the engine).
    public static func configure(enabled: Bool, maximumTracks: Int) {
        HTTPStreamCache.configure(enabled: enabled, maximumTracks: maximumTracks)
    }

    /// Delete every cached track from disk.
    public static func clear() {
        HTTPStreamCache.clear()
    }

    /// How many tracks are cached on disk right now.
    public static var cachedTrackCount: Int {
        HTTPStreamCache.cachedTrackCount
    }
}
