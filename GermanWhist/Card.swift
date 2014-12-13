//
//  Card.swift
//  GermanWhist
//
//  Created by Earnest Wheeler on 12/8/14.
//  Copyright (c) 2014 GoldWheels. All rights reserved.
//

import Foundation
import SpriteKit

class Card: UIImageView {
    var suit: Character
    var value: Int
    var faceUp: Bool = false
    
    required init(coder aDecoder: NSCoder!) {
        fatalError("NSCoding not supported")
    }
    
    init(suit: Character, value: Int) {
        self.suit = suit
        self.value = value
        let cardFace = UIImage(named: "redback")
        super.init(image: cardFace)
    }
    
    func flip() {
        if faceUp {
            faceUp = false
            let cardFace = UIImage(named: "redback")
            self.image = cardFace
        } else {
            faceUp = true
            let cardFace = UIImage(named: "\(value)\(suit)")
            self.image = cardFace
        }
    }
    
    class func sortHand(cards: [Card]) -> [Card] {
        let ordered = sorted(cards, { (c1: Card, c2: Card) -> Bool in
            if (c1.suit == c2.suit) {
                return c1.value < c2.value
            } else {
                return c1.suit < c2.suit
            }
        })
        return ordered
    }
    
    class func winner(c1: Card, _ c2: Card, _ trump: Character) -> Card {
        if (c1.suit == c2.suit) {
            if c1.value > c2.value {
                return c1
            } else {
                return c2
            }
        } else {
            if c2.suit == trump {
                return c2
            } else {
                return c1
            }
        }
    }
    
    class func bestPlay(cards: [Card], _ lead: Character?, _ trump: Character) -> Card {
        var ranked = sorted(cards, { (c1: Card, c2: Card) -> Bool in
            if (c1.suit == c2.suit) {
                return c1.value > c2.value
            } // if the cards are the same suit
            else {
                if lead != nil {
                    if c1.suit == lead {
                        return true
                    } else if c2.suit == lead {
                        return false
                    } // if c1 is leading suit else if c2 is leading suit
                }
                if c1.suit == trump {
                    return true
                } else if c2.suit == trump {
                    return false
                } else {
                    return c1.value > c2.value
                } // if c1 is trump/else if c2 is trump/else highest value
            } // else the cards are different suits
        })
        return ranked[0]
    }
}