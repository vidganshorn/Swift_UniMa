//
//  FirstViewController.swift
//  RangeComm
//
//  Created by Christoph Mueller on 28.10.15.
//  Copyright © 2015 Christoph Mueller. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

import Parse
import Bolts

class FirstViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    let locationManager = CLLocationManager()

    @IBOutlet weak var mapView: MKMapView!
    
    var messages = [PFObject]()

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        self.locationManager.requestWhenInUseAuthorization()
        // self.locationManager.startUpdatingLocation()
        if #available(iOS 9.0, *) {
            self.locationManager.requestLocation()
        } else {
            // Fallback on earlier versions
        }
        
        self.mapView.showsUserLocation = true
        
        getMessagesNearby()
        
        var timer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: Selector("getLatestMessageNearby"), userInfo: nil, repeats: true)
        
        // var message = getLatestMessageNearby()

    }
    
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        if (annotation is MKUserLocation) { return nil }
            
            let reuseID = "jodel"
            var pin = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseID)
            
            if pin != nil {
                pin!.annotation = annotation
            } else {
                pin = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
                
                //v!.image = UIImage(named:"jodel.png")
                
                pin!.canShowCallout = true
                
                // Resize image
                let pinImage = UIImage(named: "panda.png")
                
                let size = CGSize(width: 40, height: 40)
                UIGraphicsBeginImageContext(size)
                
                pinImage!.drawInRect(CGRectMake(0, 0, size.width, size.height))
                let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
                
                UIGraphicsEndImageContext()
                
                pin?.image = resizedImage
                
                let rightButton: AnyObject! = UIButton(type: UIButtonType.DetailDisclosure)
                // pin?.rightCalloutAccessoryView = rightButton as? UIView
                
                let deleteButton = UIButton(type: UIButtonType.Custom) as UIButton
                deleteButton.frame.size.width = 30
                deleteButton.frame.size.height = 30
                // deleteButton.backgroundColor = UIColor.blueColor()
                deleteButton.setImage(UIImage(named: "chat"), forState: .Normal)
                
                pin!.rightCalloutAccessoryView = deleteButton
                
                // return pinAnnotationView
        }

        
        return pin
        
    }
    
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Location Delegate Methods
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let location = locations.last
        
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.075, longitudeDelta: 0.075))
        
        self.mapView.setRegion(region, animated: true)
        
    
    }
    
    
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError)
    {
        print("Error: " + error.localizedDescription)
    }
    
    
    /*
    *
    *   Function -  GET messages nearby
    *               based on your current location
    *               synchronous call
    *
    */
    func getMessagesNearby() -> [PFObject] {
        
        var objects = [PFObject]()
        
        // User location
        let userGeoPoint = PFGeoPoint(latitude:self.locationManager.location!.coordinate.latitude, longitude:self.locationManager.location!.coordinate.longitude)
        
        // Create a query for messages
        let query = PFQuery(className:"Message")
        
        // Interested in messages within 10km near to user.
        query.whereKey("location", nearGeoPoint: userGeoPoint, withinKilometers: 10.0)
        
        // GET latest messages at first
        query.orderByDescending("createdAt")
        
        // Limit what could be a lot of points.
        query.limit = 20
        
        // SEND synchronous request and GET final list of (comment) objects
        do {
            try objects = query.findObjects()
            
            for object in objects {
                messages.append(object)
            }
            
        }
        catch {
            print("error")
        }
        
        // self.tableView?.reloadData()
        
        /*
        *  Location for message
        */
        for message in messages {
            
            let location = message.objectForKey("location") as? PFGeoPoint
            let likes = message.objectForKey("rating") as! Int
            
            // show jodels on map
            let jodel = MapText(title: message.objectForKey("text") as! String,
                time: String(likes) + " likes",
                color: "Red",
                coordinate: CLLocationCoordinate2D(latitude: location!.latitude, longitude: location!.longitude))
            
            self.mapView.addAnnotation(jodel)
            
            mapView.delegate = self
        }
        
        return objects
    }
    
    func getLatestMessageNearby() -> [PFObject] {
        
        var objects = [PFObject]()
        
        // User location
        let userGeoPoint = PFGeoPoint(latitude:self.locationManager.location!.coordinate.latitude, longitude:self.locationManager.location!.coordinate.longitude)
        
        // Create a query for messages
        let query = PFQuery(className:"Message")
        
        // Interested in messages within 10km near to user.
        query.whereKey("location", nearGeoPoint: userGeoPoint, withinKilometers: 10.0)
        
        // GET latest messages at first
        query.orderByDescending("createdAt")
        
        // Limit what could be a lot of points.
        // Get only latest message
        query.limit = 20
        
        // SEND synchronous request and GET final list of (comment) objects
        do {
            try objects = query.findObjects()
            
            if (objects[0] == messages[0]) {
                // DO nothing
            }
            else {
                print("Test")
            }
        }
        catch {
            print("error")
        }
        
        /*
        *  Location for message
        */
        for message in messages {
            
            let location = message.objectForKey("location") as? PFGeoPoint
            let likes = message.objectForKey("rating") as! Int
            
            // show jodels on map
            let jodel = MapText(title: message.objectForKey("text") as! String,
                time: String(likes) + " likes",
                color: "Red",
                coordinate: CLLocationCoordinate2D(latitude: location!.latitude, longitude: location!.longitude))
            
            self.mapView.addAnnotation(jodel)
            
            mapView.delegate = self
        }
        
        return objects
        
    }
    /*
    func updateMessages() -> [PFObject] {
        
        var objects = [PFObject]()
        
        // User location
        let userGeoPoint = PFGeoPoint(latitude:self.locationManager.location!.coordinate.latitude, longitude:self.locationManager.location!.coordinate.longitude)
        
        // Create a query for messages
        let query = PFQuery(className:"Message")
        
        // Interested in messages within 10km near to user.
        query.whereKey("location", nearGeoPoint: userGeoPoint, withinKilometers: 10.0)
        
        // GET latest messages at first
        query.orderByDescending("createdAt")
        
        // Limit what could be a lot of points.
        // Get only latest message
        // query.limit = 20
        
        var int_message = 0
        var int_object = 0
        
        // SEND synchronous request and GET final list of (message) objects
        do {
            try objects = query.findObjects()
            
            for object in objects {
                
                if (objects[int_object] == messages[int_message]) {
                // DO nothing
                }
            else {
                print("Test")
            }
        }
        catch {
            print("error")
        }
        
        return objects
    }
    */
}

