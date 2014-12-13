//
//  GameViewController.swift
//  GermanWhist
//
//  Created by Earnest Wheeler on 12/11/14.
//  Copyright (c) 2014 GoldWheels. All rights reserved.
//

import UIKit
import Foundation

class GameViewController: UIViewController {
    @IBOutlet weak var playerCard1Image: UIImageView! // tag = 0
    @IBOutlet weak var playerCard2Image: UIImageView! // tag = 1
    @IBOutlet weak var playerCard3Image: UIImageView! // tag = 2
    @IBOutlet weak var playerCard4Image: UIImageView! // tag = 3
    @IBOutlet weak var playerCard5Image: UIImageView! // tag = 4
    @IBOutlet weak var playerCard6Image: UIImageView! // tag = 5
    @IBOutlet weak var playerCard7Image: UIImageView! // tag = 6
    @IBOutlet weak var playerCard8Image: UIImageView! // tag = 7
    @IBOutlet weak var playerCard9Image: UIImageView! // tag = 8
    @IBOutlet weak var playerCard10Image: UIImageView! // tag = 9
    @IBOutlet weak var playerCard11Image: UIImageView! // tag = 10
    @IBOutlet weak var playerCard12Image: UIImageView! // tag = 11
    @IBOutlet weak var playerCard13Image: UIImageView! // tag = 12
    
    @IBOutlet weak var opponentCard1Image: UIImageView! // tag = 13
    @IBOutlet weak var opponentCard2Image: UIImageView! // tag = 14
    @IBOutlet weak var opponentCard3Image: UIImageView! // tag = 15
    @IBOutlet weak var opponentCard4Image: UIImageView! // tag = 16
    @IBOutlet weak var opponentCard5Image: UIImageView! // tag = 17
    @IBOutlet weak var opponentCard6Image: UIImageView! // tag = 18
    @IBOutlet weak var opponentCard7Image: UIImageView! // tag = 19
    @IBOutlet weak var opponentCard8Image: UIImageView! // tag = 20
    @IBOutlet weak var opponentCard9Image: UIImageView! // tag = 21
    @IBOutlet weak var opponentCard10Image: UIImageView! // tag = 22
    @IBOutlet weak var opponentCard11Image: UIImageView! // tag = 23
    @IBOutlet weak var opponentCard12Image: UIImageView! // tag = 24
    @IBOutlet weak var opponentCard13Image: UIImageView! // tag = 25
    
    @IBOutlet weak var topCardOfDeck: UIImageView! // tag = 26
    
    @IBOutlet weak var playerPlayedCard: UIImageView! // tag = 30
    @IBOutlet weak var opponentPlayedCard: UIImageView! // tag = 31
    
    @IBOutlet weak var trumpLabel: UILabel!
    @IBOutlet weak var opponentPointsLabel: UILabel!
    @IBOutlet weak var playerPointsLabel: UILabel!
    
    var deck: [Card] = []
    var playerHand: [Card] = []
    var opponentHand: [Card] = []
    var currCard: Card?
    
    var topCard: Card?
    var bidTurn: Int?
    var trickTurn: Int?
    var turn = 0
    
    var trump: Character! = "x"
    var dummyCard = Card(suit: "j", value: 0)
    var playerCard: Card?
    var opponentCard: Card?
    var isPlayerTurn: Bool = arc4random_uniform(1) == 1;
    
    
    var playerPoints = 0
    var opponentPoints = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        var suits: [Character] = ["c", "d", "h", "s"]
        for s in 0...3 {
            for v in 2...14 {
                let card = Card(suit: suits[s], value: v)
                deck.append(card)
            }
        } // for loops build the complete deck
        
        
        for i in 1...13 {
            let index1 = Int(arc4random_uniform(51 - (i - 1) * 2))
            let index2 = Int(arc4random_uniform(51 - (i * 2 - 1)))
            let card1 = deck[index1]
            deck.removeAtIndex(index1)
            let card2 = deck[index2]
            deck.removeAtIndex(index2)
            let playerSpot = view.viewWithTag(i) as UIImageView
            let opponentSpot = view.viewWithTag(i + 13) as UIImageView
            if isPlayerTurn {
                
                playerHand.append(card1)
                card1.flip()
                // flip the card and animate it moving to the hand
                playerSpot.image = card1.image
                opponentHand.append(card2);
                // animate the card moving to the hand
                opponentSpot.image = card2.image
            } else {
                opponentHand.append(card1);
                opponentSpot.image = card1.image
                playerHand.append(card2)
                card2.flip()
                playerSpot.image = card2.image
            }
            // we need to deal the cards into the hands
        } // add cards to the players' hand
        
        playerHand = Card.sortHand(playerHand)
        for i in 0...12 {
            let pCard = playerHand[i]
            // we need to animate sorting the hand
        } // sort the player's hand visually: clubs->diamonds->hearts->spades
        
        
        
        
        let topIndex = Int(arc4random_uniform(25))
        topCard = deck[topIndex]
        deck.removeAtIndex(topIndex)
        let topCardView = view.viewWithTag(27) as UIImageView
        topCard!.flip()
        topCardView.image = topCard!.image
        trump = topCard!.suit
        bidTurn = 0
        playTurn()
        
        var trumpName = ""
        if trump == "c" {
            trumpName = "Clubs"
        } else if trump == "d" {
            trumpName = "Diamonds"
        } else if trump == "h" {
            trumpName = "Hearts"
        } else if trump == "s" {
            trumpName = "Spades"
        }
        trumpLabel.text = "Trump:\n" + trumpName
        
        playerPointsLabel.text = "Player: \(playerPoints)"
        opponentPointsLabel.text = "Opponent: \(opponentPoints)"
    } // viewDidLoad
    
    @IBAction func cardTap(sender: UITapGestureRecognizer) {
        print(sender.view)
    }
    
    
    
    func playTurn() {
        if !isPlayerTurn {
            if playerCard != nil {
                opponentPlay(playerCard!.suit)
            } else {
                opponentPlay(nil)
            }
        }
    } // playTurn
    
    // cleanUp ends the turn and gives out new cards if appropriate, then calls begin turn if appropriate
    func cleanUp() {
        var winningCard = Card.winner(playerCard!, opponentCard!, trump)
        if bidTurn != nil {
            if winningCard == playerCard {
                playerPoints++
                
                var emptyIndex = find(playerHand, dummyCard)
                playerHand[emptyIndex!] = topCard!
                let playerSpot = view.viewWithTag(emptyIndex! + 1) as UIImageView
                // need to remove topcard from the deck
                playerSpot.image = topCard!.image
                // put the top card in the player's hand
                
                let deckIndex = Int(arc4random_uniform(24 - bidTurn! * 2))
                emptyIndex = find(opponentHand, dummyCard)
                opponentHand[emptyIndex!] = deck[deckIndex]
                let opponentSpot = view.viewWithTag(emptyIndex! + 14) as UIImageView

                // put the next card in the opponent's hand
                deck.removeAtIndex(deckIndex)
                
                isPlayerTurn = true
            } // player wins the turn
            else {
                opponentPoints++
                
                var emptyIndex = find(opponentHand, dummyCard)
                opponentHand[emptyIndex!] = topCard!
                topCard!.flip()
                // put the topCard in the opponent's hand
                
                let deckIndex = Int(arc4random_uniform(24 - bidTurn! * 2))
                emptyIndex = find(playerHand, dummyCard)
                playerHand[emptyIndex!] = deck[deckIndex]
                deck[deckIndex].flip()
                // put the next card in the player's hand
                deck.removeAtIndex(deckIndex)
                
                isPlayerTurn = false
            } // bot wins the turn
            
            // sort hands:
            playerHand = Card.sortHand(playerHand)
            for i in 0...12 {
                let pCard = playerHand[i]
                // sort the player hand but we might not actually do this...
            } // sort the hands visually (clubs->diamonds->hearts->spades for player)
            
            
            playerCard = nil
            opponentCard = nil
            
            bidTurn!++
            if bidTurn < 13 {
                let topIndex = Int(arc4random_uniform(25 - bidTurn! * 2))
                topCard = deck[topIndex]
                deck.removeAtIndex(topIndex)
                topCard!.flip()
                playTurn()
            } // more bid turns
            else {
                bidTurn = nil
                trickTurn = 0
                print("Player: \(playerPoints)\nBot:\(opponentPoints)\n")
            } // start trick turns
        } else if trickTurn != nil {
            if winningCard == playerCard {
                playerPoints++
            } // player wins the turn
            else {
                opponentPoints++
            } // bot wins the turn
            if trickTurn < 13 {
                
            } // more trick turns
            else {
                if playerPoints > opponentPoints {
                    
                } // player wins
                else {
                    
                } // bot wins
            }
        }
    } // cleanUp
    
    func opponentPlay(lead: Character?) {
        if wantToWin() {
            opponentCard = Card.bestPlay(opponentHand, lead, trump)
            let index = find(opponentHand, opponentCard!)
            // play the card at index
            opponentHand[index!].flip()
            opponentHand.removeAtIndex(index!)
            if trickTurn == nil {
                opponentHand.insert(dummyCard, atIndex: index!)
            }
        } // play best card because you want to win
        else {
            // figure out the worst card to play
            let index = find(opponentHand, opponentCard!)
            // play the card at index
            opponentHand.removeAtIndex(index!)
            if trickTurn == nil {
                opponentHand.insert(dummyCard, atIndex: opponentHand.endIndex)
            }
        } // play worst card because you want to lose
        if playerCard != nil {
            cleanUp()
        } // if player has played, clean up
    } // opponentPlay
    
    func wantToWin() -> Bool {
        return true
    } // wantToWin
    
}