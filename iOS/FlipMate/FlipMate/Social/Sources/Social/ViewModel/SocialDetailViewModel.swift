//
//  SocialDetailViewModel.swift
//
//
//  Created by 권승용 on 6/2/24.
//

import Foundation
import Combine
import Domain
import Core

public struct SocialDetailViewModelActions {
    var didCancelSocialDetail: () -> Void
    var didFinishUnfollow: () -> Void
    
    public init(didCancelSocialDetail: @escaping () -> Void, didFinishUnfollow: @escaping () -> Void) {
        self.didCancelSocialDetail = didCancelSocialDetail
        self.didFinishUnfollow = didFinishUnfollow
    }
}

public protocol SocialDetailViewModelInput {
    func viewDidLoad()
    func didUnfollowFriend()
    func dismissButtonDidTapped()
}

public protocol SocialDetailViewModelOutput {
    var friendPublisher: AnyPublisher<Friend, Never> { get }
    var seriesPublusher: AnyPublisher<[Series], Never> { get }
}

public typealias SocialDetailViewModelProtocol = SocialDetailViewModelInput & SocialDetailViewModelOutput

public final class SocialDetailViewModel: SocialDetailViewModelProtocol {
    // MARK: - Properties
    private var cancellables = Set<AnyCancellable>()
    private let friend: Friend
    private let actions: SocialDetailViewModelActions?
    
    // MARK: - UseCase
    private let loadChartUseCase: LoadChartUseCase
    private let unfollowUseCase: UnfollowFriendUseCase
    
    // MARK: - Subject
    private lazy var friendSubject = CurrentValueSubject<Friend, Never>(friend)
    private let seriesSubject = PassthroughSubject<[Series], Never>()
    
    // MARK: - Publisher
    public var friendPublisher: AnyPublisher<Friend, Never> {
        return friendSubject.eraseToAnyPublisher()
    }
    
    public var seriesPublusher: AnyPublisher<[Series], Never> {
        return seriesSubject.eraseToAnyPublisher()
    }
    
    public init(friend: Friend,
         loadChartUseCase: LoadChartUseCase,
         unfollowUseCase: UnfollowFriendUseCase,
         actions: SocialDetailViewModelActions? = nil) {
        self.friend = friend
        self.loadChartUseCase = loadChartUseCase
        self.unfollowUseCase = unfollowUseCase
        self.actions = actions
    }
    
    public func viewDidLoad() {
        loadChartUseCase.loadChart(at: friend.id)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    FMLogger.friend.log("차트 조회 성공")
                case .failure(let error):
                    FMLogger.friend.error("차트 조회 실패 \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] chartInfo in
                guard let self = self else { return }
                self.handleChartInfo(chartInfo)
            }
            .store(in: &cancellables)
    }
    
    public func didUnfollowFriend() {
        unfollowUseCase.unfollow(at: friend.id)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    FMLogger.friend.log("팔로우 취소 성공")
                case .failure(let error):
                    FMLogger.friend.error("팔로우 취소 실패 \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] _ in
                guard let self = self else { return }
                self.actions?.didFinishUnfollow()
            }
            .store(in: &cancellables)
    }
    
    public func dismissButtonDidTapped() {
        actions?.didCancelSocialDetail()
    }
}

private extension SocialDetailViewModel {
    func handleChartInfo(_ chartInfo: SocialChart) {
        guard chartInfo.myData.count >= 7, chartInfo.friendData.count >= 7 else { return }
        
        let myChartData = generateSeriesData(
            from: chartInfo.myData,
            user: NSLocalizedString("me", comment: ""),
            isMySereis: true,
            hexString: "78FB4EFF")
        let friendChartData = generateSeriesData(
            from: chartInfo.friendData,
            user: NSLocalizedString("friend", comment: ""),
            isMySereis: false,
            hexString: "285FF4FF")
        
        let newSeries: [Series] = [myChartData, friendChartData]
        
        seriesSubject.send(newSeries)
    }
    
    func generateSeriesData(from data: [Int], user: String, isMySereis: Bool, hexString: String) -> Series {
        let weekdays = (0..<7).map { index in
            Date(timeIntervalSinceNow: -86400 * Double(6 - index))
        }
        
        return Series(isMySeries: isMySereis, user: user, studyTime: data, weekdays: weekdays, hexString: hexString)
    }
}
