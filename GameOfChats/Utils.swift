//
//  Utils.swift
//  GameOfChats
//
//  Created by Daniel Ilchishyn on 1/31/17.
//  Copyright © 2017 KRUBERLICK. All rights reserved.
//

import UIKit

extension String {
    subscript(i: Int) -> Character {
        return self[characters.index(startIndex, offsetBy: i)]
    }

    subscript(i: Int) -> String {
        return String(self[i] as Character)
    }

    subscript(r: Range<Int>) -> String {
        return substring(with: characters.index(startIndex, offsetBy: r.lowerBound)
            ..< characters.index(startIndex, offsetBy: r.upperBound))
    }
}

extension UIColor {
    convenience init(hexString: String, alpha: CGFloat = 1) {
        let length = hexString.characters.count

        strtoul(hexString, nil, 16)

        let r = CGFloat(strtoul(hexString[length - 6 ..< length - 4], nil, 16)) / 255
        let g = CGFloat(strtoul(hexString[length - 4 ..< length - 2], nil, 16)) / 255
        let b = CGFloat(strtoul(hexString[length - 2 ..< length], nil, 16)) / 255

        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
}

extension UIColor {
    @nonobjc static var navigationBarBackground = UIColor(hexString: "23B7FB")
    @nonobjc static var lightBackground = UIColor(hexString: "F7FCFF")
    @nonobjc static var darkText = UIColor(hexString: "393939")
    @nonobjc static var disabledText = UIColor(hexString: "A7A7A7")
    @nonobjc static var profileHeaderBackground = UIColor(hexString: "4486D4")
    @nonobjc static var loginTextFieldBackground = UIColor(hexString: "3595C0")
    @nonobjc static var loginButtonBackground = UIColor(hexString: "FFC800")
    @nonobjc static var loginBackgroundGradientTop = UIColor(hexString: "00C6FF")
    @nonobjc static var loginBackgroundGradientBottom = UIColor(hexString: "00CFC4")
    @nonobjc static var separatorColor = UIColor(hexString: "DBDBDB")
}

extension UIViewController {
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(
            title: NSLocalizedString("ok", comment: ""),
            style: .default,
            handler: nil
        )

        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}
