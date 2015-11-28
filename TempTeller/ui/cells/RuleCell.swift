//
//  RuleCell.swift
//  TempTeller
//
//  Created by Ben La Monica on 6/9/15.
//  Copyright (c) 2015 Benjamin Alan La Monica. All rights reserved.
//

import UIKit

class RuleCell : UITableViewCell {
    var rule : Rule {
        didSet {
            isEnabled.setOn(rule.enabled, animated: false)
            message.text = rule.message
        }
    }
    @IBOutlet var isEnabled : UISwitch!
    @IBOutlet var message : UILabel!
    @IBOutlet var temp : UILabel!
    @IBOutlet var humidity : UILabel!
    @IBOutlet var UITextime : UILabel!
    
    @IBAction func update() {
        rule.enabled = isEnabled.on
    }
    
    required init?(coder aDecoder: NSCoder) {
        rule = Rule()
        super.init(coder: aDecoder)
    }
}