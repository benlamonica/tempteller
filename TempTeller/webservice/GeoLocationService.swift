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
import SwiftHTTP
import XCGLogger

class GeoLocationService : NSObject, CLLocationManagerDelegate {

    let log = XCGLogger.defaultInstance()
    let locationManager = CLLocationManager()
    var callback : ((locId: String, name: String, lng: String, lat: String, errMsg: String?) -> ())!
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func getLocation(search : String, handler : ((locId: String, name: String, lng: String, lat: String,  errMsg: String?) -> ())) {
        let url = NSString(string: "https://query.yahooapis.com/v1/public/yql?format=json&q=select * from geo.placefinder where text=\"\(search)\" and gflags=\"R\"").stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        
        do {
            let req = try HTTP.GET(url)
            req.start { response in
                if response.error != nil {
                    let msg = response.error!.localizedDescription ?? ""
                    handler(locId: "", name: "", lng: "", lat: "", errMsg: msg)
                    return
                }
                
                let jsonString = NSString(data: response.data, encoding: NSUTF8StringEncoding)
                self.log.debug("Received \(jsonString)")
                
                let json = JSON(data: response.data, options: [])
                
                if json["query"] != JSON.null && json["query"]["results"] != JSON.null {
                    let locName = json["query"]["results"]["Result"]["line2"].string ?? "Unknown Location"
                    let lng = json["query"]["results"]["Result"]["longitude"].string ?? ""
                    let lat = json["query"]["results"]["Result"]["latitude"].string ?? ""
                    let woeId = json["query"]["results"]["Result"]["woeid"].string ?? ""
                    let woeType = json["query"]["results"]["Result"]["woetype"].string ?? ""
                    let locId = "\(woeType)_\(woeId)"
                    self.log.info("Found \(locId) - \(locName) at (\(lng),\(lat))")
                    handler(locId: locId, name: locName, lng: lng, lat: lat, errMsg: nil)
                } else {
                    handler(locId: "", name: "", lng: "", lat: "", errMsg: "Could not find location")
                }
            }
        } catch let error {
            log.error("got an error creating request \(error)")
            handler(locId: "", name: "", lng: "", lat: "", errMsg: "\(error)")
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
        getLocation(search, handler: callback)
    }
}