//
//  ChartEndpoints.swift
//  FlipMate
//
//  Created by 신민규 on 12/5/23.
//

import Foundation
import Network

struct ChartEndpoints {
    static func fetchDailyLog(date: Date) -> EndPoint<DailyChartLogResponseDTO> {
        return EndPoint(
            baseURL: BaseURL.flipmateDomain,
            path: Paths.studylogs + "/stats" + "?date=\(date.dateToString(format: .yyyyMMdd))",
            method: .get)
    }
    
    static func fetchWeeklyLog() -> EndPoint<WeeklyChartLogResponseDTO> {
        let date = Date()
        return EndPoint(
            baseURL: BaseURL.flipmateDomain,
            path: Paths.studylogs + "/stats/weekly" + "?date=\(date.dateToString(format: .yyyyMMdd))", method: .get)
    }
}
