//
//  WeatherService.swift
//  TempTeller
//
//  Created by Ben La Monica on 5/24/15.
//  Copyright (c) 2015 Benjamin Alan La Monica. All rights reserved.
//

import Foundation
import CoreLocation
import SwiftyJSON

class WeatherService : NSObject, CLLocationManagerDelegate {
    
    let queue = NSOperationQueue()
    let locationManager = CLLocationManager()
    var callback : ((locId: String, name: String, lng: String, lat: String, errMsg: String?) -> ())!
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func getLocation(search : String, completionHandler : ((locId: String, name: String, lng: String, lat: String,  errMsg: String?) -> ())?) {
        let url = NSString(string: "https://query.yahooapis.com/v1/public/yql?format=json&q=select * from geo.placefinder where text=\"\(search)\" and gflags=\"R\"").stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        
        let nsurl : NSURL! = NSURL(string: url!)

        NSURLConnection.sendAsynchronousRequest(NSURLRequest(URL: nsurl), queue: queue) { (response : NSURLResponse?, data : NSData?, error: NSError?) -> Void in
            if error != nil {
                if let handler = completionHandler {
                    let msg = error?.localizedDescription ?? ""
                    handler(locId: "", name: "", lng: "", lat: "", errMsg: msg)
                }
            } else {
                let jsonString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                NSLog("Received \(jsonString)")

                let json = JSON(data: data!, options: [])
                
                if json["query"] != JSON.null && json["query"]["results"] != JSON.null {
                    let locName = json["query"]["results"]["Result"]["line2"].string ?? "Unknown Location"
                    let lng = json["query"]["results"]["Result"]["longitude"].string ?? ""
                    let lat = json["query"]["results"]["Result"]["latitude"].string ?? ""
                    let woeId = json["query"]["results"]["Result"]["woeid"].string ?? ""
                    let woeType = json["query"]["results"]["Result"]["woetype"].string ?? ""
                    let locId = "\(woeType)_\(woeId)"
                    NSLog("Found \(locId) - \(locName) at (\(lng),\(lat))")
                    if let handler = completionHandler {
                        handler(locId: locId, name: locName, lng: lng, lat: lat, errMsg: nil)
                    }
                } else {
                    if let handler = completionHandler {
                        handler(locId: "", name: "", lng: "", lat: "", errMsg: "Could not find location")
                    }
                }
            }
        }
    }
    
    func getLocationWithGPS(callback : (locId: String, name: String, lng: String, lat: String, errMsg: String?) -> ()) {
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