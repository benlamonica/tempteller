//
//  SettingsViewController.swift
//  TempTeller
//
//  Created by Ben La Monica on 7/10/15.
//  Copyright (c) 2015 Benjamin Alan La Monica. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController : UIViewController {
    var nav : UINavigationController!
    @IBOutlet var serverUrl : UITextField!
    @IBOutlet var deviceToken : UITextField!
    @IBOutlet var scrollView : UIScrollView!
    @IBOutlet var contentView : UIView!
    @IBOutlet var widthConstraint : NSLayoutConstraint!
    
    let settings = NSUserDefaults.standardUserDefaults()
    
    @IBAction
    func openForecastIO() {
        UIApplication.sharedApplication().openURL(NSURL(string:"https://forecast.io")!)
    }
    
    @IBAction
    func openYahoo() {
        UIApplication.sharedApplication().openURL(NSURL(string:"https://yahoo.com")!)
    }
    
    override func viewWillLayoutSubviews() {
        let windows = UIApplication.sharedApplication().windows
        let width = windows[0].frame.width
        widthConstraint.constant = width
        contentView.frame = CGRect(x: 0, y: 0, width: width, height: contentView.frame.height)
    }
    
    override func viewDidLayoutSubviews() {
        scrollView.contentSize = CGSize(width: contentView.frame.width, height: contentView.frame.height)
    }
    
    override func viewDidLoad() {
        if let url = settings.valueForKey("serverUrl") as? String {
            serverUrl.text = url
        }
        if let token = settings.valueForKey("deviceToken") as? String {
            deviceToken.text = token
        } else {
            deviceToken.text = "Not Subscribed"
        }
    }
    
    @IBAction func save(sender: AnyObject?) {
        settings.setValue(serverUrl.text, forKey: "serverUrl")
        settings.synchronize()
        nav.popToRootViewControllerAnimated(true)
    }
}
