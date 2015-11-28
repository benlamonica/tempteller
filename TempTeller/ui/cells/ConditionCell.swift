//
//  ConditionCell.swift
//  TempTeller
//
//  Created by Ben La Monica on 6/3/15.
//  Copyright (c) 2015 Benjamin Alan La Monica. All rights reserved.
//

import UIKit

class ConditionCell : UITableViewCell, SubRuleDisplaying, UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet var buttons : UICollectionView!
    @IBOutlet var opButton : UIButton!
    @IBOutlet var label : UILabel!
    
    var tagMap : [Int:Condition] = [:]
    var conditionMap : [Condition:Int] = [:]
    
    var subrule : ConditionSubRule!

    func addTag(tag: Int, condition: Condition) {
        tagMap[tag] = condition
        conditionMap[condition] = tag
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addTag(1, condition: Condition.Sunny)
        addTag(2, condition: Condition.Cloudy)
        addTag(3, condition: Condition.Rainy)
        addTag(4, condition: Condition.Foggy)
        addTag(5, condition: Condition.Snowy)
        addTag(6, condition: Condition.Windy)
    }
    
    func showSelection(weatherButton : UIButton?, selected: Bool) {
        if let button = weatherButton {
            button.backgroundColor = selected ? UIColor.groupTableViewBackgroundColor() : UIColor.clearColor()
        }
    }
    
    func displayRule(subrule : SubRule) {
        if let rule = subrule as? ConditionSubRule {
            self.subrule = rule
            
            // clear all button states
            for tag in tagMap.keys {
                showSelection(buttons.viewWithTag(tag) as? UIButton, selected: false)
            }
            
            for (k,v) in rule.conditions {
                showSelection(buttons.viewWithTag(conditionMap[k]!) as? UIButton, selected: v)
            }
            
            
            opButton.setTitle(rule.op.rawValue, forState: UIControlState.Normal)
            updateLabel()
        }
    }
    
    @IBAction func toggleOp(button : UIButton) {
        let currentOp = BooleanOp(rawValue: button.titleLabel!.text!)!
        let newOp = currentOp == BooleanOp.IS_NOT ? BooleanOp.IS : BooleanOp.IS_NOT
        button.setTitle(newOp.rawValue, forState: UIControlState.Normal)
        subrule.op = newOp
        updateLabel()
    }
    
    @IBAction func toggleCondition(button : UIButton) {
        if let condition = tagMap[button.tag] {
            let val : Bool = subrule.conditions[condition] ?? false
            showSelection(button, selected: !val)
            if (!val) {
                subrule.conditions[condition] = true
            } else {
                subrule.conditions.removeValueForKey(condition)
            }
            
            updateLabel()
            
            var view = superview
            
            while (view != nil && !view!.isKindOfClass(UITableView)) {
                view = view!.superview
            }

            if let tableView = view as? UITableView {
                tableView.reloadData()
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tagMap.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let tag = indexPath.item+1
        var cell : UICollectionViewCell
        var condition = Condition.Sunny
        if let c = tagMap[tag]  { // add 1 to the indexPath, because our tags start with 1, not 0
            cell = collectionView.dequeueReusableCellWithReuseIdentifier(c.rawValue, forIndexPath: indexPath) 
            condition = c
        } else {
            cell = collectionView.dequeueReusableCellWithReuseIdentifier(Condition.Sunny.rawValue, forIndexPath: indexPath) 
        }
        
        if subrule != nil {
            if let button = cell.viewWithTag(tag) as? UIButton {
                showSelection(button, selected: subrule.conditions[condition] == true)
            }
        }

        return cell

    }
    
    func conditionText() -> String {
        let conditions = subrule.conditions.keys.sort({self.conditionMap[$0] < self.conditionMap[$1]}).map {$0.rawValue}
        var condition = ""
        
        switch conditions.count {
        case 0: condition = ""
        case 1: condition = conditions[0]
        case 2: condition = conditions.joinWithSeparator(" or ")
        default: condition = "\(conditions[0..<conditions.count-1].joinWithSeparator(", ")) or \(conditions[conditions.count-1])"
        }
        
        return condition
    }
    
    func updateLabel() {
        
        label.text = "and if the current condition \(subrule.op.rawValue) \(conditionText())"
    }

}