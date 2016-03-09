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

import MultipeerConnectivity

class FirstViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, MPCManagerDelegate {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var isAdvertising: Bool!
    
    let locationManager = CLLocationManager()

    @IBOutlet weak var mapView: MKMapView!
    
    var messages = [PFObject]()

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        self.locationManager.requestWhenInUseAuthorization()
        
        self.locationManager.startUpdatingLocation()
        
        /*
        if #available(iOS 9.0, *) {
            self.locationManager.requestLocation()
        } else {
            // Fallback on earlier versions
        }
        */
        
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
            }
            else {
                
                pin = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
                
                //v!.image = UIImage(named:"jodel.png")
                
                pin!.canShowCallout = true
                
                // Resize image
                let pinImage = UIImage(named: "panda.png")
                
                let size = CGSize(width: 30, height: 30)
                UIGraphicsBeginImageContext(size)
                
                pinImage!.drawInRect(CGRectMake(0, 0, size.width, size.height))
                let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
                
                UIGraphicsEndImageContext()
                
                pin?.image = resizedImage
                
                let deleteButton = UIButton(type: UIButtonType.Custom) as UIButton
                
                deleteButton.frame.size.width = 30
                deleteButton.frame.size.height = 30
                // deleteButton.backgroundColor = UIColor.blueColor()
                deleteButton.setImage(UIImage(named: "chat"), forState: .Normal)
                
                pin!.rightCalloutAccessoryView = deleteButton
                
               if(appDelegate.mpcManager.foundPeers.isEmpty) {
                    
                    deleteButton.enabled = false
               }
               else {
                
                deleteButton.enabled = true
                
                if let cpa = annotation as? MapText! {
                    
                    // let rightButton: AnyObject! = UIButton(type: UIButtonType.DetailDisclosure)
                    // pin?.rightCalloutAccessoryView = rightButton as? UIView
                    
                    let username = cpa.username
                    
                }
                }
        }
        
        return pin
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        // Put chat functionality in HERE
        
        if let cpa = view.annotation as? MapText! {
            
            let username = cpa.username
            
            var i = 0
            
            while (i < self.appDelegate.mpcManager.foundPeers.count) {
                
                if(username == self.appDelegate.mpcManager.foundPeers[i].displayName) {
                    
                    let selectedPeer = self.appDelegate.mpcManager.foundPeers[i] as MCPeerID
                    
                    self.appDelegate.mpcManager.browser.invitePeer(selectedPeer, toSession: self.appDelegate.mpcManager.session, withContext: nil, timeout: 20)
                    
                    return
                }
                else {
                    // DO nothing
                    i = i + 1
                }
            
            }
        }
        /*
        if let cpa = view.annotation as? MapText! {
            
             peer = MCPeerID(displayName: UIDevice.currentDevice().name);
            
            let selectedPeer = self.appDelegate.mpcManager.foundPeers[messages[0]] as MCPeerID
            
            self.appDelegate.mpcManager.browser.invitePeer(cpa.username as MCPeerID, toSession: self.appDelegate.mpcManager.session, withContext: nil, timeout: 20)
            
            
            print("cpa.imageName = \(cpa.username)")
        }
        */
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
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.015, longitudeDelta: 0.015))
        
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
                
                if(NSDate().timeIntervalSinceDate(object.createdAt!) < 3600000) {
                    messages.append(object)
                }
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
            let username = message.objectForKey("username") as! String
            
            // show jodels on map
            let jodel = MapText(title: message.objectForKey("text") as! String,
                time: String(likes) + " likes",
                color: "Red",
                username: username,
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
            
            if(messages.isEmpty) {
                
            }
            else {
            
                if (objects[0] == messages[0]) {
                    // DO nothing
                }
                else {
                    print("Test")
                
                    /*
                    *  Location for message
                    */
                    for object in objects as [PFObject]! {
                    
                    let location = object.objectForKey("location") as? PFGeoPoint
                    let likes = object.objectForKey("rating") as! Int
                    let username = object.objectForKey("username") as! String
                        
                        print(object)
                    
                    // show jodels on map
                    let jodel = MapText(title: object.objectForKey("text") as! String,
                        time: String(likes) + " likes",
                        color: "Red",
                        username: username,
                        coordinate: CLLocationCoordinate2D(latitude: location!.latitude, longitude: location!.longitude))
                    
                    self.mapView.addAnnotation(jodel)
                    
                    self.mapView.delegate = self
                        
                    }
                }
            }
        }
        catch {
            print("error")
        }
        
        return objects
    }
    
    func foundPeer() {
        // tblPeers.reloadData()
    }
    
    
    func lostPeer() {
        // tblPeers.reloadData()
    }
    
    
    func invitationWasReceived(fromPeer: String) {
        let alert = UIAlertController(title: "", message: "\(fromPeer) wants to chat with you.", preferredStyle: UIAlertControllerStyle.Alert)
        
        (tabBarController!.tabBar.items![2]).badgeValue = "1"
        
        let acceptAction: UIAlertAction = UIAlertAction(title: "Accept", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            self.appDelegate.mpcManager.invitationHandler(true, self.appDelegate.mpcManager.session)
            
            (self.tabBarController!.tabBar.items![2] ).badgeValue = nil
        }
        
        let declineAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (alertAction) -> Void in
            
            // TEST
            // TODO
            // MAYBE NEEDS TO BE CORRECTED or COMMENT OUT
            // self.appDelegate.mpcManager.invitationHandler(false, self.appDelegate.mpcManager.session)
            
            (self.tabBarController!.tabBar.items![2] ).badgeValue = nil
        }
        
        alert.addAction(acceptAction)
        alert.addAction(declineAction)
        
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    
    func connectedWithPeer(peerID: MCPeerID) {
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            self.performSegueWithIdentifier("segueForChat", sender: self)
        }
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

