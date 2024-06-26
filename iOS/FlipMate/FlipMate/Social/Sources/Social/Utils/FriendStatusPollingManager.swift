//
//  FriendStatusPollingManager.swift
//
//
//  Created by 권승용 on 6/2/24.
//

import Foundation
import Combine
import Domain
import Core

public struct StopFriend {
    let id: Int
    let totalTime: Int
    
    public init(id: Int, totalTime: Int) {
        self.id = id
        self.totalTime = totalTime
    }
}

public protocol FriendStatusPollingManageable {
    var updateLearningPublihser: AnyPublisher<[UpdateFriend], Never> { get }
    var updateStopFriendsPublisher: AnyPublisher<[StopFriend], Never> { get }
    
    func update(preFriendStatusArray: [FriendStatus])
    func startPolling(friendsStatus: [FriendStatus])
    func stopPolling()
    func updateLearningFriendsBeforeLearning(friendsStatus: [FriendStatus])
}

public final class FriendStatusPollingManager: FriendStatusPollingManageable {
    private var preFriendStatusArray: [FriendStatus] = []
    private var updateFriendArray: [UpdateFriend] = []
    private let timerManager: TimerManageable
    
    private var updateLearningFriends = PassthroughSubject<[UpdateFriend], Never>()
    private var updateStopFriends = PassthroughSubject<[StopFriend], Never>()
    
    public var updateLearningPublihser: AnyPublisher<[UpdateFriend], Never> {
        return updateLearningFriends.eraseToAnyPublisher()
    }
    
    public var updateStopFriendsPublisher: AnyPublisher<[StopFriend], Never> {
        return updateStopFriends.eraseToAnyPublisher()
    }
    
    public init(timerManager: TimerManageable) {
        self.timerManager = timerManager
    }
    
    public func update(preFriendStatusArray: [FriendStatus]) {
        self.preFriendStatusArray = preFriendStatusArray
    }
    
    public func startPolling(friendsStatus: [FriendStatus]) {
        updateLearningFriendsBeforeStop(friendsStatus: friendsStatus)
        updateStopFriends(friendsStatus: friendsStatus)
        startTimer()
    }
    
    public func stopPolling() {
        updateFriendArray = []
        stopTimer()
    }
    
    public func updateLearningFriendsBeforeLearning(friendsStatus: [FriendStatus]) {
        let learningFriendsBeforeLearning = findLearningFreindsBeforLearning(friendsStatus: friendsStatus)
        for id in learningFriendsBeforeLearning {
            guard let friend = friendsStatus.filter({ $0.id == id }).first else { return }
            guard let startedTime = friend.startedTime else { continue }
            guard let date = startedTime.toDate(.yyyyMMddhhmmssZZZZZ) else { continue }
            let currentLearningTime = Int(Date().timeIntervalSince(date)) - 1
            updateFriendArray.append(UpdateFriend(id: friend.id, currentLearningTime: currentLearningTime))
        }
        startTimer()
    }
    
    private func updateLearningFriendsBeforeStop(friendsStatus: [FriendStatus]) {
        let learningFriendsBeforeStop = findLearningFriendsBeforeStop(friendsStatus: friendsStatus)
        for id in learningFriendsBeforeStop {
            guard let friend = friendsStatus.filter({ $0.id == id }).first else { return }
            guard let startedTime = friend.startedTime else { continue }
            guard let date = startedTime.toDate(.yyyyMMddhhmmssZZZZZ) else { continue }
            let currentLearningTime = Int(Date().timeIntervalSince(date)) - 1
            updateFriendArray.append(UpdateFriend(id: friend.id, currentLearningTime: currentLearningTime))
        }
    }
    
    private func updateStopFriends(friendsStatus: [FriendStatus]) {
        let stopFreindsBeforeLearning = findStopFriendsbeforeLearning(friendsStatus: friendsStatus)
        stopCurrentLearningTime(stopIdList: stopFreindsBeforeLearning, friendsStatus: friendsStatus)
    }
    
    // 공부끝 -> 공부중
    private func findLearningFriendsBeforeStop(friendsStatus: [FriendStatus]) -> [Int] {
        let beforeLearning = preFriendStatusArray
            .filter { $0.startedTime == nil }
            .map { $0.id }
        let currentStop = friendsStatus
            .filter { $0.startedTime != nil }
            .map { $0.id }
        return Array(Set(beforeLearning).intersection(Set(currentStop)))
    }
    
    // 공부중 -> 공부중
    private func findLearningFreindsBeforLearning(friendsStatus: [FriendStatus]) -> [Int] {
        let beforeLearning = preFriendStatusArray
            .filter { $0.startedTime != nil }
            .map { $0.id }
        let currentLearning = friendsStatus
            .filter { $0.startedTime != nil }
            .map { $0.id }
        return Array(Set(beforeLearning).intersection(Set(currentLearning)))
    }
    
    // 공부끝 -> 공부끝
    private func findStopFrinedsBeforeStop(friendsStatus: [FriendStatus]) -> [Int] {
        let beforeStop = preFriendStatusArray
            .filter { $0.startedTime == nil }
            .map { $0.id }
        let currentStop = friendsStatus
            .filter { $0.startedTime == nil }
            .map { $0.id }
        return Array(Set(beforeStop).intersection(Set(currentStop)))
    }
    
    // 공부중 -> 공부끝
    private func findStopFriendsbeforeLearning(friendsStatus: [FriendStatus]) -> [Int] {
        let beforeLearning = preFriendStatusArray
            .filter { $0.startedTime != nil }
            .map { $0.id }
        let currentStop = friendsStatus
            .filter { $0.startedTime == nil }
            .map { $0.id }
        return Array(Set(beforeLearning).intersection(Set(currentStop)))
    }
    
    private func removeUpdateFriendsArray(at id: Int) {
        guard let target = updateFriendArray.filter({ $0.id == id }).first else { return }
        guard let index = updateFriendArray.firstIndex(of: target) else { return }
        updateFriendArray.remove(at: index)
    }
    
    private func stopCurrentLearningTime(stopIdList: [Int], friendsStatus: [FriendStatus]) {
        if stopIdList.isEmpty { return }
        var stopFriendArray = [StopFriend]()
        
        for id in stopIdList {
            guard let totalTime = friendsStatus.filter({ $0.id == id }).first?.totalTime else { continue }
            removeUpdateFriendsArray(at: id)
            stopFriendArray.append(StopFriend(id: id, totalTime: totalTime))
        }
        
        updateStopFriends.send(stopFriendArray)
    }
    
    private func increaseLearningTime() {
        if updateFriendArray.isEmpty { return }
        updateLearningFriends.send(updateFriendArray)
        updateFriendArray.forEach { $0.currentLearningTime += 1 }
    }
    
    private func startTimer() {
        if updateFriendArray.isEmpty { return }
        if timerManager.state == .resumed { return }
        timerManager.start(completion: increaseLearningTime)
    }
    
    private func stopTimer() {
        timerManager.cancel()
    }
}
