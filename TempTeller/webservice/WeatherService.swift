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
    var callback : ((name: String?, lng: String?, lat: String?, errMsg: String?) -> ())!
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func getLocation(search : String, completionHandler : ((name: String?, lng: String?, lat: String?,  errMsg: String?) -> ())?) {
        let url = NSString(string: "https://query.yahooapis.com/v1/public/yql?format=json&q=select * from geo.placefinder where text=\"\(search)\" and gflags=\"R\"").stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        
        let nsurl : NSURL! = NSURL(string: url!)

        NSURLConnection.sendAsynchronousRequest(NSURLRequest(URL: nsurl), queue: queue) { (response : NSURLResponse?, data : NSData?, error: NSError?) -> Void in
            if error != nil {
                if let handler = completionHandler {
                    let msg = error?.localizedDescription ?? ""
                    handler(name: nil, lng: nil, lat: nil, errMsg: msg)
                }
            } else {
                let jsonString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                NSLog("Received \(jsonString)")

                let json = JSON(data: data!, options: [])
                
                if json["query"] != JSON.nullJSON && json["query"]["results"] != JSON.nullJSON {
                    let locName = json["query"]["results"]["Result"]["line2"].string ?? "Unknown Location"
                    let lng = json["query"]["results"]["Result"]["longitude"].string ?? ""
                    let lat = json["query"]["results"]["Result"]["latitude"].stringValue ?? ""
                    NSLog("Found \(locName) at (\(lng),\(lat))")
                    if let handler = completionHandler {
                        handler(name: locName, lng: lng, lat: lat, errMsg: nil)
                    }
                } else {
                    if let handler = completionHandler {
                        handler(name: nil, lng: nil, lat: nil, errMsg: "Could not find location")
                    }
                }
            }
        }
    }
    
    func getLocationWithGPS(callback : (name: String?, lng: String?, lat: String?, errMsg: String?) -> ()) {
        self.callback = callback
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation location: CLLocation, fromLocation oldLocation: CLLocation) {
        locationManager.stopUpdatingLocation()
        let search = String(format: "%.8f,%.8f", location.coordinate.latitude, location.coordinate.longitude)
        getLocation(search, completionHandler: callback)
    }
}