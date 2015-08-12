//
//  ConditionCell.swift
//  TempTeller
//
//  Created by Ben La Monica on 6/3/15.
//  Copyright (c) 2015 Benjamin Alan La Monica. All rights reserved.
//

import UIKit

class ConditionCell : UITableViewCell, SubRuleDisplaying {
    @IBOutlet var sunny : UIButton!
    @IBOutlet var cloudy : UIButton!
    @IBOutlet var rainy : UIButton!
    @IBOutlet var lightning : UIButton!
    @IBOutlet var wind : UIButton!
    @IBOutlet var snow : UIButton!
    
    var tagMap = [1:Condition.Sunny, 2:Condition.Cloudy, 3:Condition.Rainy, 4:Condition.Snow, 5:Condition.Lightning, 6:Condition.Wind]
    
    var subrule : ConditionSubRule!
    
    func showSelection(button : UIButton, selected: Bool) {
        button.backgroundColor = selected ? UIColor.groupTableViewBackgroundColor() : UIColor.clearColor()
    }
    
    func displayRule(subrule : SubRule) {
        if let rule = subrule as? ConditionSubRule {
            self.subrule = rule
            for (k,v) in rule.conditions {
                switch k {
                case Condition.Sunny :
                    showSelection(sunny, selected: v)
                case Condition.Wind :
                    showSelection(wind, selected: v)
                case Condition.Rainy :
                    showSelection(rainy, selected: v)
                case Condition.Lightning :
                    showSelection(lightning, selected: v)
                case Condition.Snow :
                    showSelection(snow, selected: v)
                case Condition.Cloudy :
                    showSelection(cloudy, selected: v)
                }
            }
        }
    }
    
    @IBAction func toggleCondition(button : UIButton) {
        if let condition = tagMap[button.tag] {
            if let val = subrule.conditions[condition] {
                subrule.conditions[condition] = !val
            } else {
                subrule.conditions[condition] = true
            }
            showSelection(button, selected: subrule.conditions[condition]!)
        }
        
    }
    
    @IBAction func saveRule() {
        subrule.conditions[Condition.Sunny] = sunny.selected
        subrule.conditions[Condition.Cloudy] = cloudy.selected
        subrule.conditions[Condition.Lightning] = lightning.selected
        subrule.conditions[Condition.Wind] = wind.selected
        subrule.conditions[Condition.Snow] = snow.selected
        subrule.conditions[Condition.Rainy] = rainy.selected
    }
}