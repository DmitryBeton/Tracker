//
//  AnalyticsService.swift
//  Tracker
//
//  Created by Дмитрий Чалов on 07.01.2026.
//


import YandexMobileMetrica

struct AnalyticsService {
    static func activate() {
        guard let configuration = YMMYandexMetricaConfiguration(apiKey: "ddc1714f-57ce-4d96-9d88-a0a072d25729") else { return }

        YMMYandexMetrica.activate(with: configuration)
    }

    func report(event: String, params : [AnyHashable : Any]) {
        YMMYandexMetrica.reportEvent(event, parameters: params, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }
}
