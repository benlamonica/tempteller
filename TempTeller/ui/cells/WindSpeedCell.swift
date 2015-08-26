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
    
    var subrule : WindSpeedSubRule?
    
    @IBAction func flipSpeedUnitsButton(sender : UIButton) {
        if let label = sender.titleLabel {
            switch label.text! {
            case SpeedUnits.MPH.rawValue:
                label.text = SpeedUnits.KPH.rawValue
            case SpeedUnits.KPH.rawValue:
                label.text = SpeedUnits.MPH.rawValue
            default:
                label.text = SpeedUnits.MPH.rawValue
            }
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
    
    func saveRule() {
        if let rule = subrule {
            rule.value = windSpeed.text.toDouble()
            rule.op = CompOp(rawValue: opButton.titleLabel!.text!)!
            rule.units = SpeedUnits(rawValue: unitButton.titleLabel!.text!)!
        }
    }
}
