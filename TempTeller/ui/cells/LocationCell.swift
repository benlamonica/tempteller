    //
//  LocationCell.swift
//  TempTeller
//
//  Created by Ben La Monica on 6/3/15.
//  Copyright (c) 2015 Benjamin Alan La Monica. All rights reserved.
//

import UIKit

class LocationCell : UITableViewCell, SubRuleDisplaying {
    @IBOutlet var location : UITextField!
    @IBOutlet var spinner : UIActivityIndicatorView!
    @IBOutlet var gpsButton : UIButton!
    var priorLocation : String?
    var subrule : LocationSubRule!
    var weatherService : WeatherService!
    
    @IBAction func lookupGPS(sender : UIButton) {
        lookupLocation(sender, weatherLookup: weatherService.getLocationWithGPS)
    }
    
    @IBAction func beginEditing() {
        priorLocation = location.text
    }
    
    @IBAction func lookupZip(sender : UIButton) {
        if priorLocation != location.text {
            func weatherLookup(callback: (name: String?, lng: String?, lat: String?, errMsg: String?) -> ()) -> () {
                weatherService.getLocation(location.text!, completionHandler: callback)
            }
            lookupLocation(sender, weatherLookup: weatherLookup)
        }
    }

    func lookupLocation(sender : UIButton, weatherLookup : ((name: String?, lng: String?, lat: String?, errMsg: String?) -> ()) -> ()) {
        
        spinner.startAnimating()
        gpsButton.enabled = false
        weatherLookup() { (name, lng, lat, errMsg) -> () in
            dispatch_async(dispatch_get_main_queue()) {
                if let searchText = name {
                    self.subrule.name = searchText
                    self.subrule.lng = lng!
                    self.subrule.lat = lat!
                    self.location.text = searchText
                }
                
                self.gpsButton.enabled = true
                self.spinner.stopAnimating()
                
                if let error = errMsg {
                    let av = UIAlertView(title: "Unable to lookup location", message: error, delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "Dismiss")
                    av.show()
                }
            }
        }
    }

    
    func displayRule(subrule : SubRule) {
        if let rule = subrule as? LocationSubRule {
            self.subrule = rule
            location.text = rule.name
        }
    }
    
}
