//
//  BaseViewController.swift
//  InChat
//
//  Created by Daniel Ilchishyn on 2/10/17.
//  Copyright © 2017 KRUBERLICK. All rights reserved.
//

import AsyncDisplayKit

class ViewControllerWithKeyboard: ASViewController<ASDisplayNode> {
    var keyboardController: KeyboardController!

    override var prefersStatusBarHidden: Bool {
        return false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        keyboardController = KeyboardController(view: view)
    }

    func hideKeyboard() {
        keyboardController.hideKeyboard()
    }
}
