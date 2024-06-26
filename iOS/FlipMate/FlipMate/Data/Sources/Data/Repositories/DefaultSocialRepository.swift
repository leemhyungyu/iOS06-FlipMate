//
//  DefaultSocialRepository.swift
//  FlipMate
//
//  Created by 임현규 on 2023/11/30.
//

import Foundation
import Combine

import Domain
import Network
import Core

public final class DefaultSocialRepository: SocialRepository {
    private let provider: Providable
    
    public init(provider: Providable) {
        self.provider = provider
    }
    
    public func getMyFriend(date: Date) -> AnyPublisher<[Friend], NetworkError> {
        let endPoint = SocialEndpoints.getMyFreinds(date: date)
        return provider.request(with: endPoint)
            .map { response -> [Friend] in
                return response.map { Friend(
                    id: $0.id,
                    nickName: $0.nickname,
                    profileImageURL: $0.imageURL,
                    totalTime: $0.totalTime,
                    startedTime: $0.startTime,
                    isStuding: $0.startTime != nil ? true: false)
                }
            }
            .eraseToAnyPublisher()
    }
    
    public func fetchMyFriend(date: Date) -> AnyPublisher<[FriendStatus], NetworkError> {
        let endpoint = SocialEndpoints.fetchMyFriend(date: date)
        return provider.request(with: endpoint)
            .map { response -> [FriendStatus] in
                return response.map {
                    FriendStatus(
                        id: $0.id,
                        totalTime: $0.totalTime,
                        startedTime: $0.startTime
                    )
                }
            }
            .eraseToAnyPublisher()
    }
}
