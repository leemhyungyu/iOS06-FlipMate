//
//  FriendAddViewModel.swift
//
//
//  Created by 권승용 on 6/2/24.
//

import Foundation
import Combine
import Domain
import Core

public struct FriendAddViewModelActions {
    var didCancleFriendAdd: () -> Void
    var didSuccessFriendAdd: () -> Void
    
    public init(didCancleFriendAdd: @escaping () -> Void, didSuccessFriendAdd: @escaping () -> Void) {
        self.didCancleFriendAdd = didCancleFriendAdd
        self.didSuccessFriendAdd = didSuccessFriendAdd
    }
}

public protocol FriendAddViewModelInput {
    func nicknameDidChange(at nickname: String)
    func didFollowFriend()
    func didSearchFriend()
    func dismissButtonDidTapped()
}

public protocol FriendAddViewModelOutput {
    var myNicknamePublihser: AnyPublisher<String, Never> { get }
    var searchFreindPublisher: AnyPublisher<FreindSeacrhItem, Never> { get }
    var searchErrorPublisher: AnyPublisher<Error, Never> { get }
    var nicknameCountPublisher: AnyPublisher<Int, Never> { get }
    var followErrorPublisher: AnyPublisher<Void, Never> { get }
}

public typealias FriendAddViewModelProtocol = FriendAddViewModelInput & FriendAddViewModelOutput

public final class FriendAddViewModel: FriendAddViewModelProtocol {
    // MARK: - Subject
    private var searchResultSubject = PassthroughSubject<FreindSeacrhItem, Never>()
    private var searchErrorSubject = PassthroughSubject<Error, Never>()
    private var nicknameCountSubject = PassthroughSubject<Int, Never>()
    private var followErrorSubject = PassthroughSubject<Void, Never>()
    
    // MARK: - Properties
    private var cancellables = Set<AnyCancellable>()
    private var friendNickname: String = ""
    private let followUseCase: FollowFriendUseCase
    private let searchUseCase: SearchFriendUseCase
    private let actions: FriendAddViewModelActions?
    private let userInfoManger: UserInfoManageable
    
    public init(followUseCase: FollowFriendUseCase,
         searchUseCase: SearchFriendUseCase,
         actions: FriendAddViewModelActions? = nil,
         userInfoManager: UserInfoManageable) {
        self.followUseCase = followUseCase
        self.searchUseCase = searchUseCase
        self.actions = actions
        self.userInfoManger = userInfoManager
    }
    
    // MARK: - output
    public var searchFreindPublisher: AnyPublisher<FreindSeacrhItem, Never> {
        return searchResultSubject.eraseToAnyPublisher()
    }
    
    public var searchErrorPublisher: AnyPublisher<Error, Never> {
        return searchErrorSubject.eraseToAnyPublisher()
    }
    
    public var nicknameCountPublisher: AnyPublisher<Int, Never> {
        return nicknameCountSubject.eraseToAnyPublisher()
    }
    
    public var myNicknamePublihser: AnyPublisher<String, Never> {
        return userInfoManger.nicknameChangePublisher
    }
    
    public var followErrorPublisher: AnyPublisher<Void, Never> {
        return followErrorSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Input
    public func didFollowFriend() {
        followUseCase.follow(at: friendNickname)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    FMLogger.friend.debug("친구 요청 성공")
                case .failure(let error):
                    guard let self = self else { return }
                    FMLogger.friend.error("친구 요청 에러 발생 \(error)")
                    self.followErrorSubject.send()
                }
            } receiveValue: { [weak self] _ in
                guard let self = self else { return }
                self.actions?.didSuccessFriendAdd()
            }
            .store(in: &cancellables)
    }
    
    public func didSearchFriend() {
        searchUseCase.search(at: friendNickname)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                switch completion {
                case .finished:
                    FMLogger.friend.debug("친구 검색 성공")
                case .failure(let error):
                    FMLogger.friend.error("친구 검색 에러 발생 \(error.localizedDescription)")
                    self.searchErrorSubject.send(error)
                }
            } receiveValue: { [weak self] friendSearchResult in
                guard let self = self else { return }
                self.searchResultSubject.send(FreindSeacrhItem(
                    nickname: friendNickname,
                    iamgeURL: friendSearchResult.imageURL,
                    status: friendSearchResult.status)
                )
            }
            .store(in: &cancellables)
    }
    
    public func nicknameDidChange(at nickname: String) {
        friendNickname = nickname
        nicknameCountSubject.send(nickname.count)
    }
    
    public func dismissButtonDidTapped() {
        actions?.didCancleFriendAdd()
    }
}
