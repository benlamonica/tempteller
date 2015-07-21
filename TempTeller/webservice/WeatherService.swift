//
//  WeatherService.swift
//  TempTeller
//
//  Created by Ben La Monica on 5/24/15.
//  Copyright (c) 2015 Benjamin Alan La Monica. All rights reserved.
//

import Foundation
import CoreLocation

class WeatherService : NSObject, CLLocationManagerDelegate {
    
    let queue = NSOperationQueue()
    let locationManager = CLLocationManager()
    var callback : ((loc : Location?, errMsg: String?) -> ())!
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func getLocation(search : String, completionHandler : ((loc : Location?, errMsg: String?) -> ())?) {
        let url = NSString(string: "https://query.yahooapis.com/v1/public/yql?format=json&q=select * from geo.placefinder where text=\"\(search)\" and gflags=\"R\"").stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        
        NSLog("Retrieving\n\(url)")

        let nsurl : NSURL! = NSURL(string: url!)

//        NSURLSession.sharedSession().
        NSURLConnection.sendAsynchronousRequest(NSURLRequest(URL: nsurl), queue: queue) { (response : NSURLResponse!, data : NSData!, error: NSError!) -> Void in
            if error != nil {
                if let handler = completionHandler {
                    handler(loc: nil, errMsg: "Error - Network Problem")
                }
            } else {
                let jsonString = NSString(data: data, encoding: NSUTF8StringEncoding)
                NSLog("Received \(jsonString)")

                let json = JSON(data: data, options: nil)
                
                if json["query"] != JSON.nullJSON && json["query"]["results"] != JSON.nullJSON {
                    let locName = json["query"]["results"]["Result"]["line2"].stringValue
                    let woeId = json["query"]["results"]["Result"]["woeid"].stringValue
                    NSLog("woeId = \(woeId), \(locName)")
                    if let handler = completionHandler {
                        handler(loc: Location(name: locName, locId: woeId), errMsg: nil)
                    }
                } else {
                    if let handler = completionHandler {
                        handler(loc: nil, errMsg: "Could not find location")
                    }
                }
            }
        }
    }
    
    func getLocationWithGPS(callback : (loc : Location?, errMsg: String?) -> ()) {
        self.callback = callback
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        if let location = newLocation {
            locationManager.stopUpdatingLocation()
            let search = String(format: "%.8f,%.8f", location.coordinate.latitude, location.coordinate.longitude)
            getLocation(search, completionHandler: callback)
        }
    }
}