//
//  FLocationManager.swift
//  ChatTheComplete
//
//  Created by Ahmad Mustafa on 31/01/2022.
//

import UIKit
import CoreLocation


class FLocationManager: NSObject, CLLocationManagerDelegate {
    
    static let shared = FLocationManager()
    let locationManager : CLLocationManager
    var locationInfoCallBack: ((_ info:LocationInformation)->())!
    var willAskLocation = true
    
    private override init() {
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLLocationAccuracyHundredMeters
        super.init()
        locationManager.delegate = self
    }
    
    func start(locationInfoCallBack: @escaping ((_ info:LocationInformation)->())) {
        self.locationInfoCallBack = locationInfoCallBack
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func stop() {
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        DispatchQueue.main.async {
            guard let mostRecentLocation = locations.last else {
                return
            }
            print(mostRecentLocation)
            let info = LocationInformation()
            info.latitude = mostRecentLocation.coordinate.latitude
            info.longitude = mostRecentLocation.coordinate.longitude
            
            
            //now fill address as well for complete information through lat long ..
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(mostRecentLocation) { (placemarks, error) in
                guard let placemarks = placemarks, let placemark = placemarks.first else { return }
                if let city = placemark.locality,
                   let state = placemark.administrativeArea,
                   let zip = placemark.postalCode,
                   let locationName = placemark.name,
                   let thoroughfare = placemark.thoroughfare,
                   let country = placemark.country {
                    info.city     = city
                    info.state    = state
                    info.zip = zip
                    info.address =  locationName + ", " + (thoroughfare as String)
                    info.country  = country
                }
                self.locationInfoCallBack(info)
            }
        }
        
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        self.showAlert()
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .denied {
            if willAskLocation{
                willAskLocation = !willAskLocation
                self.showAlert()
            }
        }
    }
    
    private func showAlert(){
        //        Utilities.dismissActivityIndicator()
        let keyWindow = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .map({$0 as? UIWindowScene})
            .compactMap({$0})
            .first?.windows
            .filter({$0.isKeyWindow}).first
        keyWindow?.endEditing(true)
        
        //        guard let window = UIApplication.shared.keyWindow else { return }
        guard let window = keyWindow else { return }
        
        let alert = UIAlertController(title: "Alert", message: "you have to enable GPS Location", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Go to Settings now", style: .default, handler: { (alert: UIAlertAction!) in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        window.rootViewController?.present(alert, animated: true, completion: nil)
    }
}

class LocationInformation {
    var city:String?
    var address:String?
    var latitude:CLLocationDegrees?
    var longitude:CLLocationDegrees?
    var zip:String?
    var state :String?
    var country:String?
    init(city:String? = "",address:String? = "",latitude:CLLocationDegrees? = Double(0.0),longitude:CLLocationDegrees? = Double(0.0),zip:String? = "",state:String? = "",country:String? = "") {
        self.city    = city
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.zip        = zip
        self.state = state
        self.country = country
    }
}

