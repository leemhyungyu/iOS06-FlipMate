//
//  ProfileSettingsViewModel.swift
//
//
//  Created by 권승용 on 6/3/24.
//

import Foundation
import Combine
import Domain
import Core

public struct ProfileSettingsViewModelActions {
    let didFinishSignUp: () -> Void
    
    public init(didFinishSignUp: @escaping () -> Void) {
        self.didFinishSignUp = didFinishSignUp
    }
}

public protocol ProfileSettingsViewModelInput {
    func nickNameChanged(_ newNickName: String)
    func profileImageChanged()
    func signUpButtonTapped(userName: String, profileImageData: Data)
}

public protocol ProfileSettingsViewModelOutput {
    var nicknamePublisher: AnyPublisher<String, Never> { get }
    var imageURLPublisher: AnyPublisher<String?, Never> { get }
    var isValidNickNamePublisher: AnyPublisher<NickNameValidationState, Never> { get }
    var isProfileImageChangedPublisher: AnyPublisher<Void, Never> { get }
    var imageNotSafePublisher: AnyPublisher<Void, Never> { get }
    var isSignUpCompletedPublisher: AnyPublisher<Void, Never> { get }
    var errorPublisher: AnyPublisher<Error, Never> { get }
}

public typealias ProfileSettingsViewModelProtocol = ProfileSettingsViewModelInput & ProfileSettingsViewModelOutput

public final class ProfileSettingsViewModel: ProfileSettingsViewModelProtocol {
    // MARK: - Use Case
    private let validateNicknameUseCase: ValidateNicknameUseCase
    private let setupProfileInfoUseCase: SetupProfileInfoUseCase
    
    // MARK: - Subjects
    private var isValidNickNameSubject = PassthroughSubject<NickNameValidationState, Never>()
    private var isProfileImageChangedSubject = PassthroughSubject<Void, Never>()
    private var imageNotSafeSubject = PassthroughSubject<Void, Never>()
    private var isSignUpCompletedSubject = PassthroughSubject<Void, Never>()
    private var errorSubject = PassthroughSubject<Error, Never>()
    private let actions: ProfileSettingsViewModelActions?
    private let userInfoManager: UserInfoManageable
    
    public init(validateNicknameUseCase: ValidateNicknameUseCase,
         setupProfileInfoUseCase: SetupProfileInfoUseCase,
         actions: ProfileSettingsViewModelActions?,
         userInfoManager: UserInfoManageable) {
        self.validateNicknameUseCase = validateNicknameUseCase
        self.setupProfileInfoUseCase = setupProfileInfoUseCase
        self.actions = actions
        self.userInfoManager = userInfoManager
    }
    
    // MARK: - Input
    public func nickNameChanged(_ newNickName: String) {
        let nickNameValidationStatus = validateNicknameUseCase.isNickNameValid(newNickName)
        isValidNickNameSubject.send(nickNameValidationStatus)
    }
    
    public func profileImageChanged() {
        isProfileImageChangedSubject.send()
    }
    
    public func signUpButtonTapped(userName: String, profileImageData: Data) {
        Task {
            do {
                let userInfo = try await setupProfileInfoUseCase.setupProfileInfo(nickName: userName, profileImageData: profileImageData)
                isSignUpCompletedSubject.send()
                userInfoManager.updateNickname(at: userInfo.name)
                userInfoManager.updateProfileImage(at: userInfo.profileImageURL)
                DispatchQueue.main.async {
                    self.actions?.didFinishSignUp()
                }
            } catch let errorBody as APIError {
                switch errorBody {
                case .duplicatedNickName:
                    isValidNickNameSubject.send(.duplicated)
                case .imageNotSafe:
                    imageNotSafeSubject.send()
                default:
                    errorSubject.send(errorBody)
                }
            } catch let error {
                errorSubject.send(error)
            }
        }
    }
    
    // MARK: - Output
    public var nicknamePublisher: AnyPublisher<String, Never> {
        return userInfoManager.nicknameChangePublisher
    }
    
    public var imageURLPublisher: AnyPublisher<String?, Never> {
        return userInfoManager.profileImageChangePublihser
    }
    
    public var isValidNickNamePublisher: AnyPublisher<NickNameValidationState, Never> {
        return isValidNickNameSubject
            .eraseToAnyPublisher()
    }
    
    public var isProfileImageChangedPublisher: AnyPublisher<Void, Never> {
        return isProfileImageChangedSubject
            .eraseToAnyPublisher()
    }
    
    public var imageNotSafePublisher: AnyPublisher<Void, Never> {
        return imageNotSafeSubject
            .eraseToAnyPublisher()
    }
    
    public var isSignUpCompletedPublisher: AnyPublisher<Void, Never> {
        return isSignUpCompletedSubject
            .eraseToAnyPublisher()
    }
    
    public var errorPublisher: AnyPublisher<Error, Never> {
        return errorSubject
            .eraseToAnyPublisher()
    }
}
