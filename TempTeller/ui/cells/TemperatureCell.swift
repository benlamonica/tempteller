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
    @IBOutlet var pickerTarget : UITextField!
    var opEditor : OpEditor!
    
    var subrule : TemperatureSubRule!
    
    @IBAction func flipTempUnitsButton(sender : UIButton) {
        if let label = sender.titleLabel {
            switch label.text! {
            case "˚F":
                subrule.isFarenheit = false
                subrule.value = (subrule.value - 32) * (5.0/9.0)
                displayRule(subrule)
            default:
                subrule.isFarenheit = true
                subrule.value = (subrule.value * (9.0/5.0)) + 32
                displayRule(subrule)
            }
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

    func displayRule(subrule : SubRule) {
        if let rule = subrule as? TemperatureSubRule {
            self.subrule = rule
            temperature.text = NSString(format: "%.1f", rule.value) as String
            unitButton.setTitle(rule.isFarenheit ? "˚F" : "˚C", forState: UIControlState.Normal)
            opButton.setTitle(rule.op.rawValue, forState: UIControlState.Normal)
        }
    }
    
    @IBAction func saveRule() {
        subrule.value = temperature.text!.toDouble()
    }
}
