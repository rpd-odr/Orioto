        let appVersion = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "dev"
        let enrichmentConfig = EnrichmentConfig(
            userAgent: "Mozz/\(appVersion) ( https://github.com/thatcube/Mozz )")
        // One shared limiter/client per service so every call across the app
        // honors one budget. MusicBrainz and ListenBrainz get SEPARATE limiters
        // (different hosts/policies).
        let mbLimiter = AsyncRateLimiter(minInterval: enrichmentConfig.minRequestInterval)
        let lbLimiter = AsyncRateLimiter(minInterval: enrichmentConfig.listenBrainzMinInterval)
        let enrichmentStore = EnrichmentStore(database)
        let enrichmentEnabledKey = Self.enrichmentEnabledKey
        self.enrichmentStore = enrichmentStore
        self.enrichmentAlgorithm = enrichmentConfig.listenBrainzAlgorithm
        self.enrichment = EnrichmentService(
            store: enrichmentStore,
            musicBrainz: MusicBrainzClient.make(config: enrichmentConfig, limiter: mbLimiter),
            listenBrainz: ListenBrainzClient.make(config: enrichmentConfig, limiter: lbLimiter),
            config: enrichmentConfig,
            isEnabled: {
                UserDefaults.standard.object(forKey: enrichmentEnabledKey) as? Bool ?? true
            })
