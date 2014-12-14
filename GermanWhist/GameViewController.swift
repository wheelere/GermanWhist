//
//  GameViewController.swift
//  GermanWhist
//
//  Created by Earnest Wheeler on 12/11/14.
//  Copyright (c) 2014 GoldWheels. All rights reserved.
//

import UIKit
import Foundation

var opponent: Opponent = Opponent.sharedOpponent

class GameViewController: UIViewController {
    
    
    @IBOutlet weak var optionsButton: UIButton!
    @IBOutlet weak var trumpLabel: UILabel!
    @IBOutlet weak var opponentPointsLabel: UILabel!
    @IBOutlet weak var playerPointsLabel: UILabel!
    
    var playerPlayedCardLocation = CGPoint(x: 265, y: 170)
    var opponentPlayedCardLocation = CGPoint(x: 185, y: 140)
    var deckLocation = CGPoint(x: 490, y: 155)
    var playerFirstCardLocation = CGPoint(x: 45, y: 270)
    var opponentFirstCardLocation = CGPoint(x: 45, y: 57)
    
    var deck: [Card] = []
    var playerHand: [Card] = []
    var currCard: Card?
    
    var topCard: Card?
    var bidTurn: Int?
    var trickTurn: Int?
    var turn = 0
    
    var suits: [Character] = ["c", "d", "h", "s"]
    var trump: Character! = "x"
    var playerPlayedCard: Card?
    var opponentPlayedCard: Card?
    var playerEmptyIndex: Int?
    var opponentEmptyIndex: Int?
    
    var isPlayerTurn: Bool = arc4random_uniform(2) == 1
    
    
    var playerPoints = 0
    var opponentPoints = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        optionsButton.layer.cornerRadius = 10
        trumpLabel.text = "Trump:\n?"
        // Do any additional setup after loading the view, typically from a nib.
    } // viewDidLoad
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        setUpGame()
        
    } // viewDidAppear
    
    @IBAction func cardTap(sender: UITapGestureRecognizer) {
        if sender.view is Card {
            let cardView = sender.view as Card
            if cardView == currCard {
                UIView.animateWithDuration(0.3, delay: 0.0, options: nil, animations: {
                    cardView.center = self.playerPlayedCardLocation
                    }, completion: nil)
                cardView.userInteractionEnabled = false
                playerPlayedCard = cardView
                playerEmptyIndex = find(playerHand, cardView)
                playerHand.removeAtIndex(playerEmptyIndex!)
                currCard = nil
                disablePlayerHand()
                if opponentPlayedCard != nil {
                    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC * 1))
                    dispatch_after(delayTime, dispatch_get_main_queue()) {
                        self.cleanUp()
                    }
                } else {
                    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC * 1))
                    dispatch_after(delayTime, dispatch_get_main_queue()) {
                        self.opponentPlay()
                    }
                }
            } else {
                var haveLedSuit = false
                if opponentPlayedCard != nil {
                    for card in playerHand {
                        if card.suit == opponentPlayedCard!.suit {
                            haveLedSuit = true
                            break
                        }
                    }
                }
                if !haveLedSuit || opponentPlayedCard!.suit == cardView.suit {
                    if currCard != nil {
                        UIView.animateWithDuration(0.3, delay: 0.0, options: nil, animations: {
                            self.currCard!.center.y = self.playerFirstCardLocation.y
                            }, completion: nil)
                    }
                    currCard = cardView
                    UIView.animateWithDuration(0.3, delay: 0.0, options: nil, animations: {
                        cardView.center.y = self.playerFirstCardLocation.y - 20
                        }, completion: nil)
                }
                
                if !haveLedSuit && bidTurn > 13 {
                    switch opponentPlayedCard!.suit! {
                    case "c":
                        opponent.opponentVoid[0] = true
                    case "d":
                        opponent.opponentVoid[1] = true
                    case "h":
                        opponent.opponentVoid[2] = true
                    case "s":
                        opponent.opponentVoid[3] = true
                    default:
                        break
                    }
                }
            }
        }
    }
    
    @IBAction func OptionsTap(sender: UIButton) {
        
        let alertController = UIAlertController(title: "Options", message: nil, preferredStyle: .Alert)
        let newGameAction = UIAlertAction(title: "Restart", style: .Default, handler: { (alert: UIAlertAction!) in
            self.setUpGame()
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        let menuAction = UIAlertAction(title: "Menu", style: .Default, handler: { (alert: UIAlertAction!) in
            self.dismissViewControllerAnimated(true, completion: nil)
        })
        alertController.addAction(newGameAction)
        alertController.addAction(menuAction)
        alertController.addAction(cancelAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func tapBackground(sender: AnyObject) {
        if currCard != nil {
            UIView.animateWithDuration(0.3, delay: 0.0, options: nil, animations: {
                self.currCard!.center.y = self.playerFirstCardLocation.y
                }, completion: nil)
            currCard = nil
        }
    }
    
    func setUpGame() {
        optionsButton.userInteractionEnabled = false
        for v in view.subviews {
            if v is Card {
                v.removeFromSuperview()
            }
        }
        deck.removeAll(keepCapacity: true)
        playerHand.removeAll(keepCapacity: true)
        opponent.hand.removeAll(keepCapacity: true)
        playerPoints = 0
        opponentPoints = 0
        trump = "x"
        self.trumpLabel.text = "Trump:\n?"
        isPlayerTurn = arc4random_uniform(2) == 1
        
        for s in 0...3 {
            for v in 2...14 {
                let card = Card(suit: suits[s], value: v)
                card.center = deckLocation
                deck.append(card)
                let recognizer = UITapGestureRecognizer(target: self, action:Selector("cardTap:"))
                recognizer.delegate = nil
                card.addGestureRecognizer(recognizer)
            }
        } // for loops build the complete deck
        
        
        for i in 0...12 {
            let index1 = Int(arc4random_uniform(52 - i * 2))
            let index2 = Int(arc4random_uniform(52 - i * 2 - 1))
            let card1 = deck[index1]
            deck.removeAtIndex(index1)
            let card2 = deck[index2]
            deck.removeAtIndex(index2)
            var dealDelay = 0.2 * (2.0 * Double(i)) as NSTimeInterval
            if isPlayerTurn {
                
                card1.flip()
                
                
                view.insertSubview(card1, atIndex: i)
                UIView.animateWithDuration(0.3, delay: dealDelay, options: nil, animations: {
                    card1.center.x = self.playerFirstCardLocation.x + CGFloat(i * 30)
                    card1.center.y = self.playerFirstCardLocation.y
                    }, completion: nil)
                // flip the card and animate it moving to the hand
                card1.layer.zPosition = CGFloat(i)
                playerHand.append(card1)
                
                
                // animate the card moving to the hand
                view.addSubview(card2)
                dealDelay += 0.2
                UIView.animateWithDuration(0.3, delay: dealDelay, options: nil, animations: {
                    card2.center.x = self.opponentFirstCardLocation.x + CGFloat(i * 30)
                    card2.center.y = self.opponentFirstCardLocation.y
                    }, completion: nil)
                card2.layer.zPosition = CGFloat(i)
                opponent.hand.append(card2)
                opponent.cardsKnown.append(card2)
            } else {
                view.addSubview(card1)
                
                UIView.animateWithDuration(0.3, delay: dealDelay, options: nil, animations: {
                    card1.center.x = self.opponentFirstCardLocation.x + CGFloat(i * 30)
                    card1.center.y = self.opponentFirstCardLocation.y
                    }, completion: nil)
                // flip the card and animate it moving to the hand
                card1.layer.zPosition = CGFloat(i)
                
                opponent.hand.append(card1)
                opponent.cardsKnown.append(card1)
                
                dealDelay += 0.2
                card2.flip()
                view.insertSubview(card2, atIndex: i)
                UIView.animateWithDuration(0.3, delay: dealDelay, options: nil, animations: {
                    card2.center.x = self.playerFirstCardLocation.x + CGFloat(i * 30)
                    card2.center.y = self.playerFirstCardLocation.y
                    }, completion: nil)
                card2.layer.zPosition = CGFloat(i)
                playerHand.append(card2)
            }
            // we need to deal the cards into the hands
        } // add cards to the players' hand
        
        
        
        playerPointsLabel.text = "Player: \(playerPoints)"
        opponentPointsLabel.text = "Opponent: \(opponentPoints)"
        let topIndex = Int(arc4random_uniform(26))
        topCard = deck[topIndex]
        deck.removeAtIndex(topIndex)
        view.addSubview(topCard!)
        trump = topCard!.suit
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC * 6))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            
            self.topCard!.flip()
            
            var trumpName = ""
            if self.trump == "c" {
                trumpName = "Clubs"
            } else if self.trump == "d" {
                trumpName = "Diamonds"
            } else if self.trump == "h" {
                trumpName = "Hearts"
            } else if self.trump == "s" {
                trumpName = "Spades"
            }
            self.trumpLabel.text = "Trump:\n" + trumpName
            self.sortPlayerHand()
            
            
            opponent.trump = self.trump
            
            self.bidTurn = 0
            let delayTime2 = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC * 1))
            dispatch_after(delayTime2, dispatch_get_main_queue()) {
                for i in 0...12 {
                    self.enablePlayerHand()
                }
                if !self.isPlayerTurn {
                    self.opponentPlay()
                }
            }
            self.optionsButton.userInteractionEnabled = true
        }

    } // setUpGame
    
    // cleanUp ends the turn and gives out new cards if appropriate, then calls begin turn if appropriate
    func cleanUp() {
        disablePlayerHand()
        var winningCard: Card?
        if (isPlayerTurn) {
            winningCard = Card.winner(playerPlayedCard!, opponentPlayedCard!, trump)
        } else {
            winningCard = Card.winner(opponentPlayedCard!, playerPlayedCard!, trump)
        }
        
        if bidTurn != nil {
            if winningCard! == playerPlayedCard {
                
                topCard!.userInteractionEnabled = true
                UIView.animateWithDuration(0.6, delay: 0.0, options: nil, animations: {
                    self.topCard!.center.x = self.playerFirstCardLocation.x + CGFloat(self.playerEmptyIndex! * 30)
                    self.topCard!.center.y = self.playerFirstCardLocation.y
                    }, completion: {(Bool) -> () in
                        if self.topCard != nil {
                            self.topCard!.flip()
                        }
                })
                playerHand.insert(topCard!, atIndex: playerEmptyIndex!)
                topCard!.removeFromSuperview()
                view.insertSubview(topCard!, atIndex: playerEmptyIndex!)
                topCard!.layer.zPosition = CGFloat(playerEmptyIndex!)
                // put the top card in the player's hand
                
                let deckIndex = Int(arc4random_uniform(25 - bidTurn! * 2))
                UIView.animateWithDuration(0.6, delay: 0.0, options: nil, animations: {
                    self.deck[deckIndex].center.x = self.opponentFirstCardLocation.x + CGFloat(self.opponentEmptyIndex! * 30)
                    self.deck[deckIndex].center.y = self.opponentFirstCardLocation.y
                    }, completion: nil)
                opponent.hand.insert(deck[deckIndex], atIndex: opponentEmptyIndex!)
                view.addSubview(deck[deckIndex])
                
                opponent.cardsKnown.append(deck[deckIndex])
                deck[deckIndex].layer.zPosition = CGFloat(opponentEmptyIndex!)
                deck.removeAtIndex(deckIndex)
                
                isPlayerTurn = true
            } // player wins the turn
            else {
                
                topCard!.flip()
                UIView.animateWithDuration(0.6, delay: 0.0, options: nil, animations: {
                    self.topCard!.center.x = self.opponentFirstCardLocation.x + CGFloat(self.opponentEmptyIndex! * 30)
                    self.topCard!.center.y = self.opponentFirstCardLocation.y
                    }, completion: {(Bool) -> () in
                        if self.topCard != nil {
                            self.topCard!.flip()
                        }
                })
                opponent.hand.insert(topCard!, atIndex: opponentEmptyIndex!)
                view.addSubview(topCard!)
                topCard!.layer.zPosition = CGFloat(opponentEmptyIndex!)
                opponent.cardsKnown.append(topCard!)
                
                
                let deckIndex = Int(arc4random_uniform(25 - bidTurn! * 2))
                deck[deckIndex].flip()
                deck[deckIndex].userInteractionEnabled = true
                UIView.animateWithDuration(0.6, delay: 0.0, options: nil, animations: {
                    self.deck[deckIndex].center.x = self.playerFirstCardLocation.x + CGFloat(self.playerEmptyIndex! * 30)
                    self.deck[deckIndex].center.y = self.playerFirstCardLocation.y
                    }, completion: nil)
                // put the next card in the player's hand
                view.insertSubview(deck[deckIndex], atIndex: playerEmptyIndex!)
                playerHand.insert(deck[deckIndex], atIndex: playerEmptyIndex!)
                deck[deckIndex].layer.zPosition = CGFloat(playerEmptyIndex!)

                deck.removeAtIndex(deckIndex)
                
                isPlayerTurn = false
            } // bot wins the turn
            sortPlayerHand()

            opponent.cardsKnown.append(playerPlayedCard!)
            
            playerPlayedCard!.removeFromSuperview()
            opponentPlayedCard!.removeFromSuperview()
            playerPlayedCard = nil
            opponentPlayedCard = nil
            
            
            bidTurn!++
            if bidTurn < 13 {
                let topIndex = Int(arc4random_uniform(26 - bidTurn! * 2))
                topCard = deck[topIndex]
                deck.removeAtIndex(topIndex)
                view.addSubview(topCard!)
            } // more bid turns
            else {
                bidTurn = nil
                trickTurn = 0
                topCard = nil
            } // start trick turns
            if !isPlayerTurn {
                disablePlayerHand()
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC * 2))
                dispatch_after(delayTime, dispatch_get_main_queue()) {
                    self.opponentPlay()
                }
            } else {
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC * 1))
                dispatch_after(delayTime, dispatch_get_main_queue()) {
                    self.enablePlayerHand()
                }
            }
        } else if trickTurn != nil {
            if winningCard! == playerPlayedCard {
                playerPoints++
                isPlayerTurn = true
            } // player wins the turn
            else {
                opponentPoints++
                isPlayerTurn = false
            } // bot wins the turn
            
            playerPlayedCard!.removeFromSuperview()
            opponentPlayedCard!.removeFromSuperview()
            playerPlayedCard = nil
            opponentPlayedCard = nil
            playerPointsLabel.text = "Player: \(playerPoints)"
            opponentPointsLabel.text = "Opponent: \(opponentPoints)"
            trickTurn!++
            if trickTurn < 13 {
                sortPlayerHand()
                smoothOpponentHand()
                if !isPlayerTurn {
                    disablePlayerHand()
                    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC * 2))
                    dispatch_after(delayTime, dispatch_get_main_queue()) {
                        self.opponentPlay()
                    }
                } else {
                    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC * 1))
                    dispatch_after(delayTime, dispatch_get_main_queue()) {
                        self.enablePlayerHand()
                    }
                }
            } // more trick turns
            else {
                var alertController: UIAlertController?
                if playerPoints > opponentPoints {
                    StatsManager.sharedStatsManager.stats.gamesWon++
                    alertController = UIAlertController(title: "You Win!", message: nil, preferredStyle: .Alert)
                } // player wins
                else {
                    alertController = UIAlertController(title: "The Computer Won!", message: nil, preferredStyle: .Alert)
                } // bot wins
                let newGameAction = UIAlertAction(title: "Play Again", style: .Default, handler: { (alert: UIAlertAction!) in
                    self.setUpGame()
                })
                StatsManager.sharedStatsManager.stats.totalGames++
                if playerPoints > StatsManager.sharedStatsManager.stats.mostTricksWon {
                    StatsManager.sharedStatsManager.stats.mostTricksWon = playerPoints
                }

                let homeAction = UIAlertAction(title: "Menu", style: .Default, handler: { (alert: UIAlertAction!)
                    in
                    self.dismissViewControllerAnimated(true, completion: nil)
                    })
                alertController!.addAction(newGameAction)
                alertController!.addAction(homeAction)
                presentViewController(alertController!, animated: true, completion: nil)
            }
        }
    } // cleanUp
    
    func opponentPlay() {
        disablePlayerHand()
        let cardToPlay: Card = opponent.playCard(playerPlayedCard, topCard)
        cardToPlay.flip()
        opponentEmptyIndex = find(opponent.hand, cardToPlay)
        opponent.hand.removeAtIndex(opponentEmptyIndex!)
        UIView.animateWithDuration(0.3, delay: 0.0, options: nil, animations: {
            cardToPlay.center = self.opponentPlayedCardLocation
            }, completion: {(Bool) in
                if (!self.isPlayerTurn) {
                    self.enablePlayerHand()
                }
        })
        opponentPlayedCard = cardToPlay
        if playerPlayedCard != nil {
            disablePlayerHand()
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC * 1))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                self.cleanUp()
            }
        } // if player has played, clean up
    } // opponentPlay
    

    func sortPlayerHand() {
        playerHand = Card.sortHand(playerHand)
        
        for i in 0...(playerHand.count - 1) {
            let card = playerHand[i]
            card.removeFromSuperview()
            view.insertSubview(card, atIndex: i)
            card.layer.zPosition = CGFloat(i)
            UIView.animateWithDuration(0.3, delay: 0.0, options: nil, animations: {
                card.center.x = self.playerFirstCardLocation.x + CGFloat(i * 30)
                card.center.y = self.playerFirstCardLocation.y
                }, completion: nil)
        }
    }
    
    func smoothOpponentHand() {
        for i in 0...(opponent.hand.count - 1) {
            let card = opponent.hand[i]
            card.layer.zPosition = CGFloat(i)
            UIView.animateWithDuration(0.3, delay: 0.0, options: nil, animations: {
                card.center.x = self.opponentFirstCardLocation.x + CGFloat(i * 30)
                card.center.y = self.opponentFirstCardLocation.y
                }, completion: nil)
        }
    }
    
    func disablePlayerHand() {
        for card in playerHand {
            card.userInteractionEnabled = false
        }
    }
    
    func enablePlayerHand() {
        for card in playerHand {
            card.userInteractionEnabled = true
        }
    }
    
}