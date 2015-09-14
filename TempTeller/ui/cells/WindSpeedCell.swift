//
//  HumidityCell.swift
//  TempTeller
//
//  Created by Ben La Monica on 7/20/15.
//  Copyright (c) 2015 Benjamin Alan La Monica. All rights reserved.
//

import UIKit

class WindSpeedCell : UITableViewCell, SubRuleDisplaying {
    @IBOutlet var windSpeed : UITextField!
    @IBOutlet var opButton : UIButton!
    @IBOutlet var unitButton : UIButton!
    @IBOutlet var pickerTarget : UITextField!
    
    var opEditor : OpEditor!
    var subrule : WindSpeedSubRule!
    
    @IBAction func pickOp() {
        if opEditor == nil {
            opEditor = OpEditor(textfield: pickerTarget)
        }
        opEditor.showOp(subrule.op) { (op) -> () in
            self.subrule.op = op
            self.opButton.setTitle(op.rawValue, forState: UIControlState.Normal)
        }
    }
    
    @IBAction func flipSpeedUnitsButton(sender : UIButton) {
        switch sender.titleLabel!.text! {
        case SpeedUnits.MPH.rawValue:
            sender.setTitle(SpeedUnits.KPH.rawValue, forState:UIControlState.Normal)
            subrule.units = SpeedUnits.KPH
        case SpeedUnits.KPH.rawValue:
            sender.setTitle(SpeedUnits.MPH.rawValue, forState:UIControlState.Normal)
            subrule.units = SpeedUnits.MPH
        default:
            sender.setTitle(SpeedUnits.MPH.rawValue, forState:UIControlState.Normal)
            subrule.units = SpeedUnits.MPH
        }
    }
    
    func displayRule(subrule : SubRule) {
        if let rule = subrule as? WindSpeedSubRule {
            self.subrule = rule
            windSpeed.text = String("\(rule.value)")
            opButton.titleLabel?.text = rule.op.rawValue
            unitButton.titleLabel?.text = rule.units.rawValue
        }
    }
    
    @IBAction
    func saveRule() {
        if let rule = subrule {
            rule.value = windSpeed.text.toDouble()
        }
    }
}
