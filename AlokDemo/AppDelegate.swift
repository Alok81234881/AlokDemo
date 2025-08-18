//
//  AppDelegate.swift
//  AlokDemo
//
//  Created by Alok SIngh on 18/08/25.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if #available(iOS 13.0, *) {
            // SceneDelegate handles window
        } else {
            let window = UIWindow(frame: UIScreen.main.bounds)
            let nav = UINavigationController()
            let appCoordinator = AppCoordinator(navigationController: nav)
            appCoordinator.start()
            window.rootViewController = nav
            window.makeKeyAndVisible()
            self.window = window
        }
        return true
    }

    // MARK: UISceneSession Lifecycle (iOS 13+)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
