//
//  AppDelegate.swift
//  MVC_to_MVVM
//
//  Created by GreenChiu on 2018/12/21.
//  Copyright © 2018 Green. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        let navigationController = UINavigationController(rootViewController: MVCViewController())
        let navigationController = UINavigationController(rootViewController: ToDoListViewController())
        let aWindow = UIWindow()
        aWindow.rootViewController = navigationController
        aWindow.makeKeyAndVisible()
        window = aWindow
        return true
    }
}

