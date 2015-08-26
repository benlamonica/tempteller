//
//  TimeEditorDataSource.swift
//  TempTeller
//
//  Created by Ben La Monica on 8/21/15.
//  Copyright (c) 2015 Benjamin Alan La Monica. All rights reserved.
//

import Foundation
import UIKit

class TimeEditorDataSource : NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        switch component {
        case 0: return NSString(format: "%02d", row+1) as String
        case 1: return ":"
        case 2: return NSString(format: "%02d", row*5) as String
        case 3: return row == 0 ? "AM" : "PM"
        default: return ""
        }
    }
    
    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 50
    }
    
    // returns the number of 'columns' to display.
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 4
    }
    
    // returns the # of rows in each component..
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
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
    
    func dismissPicker() {
        textfield.resignFirstResponder()
    }
 
    func getTime() -> String {
        let hours = NSString(format: "%02d", picker.selectedRowInComponent(0) + 1)
        let minutes = NSString(format: "%02d", picker.selectedRowInComponent(2) * 5)
        let ampm = picker.selectedRowInComponent(3) == 0 ? "AM" : "PM"
        
        return "\(hours):\(minutes) \(ampm)"
    }
    
    func pickTime() {
        dismissPicker()
        callback(getTime())
    }

    func setTime(time: String) {
        if time =~ "\\d+:\\d+ (AM|PM)" {
            let timeSplit = time.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: ": "))
            let hours = timeSplit[0].toInt() ?? 0
            let minutes = (timeSplit[1].toInt() ?? 0) / 5
            let ampm = timeSplit[2] == "PM" ? 1 : 0
            picker.selectRow(hours-1, inComponent: 0, animated: false)
            picker.selectRow(minutes, inComponent: 2, animated: false)
            picker.selectRow(ampm, inComponent: 3, animated: false)
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
