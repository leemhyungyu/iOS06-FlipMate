//
//  DefaultChartRepository.swift
//  FlipMate
//
//  Created by 신민규 on 12/5/23.
//

import Foundation

final class DefaultChartRepository: ChartRepository {
    private let provider: Providable
    
    init(provider: Providable) {
        self.provider = provider
    }
    
    func fetchDailyLog(date: Date) async throws -> ChartLog {
        let endpoint = ChartEndpoints.fetchDailyLog(date: date)
        let responseDTO = try await provider.request(with: endpoint)
        
        let categories = responseDTO.categories?.map { dto in
            return Category(id: dto.id, color: dto.color, subject: dto.name, studyTime: dto.todayTime)
        } ?? []
        
        return ChartLog(studyLog: StudyLog(totalTime: responseDTO.todayTime, category: categories), percentage: responseDTO.percentage)
    }
}