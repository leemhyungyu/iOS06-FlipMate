//
//  FriendUseCase.swift
//  FlipMate
//
//  Created by 임현규 on 2023/11/29.
//

import Foundation
import Combine

protocol FriendUseCase {
    func follow(at nickname: String) -> AnyPublisher<String, NetworkError>
    func search(at nickname: String) -> AnyPublisher<String?, NetworkError>
}