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
        let ruleTypes : [String:SubRule] = ["Time":TimeSubRule(),
            "Location":LocationSubRule(),
            "Temperature":TemperatureSubRule(),
            "Humidity":HumiditySubRule(),
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
        var insets = UIEdgeInsets(top: self.nav.navigationBar.bounds.height + UIApplication.sharedApplication().statusBarFrame.height, left: 0, bottom: toolbar.bounds.height, right: 0)
        tableView.contentInset = insets
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
        if proposedDestinationIndexPath.item < 2 {
            return NSIndexPath(forItem: 2, inSection: 0)
        }
        return proposedDestinationIndexPath
    }
    
    func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.item < 2 {
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
        
        if tableView.frame.width <= 320 {
            // animate the row size change for condition cells
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.item < count(editRule.subrules) && tableView.frame.width <= 320 {
            if editRule.subrules[indexPath.item] is ConditionSubRule && tableView.editing {
                return 106
            }
        }
        
        return 70
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
        editRule.subrules.append(rulePickerDataSource.getSubRule(ruleChosen))

        // todo, animate the add
        tableView.beginUpdates()
        tableView.insertRowsAtIndexPaths([NSIndexPath(forItem: count(editRule.subrules)-1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
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
        if let cell2 = cell as? SubRuleDisplaying {
            cell2.displayRule(subRule)
        }
        return cell
    }
    
    func lookupLocation(sender : UIButton, weatherLookup : ((name: String?, locId: String?, errMsg: String?) -> ()) -> ()) {
        let spinner = sender.superview?.viewWithTag(1) as! UIActivityIndicatorView
        let gpsButton = sender.superview?.viewWithTag(2) as! UIButton
        let zipButton = sender.superview?.viewWithTag(3) as! UIButton
        let searchBox = sender.superview?.viewWithTag(4) as! UITextField
        let cell = sender.superview?.superview! as! UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)
        
        spinner.startAnimating()
        gpsButton.enabled = false
        zipButton.enabled = false
        weatherLookup() { (name, locId, errMsg) -> () in
            dispatch_async(dispatch_get_main_queue()) {
                if let searchText = name {
                    let subRule = self.editRule.subrules[indexPath!.item] as! LocationSubRule
                    subRule.name = searchText
                    subRule.locId = locId!
                    searchBox.text = searchText
                }
                
                gpsButton.enabled = true
                zipButton.enabled = true
                spinner.stopAnimating()
                
                if let error = errMsg {
                    let av = UIAlertView(title: "Unable to lookup location", message: error, delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "Dismiss")
                    av.show()
                }
            }
        }
    }
    
    @IBAction func lookupGPS(sender : UIButton) {
        lookupLocation(sender, weatherLookup: weatherService.getLocationWithGPS)
    }
    
    @IBAction func lookupZip(sender : UIButton) {
        let searchBox = sender.superview?.viewWithTag(4) as! UITextField
        func weatherLookup(callback: (name: String?, locId: String?, errMsg: String?) -> ()) -> () {
            weatherService.getLocation(searchBox.text, completionHandler: callback)
        }
        lookupLocation(sender, weatherLookup: weatherLookup)
    }
    
    @IBAction func flipTempUnitsButton(sender : UIButton) {
        if let label = sender.titleLabel {
            switch label.text! {
                case "˚F":
                    sender.setTitle("˚C", forState: UIControlState.Normal)
            default:
                sender.setTitle("˚F", forState: UIControlState.Normal)
            }
        }
    }

    @IBAction func opButtonPushed(opButton: UIButton) {
        var l = CompOp.EQ
        switch CompOp(rawValue:opButton.titleLabel!.text!)! {
        case .LT: l = .LTE
        case .LTE: l = .GT
        case .GT: l = .GTE
        case .GTE: l = .EQ
        case .EQ: l = .LT
        default: l = .EQ
        }
        
        opButton.setTitle(l.rawValue, forState: UIControlState.Normal)
    }
    
    @IBAction func flipSpeedUnitsButton(sender : UIButton) {
        if let label = sender.titleLabel {
            switch label.text! {
            case SpeedUnits.MPH.rawValue:
                label.text = SpeedUnits.KPH.rawValue
            case SpeedUnits.KPH.rawValue:
                label.text = SpeedUnits.MPH.rawValue
            default:
                label.text = SpeedUnits.MPH.rawValue
            }
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let newVal = (textField.text as NSString).stringByReplacingCharactersInRange(range, withString: string)
        return newVal.match("^-?\\d*\\.?\\d*$")
    }
}