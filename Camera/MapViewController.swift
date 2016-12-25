//
//  MapViewController.swift
//  Camera
//
//  Created by Kevin Yan on 12/4/16.
//  Copyright © 2016 Kevin Yan. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlacePicker

class MapViewController: UIViewController{

    var map: GMSMapView!
    var placePicker: GMSPlacePicker!
    var locationManager: CLLocationManager!
    
    var long: Double!
    var lat: Double!
    
    @IBOutlet var mapViewContainer: UIView!
    
    
    @IBAction func getPlaces(_ sender: AnyObject) {
        
        if locationManager.location == nil {
            let updateLocationAlert = UIAlertController(title: "Location not found. You must authorize map usage.", message: "", preferredStyle: UIAlertControllerStyle.alert)
            updateLocationAlert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
            self.present(updateLocationAlert, animated: true, completion: nil)
            
            locationManager.requestAlwaysAuthorization()
        }
        else{
        let here = CLLocationCoordinate2DMake(lat, long)
        let viewport = GMSCoordinateBounds(coordinate: here, coordinate: here)
        let config = GMSPlacePickerConfig(viewport: viewport)
        placePicker = GMSPlacePicker(config: config)
        
        placePicker.pickPlace{
            (place: GMSPlace?, error: Error?) -> Void in
            
            if let error = error{
                print("error occured")
                return
            }
            
            if let place = place{
                let coords = CLLocationCoordinate2DMake(place.coordinate.latitude, place.coordinate.longitude)
                let somePlace = GMSMarker(position: coords)
                somePlace.map = self.map
                somePlace.title = place.name
            }
        }
        }
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager.requestAlwaysAuthorization()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //displays the google map
        map = GMSMapView(frame: self.mapViewContainer.frame)
        view.addSubview(map)
        
        if locationManager.location == nil{
            let updateLocationAlert = UIAlertController(title: "Location not found. Try coming back to the screen or enable map usage.", message: "", preferredStyle: UIAlertControllerStyle.alert)
            updateLocationAlert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
            self.present(updateLocationAlert, animated: true, completion: nil)
            //print("Try coming back to the screen to update location.")
            locationManager.requestAlwaysAuthorization()
        }
        else{
            let currentLocation: CLLocation = locationManager.location!
            long = currentLocation.coordinate.longitude
            lat = currentLocation.coordinate.latitude
            let coords = CLLocationCoordinate2DMake(lat, long)
            
            //displays your location
            let mark = GMSMarker(position: coords)
            mark.title = "I'm Here"
            mark.map = map
            map.animate(toLocation: coords)
            map.animate(toZoom: 20.0)
        }
    }
}
