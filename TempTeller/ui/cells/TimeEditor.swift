//
//  TimeEditorDataSource.swift
//  TempTeller
//
//  Created by Ben La Monica on 8/21/15.
//  Copyright (c) 2015 Benjamin Alan La Monica. All rights reserved.
//

import Foundation
import UIKit

let DAYS = ["Today", "Tomorrow", "2 days", "3 days", "4 days", "5 days", "6 days", "7 days"]

class TimeEditorDataSource : NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var showFutureTimes = true

    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        var comp = component
        if showFutureTimes && comp == 0 {
            return DAYS[row]
        } else {
            comp--
        }
        
        switch comp {
        case 0: return NSString(format: "%02d", row+1) as String
        case 1: return ":"
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
        return showFutureTimes ? 5 : 4
    }
    
    // returns the # of rows in each component..
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var comp = component
        if showFutureTimes && comp == 0 {
            return 8
        }
        comp--
        switch comp {
        case 0: return 12
        case 1: return 1
        case 2: return 60 / 5
        case 3: return 2
        default: return 0
        }
    }

}

class TimeEditor : NSObject {
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
        if time =~ "\\d+:\\d+ (AM|PM)" {
            let daySplit = time.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: "@"))
            var timeMinusDays = daySplit[0]
            if count(daySplit) > 1 {
                timeMinusDays = daySplit[1].trim()
            }
            let timeSplit = timeMinusDays.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: ": "))
            let hours = timeSplit[0].toInt() ?? 0
            let minutes = (timeSplit[1].toInt() ?? 0) / 5
            let ampm = timeSplit[2] == "PM" ? 1 : 0
            var idx = 0
            if showFutureTimes {
                if count(daySplit) > 1 {
                    picker.selectRow(find(DAYS, daySplit[0].trim()  ) ?? 0, inComponent: 0, animated: false)
                } else {
                    picker.selectRow(0, inComponent: 0, animated: false)
                }
                idx = 1
            }
            picker.selectRow(hours-1, inComponent: idx, animated: false)
            picker.selectRow(minutes, inComponent: idx+2, animated: false)
            picker.selectRow(ampm, inComponent: idx+3, animated: false)
            textfield.becomeFirstResponder()
        } else {
            NSLog("Invalid time format received: \(time)")
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
        picker.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
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
        
        let doneButton = UIBarButtonItem(title: "Set Time", style: UIBarButtonItemStyle.Done, target: self, action: "pickTime")
        let spacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: "dismissPicker")
        doneButton.tintColor = UIColor.whiteColor()
        cancelButton.tintColor = UIColor.whiteColor()
        pickerToolbar.setItems([cancelButton, spacer, doneButton], animated: false)
        textfield.inputView = picker
        textfield.inputAccessoryView = pickerToolbar
        self.textfield = textfield
    }

    
}
