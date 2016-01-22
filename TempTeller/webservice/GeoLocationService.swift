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
        let geo = CLGeocoder()
        geo.geocodeAddressString(search) { (place, err) -> Void in
            if let mark = place?.first, loc = mark.location  {
                handler(locId: "", name: search, lng: loc.coordinate.longitude.format(), lat: loc.coordinate.latitude.format(), errMsg: err?.description)
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
        let geo = CLGeocoder()
        geo.reverseGeocodeLocation(location) { (place, err) -> Void in
            if let mark = place?.first  {
                let name = "\(mark.name ?? "\(location.coordinate)")\(mark.locality != nil ? ", \(mark.locality!)" : "")\(mark.postalCode != nil ? ", \(mark.postalCode!)" : "")"
                self.callback(locId: "", name: name, lng: location.coordinate.longitude.format(), lat: location.coordinate.latitude.format(), errMsg: err?.description)
            } else {
                self.callback(locId: "", name: "\(location.coordinate)", lng: location.coordinate.longitude.format(), lat: location.coordinate.latitude.format(), errMsg: err?.description)
            }
        }
    }
}