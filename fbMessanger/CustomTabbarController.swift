//
//  CustomTabbarController.swift
//  fbMessanger
//
//  Created by Sudhanshu Sudhanshu on 4/9/18.
//  Copyright © 2018 Sudhanshu. All rights reserved.
//

import UIKit

class CustomTabbarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
        let collectionLayout = UICollectionViewFlowLayout()
        let recentController = FriendsController(collectionViewLayout: collectionLayout)
        let recentNavController = UINavigationController.init(rootViewController: recentController)
        recentNavController.tabBarItem.title = "Recent"
        recentNavController.tabBarItem.image = UIImage(named: "recent")
        
        self.viewControllers = [recentNavController, createDummyNavController(title: "Calls", imageName: "calls"), createDummyNavController(title: "Groups", imageName: "groups"), createDummyNavController(title: "People", imageName: "people"), createDummyNavController(title: "Settings", imageName: "settings")]
        
    }

    private func createDummyNavController(title: String, imageName: String) -> UINavigationController {
        let viewController = UIViewController()
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.tabBarItem.title = title
        navigationController.tabBarItem.image = UIImage(named: imageName)
        return navigationController
    }
}
