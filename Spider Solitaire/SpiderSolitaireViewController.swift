//
//  ViewController.swift
//  Spider Solitaire
//
//  Created by Yanbing Peng on 10/04/16.
//  Copyright © 2016 Yanbing Peng. All rights reserved.
//

import UIKit
import AVFoundation
import GoogleMobileAds

class SpiderSolitaireViewController: UIViewController {

    // MARK: -variables
    var gameModel : SpiderSolitaireGameModel!
    
    //private var dynamicAnimator : UIDynamicAnimator!
    //private var snapBehaviour : UISnapBehavior!
    
    private var cardStacksOnHold = [PokerView]()
    
    private var dealedCardStack1 = [PokerView]()
    private var dealedCardStack2 = [PokerView]()
    private var dealedCardStack3 = [PokerView]()
    private var dealedCardStack4 = [PokerView]()
    private var dealedCardStack5 = [PokerView]()
    private var dealedCardStack6 = [PokerView]()
    private var dealedCardStack7 = [PokerView]()
    private var dealedCardStack8 = [PokerView]()
    private var dealedCardStack9 = [PokerView]()
    private var dealedCardStack10 = [PokerView]()
    
    private lazy var dealedCardStacks : [[PokerView]] = {
        return [self.dealedCardStack1, self.dealedCardStack2, self.dealedCardStack3, self.dealedCardStack4, self.dealedCardStack5, self.dealedCardStack6, self.dealedCardStack7, self.dealedCardStack8, self.dealedCardStack9, self.dealedCardStack10]
    }()
    
    //private var cardStackIndexToDeal = 0
    
    private var movedPokerViewIndexPaths = [NSIndexPath]()
    
    private var dateTimestart = NSDate()
    
    private var gameTimer = NSTimer.init()
    
    private var cardStackCompleted = [PokerView]()
    
    private var currentMovingCardIndexPath : NSIndexPath?
    
    let tutorialMessages = [NSLocalizedString("AlertTutorialMessage1", comment: "AlertTutorialMessage1"), NSLocalizedString("AlertTutorialMessage2", comment: "AlertTutorialMessage2"), NSLocalizedString("AlertTutorialMessage3", comment: "AlertTutorialMessage3"), NSLocalizedString("AlertTutorialMessage4", comment: "AlertTutorialMessage4"), NSLocalizedString("AlertTutorialMessage5", comment: "AlertTutorialMessage5")]
    var tutorialMessageIndex = 0
    
    var dealCardAudioPlayers : [AVAudioPlayer] = [AVAudioPlayer]()
    
    var gameStarted = false
    
    // MARK: -outlets
    @IBOutlet weak var cardStacksOnHoldPlaceHolder: PokerView!
    
    @IBOutlet var cardStacksDealedPlaceHolders: [PokerView]!
    
    @IBOutlet weak var adBannerView: GADBannerView!
    
    var winAudioPlayer : AVAudioPlayer?
    
    // MARK: -target actions
    @IBAction func newGameButtonPressed(sender: UIBarButtonItem) {
        if gameModel.getTotalMoveCount > 0 && gameModel.completeStackCount < 8{
            let alert = UIAlertController.init(title: NSLocalizedString("AlertNewGameTitle", comment: "AlertNewGameTitle"), message: NSLocalizedString("AlertNewGameMessage", comment: "AlertNewGameMessage"), preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction.init(title: NSLocalizedString("AlertNewGameRestartButton", comment: "AlertNewGameRestartButton"), style: UIAlertActionStyle.Destructive, handler: { [weak self](alertAction) in
                self?.startNewGame()
            }))
            alert.addAction(UIAlertAction.init(title: NSLocalizedString("AlertNewGameCancelButton", comment: "AlertNewGameCancelButton"), style: UIAlertActionStyle.Cancel, handler: { (alertAction) in
                
            }))
            presentViewController(alert, animated: true, completion: nil)
        }
        else{
            startNewGame()
        }
    }
    
    // MARK: -notification related
    private func registerNotifications(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleNotification(_:)), name: CONSTANTS.NOTI_SOLITAIRE_MODEL_CHANGED, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleApplicationWillResignActive(_:)), name: UIApplicationWillResignActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleApplicationWillEnterForeground(_:)), name: UIApplicationWillEnterForegroundNotification, object: nil)
    }
    
    private func deregisterNotifications(){
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    func handleApplicationWillResignActive(notification:NSNotification){
        //print("ApplicationWillResignActive")
        if gameStarted{
            gameTimer.invalidate()
            //if game is not finished,  record the time used so far
            let nowTime = NSDate()
            let timeUsedSoFar = Int.init(nowTime.timeIntervalSinceDate(dateTimestart)) + NSUserDefaults.standardUserDefaults().integerForKey(CONSTANTS.NSUSER_DEFAULTS_TIME_ELLAPSED_KEY)
            //print("[TimeUsedSoFar]: \(timeUsedSoFar)")
            NSUserDefaults.standardUserDefaults().setInteger(timeUsedSoFar, forKey: CONSTANTS.NSUSER_DEFAULTS_TIME_ELLAPSED_KEY)
        }
    }
    func handleApplicationWillEnterForeground(notification:NSNotification){
        //print("ApplicationWillEnterForegaround")
        if gameStarted{
            //if game is started previously
            dateTimestart = NSDate()
            gameTimer.invalidate()
            gameTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: NSBlockOperation(block: {[weak self] in
                self?.updateTitle()
            }), selector: #selector(NSOperation.main), userInfo: nil, repeats: true)
        }
    }
    func handleNotification(notification:NSNotification){
        //print("[handleNotification]")
        if let userInfo = notification.userInfo{
            if let changeType = userInfo["changeType"] as? String{
                dispatch_async(dispatch_get_main_queue(), { [weak self] in
                    switch changeType {
                    case "cardStacksOnHoldCreated":
                        self?.handleCardStacksOnHoldCreate()
                    case "cardStackDealed":
                        self?.handleDealCardStack()
                    case "processCardMoveableAndFlipStatus":
                        self?.handleCardMoveableAndFlipStatus()
                    case "processCardCompletion":
                        self?.handleCardCompletion()
                    default:
                        break
                    }
                })
            }
        }
    }
    
    // MARK: -private funcs
    private func showTutorial(needAnimation:Bool){

        let alert = UIAlertController.init(title: NSLocalizedString("AlertTutorialTitle", comment: "AlertTutorialTitle"), message: tutorialMessages[tutorialMessageIndex], preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction.init(title: NSLocalizedString("AlertTutorialBackButton", comment: "AlertTutorialBackButton"), style: UIAlertActionStyle.Default, handler: { [weak self] (alertAction) in
            if self?.tutorialMessageIndex > 0{
                self?.tutorialMessageIndex -= 1
                alert.dismissViewControllerAnimated(false, completion: nil)
                self?.showTutorial(false)
            }
        }))
        alert.addAction(UIAlertAction.init(title: NSLocalizedString("AlertTutorialNextButton", comment: "AlertTutorialNextButton"), style: UIAlertActionStyle.Default, handler: {[weak self] (alertAction) in
            if self?.tutorialMessageIndex < 4{
                self?.tutorialMessageIndex += 1
                //print("\(self?.tutorialMessages[self!.tutorialMessageIndex])")
                alert.dismissViewControllerAnimated(false, completion: nil)
                self?.showTutorial(false)
                //print("ShowTutorial")
            }
        }))
        alert.addAction(UIAlertAction.init(title: NSLocalizedString("AlertTutorialCloseButton", comment: "AlertTutorialCloseButton"), style: UIAlertActionStyle.Default, handler: { (alertAction) in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        alert.addAction(UIAlertAction.init(title: NSLocalizedString("AlertTutorialNotShowAgainButton", comment: "AlertTutorialNotShowAgainButton"), style: UIAlertActionStyle.Cancel, handler: { (alertAction) in
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: CONSTANTS.NSUSER_DEFAULTS_NOT_SHOW_TUTORIAL_KEY)
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        presentViewController(alert, animated: needAnimation, completion: nil)
        
    }
    
    private func startNewGame(){
        NSUserDefaults.standardUserDefaults().setInteger(0, forKey: CONSTANTS.NSUSER_DEFAULTS_TIME_ELLAPSED_KEY)
        
        var numberOfSuits = NSUserDefaults.standardUserDefaults().integerForKey(CONSTANTS.NSUSER_DEFAULTS_NUMBER_OF_SUITS_KEY)
        if numberOfSuits <= 0{
            numberOfSuits = 1
        }
        gameModel.suitCount = numberOfSuits
        currentMovingCardIndexPath = nil
        
        //cardStackIndexToDeal = 0
        for stack in cardStacksOnHold{
            stack.removeFromSuperview()
        }
        for completedStack in cardStackCompleted{
            completedStack.removeFromSuperview()
        }
        for (index, stack) in dealedCardStacks.enumerate(){
            for card in stack{
                card.removeFromSuperview()
            }
            dealedCardStacks[index].removeAll()
        }
        cardStacksOnHold = [PokerView]()
        cardStackCompleted = [PokerView]()
        
        gameModel.startNewGame()
        gameTimer.invalidate()
        gameStarted = true
        self.title = "[\(NSLocalizedString("PageTitleMove", comment: "PageTitleMove"))] 0\t[\(NSLocalizedString("PageTitleTime", comment: "PageTitleTime"))] 00:00"

    }
    
    private func updateTitle(){
        let previousUsedTime = NSUserDefaults.standardUserDefaults().integerForKey(CONSTANTS.NSUSER_DEFAULTS_TIME_ELLAPSED_KEY)
        //print("[PreviousUsedTime]: \(previousUsedTime)")
        //print("[dateTimeStart]: \(dateTimestart)")
        let currentDatetime = NSDate()
        let timeInterval = Int.init(currentDatetime.timeIntervalSinceDate(dateTimestart)) + previousUsedTime
        let second = timeInterval % 60
        let minute = ((timeInterval - second) % 3600) / 60
        let hour = (timeInterval - minute * 60 - second) / 3600
        
        self.title = "[\(NSLocalizedString("PageTitleMove", comment: "PageTitleMove"))] \(String.init(format: "%d", gameModel.getTotalMoveCount))\t[\(NSLocalizedString("PageTitleTime", comment: "PageTitleTime"))] \(hour > 0 ? "\(String.init(format: "%02d:", hour))" : "")\(String.init(format: "%02d", minute)):\(String.init(format: "%02d", second))"
        
        gameTimer.invalidate()
        gameTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: NSBlockOperation(block: {[weak self] in
            self?.updateTitle()
            }), selector: #selector(NSOperation.main), userInfo: nil, repeats: true)
    }
    
    private func handleCardStacksOnHoldCreate(){
        for var dealedCardStack in dealedCardStacks{
            for cardView in dealedCardStack{
                cardView.removeFromSuperview()
            }
            dealedCardStack.removeAll()
        }
        
        if gameModel.getCardStacksOnHold.count > cardStacksOnHold.count{
            var stackFrame = cardStacksOnHoldPlaceHolder.frame
            let leftShiftOffset = round( CGFloat.init(stackFrame.size.width * 0.2) )
            
            var stackToAppend = [PokerView]()
            for index in 0 ..< gameModel.getCardStacksOnHold.count{
                if index < cardStacksOnHold.count{
                    stackFrame = CGRectIntegral( CGRectMake(stackFrame.origin.x - leftShiftOffset, stackFrame.origin.y, stackFrame.size.width, stackFrame.size.height) )
                }
                else{
                    let stackView = PokerView.init(frame: stackFrame)
                    stackView.pokerImageName = "PokerBack"
                    stackView.viewMoveDelegate = self
                    stackView.setPokerViewAsStackView()
                    stackView.layer.zPosition = CONSTANTS.CONST_POKER_VIEW_Z_POSITION_BASE_VALUE - 1
                    stackToAppend.append(stackView)
                    self.view.addSubview(stackView)
                    self.view.bringSubviewToFront(stackView)
                    stackFrame = CGRectIntegral( CGRectMake(stackFrame.origin.x - leftShiftOffset, stackFrame.origin.y, stackFrame.size.width, stackFrame.size.height) )
                }
            }
            if stackToAppend.count > 0{
                cardStacksOnHold += stackToAppend
            }
            gameModel.dealCardStack()
        }
    }
    
    private func handleDealCardStack(){
        var animationDelay : NSTimeInterval = 0
        for i in 0 ..< 10{
            let modelDealedCardStack = gameModel.dealedCardStacks[i]
            //print("viewReceivedDealedStack: \(modelDealedCardStack)")
            let viewDealedCardStack = dealedCardStacks[i]
            if modelDealedCardStack.count > viewDealedCardStack.count{
                if let modelDealedCard = modelDealedCardStack.last{
                    var placeHolder : PokerView? = nil
                    for _placeHolder in cardStacksDealedPlaceHolders{
                        if _placeHolder.tag == i{
                            placeHolder = _placeHolder
                        }
                    }
                    //print("[DealedCardStackCount]: \(viewDealedCardStack.count)")
                    if let cardStackPlaceHolder = placeHolder , originPlaceHolder = cardStacksOnHold.last{
                        var pokerViewDestFrame = cardStackPlaceHolder.frame
                        let downShiftOffset = round( CGFloat.init(pokerViewDestFrame.size.height * 0.2 *  CGFloat(viewDealedCardStack.count)) )
                        pokerViewDestFrame = CGRectIntegral( CGRectMake(pokerViewDestFrame.origin.x, pokerViewDestFrame.origin.y + downShiftOffset, pokerViewDestFrame.size.width, pokerViewDestFrame.size.height) )
                        let pokerViewOriginFrame = originPlaceHolder.frame
                        
                        let pokerView = PokerView.init(frame: pokerViewOriginFrame)
                        pokerView.pokerImageName = modelDealedCard._cardImageName
                        pokerView.pokerIsFacingUp = false

                        let pokerViewIndexPath = NSIndexPath.init(forRow: dealedCardStacks[i].count, inSection: i)
                        pokerView.pokerViewIndexPath = pokerViewIndexPath
                        pokerView.layer.zPosition = CONSTANTS.CONST_POKER_VIEW_Z_POSITION_BASE_VALUE + CGFloat.init(pokerViewIndexPath.row)
                        //print("pokerView Z Pos: \(pokerView.layer.zPosition)")
                        pokerView.viewMoveDelegate = self
                        self.view.addSubview(pokerView)
                        self.view.bringSubviewToFront(pokerView)
                        dealedCardStacks[i].append(pokerView)
                        
                        UIView.animateWithDuration(0.1, delay: animationDelay, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                            pokerView.frame = pokerViewDestFrame
                            }, completion: {[weak self] (complete) in
                                self?.playDealCardSound()
                            }
                        )
                        
                        if modelDealedCard._cardIsFacingUp{
                            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(animationDelay * Double(NSEC_PER_SEC)))
                            dispatch_after(delayTime, dispatch_get_main_queue(), {
                                pokerView.pokerIsFacingUp = modelDealedCard._cardIsFacingUp
                            })
                        }
                        animationDelay +=  0.1
                    }
                }
            }
        }
        let cardStackToRemove = cardStacksOnHold.removeLast()
        cardStackToRemove.removeFromSuperview()
        
        if cardStacksOnHold.count > 5{
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(animationDelay * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue(), { [weak self] in
                self?.gameModel.dealCardStack()
            })
        }
        else if cardStacksOnHold.count == 5{
            dateTimestart = NSDate()
            updateTitle()
            gameTimer.invalidate()
            gameTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: NSBlockOperation(block: {[weak self] in
                self?.updateTitle()
                }), selector: #selector(NSOperation.main), userInfo: nil, repeats: true)
        }
    }
    private func handleCardMoveableAndFlipStatus(){
        //print("[model]:\n" + "\(gameModel.dealedCardStacks)")
        //print("[view]:\n" + "\(dealedCardStacks)")
        
        for (i, modelStack) in gameModel.dealedCardStacks.enumerate(){
            for (j, modelCard) in modelStack.enumerate(){
                (dealedCardStacks[i][j]).clearViewOffset()
                (dealedCardStacks[i][j]).pokerIsFacingUp = modelCard._cardIsFacingUp
                (dealedCardStacks[i][j]).pokerIsMoveable = modelCard._cardIsMoveable
            }
        }
    }
    
    private func handleCardCompletion(){
        //print("handlCardComplete: \(gameModel.completeStackIndex)")
        var cardStackCompletedPlaceHolderRect : CGRect? = nil
        for _placeHolder in cardStacksDealedPlaceHolders{
            if _placeHolder.tag == 0{
                let firstCardStackDealedRect = _placeHolder.frame
                cardStackCompletedPlaceHolderRect = CGRectIntegral( CGRect.init(x: firstCardStackDealedRect.origin.x, y: cardStacksOnHoldPlaceHolder.frame.origin.y, width: firstCardStackDealedRect.size.width, height: firstCardStackDealedRect.size.height) )
                //print("[cardStackCompletedPlaceHolderRect]: \(cardStackCompletedPlaceHolderRect!)")
                break
            }
        }
        if let placeHolder = cardStackCompletedPlaceHolderRect{
            if gameModel.completeStackIndex >= 0{
                let stackIndex = gameModel.completeStackIndex
                let cardCount = dealedCardStacks[stackIndex].count
                var animationDelay : Double = 0
                for index in 1 ... 13{
                    let cardIndex = cardCount - index
                    let pokerView = dealedCardStacks[stackIndex][cardIndex]
                    let completeStackCount = gameModel.completeStackCount
                    pokerView.clearViewOffset()
                    gameModel.dealedCardStacks[stackIndex].removeAtIndex(cardIndex)
                    dealedCardStacks[stackIndex].removeAtIndex(cardIndex)
                    pokerView.layer.zPosition = CONSTANTS.CONST_POKER_VIEW_Z_POSITION_BASE_VALUE * 10
                    UIView.animateWithDuration(0.5, delay: animationDelay, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                            pokerView.frame = CGRectIntegral( CGRect.init(x: placeHolder.origin.x + round(placeHolder.size.width * 0.2 * CGFloat(completeStackCount)), y: placeHolder.origin.y, width: placeHolder.size.width, height: placeHolder.size.height) )
                        }, completion: {[weak self] (complete) in
                            if let wSelf = self{
                                wSelf.playDealCardSound()
                                if index != 13{
                                    pokerView.removeFromSuperview()
                                }
                                else{
                                    pokerView.pokerIsMoveable = false
                                    pokerView.layer.zPosition = CONSTANTS.CONST_POKER_VIEW_Z_POSITION_BASE_VALUE
                                    wSelf.view.bringSubviewToFront(pokerView)
                                    wSelf.cardStackCompleted.append(pokerView)
                                }
                            }
                        }
                    )
                    animationDelay += 0.1
                }
            }
        }
        gameModel.completeStackIndex = -1
        gameModel.processCardMoveableAndFlipCompletionStatus()
        if gameModel.completeStackCount >= 8{
            NSUserDefaults.standardUserDefaults().setInteger(0, forKey: CONSTANTS.NSUSER_DEFAULTS_TIME_ELLAPSED_KEY)
            UIAlertView.init(title: NSLocalizedString("AlertWinTitle", comment: "AlertWinTitle"), message: NSLocalizedString("AlertWinMessage", comment: "AlertWinMessage"), delegate: nil, cancelButtonTitle: NSLocalizedString("AlertWinCancelButton", comment: "AlertWinCancelButton")).show()
            gameTimer.invalidate()
            gameStarted = false
            winAudioPlayer?.play()
        }
    }
    
    private func playDealCardSound(){
        let needPlaySound = !NSUserDefaults.standardUserDefaults().boolForKey(CONSTANTS.NSUSER_DEFAULTS_NO_SOUND_EFFECTS_KEY)
        
        if needPlaySound{
            var availablePlayer : AVAudioPlayer? = nil
            for player in dealCardAudioPlayers{
                if player.playing == false{
                    availablePlayer = player
                    break
                }
            }
            
            if availablePlayer == nil{
                do{
                    if let soundFileUrl = NSBundle.mainBundle().pathForResource("cardPlace1", ofType: "wav"){
                        try availablePlayer = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: soundFileUrl))
                        availablePlayer?.prepareToPlay()
                        availablePlayer?.numberOfLoops = 0
                        dealCardAudioPlayers.append(availablePlayer!)
                    }
                }
                catch{
                    print(error)
                }
            }
            
            if let play = availablePlayer{
                play.play()
            }
        }
    }
    
    // MARK: -view life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "[\(NSLocalizedString("PageTitleMove", comment: "PageTitleMove"))] 0\t[\(NSLocalizedString("PageTitleTime", comment: "PageTitleTime"))] 00:00"
        
        gameModel = SpiderSolitaireGameModel()
        
        self.adBannerView.adUnitID = "ca-app-pub-3199275288482759/7527082221"
        self.adBannerView.rootViewController = self
        self.adBannerView.loadRequest(GADRequest.init())
        //self.adBannerView.hidden = true
        
        do{
            if let soundFileUrl = NSBundle.mainBundle().pathForResource("taDa", ofType: "wav"){
                try winAudioPlayer = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: soundFileUrl))
                winAudioPlayer?.prepareToPlay()
            }
        }
        catch{
            print(error)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        registerNotifications()
        let notShowTutorial = NSUserDefaults.standardUserDefaults().boolForKey(CONSTANTS.NSUSER_DEFAULTS_NOT_SHOW_TUTORIAL_KEY)
        if !notShowTutorial{
            showTutorial(true)
        }
        //print("[viewWillAppear]")
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        deregisterNotifications()
        //print("[viewWillDisappear]")
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destVc = segue.destinationViewController as? OptionsViewController{
            if let popoverVc = destVc.popoverPresentationController{
                popoverVc.delegate = self
            }
        }
    }
}
extension SpiderSolitaireViewController : UIPopoverPresentationControllerDelegate{
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
}
extension SpiderSolitaireViewController : PokerViewMoveDelegate{
    func handlePokerCardTap(atIndexPath indexPath: NSIndexPath) {
        playDealCardSound()
        let offsetState = (dealedCardStacks[indexPath.section][indexPath.row]).viewIsOffsetted
        for (i, cardStack) in dealedCardStacks.enumerate(){
            for (j, _) in cardStack.enumerate(){
                if indexPath.section == i{
                    if j >= indexPath.row{
                        if dealedCardStacks[i][j].pokerIsFacingUp{
                            dealedCardStacks[i][j].viewIsOffsetted = !offsetState
                        }
                    }
                    else{
                        dealedCardStacks[i][j].viewIsOffsetted = false
                    }
                }
                else{
                    dealedCardStacks[i][j].viewIsOffsetted = false
                }
            }
        }
    }
    func handlePokerStackTap() {
        var validToDealMore = true
        var hasEmptyColumns = false
        var totalDealedCardCount = 0
        for stack in dealedCardStacks{
            totalDealedCardCount += stack.count
            if stack.count == 0{
                hasEmptyColumns = true
            }
        }
        if hasEmptyColumns && totalDealedCardCount > 10{
            validToDealMore = false
        }
        
        if validToDealMore{
            for (i, cardStack) in dealedCardStacks.enumerate(){
                for(j, _) in cardStack.enumerate(){
                    (dealedCardStacks[i][j]).viewIsOffsetted = false
                }
            }
            gameModel.dealCardStack()
        }
        else{
            UIAlertView.init(title: NSLocalizedString("AlertWarningTitle", comment: "AlertWarningTitle"), message: NSLocalizedString("AlertWarningMessage", comment: "AlertWarningMessage"), delegate: nil, cancelButtonTitle: NSLocalizedString("AlertWarningCancelButton", comment: "AlertWarningCancelButton")).show()
        }
    }
    
    func handleUnmoveableViewPanGesture(atIndexPath indexPath: NSIndexPath, panGesture: UIPanGestureRecognizer) {
        for (_, cardView) in dealedCardStacks[indexPath.section].enumerate(){
            if cardView.pokerIsMoveable{
                cardView.panGestureRecognized(panGesture)
                break
            }
        }
    }
    
    func handlePokerViewMoveBegan(atIndexPath indexPath: NSIndexPath) {
        //dealCardAudioPlayer?.play()
        if currentMovingCardIndexPath != nil{
            if currentMovingCardIndexPath != indexPath{
                return
            }
        }
        else{
            currentMovingCardIndexPath = indexPath
        }
        
        movedPokerViewIndexPaths = [NSIndexPath]()
        if indexPath.row  < dealedCardStacks[indexPath.section].count{
            for index in indexPath.row ..< dealedCardStacks[indexPath.section].count{
                movedPokerViewIndexPaths.append(NSIndexPath.init(forRow: index, inSection: indexPath.section))
                let pokerView = dealedCardStacks[indexPath.section][index]
                //print("\(pokerView) move began")
                pokerView.handleViewMoveBegan()
            }
        }
    }
    func handlePokerViewMoveChanged(atIndexPath moveIndexPath:NSIndexPath, translation:CGPoint) {
        if currentMovingCardIndexPath != nil{
            if currentMovingCardIndexPath != moveIndexPath{
                return
            }
        }
        for indexPath in movedPokerViewIndexPaths{
            let pokerView = dealedCardStacks[indexPath.section][indexPath.row]
            pokerView.handleViewMoveChanged(translation)
        }
    }
    func handlePokerViewMoveCancelled(atIndexPath moveIndexPath: NSIndexPath) {
        if currentMovingCardIndexPath != nil{
            if currentMovingCardIndexPath != moveIndexPath{
                return
            }
            else{
                currentMovingCardIndexPath = nil
            }
        }
        
        for indexPath in movedPokerViewIndexPaths{
            let pokerView = dealedCardStacks[indexPath.section][indexPath.row]
            pokerView.handleViewMoveCancelled()
        }
    }
    func handlePokerViewMoveFailed(atIndexPath moveIndexPath: NSIndexPath) {
        if currentMovingCardIndexPath != nil{
            if currentMovingCardIndexPath != moveIndexPath{
                return
            }
            else{
                currentMovingCardIndexPath = nil
            }
        }
        
        for indexPath in movedPokerViewIndexPaths{
            let pokerView = dealedCardStacks[indexPath.section][indexPath.row]
            pokerView.handleViewMoveFailed()
        }
    }
    func handlePokerViewMoveEnd(atIndexPath moveIndexPath: NSIndexPath) {
        playDealCardSound()
        //!! double check this
        for(i, _) in dealedCardStacks.enumerate(){
            for (j, _) in dealedCardStacks[i].enumerate(){
                (dealedCardStacks[i][j]).viewIsOffsetted = false
            }
        }
        
        if currentMovingCardIndexPath != nil{
            if currentMovingCardIndexPath != moveIndexPath{
                return
            }
            else{
                currentMovingCardIndexPath = nil
            }
        }
        
        if let indexPath = movedPokerViewIndexPaths.first{
            let movedPokerPosition = (dealedCardStacks[indexPath.section][indexPath.row]).center
            
            var targetIndexPath : NSIndexPath? = nil
            var targetView : PokerView? = nil
            var initalOffset :CGFloat = 1
            for (i, stack) in dealedCardStacks.enumerate(){
                if i == indexPath.section{
                    continue
                }
                if let lastPokerView = stack.last{
                    let cardHolderView = cardStacksDealedPlaceHolders[i]
                    //lastPokerView.frame
                    if CGRectContainsPoint(CGRectMake(cardHolderView.frame.origin.x, cardHolderView.frame.origin.y, cardHolderView.frame.size.width, lastPokerView.frame.origin.y - cardHolderView.frame.origin.y + lastPokerView.frame.size.height), movedPokerPosition){
                        targetView = lastPokerView
                        initalOffset = 1
                        //targetIndexPath = NSIndexPath.init(forRow: stack.count - 1, inSection: i)
                        targetIndexPath = targetView?.pokerViewIndexPath
                        break
                    }
                }
                else{
                    let cardHolderView = cardStacksDealedPlaceHolders[i]
                    
                    if CGRectContainsPoint(cardHolderView.frame, movedPokerPosition){
                        targetView = cardHolderView
                        initalOffset = 0
                        targetIndexPath = NSIndexPath.init(forRow: 0, inSection: i)
                        break
                    }
                }
            }
            //print("targetIndexPath: \(targetIndexPath?.section)-\(targetIndexPath?.row) targetView: \(targetView?.pokerImageName)")
            if let destIndexPath = targetIndexPath, destView = targetView{
                if indexPath.section == destIndexPath.section
                {
                    //print("\(indexPath.section) == \(destIndexPath.section)")
                    for movedPokerViewindexPath in movedPokerViewIndexPaths{
                        (dealedCardStacks[movedPokerViewindexPath.section][movedPokerViewindexPath.row]).resetToOriginal()
                    }
                }
                else{
                    //print("\(indexPath)")
                    //print("\(destView.pokerViewIndexPath)")
                    //print("\(destIndexPath)")
                    if !gameModel.validateCardMove(indexPath, toDestIndexPath: destIndexPath) {
                        for movedPokerViewindexPath in movedPokerViewIndexPaths{
                            (dealedCardStacks[movedPokerViewindexPath.section][movedPokerViewindexPath.row]).resetToOriginal()
                        }
                    }
                    else{
                        let downShiftOffset = round( CGFloat.init(destView.frame.size.height * 0.2) )
                        var zPosIncrement:CGFloat = 1
                        
                        for i in indexPath.row ..< (dealedCardStacks[indexPath.section]).count{
                            let pokerView = dealedCardStacks[indexPath.section][i]
                            dealedCardStacks[destIndexPath.section].append(pokerView)
                            pokerView.center = CGPoint.init(x: destView.center.x, y: destView.center.y + downShiftOffset * (CGFloat.init(i - indexPath.row) + initalOffset))
                            pokerView.pokerViewIndexPath = NSIndexPath.init(forRow: destIndexPath.row + (i - indexPath.row) + Int(initalOffset), inSection: destIndexPath.section)
                            pokerView.layer.zPosition = destView.layer.zPosition + zPosIncrement
                            zPosIncrement += 1
                            //print("pokerView \(pokerView) Z Pos: \(pokerView.layer.zPosition)")
                            self.view.bringSubviewToFront(pokerView)
                            pokerView.clearOriginal()
                        }
                        dealedCardStacks[indexPath.section].removeRange(indexPath.row ..< (dealedCardStacks[indexPath.section]).count)
                        updateTitle()
                        gameModel.processCardMoveableAndFlipCompletionStatus()
                    }
                }
            }
            else{
                for movedPokerViewindexPath in movedPokerViewIndexPaths{
                    (dealedCardStacks[movedPokerViewindexPath.section][movedPokerViewindexPath.row]).resetToOriginal()
                }
            }
        }
    }
}






