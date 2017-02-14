//
//  LoginNode.swift
//  GameOfChats
//
//  Created by Daniel Ilchishyn on 1/31/17.
//  Copyright © 2017 KRUBERLICK. All rights reserved.
//

import AsyncDisplayKit
import RxSwift

extension LoginNode: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameTextField {
            emailTextField.becomeFirstResponder()
        }
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        }
        if textField == passwordTextField {
            switch mode {
            case .login:
                publishUserInput()
            case .register:
                passwordConfirmTextField.becomeFirstResponder()
            }
        }
        if textField == passwordConfirmTextField {
            publishUserInput()
        }
        return true
    }
}

class LoginNode: BaseDisplayNode {
    enum Mode {
        case login
        case register
    }

    enum UserInputResult {
        case login(String, String)
        case register(String, String, String, String)
    }

    let userInputResultPublisher = PublishSubject<UserInputResult>()
    var keyboardController: KeyboardController!

    lazy var titleNode: ASTextNode = {
        let textNode = ASTextNode()
        let textAttribs = [NSForegroundColorAttributeName: UIColor.white,
                           NSFontAttributeName: UIFont.systemFont(
                            ofSize: 60, weight: UIFontWeightUltraLight)]

        textNode.attributedText = NSAttributedString(
            string: NSLocalizedString("InChat", comment: ""),
            attributes: textAttribs
        )
        return textNode
    }()

    let textFieldFactory: (String) -> UITextField = {
        let textField = UITextField()
        let spacerView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 1))

        textField.leftView = spacerView
        textField.rightView = spacerView
        textField.leftViewMode = .always
        textField.rightViewMode = .always
        textField.backgroundColor = .loginTextFieldBackground
        textField.layer.borderColor = UIColor.white.cgColor
        textField.layer.borderWidth = 1
        textField.defaultTextAttributes = [NSForegroundColorAttributeName: UIColor.white,
                                           NSFontAttributeName: UIFont.systemFont(ofSize: 20)]
        textField.attributedPlaceholder = NSAttributedString(
            string: $0,
            attributes: [NSForegroundColorAttributeName: UIColor(white: 1, alpha: 0.5),
                         NSFontAttributeName: UIFont.systemFont(ofSize: 20)]
        )
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.layer.masksToBounds = true
        return textField
    }

    lazy var usernameTextField: UITextField = {
        let textField = self.textFieldFactory(NSLocalizedString("your_name", comment: ""))

        textField.autocapitalizationType = .words
        textField.autocorrectionType = .yes
        textField.layer.cornerRadius = self.textFieldsHeight / 2
        textField.returnKeyType = .next
        textField.delegate = self
        return textField
    }()

    lazy var emailTextField: UITextField = {
        let textField = self.textFieldFactory(NSLocalizedString("email", comment: ""))

        textField.layer.cornerRadius = self.textFieldsHeight / 2
        textField.keyboardType = .emailAddress
        textField.returnKeyType = .next
        textField.delegate = self
        return textField
    }()

    lazy var passwordTextField: UITextField = {
        let textField = self.textFieldFactory(NSLocalizedString("password", comment: ""))

        textField.isSecureTextEntry = true
        textField.layer.cornerRadius = self.textFieldsHeight / 2
        textField.returnKeyType = self.mode == .login ? .done : .next
        textField.delegate = self
        return textField
    }()

    lazy var passwordConfirmTextField: UITextField = {
        let textField = self.textFieldFactory(NSLocalizedString("password_confirm", comment: ""))

        textField.isSecureTextEntry = true
        textField.layer.cornerRadius = self.textFieldsHeight / 2
        textField.returnKeyType = .done
        textField.delegate = self
        return textField
    }()

    let textFieldsHeight: CGFloat = 50
    var usernameNode: ASDisplayNode!
    var emailNode: ASDisplayNode!
    var passwordNode: ASDisplayNode!
    var passwordConfirmNode: ASDisplayNode!

    lazy var mainButtonNode: ASButtonNode = {
        let buttonNode = ASButtonNode()
        let titleAttribs = [NSForegroundColorAttributeName: UIColor.white,
                            NSFontAttributeName: UIFont.systemFont(ofSize: 25)]

        buttonNode.backgroundColor = .loginButtonBackground
        buttonNode.setAttributedTitle(NSAttributedString(
            string: NSLocalizedString(self.mode == .login
                ? "login"
                : "register", comment: ""),
            attributes: titleAttribs),
                                      for: [])
        buttonNode.cornerRadius = 5
        buttonNode.addTarget(
            self,
            action: #selector(LoginNode.mainButtonNodeTapped),
            forControlEvents: .touchUpInside
        )
        return buttonNode
    }()

    lazy var bottomText: ASTextNode = {
        let textNode = ASTextNode()
        let textAttribs = [NSForegroundColorAttributeName: UIColor.white,
                           NSFontAttributeName: UIFont.systemFont(ofSize: 15)]

        textNode.attributedText = NSAttributedString(
            string: NSLocalizedString(self.mode == .login
                ? "not_registered"
                : "have_an_account", comment: ""),
            attributes: textAttribs
        )
        return textNode
    }()

    lazy var bottomButton: ASButtonNode = {
        let buttonNode = ASButtonNode()
        let textAttribs: [String: Any] = [NSForegroundColorAttributeName: UIColor.white,
                                          NSFontAttributeName: UIFont.systemFont(ofSize: 15),
                                          NSUnderlineStyleAttributeName: 1]

        buttonNode.setAttributedTitle(
            NSAttributedString(
                string: NSLocalizedString(
                    self.mode == .login
                        ? "create_account"
                        : "login", comment: ""
            ), attributes: textAttribs),
            for: [])
        buttonNode.hitTestSlop = UIEdgeInsets(top: -20,
                                              left: -100,
                                              bottom: -20,
                                              right: -100)
        buttonNode.addTarget(self,
                             action: #selector(LoginNode.modeSwitch),
                             forControlEvents: .touchUpInside)
        return buttonNode
    }()

    var mode: Mode = .login {
        didSet {
            transitionLayout(withAnimation: true,
                             shouldMeasureAsync: true,
                             measurementCompletion: nil)
        }
    }

    override init() {
        super.init()
        usernameNode = ASDisplayNode(viewBlock: { [weak self] in self?.usernameTextField ?? UIView() })
        emailNode = ASDisplayNode(viewBlock: { [weak self] in self?.emailTextField ?? UIView() })
        passwordNode = ASDisplayNode(viewBlock: { [weak self] in self?.passwordTextField ?? UIView() })
        passwordConfirmNode = ASDisplayNode(viewBlock: { [weak self] in self?.passwordConfirmTextField ?? UIView() })
        automaticallyManagesSubnodes = true
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        usernameNode.style.flexBasis = ASDimensionMakeWithPoints(50)
        emailNode.style.flexBasis = ASDimensionMakeWithPoints(50)
        passwordNode.style.flexBasis = ASDimensionMakeWithPoints(50)
        passwordConfirmNode.style.flexBasis = ASDimensionMakeWithPoints(50)

        let textFieldsStack = ASStackLayoutSpec(direction: .vertical,
                                                spacing: 10,
                                                justifyContent: .center,
                                                alignItems: .center,
                                                children: mode == .login
                                                    ? [emailNode,
                                                       passwordNode]
                                                    : [usernameNode,
                                                       emailNode,
                                                       passwordNode,
                                                       passwordConfirmNode])

        mainButtonNode.style.preferredSize = CGSize(width: 170, height: 60)

        let addMainButton = ASStackLayoutSpec(direction: .vertical,
                                              spacing: 15,
                                              justifyContent: .center,
                                              alignItems: .center,
                                              children: [textFieldsStack,
                                                         mainButtonNode])

        let addTitleStack = ASStackLayoutSpec(direction: .vertical,
                                              spacing: constrainedSize.max.height < 568
                                                ? 15 : 30,
                                              justifyContent: .center,
                                              alignItems: .center,
                                              children: [titleNode,
                                                         addMainButton])

        if constrainedSize.max.height < 568 {
            return ASInsetLayoutSpec(
                insets: UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30),
                child: addTitleStack
            )
        }

        let bottomStack = ASStackLayoutSpec(direction: .vertical,
                                            spacing: 0,
                                            justifyContent: .center,
                                            alignItems: .center,
                                            children: [bottomText,
                                                       bottomButton])
        let addBottomStack = ASStackLayoutSpec(direction: .vertical,
                                               spacing: 15,
                                               justifyContent: .center,
                                               alignItems: .center,
                                               children: [addTitleStack,
                                                          bottomStack])
        let insets = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0,
                                                            left: 30,
                                                            bottom: 0,
                                                            right: 30),
                                       child: addBottomStack)

        return insets
    }

    override func didLoad() {
        super.didLoad()
        keyboardController.parentView = view
        mainButtonNode.layer.shadowColor = UIColor.black.cgColor
        mainButtonNode.layer.shadowOpacity = 0.2
        mainButtonNode.layer.shadowOffset = CGSize(width: 0, height: 2)
        mainButtonNode.layer.shadowRadius = 4
        view.addGestureRecognizer(
            UITapGestureRecognizer(target: self,
                                   action: #selector(LoginNode.hideKeyboard))
        )
    }

    override func layout() {
        super.layout()
        setupGradientBackground()
    }

    override func animateLayoutTransition(_ context: ASContextTransitioning) {
        updateTexts()
        super.animateLayoutTransition(context)
    }

    func updateTexts() {
        passwordTextField.returnKeyType = self.mode == .login ? .done : .next
        mainButtonNode.setAttributedTitle(
            NSAttributedString(string: NSLocalizedString(mode == .login
                ? "login"
                : "register", comment: ""),
                               attributes: mainButtonNode
                                .attributedTitle(for: [])?
                                .attributes(at: 0, effectiveRange: nil)), for: [])
        bottomText.attributedText = NSAttributedString(
            string: NSLocalizedString(mode == .login
                ? "not_registered"
                : "have_an_account", comment: ""),
            attributes: bottomText.attributedText?
                .attributes(at: 0, effectiveRange: nil))
        bottomButton.setAttributedTitle(
            NSAttributedString(string: NSLocalizedString(mode == .login
                ? "create_account"
                : "login", comment: ""),
                               attributes: bottomButton
                                .attributedTitle(for: [])?
                                .attributes(at: 0, effectiveRange: nil)), for: [])
    }

    func setupGradientBackground() {
        let gradientLayer = CAGradientLayer()

        gradientLayer.frame = view.bounds
        gradientLayer.colors = [UIColor.loginBackgroundGradientTop.cgColor,
                                UIColor.loginBackgroundGradientBottom.cgColor]
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    func modeSwitch() {
        usernameTextField.text = ""
        passwordTextField.text = ""
        passwordConfirmTextField.text = ""
        if mode == .login {
            mode = .register
        } else {
            mode = .login
        }
    }

    func mainButtonNodeTapped() {
        mainButtonNode.animatePush { [weak self] in
            self?.publishUserInput()
        }
    }

    func publishUserInput() {
        keyboardController.hideKeyboard { [weak self] in
            guard let strongSelf = self else {
                return
            }

            switch strongSelf.mode {
            case .login:
                strongSelf.userInputResultPublisher.onNext(.login(strongSelf.emailTextField.text ?? "",
                                                                  strongSelf.passwordTextField.text ?? ""))
            case .register:
                strongSelf.userInputResultPublisher.onNext(.register(strongSelf.usernameTextField.text ?? "",
                                                                     strongSelf.emailTextField.text ?? "",
                                                                     strongSelf.passwordTextField.text ?? "",
                                                                     strongSelf.passwordConfirmTextField.text ?? ""))
            }
        }
    }

    func hideKeyboard() {
        keyboardController.hideKeyboard()
    }
}
