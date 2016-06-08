//
//  PokerCard.swift
//  Spider Solitaire
//
//  Created by Yanbing Peng on 12/04/16.
//  Copyright © 2016 Yanbing Peng. All rights reserved.
//

import Foundation

class PokerCard : NSObject{
    let _cardRank:Int
    let _cardSuit:CardSuit
    
    var _cardIsFacingUp = false
    var _cardIsMoveable = false
    
    var _cardImageName : String{
        get{
            return "\(_cardRank)\(_cardSuit.name())"
        }
    }
    
    init(cardRank:Int, cardSuit:CardSuit) {
        _cardRank = cardRank
        _cardSuit = cardSuit
        super.init()
    }
    
    override var description: String{
        return _cardImageName
    }
}