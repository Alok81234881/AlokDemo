//
//  AppDelegate.swift
//  AlokDemo
//
//  Created by Alok SIngh on 18/08/25.
//

import UIKit

final class AppCoordinator {
    private let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let vm = HoldingsListViewModel()
        let vc = HoldingsViewController(viewModel: vm)
        vc.title = "Holdings"
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.view.backgroundColor = .systemBackground
        navigationController.pushViewController(vc, animated: false)
    }
}
