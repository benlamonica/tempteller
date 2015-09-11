//
//  ForecastTemperatureCell.swift
//  TempTeller
//
//  Created by Ben La Monica on 9/11/15.
//  Copyright (c) 2015 Benjamin Alan La Monica. All rights reserved.
//

import Foundation
import UIKit

class ForecastTemperatureCell : TemperatureCell {
    @IBOutlet var atTime : UIButton!
    @IBOutlet var textfield: UITextField!
    var timeEditor : TimeEditor!
    var forecastSubrule : ForecastTempSubRule!
    
    @IBAction func editTime(sender: UIButton) {
        if timeEditor == nil {
            timeEditor = TimeEditor(textfield: textfield)
        }
        timeEditor.showPicker(sender.titleLabel!.text!) { (newTime) -> () in
            sender.titleLabel!.text! = newTime
            sender.setTitle(newTime, forState: UIControlState.Normal)
            self.forecastSubrule.forecastTime = newTime
        }
    }
    
    override func displayRule(subrule: SubRule) {
        forecastSubrule = subrule as! ForecastTempSubRule
        super.displayRule(subrule)
    }

}