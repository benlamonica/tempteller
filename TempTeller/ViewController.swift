//
//  ViewController.swift
//  TempTeller
//
//  Created by Ben La Monica on 5/19/15.
//  Copyright (c) 2015 Benjamin Alan La Monica. All rights reserved.
//

import UIKit

class ViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate {

    var data : [Rule] = [Rule(), Rule(), Rule(), Rule(), Rule(), Rule(), Rule(), Rule(), Rule(), Rule(), Rule()]

    override func viewDidLoad() {
        super.viewDidLoad()
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

    override func viewWillAppear(animated: Bool) {
        tableView.reloadData()
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
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let segueId = segue.identifier {
            if segueId == "ShowDetail" && sender != nil {
                if let cell = sender as? RuleCell {
                    let controller = (segue.destinationViewController as! RuleDetailController)
                    controller.rule = cell.rule
                    controller.nav = navigationController
                }
            }
        }
    }
    
}

class RuleCell : UITableViewCell {
    var rule : Rule {
        didSet {
            isEnabled.setOn(rule.isEnabled, animated: false)
            message.text = rule.message
            let tempUnit = rule.isFarenheit ? "˚F" : "˚C"
            time.text = rule.timeRange.isEmpty ? "Time: \(rule.timeRange.startIndex)" : "Time: \(rule.timeRange.startIndex) - \(rule.timeRange.endIndex)"

            if rule.humidityRange.min.distanceTo(rule.humidityRange.max) < 0.001 {
                humidity.text = "Humidity: \(rule.humidityRange.min.format()) %"
            } else {
                humidity.text = "Humidity: \(rule.humidityRange.min.format()) - \(rule.humidityRange.max.format()) %"
            }

            if rule.tempRange.min.distanceTo(rule.tempRange.max) < 0.001 {
                temp.text = "Temp: \(rule.tempRange.min.format()) \(tempUnit)"
            } else {
                temp.text = "Temp: \(rule.tempRange.min.format()) - \(rule.tempRange.max.format()) \(tempUnit)"
            }
        }
    }
    @IBOutlet var isEnabled : UISwitch!
    @IBOutlet var message : UILabel!
    @IBOutlet var temp : UILabel!
    @IBOutlet var humidity : UILabel!
    @IBOutlet var time : UILabel!

    @IBAction func update() {
        rule.isEnabled = isEnabled.on
    }
    
    required init(coder aDecoder: NSCoder) {
        rule = Rule()
        super.init(coder: aDecoder)
    }
}