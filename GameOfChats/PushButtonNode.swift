//
//  PushButton.swift
//  InChat
//
//  Created by Daniel Ilchishyn on 2/2/17.
//  Copyright © 2017 KRUBERLICK. All rights reserved.
//

import AsyncDisplayKit

extension ASDisplayNode {
    func animateTap(completion: (() -> ())? = nil) {
        UIView.animate(withDuration: 0.1, animations: {
            self.view.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }, completion: { _ in
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           usingSpringWithDamping: 0.5,
                           initialSpringVelocity: 0.5,
                           options: [],
                           animations: {
                            self.view.transform = CGAffineTransform(
                                scaleX: 1, y: 1
                            )
            }, completion: { _ in
                completion?()
            })
        })
    }
}

class PushButtonNode: ASButtonNode {
    var targetCallback: (() -> ())?

    override func didLoad() {
        super.didLoad()
        addTarget(self,
                  action: #selector(PushButtonNode.tapHandler),
                  forControlEvents: .touchUpInside)
    }

    @objc private func tapHandler() {
        animateTap(completion: targetCallback)
    }
}
