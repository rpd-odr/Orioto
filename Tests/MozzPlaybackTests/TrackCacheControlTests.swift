import XCTest
@testable import MozzPlayback

/// The Settings section configures the local track cache through
/// `TrackCacheControl` rather than importing `MozzAudioEngine` — the shell
/// import interlock fails the build on that import, so this facade is the one
/// doorway the app has. These assertions keep the doorway working: if the
/// forwarding breaks, Settings silently stops configuring the cache.
final class TrackCacheControlTests: XCTestCase {
    func testConfigureAndClearAreForwardedToTheEngineCache() {
        TrackCacheControl.configure(enabled: true, maximumTracks: 3)
        TrackCacheControl.clear()
        XCTAssertEqual(TrackCacheControl.cachedTrackCount, 0)

        // Disabling must not lose the count contract: Settings reads it to
        // decide whether "Clear Local Cache" is actionable.
        TrackCacheControl.configure(enabled: false, maximumTracks: 1)
        XCTAssertEqual(TrackCacheControl.cachedTrackCount, 0)

        // Restore the app's default for the test runner and any later test.
        TrackCacheControl.configure(enabled: true, maximumTracks: 3)
        TrackCacheControl.clear()
    }
}
