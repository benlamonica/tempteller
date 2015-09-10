//
//  TimeCell.swift
//  TempTeller
//
//  Created by Ben La Monica on 8/19/15.
//  Copyright (c) 2015 Benjamin Alan La Monica. All rights reserved.
//

import Foundation
import UIKit

class TimeCell : UITableViewCell, SubRuleDisplaying {
    @IBOutlet var fromTime : UIButton!
    @IBOutlet var toTime : UIButton!
    @IBOutlet var andLabel : UILabel!
    @IBOutlet var timeOp : UIButton!
    @IBOutlet var textfield: UITextField!
    @IBOutlet var widthConstraint : NSLayoutConstraint!
    
    var pickerView : UIPickerView!
    var subrule : TimeSubRule!
    var timeEditor : TimeEditor!
    
    func save() {
        subrule.timeRange.min = fromTime.titleLabel!.text!
        subrule.timeRange.max = toTime.titleLabel!.text!
        displayRule(subrule)
    }
    
    @IBAction func editTime(sender: UIButton) {
        if timeEditor == nil {
            timeEditor = TimeEditor(textfield: textfield)
            timeEditor.showFutureTimes = false
        }
        timeEditor.showPicker(sender.titleLabel!.text!) { (newTime) -> () in
            sender.titleLabel!.text! = newTime
            sender.setTitle(newTime, forState: UIControlState.Normal)
            self.save()
        }
    }
    
    @IBAction func toggleTimeOp() {
        subrule.op = subrule.op == TimeOp.AT ? TimeOp.BETWEEN : TimeOp.AT
        let isVisible = subrule.op == TimeOp.BETWEEN

        if (subrule.op == TimeOp.AT) {
            subrule.timeRange.max = subrule.timeRange.min
        }
        timeOp.setTitle(subrule.op.rawValue, forState: UIControlState.Normal)
        if subrule.op == TimeOp.AT {
            widthConstraint.constant = 170
        } else {
            widthConstraint.constant = 300
        }

        UIView.animateWithDuration(0.25) {
            self.toTime.alpha = isVisible ? 1.0 : 0.0
            self.andLabel.alpha = self.toTime.alpha
        }
    }
    
    func displayRule(subrule: SubRule) {
        if let rule = subrule as? TimeSubRule {
            self.subrule = rule
            timeOp.setTitle(rule.op.rawValue, forState: UIControlState.Normal)
            fromTime.setTitle(rule.timeRange.min, forState: UIControlState.Normal)
            toTime.setTitle(rule.timeRange.max, forState: UIControlState.Normal)
            toTime.alpha = (rule.op == TimeOp.AT) ? 0.0 : 1.0
            andLabel.alpha = (rule.op == TimeOp.AT) ? 0.0 : 1.0
            
            if rule.op == TimeOp.AT {
                widthConstraint.constant = 170
            } else {
                widthConstraint.constant = 300
            }

            layoutIfNeeded()
        }
    }
    
}