//
//  RuleDetailController.swift
//  TempTeller
//
//  Created by Ben La Monica on 5/22/15.
//  Copyright (c) 2015 Benjamin Alan La Monica. All rights reserved.
//

import Foundation
import UIKit

class RuleDetailController : UIViewController, UITableViewDelegate, UITextFieldDelegate, UITableViewDataSource {
    @IBOutlet var tableView : UITableView!
    @IBOutlet var reorderBtn : UIBarButtonItem!
    let swapImg = UIImage(named: "swap")
    var nav : UINavigationController!
    @IBOutlet var toolbar : UIToolbar!
    var rule : Rule! {
        didSet {
            editRule = rule.copy() as? Rule
        }
    }
    var editRule : Rule!
    var actionSheet : UIActionSheet?
    let weatherService = WeatherService()
    var picker : UIPickerView!
    var activeTextField : UITextField?
    var pickerToolbar : UIToolbar!
    

    class RulePickerDataSource : NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
        let ruleTypes : [String:SubRule] = ["Location":LocationSubRule(),
            "Temperature":TemperatureSubRule(),
            "Humidity":HumiditySubRule(),
            "Wind":WindSpeedSubRule(),
            "Condition":ConditionSubRule(),
            "Forecast Condition":ForecastConditionSubRule(),
            "Forecast Temperature":ForecastTempSubRule()]
        
        let ruleKeys : [String]
        
        override init() {
            ruleKeys = ruleTypes.keys.array.sorted(<)
        }

        func getSubRule(subruleIdx: Int) -> SubRule {
            let subrule = ruleTypes[ruleKeys[subruleIdx]]!
            return subrule.copy() as! SubRule
        }
        
        func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
            return ruleKeys[row]
        }
        
        // returns the number of 'columns' to display.
        func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
            return 1
        }
        
        // returns the # of rows in each component..
        func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return count(ruleKeys)
        }
    }
    let rulePickerDataSource = RulePickerDataSource()

    func setupPicker() {
        // create a UIPicker view as a custom keyboard view
        picker = UIPickerView()
        picker.sizeToFit()
        picker.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        picker.delegate = rulePickerDataSource
        picker.dataSource = rulePickerDataSource
        picker.showsSelectionIndicator = true
        
        // add a done button
        pickerToolbar = UIToolbar()
        pickerToolbar.barStyle = UIBarStyle.Black
        pickerToolbar.translucent = true
        pickerToolbar.tintColor = nil
        pickerToolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: "pickSubRule")
        let spacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: "dismissPicker")
        doneButton.tintColor = UIColor.whiteColor()
        cancelButton.tintColor = UIColor.whiteColor()
        pickerToolbar.setItems([cancelButton, spacer, doneButton], animated: false)
    }
    
    override func viewDidLoad() {
        setupPicker()
        resetInsets()
    }
    
    @IBAction func save(sender: AnyObject?) {
        if let ruleToSave = editRule {
            rule.subrules = ruleToSave.subrules
            rule.saved = true
        }
        nav.popViewControllerAnimated(true)
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        // prevent the message and location
        if indexPath.item < 2 {
            return UITableViewCellEditingStyle.None
        }
        if (!tableView.editing) {
            return UITableViewCellEditingStyle.Delete
        } else {
            return UITableViewCellEditingStyle.None
        }
    }
    
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        var movingRule = editRule.subrules[sourceIndexPath.item]

        if sourceIndexPath.item > destinationIndexPath.item {
            editRule.subrules.removeAtIndex(sourceIndexPath.item)
            editRule.subrules.insert(movingRule, atIndex: destinationIndexPath.item)
        } else {
            editRule.subrules.insert(movingRule, atIndex: destinationIndexPath.item)
            editRule.subrules.removeAtIndex(sourceIndexPath.item)
        }

        tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, targetIndexPathForMoveFromRowAtIndexPath sourceIndexPath: NSIndexPath, toProposedIndexPath proposedDestinationIndexPath: NSIndexPath) -> NSIndexPath {
        if proposedDestinationIndexPath.item < 3 {
            return NSIndexPath(forItem: 3, inSection: 0)
        }
        return proposedDestinationIndexPath
    }
    
    func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.item < 3 {
            return false
        }
        return true
    }
    
    @IBAction func enableRowSwap() {
        tableView.setEditing(!tableView.editing, animated: true)
        if (tableView.editing) {
            reorderBtn.image = nil
            reorderBtn.title = "Done"
        } else {
            reorderBtn.title = nil
            reorderBtn.image = swapImg
        }
        
        tableView.reloadData()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func adjustInsetsToShowKeybaord() {
        tableView.contentInset = getInsets(additionalBottom: 225)
    }

    func getInsets(additionalBottom: CGFloat = 0) -> UIEdgeInsets {
        var insets = UIEdgeInsets(top: self.nav.navigationBar.bounds.height + UIApplication.sharedApplication().statusBarFrame.height, left: 0, bottom: toolbar.bounds.height + additionalBottom, right: 0)
        return insets
    }
    
    func resetInsets() {
        tableView.contentInset = getInsets()
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var size : CGFloat = 70

        if indexPath.item < editRule.subrules.count {
            let subrule = editRule.subrules[indexPath.item]
            if let condition = subrule as? ConditionSubRule {
                size = 116
            }
        }
        
        return size
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            tableView.beginUpdates()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            editRule.subrules.removeAtIndex(indexPath.item)
            tableView.endUpdates()
        }
    }

    
    @IBAction func addSubRule() {
        let textfield = view.viewWithTag(100) as! UITextField
        textfield.inputView = picker
        textfield.inputAccessoryView = pickerToolbar
        textfield.becomeFirstResponder()
        activeTextField = textfield
    }

    func pickSubRule() {
        let ruleChosen = picker.selectedRowInComponent(0)
        let ds = rulePickerDataSource
        let newSubrule = rulePickerDataSource.getSubRule(ruleChosen)
        
        editRule.subrules.append(newSubrule)
        let index = count(editRule.subrules)-1

        // todo, animate the add
        tableView.beginUpdates()
        tableView.insertRowsAtIndexPaths([NSIndexPath(forItem: index, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
        tableView.endUpdates()
        
        dismissPicker()
    }
    
    func dismissPicker() {
        if let textfield = activeTextField {
            textfield.resignFirstResponder()
            textfield.hidden = true
        }
    }
    

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return count(editRule.subrules)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let subRule = editRule.subrules[indexPath.item]
        let className = subRule.classForCoder.description()
        let cellType = className.substringFromIndex(find(className,".")!.successor())
        let cell = tableView.dequeueReusableCellWithIdentifier(cellType, forIndexPath: indexPath) as! UITableViewCell

        // inject the weather service into the location cell so that it can do location lookup
        if let locCell = cell as? LocationCell {
            locCell.weatherService = weatherService
        }
        
        if let subCell = cell as? SubRuleDisplaying {
            subCell.displayRule(subRule)
        }
        
        return cell
    }
    
}