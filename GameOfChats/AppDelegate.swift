//
//  AppDelegate.swift
//  GameOfChats
//
//  Created by Daniel Ilchishyn on 1/31/17.
//  Copyright © 2017 KRUBERLICK. All rights reserved.
//

import AsyncDisplayKit
import Firebase
import DITranquillity

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions
        launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FIRApp.configure()

        window = UIWindow(frame: UIScreen.main.bounds)

        let builder = DIContainerBuilder()

        builder.register(assembly: AppAssembly())

        let scope = try! builder.build()
        let presentationManager: PresentationManager = try! scope.resolve()

        window?.rootViewController = presentationManager.getInitialViewController()
        window?.makeKeyAndVisible()
        return true
    }
}

