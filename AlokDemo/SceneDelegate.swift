//
//  SceneDelegate.swift
//  AlokDemo
//
//  Created by Alok SIngh on 18/08/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var appCoordinator: AppCoordinator?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let nav = UINavigationController()
        let coordinator = AppCoordinator(navigationController: nav)
        coordinator.start()

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = nav
        window.makeKeyAndVisible()

        self.window = window
        self.appCoordinator = coordinator
    }
}
