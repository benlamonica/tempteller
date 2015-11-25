//
//  SettingsViewController.swift
//  TempTeller
//
//  Created by Ben La Monica on 7/10/15.
//  Copyright (c) 2015 Benjamin Alan La Monica. All rights reserved.
//

import Foundation
import UIKit
import StoreKit

class SettingsViewController : UITableViewController {
    var nav : UINavigationController!
    @IBOutlet var serverUrl : UITextField!
    @IBOutlet var deviceToken : UITextField!
    @IBOutlet var oneMonthPrice : UILabel!
    @IBOutlet var sixMonthPrice : UILabel!
    @IBOutlet var oneYearPrice : UILabel!
    @IBOutlet var subEnd : UITableViewCell!
    
    var config = TTConfig.shared
    let subMgr = SubscriptionManager()
    var email : EmailUtil!
    let txns : [SKPaymentTransaction] = []
    var subEndDate : NSDate?
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier ?? "DoNothing" {
        case "ShowWhy" :
            break
        default:
            break
        }
    }
    
    let SHOW_FORECAST_IO = NSIndexPath(forItem: 0, inSection: 0)
    let SHOW_YAHOO = NSIndexPath(forItem: 1, inSection: 0)
    let WHY_SUBSCRIBE = NSIndexPath(forItem: 0, inSection: 2)
    let SUBSCRIBE_1M = NSIndexPath(forItem: 0, inSection: 3)
    let SUBSCRIBE_6M = NSIndexPath(forItem: 1, inSection: 3)
    let SUBSCRIBE_1Y = NSIndexPath(forItem: 2, inSection: 3)
    let RESTORE_SUBS = NSIndexPath(forItem: 0, inSection: 4)
    let REQUEST_SUPPORT = NSIndexPath(forItem: 0, inSection: 5)
    
    func getSubHandler() -> ((txn: [SKPaymentTransaction]) -> ()) {
        return { (receipts: [SKPaymentTransaction]) in
            for receipt in receipts {
                NSLog("Purchased: \(receipt.payment.productIdentifier) - \(receipt.transactionDate)")
            }
        }
    }
        
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        switch indexPath {
        case SHOW_FORECAST_IO:
            openForecastIO()
        case SHOW_YAHOO:
            openYahoo()
        case SUBSCRIBE_1M:
            subMgr.subscribe("1_Month", onCompletion: getSubHandler())
        case SUBSCRIBE_6M:
            subMgr.subscribe("6_Month", onCompletion: getSubHandler())
        case SUBSCRIBE_1Y:
            subMgr.subscribe("12_Month", onCompletion: getSubHandler())
        case RESTORE_SUBS:
            subMgr.restoreSubs(getSubHandler())
        case REQUEST_SUPPORT:
            requestSupport()
        default: break
            // do nothing
        }
    }
    
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return super.tableView(tableView, titleForFooterInSection: section)
    }
    
   override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return super.tableView(tableView, titleForHeaderInSection: section)
    }

    func requestSupport() {
        
        email.sendEmailWithSubject("TempTeller Support", body: "Please enter your support question here.\n\nDeviceToken: \(deviceToken.text!)", attachments:nil)
    }
    
    func openForecastIO() {
        UIApplication.sharedApplication().openURL(NSURL(string:"https://forecast.io")!)
    }
    
    func openYahoo() {
        UIApplication.sharedApplication().openURL(NSURL(string:"https://yahoo.com")!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        serverUrl.text = config.serverUrl
        deviceToken.text = config.pushToken
        
        email = EmailUtil(parentController: self)
    }
    
    @IBAction func save(sender: AnyObject?) {
        config.serverUrl = serverUrl.text!
        nav.popToRootViewControllerAnimated(true)
    }
}
