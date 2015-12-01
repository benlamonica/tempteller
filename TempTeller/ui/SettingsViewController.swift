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

class SettingsViewController : UITableViewController, StatusNotifier {
    var nav : UINavigationController!
    @IBOutlet var serverUrl : UITextField!
    @IBOutlet var deviceToken : UITextField!
    @IBOutlet var subEnd : UITableViewCell!
    var statusSpinner : UIActivityIndicatorView?
    var statusLbl : UILabel?
    var origText : String?
    var statusCell : NSIndexPath?
    
    
    var config = TTConfig.shared
    var subMgr : SubscriptionManager!
    var email : EmailUtil!
    let txns : [SKPaymentTransaction] = []
    var subEndDate : NSDate?
    let df = NSDateFormatter()
    
    func updatePrices(prices: [String:SKProduct]) {
        updatePriceInCell(SUBSCRIBE_1M, product: prices["1_Month"])
        updatePriceInCell(SUBSCRIBE_6M, product: prices["6_Month"])
        updatePriceInCell(SUBSCRIBE_1Y, product: prices["12_Month"])
    }

    
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if (section == WHY_SUBSCRIBE.section) {
            if config.subEndDate == "NotSubscribed" {
                return "⛔ You are not currently subscribed. You will not receive notifications."
            } else if config.subEndDate < df.stringFromDate(NSDate()) {
                return "⛔ Your subscription ended on \(config.subEndDate). You will not receive notifications."
            } else {
                return "✅ You are subscribed until \(config.subEndDate)"
            }
        } else {
            return super.tableView(tableView, titleForFooterInSection: section)
        }
    }
    
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
            self.hideStatus()
        }
    }
        
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        if statusCell != nil {
            // don't let the user click on anything if we are in the process of doing something else
            return
        }
        
        switch indexPath {
        case SHOW_FORECAST_IO:
            openForecastIO()
        case SHOW_YAHOO:
            openYahoo()
        case SUBSCRIBE_1M:
            showStatusInCell(indexPath)
            subMgr.subscribe("1_Month", onCompletion: getSubHandler())
        case SUBSCRIBE_6M:
            showStatusInCell(indexPath)
            subMgr.subscribe("6_Month", onCompletion: getSubHandler())
        case SUBSCRIBE_1Y:
            showStatusInCell(indexPath)
            subMgr.subscribe("12_Month", onCompletion: getSubHandler())
        case RESTORE_SUBS:
            showStatusInCell(indexPath)
            subMgr.restoreSubs(getSubHandler())
        case REQUEST_SUPPORT:
            requestSupport()
        default: break
            // do nothing
        }
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
        email = EmailUtil(parentController: self)
        df.dateFormat = "yyyy-MM-dd"
        subMgr = SubscriptionManager(status: self)

    }
    
    func updatePriceInCell(cellPath: NSIndexPath, product: SKProduct?) {
        if let cell = tableView.cellForRowAtIndexPath(cellPath), let prod = product {
            let statusSpinner = cell.viewWithTag(2) as? UIActivityIndicatorView
            statusSpinner?.stopAnimating()
            if let priceLbl = cell.viewWithTag(3) as? UILabel {
                priceLbl.text = prod.localizedPrice()
                priceLbl.hidden = false
            }
        }
    }
    
    func showStatusInCell(cellPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(cellPath) {
            statusLbl = cell.viewWithTag(1) as? UILabel
            origText = statusLbl?.text
            statusSpinner = cell.viewWithTag(2) as? UIActivityIndicatorView
            statusSpinner?.startAnimating()
            if let priceLbl = cell.viewWithTag(3) as? UILabel {
                priceLbl.hidden = true
            }
        }
    }
    
    func hideStatus() {
        UIView.animateWithDuration(0.0, animations: {}) { (completed: Bool) in
            if let cellPath = self.statusCell, let cell = self.tableView.cellForRowAtIndexPath(cellPath) {
                self.statusLbl?.text = self.origText
                self.statusSpinner?.stopAnimating()
                self.statusLbl = nil
                self.statusSpinner = nil
                self.statusCell = nil
                if let priceLbl = cell.viewWithTag(3) as? UILabel {
                    priceLbl.hidden = false
                }
            }
        }
    }
    
    func setStatus(status : String) {
        UIView.animateWithDuration(0.0, animations: {}) { (completed: Bool) in
            self.statusLbl?.text = status
        }
    }
    
    func fail(msg: String) {
        UIView.animateWithDuration(0.0, animations: {}) { (completed: Bool) in
            let alert = UIAlertView(title: "Problem", message: msg, delegate: nil, cancelButtonTitle: "Dismiss")
            alert.show()
            self.hideStatus()
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        serverUrl.text = config.server
        deviceToken.text = config.pushToken
    }
    
    @IBAction func save(sender: AnyObject?) {
        config.server = serverUrl.text!
        nav.popToRootViewControllerAnimated(true)
    }
}
