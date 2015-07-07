//
//  MessageCell.swift
//  TempTeller
//
//  Created by Ben La Monica on 6/3/15.
//  Copyright (c) 2015 Benjamin Alan La Monica. All rights reserved.
//

import UIKit

class MessageCell : UITableViewCell, SubRuleDisplaying {
    @IBOutlet var message : UITextField!
    var subrule : MessageSubRule!
    
    func displayRule(subrule : SubRule) {
        if let rule = subrule as? MessageSubRule {
            self.subrule = rule
            message.text = rule.message
        }
    }
    
    @IBAction func saveRule() {
        if let rule = subrule {
            rule.message = message.text
        }
    }
}