//
//  AppDelegate.swift
//  GameOfChats
//
//  Created by Daniel Ilchishyn on 1/31/17.
//  Copyright © 2017 KRUBERLICK. All rights reserved.
//

import AsyncDisplayKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions
        launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FIRApp.configure()
        window = UIWindow(frame: UIScreen.main.bounds)
        if let _ = FIRAuth.auth()?.currentUser?.uid {
            window?.rootViewController = BaseNavigationController(
                rootViewController: LastMessagesViewController()
            )
        } else {
            window?.rootViewController = LoginViewController()
        }
        window?.makeKeyAndVisible()
        return true
    }
}

