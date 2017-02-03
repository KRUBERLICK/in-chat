//
//  ViewController.swift
//  GameOfChats
//
//  Created by Daniel Ilchishyn on 1/31/17.
//  Copyright © 2017 KRUBERLICK. All rights reserved.
//

import AsyncDisplayKit
import RxSwift
import Firebase

class LoginViewController: ASViewController<ASDisplayNode> {
    private let loginNode = LoginNode()
    private var disposeBag = DisposeBag()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    init() {
        super.init(node: loginNode)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupLoginNodeObserver()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        disposeBag = DisposeBag()
    }

    private func setupLoginNodeObserver() {
        loginNode.userInputResultPublisher
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] in
                switch $0 {
                case let .login(email, password):
                    guard !email.isEmpty,
                        !password.isEmpty else {
                            self.showAlert(
                                title: NSLocalizedString("error", comment: ""),
                                message: NSLocalizedString("input_all_fields", comment: "")
                            )
                            return
                    }

                AuthManager.shared.signInUser(email: email, password: password)
                    .subscribe(onError: { [weak self] error in
                        guard let strongSelf = self else {
                            return
                        }
                        let error = error as NSError
                        var errorMessage: String

                        switch error.code {
                        case FIRAuthErrorCode.errorCodeUserDisabled.rawValue:
                            errorMessage = "user_disabled"
                        case FIRAuthErrorCode.errorCodeWrongPassword.rawValue:
                            errorMessage = "wrong_password"
                        case FIRAuthErrorCode.errorCodeInvalidEmail.rawValue:
                            errorMessage = "wrong_email"
                        case FIRAuthErrorCode.errorCodeUserNotFound.rawValue:
                            errorMessage = "user_not_found"
                        case FIRAuthErrorCode.errorCodeNetworkError.rawValue:
                            errorMessage = "network_error"
                        default:
                            errorMessage = "unknown_error"
                        }
                        strongSelf.showAlert(title: NSLocalizedString("error", comment: ""),
                                             message: NSLocalizedString(errorMessage, comment: ""))
                    }, onCompleted: { [weak self] in
                        guard let strongSelf = self else {
                            return
                        }

                        strongSelf.proceedToApp()
                    })
                    .addDisposableTo(self.disposeBag)
                case let .register(username, email, password, confirm):
                    guard !username.isEmpty,
                        !email.isEmpty,
                        !password.isEmpty,
                        !confirm.isEmpty else {
                            self.showAlert(
                                title: NSLocalizedString("error", comment: ""),
                                message: NSLocalizedString("input_all_fields", comment: "")
                            )
                            return
                    }

                    guard password == confirm else {
                        self.showAlert(
                            title: NSLocalizedString("error", comment: ""),
                            message: NSLocalizedString("passwords_dont_match", comment: "")
                        )
                        return
                    }

                    AuthManager.shared.registerUser(email: email, password: password)
                        .flatMap { DatabaseManager.shared.addUser(uid: $0.uid, username: username, email: email) }
                        .subscribe(onError: { [weak self] error in
                            guard let strongSelf = self else {
                                return
                            }
                            let error = error as NSError
                            var errorMessage: String

                            switch error.code {
                            case FIRAuthErrorCode.errorCodeInvalidEmail.rawValue:
                                errorMessage = "invalid_email_format"
                            case FIRAuthErrorCode.errorCodeWeakPassword.rawValue:
                                errorMessage = "weak_password_error"
                            case FIRAuthErrorCode.errorCodeEmailAlreadyInUse.rawValue:
                                errorMessage = "email_already_in_use"
                            case FIRAuthErrorCode.errorCodeNetworkError.rawValue:
                                errorMessage = "network_error"
                            default:
                                errorMessage = "unknown_error"
                            }
                            strongSelf.showAlert(title: NSLocalizedString("error", comment: ""),
                                                 message: NSLocalizedString(errorMessage, comment: ""))
                        }, onCompleted: { [weak self] in
                            guard let strongSelf = self else {
                                return
                            }

                            strongSelf.proceedToApp()
                        })
                        .addDisposableTo(self.disposeBag)
                }
            })
            .addDisposableTo(disposeBag)
    }

    private func proceedToApp() {
        guard let window = view.window else {
            return
        }

        let lastMessagesViewController = BaseNavigationController(
            rootViewController: LastMessagesViewController()
        )

        UIView.performWithoutAnimation {
            lastMessagesViewController.view.setNeedsLayout()
            lastMessagesViewController.view.layoutIfNeeded()
        }
        UIView.transition(with: window,
                          duration: 0.5,
                          options: .transitionFlipFromRight,
                          animations: {
                            window.rootViewController = lastMessagesViewController
        }, completion: nil)
    }
}

