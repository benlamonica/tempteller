//
//  ConvertibleToDictionary.swift
//  TempTeller
//
//  Created by Ben La Monica on 7/17/15.
//  Copyright (c) 2015 Benjamin Alan La Monica. All rights reserved.
//

import Foundation

protocol ConvertableToDictionary {
    func toDict() -> [String:AnyObject]
}
