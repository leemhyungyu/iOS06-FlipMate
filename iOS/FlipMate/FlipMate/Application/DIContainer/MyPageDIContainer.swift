//
//  MyPageDIContainer.swift
//  FlipMate
//
//  Created by 권승용 on 12/7/23.
//

import UIKit
import MyPage
import Domain
import Network
import Core
import Data

final class MyPageDIContainer: MyPageFlowCoordinatorDependencies {
    struct Dependencies {
        let provider: Providable
        let userInfoManager: UserInfoManageable
    }
    
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    func makeMyPageFlowCoordinator(navigationController: UINavigationController?) -> MyPageFlowCoordinator {
        return MyPageFlowCoordinator(
            dependencies: self,
            navigationController: navigationController)
    }
    
    func makeMyPageViewController(actions: MyPageViewModelActions) -> UIViewController {
        return MyPageViewController(
            viewModel: makeMyPageViewModel(actions: actions)
        )
    }
    
    private func makeMyPageViewModel(actions: MyPageViewModelActions) -> MyPageViewModel {
        let repository = DefaultAuthenticationRepository(provider: dependencies.provider)
        return MyPageViewModel(
            signOutUseCase: DefaultSignOutUseCase(),
            withdrawUseCase: DefaultWithdrawUesCase(
                repository: repository),
            actions: actions,
            userInfoManager: dependencies.userInfoManager)
    }
    
    func makeProfileSettingsViewController(actions: ProfileSettingsViewModelActions) -> UIViewController {
        return ProfileSettingsViewController(viewModel: makeProfileSettingsViewModel(actions: actions))
    }
    
    func makePrivacyPolicyViewController() -> UIViewController {
        return PrivacyPolicyViewController()
    }
    
    private func makeProfileSettingsViewModel(actions: ProfileSettingsViewModelActions) -> ProfileSettingsViewModel {
        return ProfileSettingsViewModel(
            validateNicknameUseCase: DefaultValidateNicknameUseCase(validator: NickNameValidator()),
            setupProfileInfoUseCase: DefaultSetupProfileInfoUseCase(repository: DefaultProfileSettingsRepository(provider: dependencies.provider)),
            actions: actions,
            userInfoManager: dependencies.userInfoManager)
    }
}
