//
//  PokerView.swift
//  Spider Solitaire
//
//  Created by Yanbing Peng on 10/04/16.
//  Copyright © 2016 Yanbing Peng. All rights reserved.
//

import UIKit

@IBDesignable
class PokerView: UIView {
    
    private let pokerBackImageName = "CardBack"
    private let pokerSpaceImageName = "CardSpace"
    
    @IBInspectable
    var pokerImageName:String = "CardSpace"{
        didSet{
            var imageName = ""
            if pokerIsFacingUp{
                imageName = pokerImageName
            }
            else{
                if pokerImageName == pokerSpaceImageName{
                    imageName = pokerSpaceImageName
                    
                }else{
                    imageName = pokerBackImageName
                }
            }
            if imageName != oldValue{
                if let image = UIImage.init(named: imageName){
                    pokerImageView.image = image
                }
            }
        }
    }
    var pokerIsFacingUp = false{
        didSet{
            if pokerIsFacingUp != oldValue{
                var imageName = ""
                if pokerIsFacingUp{
                    //print("poker is facing up")
                    imageName = pokerImageName
                }
                else{
                    //print("poker is facing down")
                    if pokerImageName == pokerSpaceImageName{
                        imageName = pokerSpaceImageName
                    }else{
                        imageName = pokerBackImageName
                    }
                }
                if let image = UIImage.init(named: imageName){
                    if pokerImageName == pokerSpaceImageName{
                        pokerImageView.image = image
                    }
                    else{
                        UIView.transitionWithView(pokerImageView, duration: 0.1, options: [UIViewAnimationOptions.TransitionFlipFromLeft, UIViewAnimationOptions.CurveEaseInOut], animations: { [weak self] in
                            self?.pokerImageView.image = image
                            }, completion: nil)
                    }
                }
            }
        }
    }
    
    var pokerIsMoveable = false
    
    var pokerViewIndexPath : NSIndexPath?
    
    var viewOriginalPosition : CGPoint?
    
    var viewOriginalZPosition : CGFloat?
    
    var viewMoveDelegate : PokerViewMoveDelegate?
    
    var viewOriginalPosBeforeOffset : CGPoint?
    
    var viewIsOffsetted = false{
        didSet{
            if !pokerIsFacingUp{
                viewIsOffsetted = false
                return
            }
            
            if viewIsOffsetted == true{
                if viewOriginalPosBeforeOffset == nil{
                    viewOriginalPosBeforeOffset = self.center
                    self.center = CGPoint.init(x: self.center.x, y: round(self.center.y + self.bounds.size.height / 3.0))
                }
            }
            else{
                if viewOriginalPosBeforeOffset != nil{
                    viewOriginalPosition = viewOriginalPosBeforeOffset
                    self.center = viewOriginalPosBeforeOffset!
                    viewOriginalPosBeforeOffset = nil
                }
            }
        }
    }
    
    var viewIsStackView = false
    
    override var description: String{
        //return "(\(pokerViewIndexPath != nil ? "(\(pokerViewIndexPath!.section):\(pokerViewIndexPath!.row))" : "")\(pokerImageName), FaceUp:\(pokerIsFacingUp), Moveable:\(pokerIsMoveable))\n"
        return "\(pokerImageName)"
    }
    
    // MARK: - Outlets
    @IBOutlet weak var pokerImageView: UIImageView!
    

    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    private func xibSetup(){
        let nib = UINib(nibName: "PokerView", bundle: NSBundle(forClass: self.dynamicType))
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        view.frame = bounds
        view.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognized(_:)))
        self.gestureRecognizers = [panRecognizer]
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapGestureRecognized(_:)) )
        self.gestureRecognizers?.append(tapRecognizer)
        
        addSubview(view)
    }
    
    // MARK: - Public API
    func clearViewOffset(){

        if viewOriginalPosBeforeOffset != nil{
            viewOriginalPosBeforeOffset = nil
        }
        viewIsOffsetted = false
    }
    func setPokerViewAsStackView(){
        //print("setPokerViewAsStackView")
        viewIsStackView = true
    }
    
    func resetToOriginal(){
        if let position = viewOriginalPosition{
            UIView.animateWithDuration(0.1, animations: { [weak self] in
                self?.center = position
                }, completion: { [weak self] (completed) in
                    if let zPosition = self?.viewOriginalZPosition{
                        self?.layer.zPosition = zPosition
                        self?.viewIsOffsetted = false
                    }
            })
        }
        else{
            self.viewIsOffsetted = false
        }
    }
    
    func clearOriginal(){
        viewOriginalPosition = nil
        viewOriginalZPosition = nil
    }
    
    // MARK: - View Move handlers
    func handleViewMoveBegan(){
        if pokerIsMoveable{
            //print("[Move Begin]: \(self)")
            viewOriginalPosition = self.center
            viewOriginalZPosition = self.layer.zPosition
            self.layer.zPosition = CONSTANTS.CONST_POKER_VIEW_Z_POSITION_BASE_VALUE * 10 + self.layer.zPosition
        }
    }
    func handleViewMoveChanged(translation:CGPoint){
        if pokerIsMoveable{
            self.center = CGPointMake(self.center.x + translation.x, self.center.y + translation.y)
        }
    }

    func handleViewMoveCancelled(){
        if pokerIsMoveable{
            resetToOriginal()
        }
    }
    func handleViewMoveFailed(){
        if pokerIsMoveable{
            resetToOriginal()
        }
    }
    
    
    // MARK: - Gesture handler
    func tapGestureRecognized(gesture: UITapGestureRecognizer){
        //print("tapGestureRecognized")
        if viewIsStackView{
            viewMoveDelegate?.handlePokerStackTap()
        }
        else{
            if let indexPath = self.pokerViewIndexPath{
                if self.pokerIsMoveable{
                    viewMoveDelegate?.handlePokerCardTap(atIndexPath: indexPath)
                }
            }
        }
    }
    
    func panGestureRecognized(gesture: UIPanGestureRecognizer) {
        //print("panGestureRecognized")
        if pokerIsMoveable{
            switch gesture.state {
            case .Began:
                if let indexPath = self.pokerViewIndexPath{
                    viewMoveDelegate?.handlePokerViewMoveBegan(atIndexPath: indexPath)
                }
            case .Changed:
                if let suView = self.superview{
                    let translation = gesture.translationInView(suView)
                    if let indexPath = self.pokerViewIndexPath{
                        viewMoveDelegate?.handlePokerViewMoveChanged(atIndexPath: indexPath,  translation: translation)
                    }
                    gesture.setTranslation(CGPointZero, inView: suView)
                }
            case .Ended:
                //print("\(self.pokerImageName) pan ended")
                if let indexPath = self.pokerViewIndexPath{
                    viewMoveDelegate?.handlePokerViewMoveEnd(atIndexPath: indexPath)
                }
            case .Cancelled:
                if let indexPath = self.pokerViewIndexPath{
                    viewMoveDelegate?.handlePokerViewMoveCancelled(atIndexPath: indexPath)
                }
            case .Failed:
                if let indexPath = self.pokerViewIndexPath{
                    viewMoveDelegate?.handlePokerViewMoveFailed(atIndexPath: indexPath)
                }
            default:
                break
            }
        }
        else{
            if let indexPath = self.pokerViewIndexPath{
                viewMoveDelegate?.handleUnmoveableViewPanGesture(atIndexPath: indexPath, panGesture: gesture)
            }
        }
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
}
