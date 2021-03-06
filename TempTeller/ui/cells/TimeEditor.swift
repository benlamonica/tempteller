//
//  TimeEditorDataSource.swift
//  TempTeller
//
//  Created by Ben La Monica on 8/21/15.
//  Copyright (c) 2015 Benjamin Alan La Monica. All rights reserved.
//

import Foundation
import UIKit
import XCGLogger

let DAYS = ["Today", "Tomorrow", "2 days", "3 days", "4 days", "5 days", "6 days", "7 days"]
let NUM_HOURS = 12
let NUM_AMPM = 2

class TimeEditorDataSource : NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var showFutureTimes = true
    var showMinutes = true

    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var comp = component
        if showFutureTimes {
            if comp == 0 {
                return DAYS[row]
            } else {
                comp -= 1
            }
        }
        
        switch comp {
        case 0: return NSString(format: "%d", row+1) as String
        case 1: return showMinutes ? ":" : (row == 0 ? "AM" : "PM")
        case 2: return NSString(format: "%02d", row*5) as String
        case 3: return row == 0 ? "AM" : "PM"
        default: return ""
        }
    }
    
    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        if showFutureTimes {
            switch component {
            case 0: return 125
            case 2: return 25
            default: return 50
            }
        } else {
            return 50
        }
    }
    
    // returns the number of 'columns' to display.
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 5 - (showFutureTimes ? 0 : 1) - (showMinutes ? 0 : 2)
    }
    
    // returns the # of rows in each component..
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var comp = component
        if showFutureTimes {
            if component == 0 {
                return DAYS.count
            } else {
                comp -= 1
            }
        }

        switch comp {
        case 0: return NUM_HOURS
        case 1: return showMinutes ? 1 : NUM_AMPM
        case 2: return 60 / 5
        case 3: return 2
        default: return 0
        }
    }

}

class TimeEditor : NSObject {
    let log = XCGLogger.defaultInstance()
    var textfield : UITextField!
    var picker : UIPickerView!
    var pickerToolbar : UIToolbar!
    var callback : ((String) -> ())!
    let ds = TimeEditorDataSource()
    var showFutureTimes : Bool = true {
        willSet(newVal) {
            ds.showFutureTimes = newVal
        }
    }
    var showMinutes : Bool = true {
        willSet(newVal) {
            ds.showFutureTimes = newVal
        }
    }
    
    func dismissPicker() {
        textfield.resignFirstResponder()
    }
 
    func getTime() -> String {
        var days = ""
        var idx = 0
        if showFutureTimes {
            days = "\(DAYS[picker.selectedRowInComponent(0)]) @ "
            idx = 1
        }
        let hours = NSString(format: "%02d", picker.selectedRowInComponent(idx) + 1)
        let minutes = NSString(format: "%02d", picker.selectedRowInComponent(idx+2) * 5)
        let ampm = picker.selectedRowInComponent(idx+3) == 0 ? "AM" : "PM"
        
        return "\(days)\(hours):\(minutes) \(ampm)"
    }
    
    func pickTime() {
        dismissPicker()
        callback(getTime())
    }

    func setTime(time: String) {
        if time =~ "\\d+:\\d+? (AM|PM)" {
            let daySplit = time.split("@")
            var timeMinusDays = daySplit[0]
            if daySplit.count > 1 {
                timeMinusDays = daySplit[1].trim()
            }
            let timeSplit = timeMinusDays.split(": ")
            let hours = Int(timeSplit[0]) ?? 0
            let minutes = (Int(timeSplit[1]) ?? 0) / 5
            let ampm = timeSplit[2] == "PM" ? 1 : 0
            var idx = 0
            if showFutureTimes {
                if daySplit.count > 1 {
                    picker.selectRow(DAYS.indexOf(daySplit[0].trim()  ) ?? 0, inComponent: 0, animated: false)
                } else {
                    picker.selectRow(0, inComponent: 0, animated: false)
                }
                idx = 1
            }
            picker.selectRow(hours-1, inComponent: idx, animated: false)
            if showMinutes {
                picker.selectRow(minutes, inComponent: idx+2, animated: false)
                picker.selectRow(ampm, inComponent: idx+3, animated: false)
            } else {
                picker.selectRow(ampm, inComponent: idx+1, animated: false)
            }
            textfield.becomeFirstResponder()
        } else {
            log.warning("Invalid time format received: \(time)")
        }
    }
    
    func showPicker(time: String, callback: (String)->()) {
        self.callback = callback
        setTime(time)
    }
    
    init(textfield: UITextField) {
        // create a UIPicker view as a custom keyboard view
        picker = UIPickerView()
        picker.sizeToFit()
        picker.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        picker.delegate = ds
        picker.dataSource = ds
        picker.showsSelectionIndicator = true

        // add a done button
        pickerToolbar = UIToolbar()
        pickerToolbar.barStyle = UIBarStyle.Black
        pickerToolbar.translucent = true
        pickerToolbar.tintColor = nil
        pickerToolbar.sizeToFit()
        
        super.init()
        
        let doneButton = UIBarButtonItem(title: "Set Time", style: UIBarButtonItemStyle.Done, target: self, action: #selector(pickTime))
        let spacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(dismissPicker))
        doneButton.tintColor = UIColor.whiteColor()
        cancelButton.tintColor = UIColor.whiteColor()
        pickerToolbar.setItems([cancelButton, spacer, doneButton], animated: false)
        textfield.inputView = picker
        textfield.inputAccessoryView = pickerToolbar
        self.textfield = textfield
    }

    
}
