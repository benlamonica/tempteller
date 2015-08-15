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
    
    var subrule : HumiditySubRule?
    
    func displayRule(subrule : SubRule) {
        if let rule = subrule as? HumiditySubRule {
            self.subrule = rule
            humidity.text = String("\(rule.value)")
            opButton.titleLabel?.text = rule.op.rawValue
        }
    }
    
    @IBAction func saveRule() {
        if let rule = subrule {
            rule.value = humidity.text.toDouble()
            rule.op = CompOp(rawValue: opButton.titleLabel!.text!)!
        }
    }
}
