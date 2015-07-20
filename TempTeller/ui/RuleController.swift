//
//  ViewController.swift
//  TempTeller
//
//  Created by Ben La Monica on 5/19/15.
//  Copyright (c) 2015 Benjamin Alan La Monica. All rights reserved.
//

import UIKit

class RuleController: UITableViewController, UITableViewDataSource, UITableViewDelegate {

    var data : [Rule] = []
    let settings = NSUserDefaults.standardUserDefaults()

    func stylizeTableViewHeader() {
        var nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.Black
        nav?.tintColor = UIColor.whiteColor()
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
        label.textAlignment = .Center
        let text = NSMutableAttributedString (
            string: "TempTeller",
            attributes: [NSForegroundColorAttributeName: UIColor.orangeColor(), NSFontAttributeName: UIFont.boldSystemFontOfSize(20.0)])
        
        text.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 0x9F/255.0, green: 0xD9/255.0, blue: 0xE7/255.0, alpha: 1.0), range: NSRange(location: 4,length: 6))
        label.attributedText = text
        navigationItem.titleView = label
    }
    
    func loadRules() {
        if let rulesJson = settings.valueForKey("rules") as? String {
            let json = JSON(data: rulesJson)
            for rule in json.arrayValue {
                data.append(Rule(json: rule))
            }
        }
    }
    
    func saveRules() {
        let model = data.map({$0.toDict()})
        var err = NSErrorPointer()
        if let json = NSJSONSerialization.dataWithJSONObject(model, options: nil, error: err) {
            let jsonString = NSString(data: json, encoding: NSUTF8StringEncoding) as! String
            NSLog(jsonString)
            settings.setValue(jsonString, forKey: "rules")
        } else {
            NSLog("Failed to serialize to JSON: \(err)")
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stylizeTableViewHeader()
        loadRules()
        registerForNotications()
    }

    func registerForNotications() {
        // only register if we have rules, otherwise, register after the first rule is created
        if count(data) > 0 {
            // see https://thatthinginswift.com/remote-notifications/
            let app = UIApplication.sharedApplication()
            let settings = app.currentUserNotificationSettings()
            let alertsEnabled = (settings.types & UIUserNotificationType.Alert) != nil
            
            if (!alertsEnabled) {
                let settings = UIUserNotificationSettings(forTypes: .Alert, categories: nil)
                UIApplication.sharedApplication().registerUserNotificationSettings(settings)
            }
        }
    }
    
    @IBAction func toggleRuleEnable(sender: UISwitch) {
        if let path = tableView.indexPathForCell((sender.superview?.superview as? UITableViewCell)!) {
            data[path.item].isEnabled = sender.on
            saveRules()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        // make sure any added rules were saved instead of cancelled.
        data = data.filter({$0.saved == true})
        tableView.reloadData()
        saveRules()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("RuleCell", forIndexPath: indexPath) as! RuleCell
        cell.rule = data[indexPath.item]
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            tableView.beginUpdates()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            data.removeAtIndex(indexPath.item)
            tableView.endUpdates()
            saveRules()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let segueId = segue.identifier {
            switch segueId {
                case "EditRule":
                    if let cell = sender as? RuleCell {
                        let controller = (segue.destinationViewController as! RuleDetailController)
                        controller.rule = cell.rule
                        controller.nav = navigationController
                    }
                case "AddRule":
                    let controller = (segue.destinationViewController as! RuleDetailController)
                    controller.nav = navigationController
                    let rule = Rule()
                    rule.saved = false
                    controller.rule = rule
                    data.append(rule)
            case "ShowConfig":
                    let controller = segue.destinationViewController as! SettingsViewController
                    controller.nav = navigationController
                default:
                    NSLog("Unknown Segue")
                
            }
        }
    }
    
}

