//
//  NumbersOnlyFilter.swift
//  TempTeller
//
//  Created by Ben La Monica on 8/28/15.
//  Copyright (c) 2015 Benjamin Alan La Monica. All rights reserved.
//

import Foundation
import UIKit

class NumbersOnlyTextFieldDelegate : ResigningTextFieldDelegate {
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let newVal = (textField.text as NSString).stringByReplacingCharactersInRange(range, withString: string)
        return newVal.match("^-?\\d*\\.?\\d*$")
    }
}