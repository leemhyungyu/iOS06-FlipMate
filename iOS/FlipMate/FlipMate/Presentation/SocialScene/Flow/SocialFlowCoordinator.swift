//
//  SocialFlowCoordinator.swift
//  FlipMate
//
//  Created by 임현규 on 2023/11/30.
//

import Foundation
import UIKit

protocol SocialFlowCoordinatorDependencies {
    func makeSocialFlowCoordinator(navigationController: UINavigationController) -> SocialFlowCoordinator
    func makeSocialViewController(actions: SocialViewModelActions) -> UIViewController
    func makeFriendAddViewController(actions: FriendAddViewModelActions) -> UIViewController
    func makeSocialDetailViewController(actions: SocialDetailViewModelActions, friend: Friend) -> UIViewController
}

final class SocialFlowCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    private var navigationController: UINavigationController
    private var dependencies: SocialFlowCoordinatorDependencies
    
    init(dependencies: SocialFlowCoordinatorDependencies, navigationController: UINavigationController) {
        self.dependencies = dependencies
        self.navigationController = navigationController
    }
    
    func start() {
        let actions = SocialViewModelActions(showFriendAddViewController: showFreindAddViewController, showSocialDetailViewController: showSocialDetailViewController)
        let socialViewController = dependencies.makeSocialViewController(actions: actions)
        navigationController.viewControllers = [socialViewController]
    }
    
    private func showFreindAddViewController() {
        let actions = FriendAddViewModelActions(
            didCancleFriendAdd: dismissFreindAddViewController,
            didSuccessFriendAdd: dismissFreindAddViewController)
        let freindAddViewContorller = dependencies.makeFriendAddViewController(actions: actions)
        let firendNavigationController = UINavigationController(rootViewController: freindAddViewContorller)
        firendNavigationController.modalPresentationStyle = .fullScreen
        navigationController.present(firendNavigationController, animated: true)
    }
    
    private func dismissFreindAddViewController() {
        navigationController.dismiss(animated: true)
    }
    
    func showSocialDetailViewController(friend: Friend) {
        let actions = SocialDetailViewModelActions(didFinishUnfollow: didFinishUnfollow)
        let socialDetailViewController = dependencies.makeSocialDetailViewController(actions: actions, friend: friend)
        navigationController.pushViewController(socialDetailViewController, animated: true)
    }
    
    func didFinishUnfollow() {
        navigationController.popViewController(animated: true)
    }
}
