//
//  DataTableViewController.swift
//  RangeComm
//
//  Created by air on 01.11.15.
//  Copyright © 2015 Christoph Mueller. All rights reserved.
//

import UIKit
import Parse
import Bolts

import CoreLocation

class DataTableViewController: UITableViewController, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    
    // Zugriff auf die NSUserDefault-Instanz
    let defaults = NSUserDefaults.standardUserDefaults()
    
    //  String array for Likes
    var myLikes = [String]()
    
    // Store messages from the server in this array
    var messages = [String]()
    
    // Store temporary messages from the server in this array
    var objects = [PFObject]()
    
    var messageIdForComment = String()
    
    // Store comments from the server in this array
    var comments = [String]()
    
    // Store temporary comments from the server in this array
    var commentObjects = [PFObject]()
    
    // Definition of colors for cells
    let appRedColor = UIColor(hexString: "#fa8072ff")
    let appGreenColor = UIColor(hexString: "#79b1a0ff")
    let appBlueColor = UIColor(hexString: "#1b91bfff")
    
    
    override func viewDidLoad() {
 
        super.viewDidLoad()
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()

        // Get messages when loading view
        getMessagesNearby()
        
        //Problem: TableView is underneath the StatusBar
        //Quickfix is done here but has to be better in Future
        self.tableView.contentInset = UIEdgeInsetsMake(10.0, 0.0, 0.0, 0.0)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.refreshControl?.addTarget(self, action: "reloadMessagesNearby:", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    override func viewWillAppear(animated: Bool) {
        //self.tableView.reloadData()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        // number if sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // number of cells
        return objects.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("LabelCell", forIndexPath: indexPath) as! NewsFeedCell
        
        
        cell.backgroundColor = UIColor.lightGrayColor()
        
        cell.contentView.layer.borderColor = UIColor.whiteColor().CGColor;
        cell.contentView.layer.borderWidth = 5.0

        var int = 0

        // Fill cells with messages
        for message in objects {
            
            // add message to a cell
            if (indexPath.row == int){
                cell.msgTLabel.text = message.objectForKey("text") as? String

                var rating = message.objectForKey("rating") as! Int
            
                
                /*
                 *  Location for message
                */
                let location = message.objectForKey("location") as? PFGeoPoint
                
                let geoCoder = CLGeocoder()
                let geoLocation = CLLocation(latitude: (location?.latitude)!, longitude: (location?.longitude)!)
                
                geoCoder.reverseGeocodeLocation(geoLocation) {
                    (placemarks, error) -> Void in
                    
                    let placeArray = placemarks as [CLPlacemark]!
                    
                    // Place details
                    var placeMark: CLPlacemark!
                    placeMark = placeArray?[0]
                    
                    let city = placeMark.addressDictionary?["City"] as? String
                    
                    cell.locationLabel.text = city as? String!
                }
                
                cell.ratingLabel.text = String(rating)
                
                
                /*
                 *  likes for message
                */
                myLikes.append("test")
                
                if(defaults.stringArrayForKey("myLikes") == nil) {
                    print("do nothing")
                }
                else {
                    myLikes = defaults.stringArrayForKey("myLikes")!
                }

                // disable likeButton if message was already liked before
                if(myLikes.contains(message.objectId as String!)) {
                    cell.likeButton.enabled = false
                }
                else {
                    cell.likeButton.enabled = true
                }
                
                // send like to server and increment rating
                cell.onLikeButtonTapped = {
                    
                    let objectId = message.objectId as! String!
                    
                    // Don't know if we will need this
                    // Counter for database entries
                    // Check how many entries are in the database and add +1
                    
                    let query = PFQuery(className:"Message")
                    
                    query.getObjectInBackgroundWithId(objectId + "") {
                        (message: PFObject?, error: NSError?) -> Void in
                
                        if error != nil {
                            print(error)
                        }
                        else if let new_rating = message {
                            
                            let old_rating = message!["rating"] as! Int
                    
                            new_rating["rating"] = old_rating + 1
                            
                            let message_rating = rating + 1
                            cell.ratingLabel.text = String(message_rating)
                    
                            new_rating.saveInBackground()
                            
                            cell.likeButton.enabled = false
                            
                            self.myLikes.append(message?.objectId as String!)
                            
                            self.defaults.setObject(self.myLikes, forKey: "myLikes")
                            
                            self.defaults.synchronize()
                            
                            // self.myLikes.append(message?.objectId as String!)
                            
                            // self.tableView?.reloadData()
                        }
                    }
                }
                
                /*
                 *  Comment for message
                */
                cell.onCommentButtonTapped = {
                    
                    self.messageIdForComment = message.objectId as String!
                    
                    self.performSegueWithIdentifier("commentSegue", sender: self)
                }
                
                /*
                 *  GET actual date for message
                */
                var dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                
                let currentDate = NSDate()
                let createdAt = message.createdAt!
                
                var diffDateComponents = NSCalendar.currentCalendar().components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day, NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second], fromDate: createdAt, toDate: currentDate, options: NSCalendarOptions.init(rawValue: 0))
                
                // Date/ Time difference between message and actual time
                if(diffDateComponents.year != 0) {
                    
                    if(diffDateComponents.year == 1) {
                        cell.ClockLabel.text = "\(diffDateComponents.year) year ago"
                    }
                    else {
                        cell.ClockLabel.text = "\(diffDateComponents.year) years ago"
                    }
                }
                else if(diffDateComponents.month != 0) {
                    
                    if(diffDateComponents.month == 1) {
                        cell.ClockLabel.text = "\(diffDateComponents.month) month ago"
                    }
                    else {
                        cell.ClockLabel.text = "\(diffDateComponents.month) months ago"
                    }
                }
                else if(diffDateComponents.hour != 0) {
                    
                    if(diffDateComponents.hour == 1) {
                        cell.ClockLabel.text = "\(diffDateComponents.hour) hour ago"
                    }
                    else {
                        cell.ClockLabel.text = "\(diffDateComponents.hour) hours ago"
                    }
                }
                else if(diffDateComponents.minute != 0) {
                    
                    if(diffDateComponents.minute == 1) {
                        cell.ClockLabel.text = "\(diffDateComponents.minute) minute ago"
                    }
                    else {
                        cell.ClockLabel.text = "\(diffDateComponents.minute) minutes ago"
                    }
                }
                else {
                    
                    if(diffDateComponents.second > 10) {
                        cell.ClockLabel.text = "\(diffDateComponents.second) seconds ago"
                    }
                    else {
                        cell.ClockLabel.text = "now"
                    }
                }
            }
            
            // color cells
            if(indexPath.row % 3 == 0) {
                cell.backgroundColor = appBlueColor
            }
            else if (indexPath.row % 2 == 0) {
                cell.backgroundColor = appRedColor
            }
            else {
                cell.backgroundColor = appGreenColor
            }

            int = int + 1
        }
        
        return cell
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "commentSegue" {
            let vc : CommentTableView = segue.destinationViewController as! CommentTableView
            
            vc.messageID = messageIdForComment
            
            commentObjects.removeAll()
        }
    }
    
    
    /*
    *
    *   Function -  GET messages nearby
    *               based on your current location
    *               synchronous call
    *
    */
    func getMessagesNearby() -> [PFObject] {

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
        }
        catch {
            print("error")
        }
        
        // self.tableView?.reloadData()
        
        return self.objects
    }
    
    /*
    *
    *   Function -  REFRESH messages nearby
    *               based on your current location
    *               asynchronous call
    *
    */
    func reloadMessagesNearby(refreshControl: UIRefreshControl) -> [PFObject] {
        
        // clear old tableview
        messages.removeAll()
        
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
        
        // SEND Request and GET final list of objects
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                //print("Successfully retrieved \(objects!.count) messages.")
                
                for object in objects as [PFObject]! {
                    self.messages.append(object.objectForKey("text") as! String)
                }
                
                self.tableView.reloadData()
                refreshControl.endRefreshing()
                
            }
            else {}
            
            self.objects = objects!
        }
        
        return self.objects
    }
    
    
    /*
    *
    *   Function -  GET messages nearby
    *               based on your current location
    *
    */
    func getComments(messageID: String) -> [PFObject] {
        
        // User location
        //let userGeoPoint = PFGeoPoint(latitude:self.locationManager.location!.coordinate.latitude, longitude:self.locationManager.location!.coordinate.longitude)
        
        // Create a query for messages
        let query = PFQuery(className:"Comment")
        
        // Interested in messages within 10km near to user.
        query.whereKey("messageID", equalTo:messageID)
        
        // GET latest messages at first
        query.orderByDescending("createdAt")
        
        // Limit what could be a lot of points.
        query.limit = 20
        
        // SEND Request and GET final list of objects
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                
                for object in objects as [PFObject]! {
                    self.comments.append(object.objectForKey("commentText") as! String)
                    
                    print(object)
                }
            }
            else {
                print("error: no data available")
            }
            
            self.commentObjects = objects!
        }
        
        // self.tableView?.reloadData()
        
        return self.commentObjects
    }
    
    var currentCity = String()
    
    func getMessageClosestCity(atLocation: PFGeoPoint) -> String {
        
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: atLocation.latitude, longitude: atLocation.longitude)
        
        var currentCity = String()
        
        geoCoder.reverseGeocodeLocation(location) {
            (placemarks, error) -> Void in
                
            let placeArray = placemarks as [CLPlacemark]!
                
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placeArray?[0]

            let city = placeMark.addressDictionary?["City"] as? String
            
            currentCity = city!
        }
        
        return currentCity
    }
}

extension UIView {
    func addBackground() {
    }
}

/*
 *  Define color for cells
*/

extension UIColor {
    public convenience init?(hexString: String) {
        let r, g, b, a: CGFloat
        
        if hexString.hasPrefix("#") {
            let start = hexString.startIndex.advancedBy(1)
            let hexColor = hexString.substringFromIndex(start)
            
            if hexColor.characters.count == 8 {
                let scanner = NSScanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexLongLong(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255
                    
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }
        
        return nil
    }
}