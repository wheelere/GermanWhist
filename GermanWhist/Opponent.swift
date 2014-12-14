//
//  Opponent.swift
//  GermanWhist
//
//  Created by Student on 12/13/14.
//  Copyright (c) 2014 GoldWheels. All rights reserved.
//

import Foundation
import UIKit

private let opponentInstance = Opponent()

class Opponent {
    
    var hand: [Card] = []
    var cardsKnown: [Card] = []
    var trump: Character?
    var opponentVoid: [Bool] = [false, false, false, false]
    
    
    init() {
    }
    
    class var sharedOpponent: Opponent {
        return opponentInstance
    }
    
    func dealHand(cards: [Card]) {
        hand = cards
        cardsKnown += cards
    }
    
    func rememberCard(card: Card) {
        cardsKnown.append(card)
    }
    
    func playCard(playerCard: Card?, _ faceUpCard: Card?) -> Card {
        var lowestWinner: Card? = nil
        var canFollowSuit: Bool?
        if playerCard != nil {
            canFollowSuit = canFollow(playerCard!.suit!)
        }
        if (faceUpCard != nil) {
            let want: Bool = wantCard(faceUpCard)
            if (playerCard == nil && want) {
                for card in hand {
                    if (isWinner(card, faceUpCard)) {
                        if (lowestWinner == nil || (lowestWinner!.suit == trump && !beatsCard(card, c2: lowestWinner!)) || (card.suit != trump && lowestWinner!.suit != trump && lowestWinner!.value > card.value)) {
                            lowestWinner = card
                        }
                    }
                }
            }
            else if (want) {
                for c in hand {
                    if (!(c.suit != playerCard!.suit && canFollowSuit!) && beatsCard(c, c2: playerCard!)) {
                        if (lowestWinner == nil || !beatsCard(c, c2: lowestWinner!)) {
                            lowestWinner = c
                        }
                    }
                }
            }
            
            if (lowestWinner == nil || !shouldPlayCard(lowestWinner!, playerCard, faceUpCard)) {
                return(worstCard(canFollowSuit, playerCard))
            } else {
                return lowestWinner!
            }
        }
        
        else {
            if (playerCard == nil) {
                lowestWinner = bestCard()
            } else {
                for c in hand {
                    if (!(c.suit != playerCard!.suit && canFollowSuit!) && beatsCard(c, c2: playerCard!)) {
                        if (lowestWinner == nil || !beatsCard(c, c2: lowestWinner!)) {
                            lowestWinner = c
                        }
                    }
                }
            }
            
            if (lowestWinner == nil) {
                    return(worstCard(canFollowSuit, playerCard))
            } else {
                return lowestWinner!
            }
        }
    }
    
    
    private func isWinner(c: Card, _ topCard: Card?) -> Bool {
        let numGreater = 14 - c.value!
        var count = 0
        for known in cardsKnown {
            if (known.suit == c.suit && known.value > c.value) {
                if (c.suit == "c" && opponentVoid[0]) || (c.suit == "d" && opponentVoid[1]) || (c.suit == "h" && opponentVoid[2]) || (c.suit == "s" && opponentVoid[3]) {
                    continue
                } else {
                    count++
                }
            }
        }
        
        if topCard != nil && topCard!.suit == c.suit && topCard!.value > c.value {
            count++
        }
        
        if count == numGreater {
            return true
        } else if (numGreater - count < 3 && cardsKnown.count < 30) {
            return true
        } else if (numGreater - count < 4 && cardsKnown.count < 18) {
            return true
        } else {
            return false
        }
    }
    
    
    private func wantCard(c: Card?) -> Bool {
        if (c!.value > 10 || c!.suit == trump || isWinner(c!, c)) {
            return true
        } else {
            return false
        }
    }
    
    private func beatsCard(c1: Card, c2: Card) -> Bool {
        if (c1.suit == c2.suit) {
            if c1.value > c2.value {
                return true
            } else {
                return false
            }
        } else {
            if c1.suit == trump {
                return true
            } else {
                return false
            }
        }
    }
    
    private func shouldPlayCard(card: Card, _ playerCard: Card?, _ faceUpCard: Card?) -> Bool {
        if (faceUpCard!.value < card.value && faceUpCard!.suit != trump) {
            return false
        } else if (playerCard == nil && card.suit == trump && faceUpCard!.suit != trump){
            return false
        } else if (card.suit == trump! && faceUpCard!.suit != trump && faceUpCard!.value! - card.value! >= 10) {
            return false
        } else {
            return true
        }
    }
    
    private func worstCard(canFollow: Bool?, _ playerCard: Card?) -> Card {
        var worst: Card?
        for card in hand {
            if (worst == nil || (card.value < worst!.value && card.suit != trump && worst!.suit != trump) || (worst!.suit == trump && card.suit == trump && card.value < worst!.value) || (worst!.suit == trump && card.suit != trump)) {
                if playerCard != nil && canFollow! && card.suit != playerCard!.suit {
                    continue
                } else {
                    worst = card
                }//else
            }
        }
        return worst!
    }
    
    private func canFollow(suit: Character) -> Bool {
        for card in hand {
            if card.suit == suit {
                return true
            }
        }
        return false
        
    }
    
    private func bestCard() -> Card{
        var best: Card?
        for card in hand {
            if (best == nil || (card.value > best!.value && best!.suit != trump) || (best!.suit == trump && card.suit == trump && card.value > best!.value) || (best!.suit != trump && card.suit == trump)) {
                if (card.suit == "c" && opponentVoid[0]) || (card.suit == "d" && opponentVoid[1]) || (card.suit == "h" && opponentVoid[2]) || (card.suit == "s" && opponentVoid[3]) {
                    continue
                } else {
                    best = card
                }
            }
        }
        return best!
    }
    
    
    
}
