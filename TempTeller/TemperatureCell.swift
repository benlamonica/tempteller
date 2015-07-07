//
//  TemperatureCell.swift
//  TempTeller
//
//  Created by Ben La Monica on 6/3/15.
//  Copyright (c) 2015 Benjamin Alan La Monica. All rights reserved.
//

import UIKit

class TemperatureCell : UITableViewCell, SubRuleDisplaying {
    @IBOutlet var temperature : UITextField!
    @IBOutlet var unitButton : UIButton!
    @IBOutlet var opButton : UIButton!
    
    var subrule : TemperatureSubRule?
    
    func displayRule(subrule : SubRule) {
        if let rule = subrule as? TemperatureSubRule {
            self.subrule = rule
            temperature.text = String("\(rule.value)")
            unitButton.titleLabel?.text = rule.isFarenheit ? "F" : "C"
            opButton.titleLabel?.text = rule.op.rawValue
        }
    }
    
    override func prepareForReuse() {
        NSLog("prepare!")
    }
    
//    override func didTransitionToState(state: UITableViewCellStateMask) {
//        if state == UITableViewCellStateMask.ShowingEditControlMask {
//            NSLog(self.contentView.description)
//            let delViews = self.subviews.filter({ $0.classForCoder.description() == "UITableViewCellEditControl"})
//            if count(delViews) > 0 {
//                delViews[0].removeFromSuperview()
//            }
//        }
//    }

    
    func saveRule() {
        if let rule = subrule {
            rule.value = temperature.text.toDouble()
            rule.isFarenheit = unitButton.titleLabel!.text == "F"
            rule.op = CompOp(rawValue: opButton.titleLabel!.text!)!
        }
    }
}
