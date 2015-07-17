//
//  MessageSubRule.swift
//  TempTeller
//
//  Created by Ben La Monica on 7/17/15.
//  Copyright (c) 2015 Benjamin Alan La Monica. All rights reserved.
//

import Foundation

class MessageSubRule : SubRule, NSCopying {
    var message : String;
    init(msg : String) {
        message = msg
        super.init()
    }
    
    override convenience init() {
        self.init(msg: "")
    }
    
    override func copyWithZone(zone: NSZone) -> AnyObject {
        return MessageSubRule(msg: message)
    }
}
