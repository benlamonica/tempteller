//
//  MessageSubRule.swift
//  TempTeller
//
//  Created by Ben La Monica on 7/17/15.
//  Copyright (c) 2015 Benjamin Alan La Monica. All rights reserved.
//

import Foundation

public class MessageSubRule : SubRule {
    public var message : String;
    public init(msg : String) {
        message = msg
        super.init()
    }
    
    override convenience init() {
        self.init(msg: "")
    }
    
    convenience init(json: JSON) {
        self.init(msg: json["message"].stringValue)
    }
    
    override public func copyWithZone(zone: NSZone) -> AnyObject {
        return MessageSubRule(msg: message)
    }
}
