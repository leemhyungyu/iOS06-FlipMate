//
//  DefaultFriendRepository.swift
//  FlipMate
//
//  Created by 임현규 on 2023/11/29.
//

import Foundation
import Combine

import Domain
import Network
import Core

public final class DefaultFriendRepository: FriendRepository {
    
    private let provider: Providable
    
    public init(provider: Providable) {
        self.provider = provider
    }
    
    public func follow(at nickname: String) -> AnyPublisher<String, NetworkError> {
        let reqeustDTO = FriendFollowReqeustDTO(nickname: nickname)
        let endPoint = FriendEndpoints.followFriend(with: reqeustDTO)
        return provider.request(with: endPoint)
            .map { response -> String in
                return response.message
            }
            .eraseToAnyPublisher()
    }
    
    public func unfollow(at id: Int) -> AnyPublisher<String, NetworkError> {
        let requestDTO = FriendUnfollowRequestDTO(id: id)
        let endPoint = FriendEndpoints.unfollowFreind(with: requestDTO)
        return provider.request(with: endPoint)
            .map { response -> String in
                return response.message
            }
            .eraseToAnyPublisher()
    }
    
    public func search(at nickname: String) -> AnyPublisher<FriendSearchResult, NetworkError> {
        let endPoint = FriendEndpoints.searchFriend(at: nickname)
        return provider.request(with: endPoint)
            .map { response -> FriendSearchResult in
                return FriendSearchResult(
                    status: FriendSearchStatus(rawValue: response.statusCode) ?? .unknown,
                    imageURL: response.profileImageURL)
            }
            .eraseToAnyPublisher()
    }
    
    public func loadChart(at id: Int) -> AnyPublisher<SocialChart, NetworkError> {
        let requestDTO = SocialDetailRequestDTO(followingID: id, date: Date().dateToString(format: .yyyyMMdd))
        let endPoint = FriendEndpoints.loadFriendData(with: requestDTO)
        return provider.request(with: endPoint)
            .map { response -> SocialChart in
                return SocialChart(myData: response.myData, friendData: response.followingData, primaryCategory: response.primaryCategory)
            }
            .eraseToAnyPublisher()
    }
}
