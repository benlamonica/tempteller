//
//  RuleDetailController.swift
//  TempTeller
//
//  Created by Ben La Monica on 5/22/15.
//  Copyright (c) 2015 Benjamin Alan La Monica. All rights reserved.
//

import Foundation
import UIKit

class RuleDetailController : UIViewController, UITextFieldDelegate {
    @IBOutlet var message : UITextField!
    @IBOutlet var minTemp : UITextField!
    @IBOutlet var maxTemp : UITextField!
    @IBOutlet var minHumidity : UITextField!
    @IBOutlet var maxHumidity : UITextField!
    @IBOutlet var minTime : UITextField!
    @IBOutlet var maxTime : UITextField!
    @IBOutlet var zipCode : UITextField!
    @IBOutlet var location : UILabel!
    var nav : UINavigationController!
    var rule : Rule!
    var resolvedLocation : Location!
    
    override func viewDidLoad() {
        minTemp.delegate = self
        maxTemp.delegate = self
        minHumidity.delegate = self
        maxHumidity.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        resolvedLocation = rule.location
        message.text = rule.message
        minTemp.text = rule.tempRange.min.format()
        maxTemp.text = rule.tempRange.max.format()
        minHumidity.text = rule.humidityRange.min.format()
        maxHumidity.text = rule.humidityRange.max.format()
        minTime.text = String(rule.timeRange.startIndex)
        maxTime.text = String(rule.timeRange.endIndex)
        if let loc = rule.location {
            zipCode.text = loc.zip
        }
    }
    
    @IBAction func save() {
        rule.message = message.text
        rule.tempRange.min = minTemp.text.toDouble()
        rule.tempRange.max = maxTemp.text.toDouble()
        rule.humidityRange.min = minHumidity.text.toDouble()
        rule.humidityRange.max = maxHumidity.text.toDouble()
        rule.timeRange.startIndex = minTime.text.toInt()!
        rule.timeRange.endIndex = maxTime.text.toInt()!

        rule.location = resolvedLocation
        
        nav.popViewControllerAnimated(true)
    }

    func textFieldDidEndEditing(textField: UITextField) {
        var minTxt : UITextField!
        var maxTxt : UITextField!
        var min : Double?
        var max : Double?
        var minDefault : String!
        var maxDefault : String!
        
        if (textField === minHumidity || textField === maxHumidity) {
            minTxt = minHumidity
            maxTxt = maxHumidity
            minDefault = "0"
            maxDefault = "0"
        } else if (textField === minTemp || textField === maxTemp) {
            minTxt = minTemp
            maxTxt = maxTemp
            minDefault = "70"
            maxDefault = "70"
        } else if (textField === minTime || textField === maxTime) {
            minTxt == minTime
            maxTxt == maxTime
            minDefault = ""
            maxDefault = ""
        } else {
            // do nothing, we don't recognize these text fields
            return
        }

        min = (minTxt.text as NSString).doubleValue
        max = (maxTxt.text as NSString).doubleValue

        if min == nil {
            min = max
        }
        
        if max == nil {
            min = max
        }
        
        if min > max {
            var temp = max
            max = min
            min = temp
        }

        if min == nil {
            minTxt.text = minDefault
        } else {
            minTxt.text = min!.format()
        }
        
        if max == nil {
            maxTxt.text = maxDefault
        } else {
            maxTxt.text = max!.format()
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let newVal = (textField.text as NSString).stringByReplacingCharactersInRange(range, withString: string)
        return newVal.match("^-?\\d*\\.?\\d*$")
    }
}