//
//  OpEditor.swift
//  TempTeller
//
//  Created by Ben La Monica on 9/8/15.
//  Copyright (c) 2015 Benjamin Alan La Monica. All rights reserved.
//

import Foundation
import UIKit

class OpEditor : NSObject, UIPickerViewDelegate, UIPickerViewDataSource {

    let ops = [CompOp.LT, CompOp.LTE, CompOp.GT, CompOp.GTE, CompOp.EQ];
    var textfield : UITextField!
    var picker : UIPickerView!
    var pickerToolbar : UIToolbar!
    var callback : ((CompOp) -> ())!
    
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return ops.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return ops[row].rawValue
    }
    
    func getOp() -> CompOp {
        return ops[picker.selectedRowInComponent(0)]
    }
    
    func dismissPicker() {
        textfield.resignFirstResponder()
    }

    func pickOp() {
        dismissPicker()
        callback(getOp())
    }

    func showOp(op: CompOp, callback: ((CompOp) -> ())) {
        self.callback = callback
        picker.selectRow(ops.indexOf(op) ?? 0, inComponent: 0, animated: false)
        textfield.becomeFirstResponder()
    }
    
    init(textfield: UITextField) {
        // create a UIPicker view as a custom keyboard view
        picker = UIPickerView()
        picker.sizeToFit()
        picker.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        picker.showsSelectionIndicator = true
        
        // add a done button
        pickerToolbar = UIToolbar()
        pickerToolbar.barStyle = UIBarStyle.Black
        pickerToolbar.translucent = true
        pickerToolbar.tintColor = nil
        pickerToolbar.sizeToFit()
        
        super.init()

        picker.delegate = self
        picker.dataSource = self

        let doneButton = UIBarButtonItem(title: "Set Operation", style: UIBarButtonItemStyle.Done, target: self, action: "pickOp")
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