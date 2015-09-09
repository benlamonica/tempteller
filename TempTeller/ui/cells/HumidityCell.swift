//
//  HumidityCell.swift
//  TempTeller
//
//  Created by Ben La Monica on 7/20/15.
//  Copyright (c) 2015 Benjamin Alan La Monica. All rights reserved.
//

import UIKit

class HumidityCell : UITableViewCell, SubRuleDisplaying {
    @IBOutlet var humidity : UITextField!
    @IBOutlet var opButton : UIButton!
    @IBOutlet var pickerTarget : UITextField!
    var opEditor : OpEditor!
    var subrule : HumiditySubRule!
    
    func displayRule(subrule : SubRule) {
        if let rule = subrule as? HumiditySubRule {
            self.subrule = rule
            humidity.text = NSString(format: "%.0f", rule.value) as String
            opButton.setTitle(rule.op.rawValue, forState: UIControlState.Normal)
        }
    }
    
    @IBAction func pickOp() {
        if opEditor == nil {
            opEditor = OpEditor(textfield: pickerTarget)
        }
        
        opEditor.showOp(subrule.op) { (op) -> () in
            self.subrule.op = op
            self.opButton.setTitle(op.rawValue, forState: UIControlState.Normal)
        }
    }
    
    @IBAction func saveRule() {
        if let rule = subrule {
            rule.value = humidity.text.toDouble()
            displayRule(rule)
        }
    }
}
