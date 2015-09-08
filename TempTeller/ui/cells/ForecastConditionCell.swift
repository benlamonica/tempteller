//
//  ForecastCondition.swift
//  TempTeller
//
//  Created by Ben La Monica on 8/19/15.
//  Copyright (c) 2015 Benjamin Alan La Monica. All rights reserved.
//

import Foundation
import UIKit

class ForecastConditionCell : ConditionCell {
    
    @IBOutlet var atTime : UIButton!
    @IBOutlet var textfield: UITextField!
    var timeEditor : TimeEditor!

    var forecastSubrule : ForecastConditionSubRule!
    
    override func displayRule(subrule : SubRule) {
        if let rule = subrule as? ForecastConditionSubRule {
            self.forecastSubrule = rule
            atTime.titleLabel!.text = rule.forecastTime
            atTime.setTitle(rule.forecastTime, forState: UIControlState.Normal)
        }
        super.displayRule(subrule)
    }

    @IBAction func editTime(sender: UIButton) {
        if timeEditor == nil {
            timeEditor = TimeEditor(textfield: textfield)
        }
        timeEditor.showPicker(sender.titleLabel!.text!) { (newTime) -> () in
            sender.titleLabel!.text! = newTime
            sender.setTitle(newTime, forState: UIControlState.Normal)
            self.forecastSubrule.forecastTime = newTime
            self.updateLabel()
        }
    }
    
    override func updateLabel() {
        let conditions = sorted(subrule.conditions.keys, {self.conditionMap[$0] < self.conditionMap[$1]}).map {$0.rawValue}
        let conditionStr = join(" or ", conditions)
        label.text = "and if \(forecastSubrule.forecastTime) the condition \(subrule.op.rawValue) \(conditionStr)"
    }
}