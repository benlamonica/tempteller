//
//  EmailUtil.swift
//  TempTeller
//
//  Created by Ben La Monica on 10/13/15.
//  Copyright © 2015 Benjamin Alan La Monica. All rights reserved.
//

import Foundation
import UIKit
import MessageUI

class EmailUtil : NSObject, MFMailComposeViewControllerDelegate {
    
    let parent : UIViewController
    var alert : UIAlertView!
    var mailView : MFMailComposeViewController!
    
    init(parentController: UIViewController) {
        parent = parentController
    }

    func sendEmailWithSubject(subject: String, body: String, attachments: [(name:String, mimeType:String, content:String)]?) {
        if MFMailComposeViewController.canSendMail() {
            mailView = MFMailComposeViewController()
            mailView.setSubject(subject)
            mailView.setToRecipients(["pojoapps@gmail.com"])

            for attachment in attachments ?? [] {
                mailView.addAttachmentData(attachment.content.dataUsingEncoding(NSUTF8StringEncoding)!, mimeType: attachment.mimeType, fileName: attachment.name)
            }
            mailView.setMessageBody(body, isHTML: true)
            mailView.mailComposeDelegate = self
            parent.presentViewController(mailView, animated: true, completion: nil)
        } else {
            alert = UIAlertView(title: "Unable to send e-mail", message: "You do not have e-mail configured", delegate: nil, cancelButtonTitle: "Dismiss")
            alert.show()
        }
    }
    
    func canSendMail() -> Bool {
        return MFMailComposeViewController.canSendMail()
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        NSLog("Mail was sent with result: %d", result.rawValue)
        parent.dismissViewControllerAnimated(true, completion: nil)
    }
}