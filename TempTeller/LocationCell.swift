//
//  LocationCell.swift
//  TempTeller
//
//  Created by Ben La Monica on 6/3/15.
//  Copyright (c) 2015 Benjamin Alan La Monica. All rights reserved.
//

import UIKit

class LocationCell : UITableViewCell, SubRuleDisplaying {
    @IBOutlet var location : UITextField!
    var subrule : LocationSubRule!
    
    func displayRule(subrule : SubRule) {
        if let rule = subrule as? LocationSubRule {
            self.subrule = rule
            location.text = rule.location.name
        }
    }
    
    @IBAction func saveRule() {
        if let rule = subrule {
            rule.location.name = location.text
        }
    }

}
