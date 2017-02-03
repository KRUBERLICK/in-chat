//
//  BaseDisplayNode.swift
//  GameOfChats
//
//  Created by Daniel Ilchishyn on 2/1/17.
//  Copyright © 2017 KRUBERLICK. All rights reserved.
//

import AsyncDisplayKit

class BaseDisplayNode: ASDisplayNode {
    override func animateLayoutTransition(_ context: ASContextTransitioning) {
        for node in subnodes {
            if context.insertedSubnodes().contains(node) {
                node.alpha = 0
            }
            else if !context.removedSubnodes().contains(node) {
                node.frame = context.initialFrame(for: node)
            }
        }
        UIView.animate(
            withDuration: 0.25,
            animations: {
                for node in self.subnodes {
                    if context.removedSubnodes().contains(node) {
                        node.alpha = 0
                    }
                    else if context.insertedSubnodes().contains(node) {
                        node.alpha = 1
                    }
                    else {
                        node.frame = context.finalFrame(for: node)
                    }
                }
        },
            completion: { finished in
                context.completeTransition(finished)
        })
    }
}
