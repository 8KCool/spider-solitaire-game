//
//  SpiderSolitaireGameModel.swift
//  Spider Solitaire
//
//  Created by Yanbing Peng on 12/04/16.
//  Copyright © 2016 Yanbing Peng. All rights reserved.
//

import Foundation

class SpiderSolitaireGameModel: NSObject {
    
    // MARK: -variables
    var suitCount: Int = 1{
        didSet{
            if suitCount == 1{
                cardSuitsAvailiable = [CardSuit.SPADE, CardSuit.SPADE, CardSuit.SPADE, CardSuit.SPADE,
                                       CardSuit.SPADE, CardSuit.SPADE, CardSuit.SPADE, CardSuit.SPADE]
            }
            else if suitCount == 2{
                cardSuitsAvailiable = [CardSuit.SPADE, CardSuit.SPADE, CardSuit.SPADE, CardSuit.SPADE,
                                       CardSuit.HEART, CardSuit.HEART, CardSuit.HEART, CardSuit.HEART]
            }
            else{
                cardSuitsAvailiable = [CardSuit.SPADE, CardSuit.HEART, CardSuit.CLUB, CardSuit.DIAMOND,
                                       CardSuit.SPADE, CardSuit.HEART, CardSuit.CLUB, CardSuit.DIAMOND]
            }
        }
    }
    
    private var cardSuitsAvailiable = [CardSuit.SPADE, CardSuit.SPADE, CardSuit.SPADE, CardSuit.SPADE,
                                       CardSuit.SPADE, CardSuit.SPADE, CardSuit.SPADE, CardSuit.SPADE]
    
    private var cardStacksOnHold = [[PokerCard]]()
    var getCardStacksOnHold : [[PokerCard]] {
        get{
            return cardStacksOnHold
        }
    }
    
    //private var cardStacksDealed = [[PokerCard]]()
    private var cardDealedStack1 = [PokerCard]()
    private var cardDealedStack2 = [PokerCard]()
    private var cardDealedStack3 = [PokerCard]()
    private var cardDealedStack4 = [PokerCard]()
    private var cardDealedStack5 = [PokerCard]()
    private var cardDealedStack6 = [PokerCard]()
    private var cardDealedStack7 = [PokerCard]()
    private var cardDealedStack8 = [PokerCard]()
    private var cardDealedStack9 = [PokerCard]()
    private var cardDealedStack10 = [PokerCard]()
    
    private var cardStackIndexToDeal = 0
    private var totalCardDealedCount = 0
    
    lazy var dealedCardStacks : [[PokerCard]] =  { return [self.cardDealedStack1, self.cardDealedStack2, self.cardDealedStack3, self.cardDealedStack4, self.cardDealedStack5, self.cardDealedStack6, self.cardDealedStack7, self.cardDealedStack8, self.cardDealedStack9, self.cardDealedStack10]}()
    
    private var totalMoveCount = 0
    var getTotalMoveCount : Int{
        get{
            return totalMoveCount
        }
    }
    
    var completeStackIndex : Int = -1
    private(set) var completeStackCount : Int = 0
    
    // MARK: - public API
    func startNewGame(){
        cardStacksOnHold = [[PokerCard]]()
        cardStackIndexToDeal = 0
        totalCardDealedCount = 0
        totalMoveCount = 0
        completeStackIndex = -1
        completeStackCount = 0
        for (index, _) in dealedCardStacks.enumerate(){
            dealedCardStacks[index].removeAll()
        }
        
        var cardStackOverall = [PokerCard]()
        for suit in cardSuitsAvailiable{
            let stack = generateCardStackWith(suit)
            cardStackOverall += stack
        }
        
        var randomCardStack = [PokerCard]()
        
        for _ in 0..<5{
            randomCardStack = [PokerCard]()
            for _ in 0..<10{
                let (card, remainingStack) = drawRandomCardFromStack(cardStackOverall)
                randomCardStack.append(card)
                cardStackOverall = remainingStack
            }
            cardStacksOnHold.append(randomCardStack)
        }
        
        randomCardStack = [PokerCard]()
        for _ in 0..<4{
            let (card, remainingStack) = drawRandomCardFromStack(cardStackOverall)
            randomCardStack.append(card)
            cardStackOverall = remainingStack
        }
        cardStacksOnHold.append(randomCardStack)
        
        for _ in 0..<5{
            randomCardStack = [PokerCard]()
            for _ in 0..<10{
                let (card, remainingStack) = drawRandomCardFromStack(cardStackOverall)
                randomCardStack.append(card)
                cardStackOverall = remainingStack
            }
            cardStacksOnHold.append(randomCardStack)
        }
        
        postNotification("cardStacksOnHoldCreated")
    }
    
    func dealCardStack(){
        if cardStacksOnHold.count > 0 {
            let dealStack = cardStacksOnHold.removeLast()
            for pokerCard in dealStack{
                totalCardDealedCount += 1
                if totalCardDealedCount > 44 {
                    pokerCard._cardIsFacingUp = true
                }
                else{
                    pokerCard._cardIsFacingUp = false
                }
                dealedCardStacks[cardStackIndexToDeal].append(pokerCard)
                cardStackIndexToDeal += 1
                if cardStackIndexToDeal > 9{
                    cardStackIndexToDeal = 0
                }
            }
            //print("cardStackDealed: \(dealStack)")
            postNotification("cardStackDealed")
            processCardMoveableAndFlipCompletionStatus()
        }
    }
    
    func validateCardMove(cardIndexPath: NSIndexPath, toDestIndexPath destIndexPath:NSIndexPath)->Bool{
        let cardMoved = dealedCardStacks[cardIndexPath.section][cardIndexPath.row]
        if let cardDest = dealedCardStacks[destIndexPath.section].last{
            //print("\(cardDest._cardRank) - \(cardMoved._cardRank ) = \(cardDest._cardRank - cardMoved._cardRank)")
            if cardDest._cardRank - cardMoved._cardRank == 1{
                for i in cardIndexPath.row ..< (dealedCardStacks[cardIndexPath.section]).count{
                    let card = dealedCardStacks[cardIndexPath.section][i]
                    dealedCardStacks[destIndexPath.section].append(card)
                }
                dealedCardStacks[cardIndexPath.section].removeRange(cardIndexPath.row ..< (dealedCardStacks[cardIndexPath.section]).count)
                totalMoveCount += 1
                return true
            }
        }
        else{
            for i in cardIndexPath.row ..< (dealedCardStacks[cardIndexPath.section]).count{
                let card = dealedCardStacks[cardIndexPath.section][i]
                dealedCardStacks[destIndexPath.section].append(card)
            }
            dealedCardStacks[cardIndexPath.section].removeRange(cardIndexPath.row ..< (dealedCardStacks[cardIndexPath.section]).count)
            totalMoveCount += 1
            return true
        }
        
        return false
    }
    
    // MARK: - private func
    func processCardMoveableAndFlipCompletionStatus(){
        //print("processCardMoveableAndFlipCompletionStatus")
        if totalCardDealedCount > 50{
            for (stackIndex, cardStack) in dealedCardStacks.enumerate(){
 
                dealedCardStacks[stackIndex].last?._cardIsFacingUp = true
                dealedCardStacks[stackIndex].last?._cardIsMoveable = true
                
                
                let needCheckForCompletion = dealedCardStacks[stackIndex].last?._cardRank == 1
                var moveableCardCount = 1
   
                for index in (cardStack.count - 1).stride(to: -1, by: -1) {
                    let previousCardIndex  = index + 1
                    if previousCardIndex < cardStack.count{
                        let previousCard = dealedCardStacks[stackIndex][previousCardIndex]
                        let currentCard = dealedCardStacks[stackIndex][index]

                        if previousCard._cardIsFacingUp{
                            if previousCard._cardIsMoveable{
                                if (currentCard._cardRank - previousCard._cardRank == 1) && (currentCard._cardSuit.name() == previousCard._cardSuit.name()) && (currentCard._cardIsFacingUp){
                                    dealedCardStacks[stackIndex][index]._cardIsMoveable = true
                                    if needCheckForCompletion{
                                        moveableCardCount += 1
                                        if moveableCardCount >= 13{
                                            completeStackIndex = stackIndex
                                            completeStackCount += 1
                                            postNotification("processCardCompletion")
                                        }
                                    }
                                }
                                else{
                                    dealedCardStacks[stackIndex][index]._cardIsMoveable = false
                                }
                            }
                            else{
                                dealedCardStacks[stackIndex][index]._cardIsMoveable = false
                            }
                            
                        }
                        else{
                            dealedCardStacks[stackIndex][index]._cardIsMoveable = false
                        }
                    }
                }
            }
            postNotification("processCardMoveableAndFlipStatus")
        }
    }
    
    private func postNotification(changeType:String){
        NSNotificationCenter.defaultCenter().postNotificationName(CONSTANTS.NOTI_SOLITAIRE_MODEL_CHANGED, object: self, userInfo: ["changeType": changeType])
    }
    
    private func drawRandomCardFromStack(stack:[PokerCard])->(card:PokerCard, remainingStack:[PokerCard]){
        var stack = stack
        let cardIndex = Int(arc4random_uniform(UInt32.init(stack.count)))
        let card = stack.removeAtIndex(cardIndex)
        return (card, stack)
    }
    private func generateCardStackWith(suit:CardSuit)->[PokerCard]{
        var cardStack = [PokerCard]()
        for rank in 1...13{
            let pokerCard = PokerCard.init(cardRank: rank, cardSuit: suit)
            cardStack.append(pokerCard)
        }
        return cardStack
    }
    
}