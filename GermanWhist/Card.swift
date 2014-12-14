//
//  Card.swift
//  GermanWhist
//
//  Created by Earnest Wheeler on 12/8/14.
//  Copyright (c) 2014 GoldWheels. All rights reserved.
//

import Foundation
import SpriteKit


private let deckLocation = CGPoint(x: 490, y: 155)
private let cardSize = CGRect(x: deckLocation.x, y: deckLocation.y, width: 50, height: 75)

class Card: UIImageView {
    var suit: Character?
    var value: Int?
    var faceUp: Bool = false
    
    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
    
    init(suit: Character, value: Int) {
        self.suit = suit
        self.value = value
        let cardFace = UIImage(named: "redback")
        super.init(image: cardFace)
        self.frame = cardSize
    }
    
    func flip() {
        if faceUp {
            faceUp = false
            let cardFace = UIImage(named: "redback")
            self.image = cardFace
        } else {
            faceUp = true
            let cardFace = UIImage(named: "\(value!)\(suit!)")
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
    
}