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
    let settings = NSUserDefaults.standardUserDefaults()
    
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
