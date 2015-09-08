//
//  ResignWhenDone.swift
//  TempTeller
//
//  Created by Ben La Monica on 8/28/15.
//  Copyright (c) 2015 Benjamin Alan La Monica. All rights reserved.
//

import Foundation
import UIKit

class ResigningTextFieldDelegate : NSObject, UITextFieldDelegate {
    @IBOutlet var detailController : RuleDetailController!
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        detailController.resetInsets()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        detailController.adjustInsetsToShowKeybaord()
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        detailController.resetInsets()
    }
}