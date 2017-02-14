//
//  KeyboardController.swift
//  GameOfChats
//
//  Created by Daniel Ilchishyn on 2/1/17.
//  Copyright © 2017 KRUBERLICK. All rights reserved.
//

import UIKit

class KeyboardController {
    var callback: (() -> ())?
    var parentView: UIView!
    var keyboardIsShowing = false

    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(KeyboardController.handleKeyboard(_:)),
            name: Notification.Name.UIKeyboardWillShow, object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(KeyboardController.handleKeyboard(_:)),
            name: Notification.Name.UIKeyboardWillHide, object: nil
        )
    }

    func hideKeyboard(completion: (() -> ())? = nil) {
        guard keyboardIsShowing else {
            completion?()
            return
        }

        callback = completion
        parentView.endEditing(false)
    }

    @objc func handleKeyboard(_ notification: Notification) {
        guard let window = parentView.window,
            let keyboardInfo = notification.userInfo,
            let keyboardFrame = (keyboardInfo[UIKeyboardFrameEndUserInfoKey]
                as AnyObject).cgRectValue,
            let animationDuration = (keyboardInfo[UIKeyboardAnimationDurationUserInfoKey]
                as AnyObject).doubleValue,
            let animationCurve = (keyboardInfo[UIKeyboardAnimationCurveUserInfoKey]
                as AnyObject).integerValue
            else {
                return
        }

        var updatedWindowFrame = window.frame

        switch notification.name {
        case Notification.Name.UIKeyboardWillShow:
            updatedWindowFrame.size.height = UIScreen.main.bounds.height - keyboardFrame.height
            keyboardIsShowing = true
        case Notification.Name.UIKeyboardWillHide:
            updatedWindowFrame.size.height = UIScreen.main.bounds.height
            keyboardIsShowing = false
        default:
            return
        }

        UIView.animate(
            withDuration: animationDuration,
            delay: 0,
            options: [UIViewAnimationOptions(
                rawValue: UInt(animationCurve) << 16
                )],
            animations: {
                window.frame = updatedWindowFrame
                window.layoutIfNeeded()
        }, completion: { _ in
            self.callback?()
            self.callback = nil
        })
    }
}
