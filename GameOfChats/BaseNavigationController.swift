//
//  BaseNavigationController.swift
//  InChat
//
//  Created by Daniel Ilchishyn on 2/2/17.
//  Copyright © 2017 KRUBERLICK. All rights reserved.
//

import AsyncDisplayKit

class BaseNavigationController: ASNavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.isOpaque = true
        navigationBar.barTintColor = .navigationBarBackground
        navigationBar.tintColor = .white
        navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont(name: "Noteworthy-Bold", size: 20)!
        ]
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        topViewController?.navigationItem.backBarButtonItem = UIBarButtonItem(
            title: "",
            style: .plain,
            target: nil,
            action: nil
        )
        super.pushViewController(viewController, animated: animated)
    }
}
