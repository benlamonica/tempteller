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
        addTag(4, condition: Condition.Lightning)
        addTag(5, condition: Condition.Snow)
        addTag(6, condition: Condition.Wind)
    }
    
    func showSelection(weatherButton : UIButton?, selected: Bool) {
        if let button = weatherButton {
            button.backgroundColor = selected ? UIColor.groupTableViewBackgroundColor() : UIColor.clearColor()
        }
    }
    
    func displayRule(subrule : SubRule) {
        if let rule = subrule as? ConditionSubRule {
            self.subrule = rule
            
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
            cell = collectionView.dequeueReusableCellWithReuseIdentifier(c.rawValue, forIndexPath: indexPath) as! UICollectionViewCell
            condition = c
        } else {
            cell = collectionView.dequeueReusableCellWithReuseIdentifier(Condition.Sunny.rawValue, forIndexPath: indexPath) as! UICollectionViewCell
        }
        
        if let button = cell.viewWithTag(tag) as? UIButton {
            showSelection(button, selected: subrule.conditions[condition] == true)
        }

        return cell

    }
    
    func updateLabel() {
        let conditions = sorted(subrule.conditions.keys, {self.conditionMap[$0] < self.conditionMap[$1]}).map {$0.rawValue}
        let conditionStr = join(" or ", conditions)
        label.text = "Current Condition \(subrule.op.rawValue) \(conditionStr)"
    }

}