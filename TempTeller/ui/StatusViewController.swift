//
//  StatusViewController.swift
//  TempTeller
//
//  Created by Ben La Monica on 11/24/15.
//  Copyright © 2015 Benjamin Alan La Monica. All rights reserved.
//

import Foundation
import UIKit

class StatusViewController : UIViewController, StatusNotifier {
    @IBOutlet var lbl : UILabel!
    
    func setStatus(status : String) {
        UIView.animateWithDuration(0.25, animations: {self.lbl.alpha=0.0}) { didFinish in
            self.lbl.text = status
            UIView.animateWithDuration(0.25, animations: {self.lbl.alpha=1.0})
        }
    }
    
    func fail(msg: String) {
        let av = UIAlertView(title: "Problem", message: msg, delegate: nil, cancelButtonTitle: "Dismiss")
        av.show()
    }
}