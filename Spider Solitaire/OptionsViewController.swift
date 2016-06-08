//
//  OptionsViewController.swift
//  Spider Solitaire
//
//  Created by Yanbing Peng on 8/05/16.
//  Copyright © 2016 Yanbing Peng. All rights reserved.
//

import UIKit

class OptionsViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var numberOfSuitsSegmentedControl: UISegmentedControl!
    @IBOutlet weak var showTutorialSegmentedControl: UISegmentedControl!
    @IBOutlet weak var soundEffectsSegmentedControl: UISegmentedControl!
    
    
    // MARK: - Target Actions
    @IBAction func numberOfSuitSegmentedControlValueChanged(segControl: UISegmentedControl) {
        var numberOfSuits = 1
        if segControl.selectedSegmentIndex == 0{
            numberOfSuits = 1
        }
        else if segControl.selectedSegmentIndex == 1{
            numberOfSuits = 2
        }
        else {
            numberOfSuits = 4
        }
        NSUserDefaults.standardUserDefaults().setInteger(numberOfSuits, forKey: CONSTANTS.NSUSER_DEFAULTS_NUMBER_OF_SUITS_KEY)
    }
    
    @IBAction func showTutorialSegmentedControlValueChanged(segControl: UISegmentedControl) {
        var notShowTutorial = true
        if segControl.selectedSegmentIndex == 0{
            notShowTutorial = false
        }
        else{
            notShowTutorial = true
        }
        NSUserDefaults.standardUserDefaults().setBool(notShowTutorial, forKey: CONSTANTS.NSUSER_DEFAULTS_NOT_SHOW_TUTORIAL_KEY)
    }
    
    @IBAction func soundEffectsSegmentedControlValueChanged(segControl: UISegmentedControl) {
        var noSoundEffects = true
        if segControl.selectedSegmentIndex == 0{
            noSoundEffects = false
        }
        else{
            noSoundEffects = true
        }
        NSUserDefaults.standardUserDefaults().setBool(noSoundEffects, forKey: CONSTANTS.NSUSER_DEFAULTS_NO_SOUND_EFFECTS_KEY)
    }
    
    @IBAction func showHintSegmentedControlValueChanged(segControl: UISegmentedControl) {
        var showHint = true
        if segControl.selectedSegmentIndex == 0{
            showHint = true
        }
        else{
            showHint = false
        }
        NSUserDefaults.standardUserDefaults().setBool(showHint, forKey: CONSTANTS.NSUSER_DEFAULTS_SHOW_HINTS_KEY)
    }

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.popoverPresentationController?.backgroundColor = self.view.backgroundColor
        let numberOfSuit = NSUserDefaults.standardUserDefaults().integerForKey(CONSTANTS.NSUSER_DEFAULTS_NUMBER_OF_SUITS_KEY)
        if numberOfSuit == 4{
            numberOfSuitsSegmentedControl.selectedSegmentIndex = 2
        }
        else if numberOfSuit == 2{
            numberOfSuitsSegmentedControl.selectedSegmentIndex = 1
        }
        else{
            numberOfSuitsSegmentedControl.selectedSegmentIndex = 0
        }
        
        let notShowTutorial = NSUserDefaults.standardUserDefaults().boolForKey(CONSTANTS.NSUSER_DEFAULTS_NOT_SHOW_TUTORIAL_KEY)
        if notShowTutorial{
            showTutorialSegmentedControl.selectedSegmentIndex = 1
        }
        else{
            showTutorialSegmentedControl.selectedSegmentIndex = 0
        }
        
        
        let noSoundEffects = NSUserDefaults.standardUserDefaults().boolForKey(CONSTANTS.NSUSER_DEFAULTS_NO_SOUND_EFFECTS_KEY)
        if noSoundEffects{
            soundEffectsSegmentedControl.selectedSegmentIndex = 1
        }
        else{
            soundEffectsSegmentedControl.selectedSegmentIndex = 0
        }
        
        self.preferredContentSize = CGSize.init(width: self.view.bounds.width, height: soundEffectsSegmentedControl.frame.origin.y + soundEffectsSegmentedControl.frame.size.height )
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
