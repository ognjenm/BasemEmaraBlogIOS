//
//  AppConfiguration.swift
//  Basem Emara
//
//  Created by Basem Emara on 2018-10-21.
//  Copyright © 2018 Zamzam Inc. All rights reserved.
//

import SwiftyPress
import ZamzamKit

class AppConfigurator: CoreConfigurator {
    private let environment: Environment
    
    override init() {
        // Declare environment mode
        self.environment = {
            #if DEBUG
            return .development
            #elseif STAGING
            return .staging
            #else
            return .production
            #endif
        }()
        
        super.init()
    }
    
    override func resolveStore() -> ConstantsStore {
        return ConstantsMemoryStore(
            environment: environment,
            itunesName: "basememara",
            itunesID: "1021806851",
            baseURL: {
                let string: String
                switch environment {
                case .development:
                    string = "https://mnemagazin.me"
                case .staging:
                    string = "https://mnemagazin.me"
                case .production:
                    string = "https://mnemagazin.me"
                }
                
                guard let url = URL(string: string) else {
                    fatalError("Could not determine base URL of server.")
                }
                
                return url
            }(),
            baseREST: "wp-json/swiftypress/v5",
            wpREST: "wp-json/wp/v2",
            email: "contact@basememara.com",
            privacyURL: "https://mnemagazin.me/privacy/?mobileembed=1",
            disclaimerURL: "https://mnemagazin.me/disclaimer/?mobileembed=1",
            styleSheet: "https://basememara.com/wp-content/themes/metro-pro/style.css",
            googleAnalyticsID: "UA-59508242-1",
            featuredCategoryID: 170,
            defaultFetchModifiedLimit: 25,
            taxonomies: ["category", "post_tag", "series"],
            postMetaKeys: ["_series_part"],
            logFileName: "mnemagazin"
        )
    }
    
    override func resolveStore() -> PreferencesStore {
        let constants: ConstantsType = resolve()
        
        return PreferencesDefaultsStore(
            defaults: {
                UserDefaults(
                    suiteName: {
                        switch constants.environment {
                        case .development, .staging:
                            return "group.io.zamzam.Basem-Emara-staging"
                        case .production:
                            return "group.io.zamzam.Basem-Emara"
                        }
                    }()
                ) ?? .standard
            }()
        )
    }
    
    override func resolveStore() -> SeedStore {
        return SeedFileStore(
            forResource: "seed.json",
            inBundle: .main
        )
    }
    
    override func resolve() -> Theme {
        let preferences: PreferencesType = resolve()
        
        return ThemePreset(rawValue: preferences.get(.currentTheme) ?? "")?.type
            ?? ThemePreset.default.type
    }
}
