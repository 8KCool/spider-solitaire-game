//
//  Enums.swift
//  Spider Solitaire
//
//  Created by Yanbing Peng on 12/04/16.
//  Copyright © 2016 Yanbing Peng. All rights reserved.
//

import Foundation
import UIKit

enum CardSuit {
    case SPADE
    case CLUB
    case HEART
    case DIAMOND
    
    func name()->String{
        switch self {
        case .SPADE:
            return "Spade"
        case .CLUB:
            return "Club"
        case .HEART:
            return "Heart"
        case .DIAMOND:
            return "Diamond"
        }
    }
}

class CONSTANTS {
    //Notifications
    static let NOTI_SOLITAIRE_MODEL_CHANGED = "PYBSpiderSolitaireModelChanged"
    
    static let CONST_POKER_VIEW_Z_POSITION_BASE_VALUE : CGFloat = 99
    
    //NSUserDefault keys
    static let NSUSER_DEFAULTS_NUMBER_OF_SUITS_KEY = "PYBSpiderSolitaireUserDefaultsNumberOfSuitsKey"
    static let NSUSER_DEFAULTS_NOT_SHOW_TUTORIAL_KEY = "PYBSpiderSolitaireUserDefaultsNotShowTutorialKey"
    static let NSUSER_DEFAULTS_SHOW_HINTS_KEY = "PYBSpiderSolitaireUserDefaultsShowHintsKey"
    static let NSUSER_DEFAULTS_NO_SOUND_EFFECTS_KEY = "PYBSpiderSolitaireUserDefaultsNoSoundEffectsKey"
    
    static let NSUSER_DEFAULTS_TIME_ELLAPSED_KEY = "PYBSpiderSolitaireUserDefaultsTimeEllapsedKey"
}