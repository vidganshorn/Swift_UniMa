//
//  SecondViewController.swift
//  RangeComm
//
//  Created by air on 28.10.15.
//  Copyright © 2015 Christoph Mueller. All rights reserved.
//

import UIKit
import CoreLocation
import Parse
import Bolts


class SecondViewController: UIViewController, CLLocationManagerDelegate, UITextViewDelegate {
    
    let locationManager = CLLocationManager()
    
    @IBOutlet var sended: UITextView!
    
    var msgs = [String]() //stores only all messages sent inside a local array
    var messagesArray = [Message]() //stores the messages sent as well as the device ID

    
    @IBOutlet weak var sendMessageBarButton: UIBarButtonItem!
    
    @IBAction func sendMessage(sender: UIBarButtonItem) {
        //Sending needs to happen
        //store text in variable
        let inputMsg = sended.text
        
        //store DeviceID in variable
        let localDeviceID = UIDevice.currentDevice().identifierForVendor?.UUIDString
        
        cancelButtonOutlet.hidden = true
        
        //Sending to Backend
        //For now store locally in an array
        //Catch Identifier as well
        msgs.append(inputMsg)
        let currentSending = Message()
        currentSending.deviceID = localDeviceID
        currentSending.text = inputMsg
        
        
        //Date and time to be captured from the device?
        let date = NSDate()
        
        // currentSending.post_Date = "\(date)"
        
        
        // How about the location
        // First approach: Use lattitude and longitude
        // Is working and distance can also be determined in Kilometers
        // Set the current location to a variable
        // let myLocation = CLLocation(latitude: self.locationManager.location!.coordinate.latitude, longitude: self.locationManager.location!.coordinate.longitude)
        
        // Since we probably can not store the CLLocation Variable type we should store the strings for latitude and longitude
        // Store these two in currentSending
        
        // currentSending.post_latitude = "\(self.locationManager.location!.coordinate.latitude)"
        // currentSending.post_longitude = "\(self.locationManager.location!.coordinate.longitude)"
        
        // let mannheimLocation = CLLocation(latitude: 49.484895, longitude: 8.461158)
        
        // let distanceBetweenMeAndMannheim = myLocation.distanceFromLocation(mannheimLocation) / 1000
        
        //local saving for testing again
        messagesArray.append(currentSending)
        
        //ID Generation should happen last, after all Attributes have been initialized. Still ID Generation by the server would really make sense.
        
        
        /*
        *
        *   SEND -  SEND messages with
        *           text, your deviceID, initial rating = 0 and
        *           your current location
        *
        */
        var message = PFObject(className:"Message")
        
        message["text"] = currentSending.text!
        message["deviceID"] = currentSending.deviceID!
        
        let point = PFGeoPoint(latitude:self.locationManager.location!.coordinate.latitude, longitude:self.locationManager.location!.coordinate.longitude)
        message["location"] = point
        
        message["rating"] = 0
        
        message.saveInBackgroundWithBlock {
            
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                print("success")
                
                let alertController = UIAlertController(title: "My Jodel", message:
                    "May the force be with you!", preferredStyle: UIAlertControllerStyle.Alert)
                
                alertController.addAction(UIAlertAction(title: "Success", style: UIAlertActionStyle.Default,handler: nil))
                
                self.presentViewController(alertController, animated: true, completion: nil)
                
                // clear Field should come after succesfull sending
                self.sended.text = "Tell us another Story...."
                
                // Don't know if we will need this
                // Counter for database entries
                // Check how many entries are in the database and add +1
                /*
                var query = PFQuery(className:"Count")
                query.getObjectInBackgroundWithId("Tbn5z3H8Kk") {
                (count: PFObject?, error: NSError?) -> Void in
                if error != nil {
                print(error)
                } else if let new_count = count {
                
                var amount = count!["count"] as! Int
                
                new_count["count"] = amount + 1
                
                new_count.saveInBackground()
                }
                }
                */
            } else {
                let alertController = UIAlertController(title: "My Jodel", message:
                    "An error occured!", preferredStyle: UIAlertControllerStyle.Alert)
                
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
        
        
        
        //close Keyboard to enable further use of the app
        self.view.endEditing(true)
        
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    override func viewDidLoad() {
        sended.delegate = self
        
        super.viewDidLoad()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        cancelButtonOutlet.hidden = true
    
    }
    
    @IBOutlet var cancelButtonOutlet: UIButton!
    
    func textViewDidBeginEditing(textView: UITextView) {
        sended.text=""
        cancelButtonOutlet.hidden = false
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        //Stub for now, nothing happening here
        
    }

    @IBAction func cancelButtonPress(sender: UIButton) {
        //just dismiss the keyboard and set the textfield back to the root
        
        self.view.endEditing(true)
        cancelButtonOutlet.hidden = true
        sended.text="Type here..."
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func sended(sender: UIButton) {
        //Sending needs to happen
        //store text in variable
        let inputMsg = sended.text
       
        //store DeviceID in variable
        let localDeviceID = UIDevice.currentDevice().identifierForVendor?.UUIDString
        
       cancelButtonOutlet.hidden = true
        
        //Sending to Backend
        //For now store locally in an array
        //Catch Identifier as well
        msgs.append(inputMsg)
        let currentSending = Message()
        currentSending.deviceID = localDeviceID
        currentSending.text = inputMsg
        
        
        //Date and time to be captured from the device?
        
        let date = NSDate()
        
        //currentSending.post_Date = "\(date)"
        
        
        
        
        //How about the location 
        //First approach: Use lattitude and longitude
        //Is working and distance can also be determined in Kilometers
        //Set the current location to a variable
        let myLocation = CLLocation(latitude: self.locationManager.location!.coordinate.latitude, longitude: self.locationManager.location!.coordinate.longitude)
        
        //Since we probably can not store the CLLocation Variable type we should store the strings for latitude and longitude
        //Store these two in currentSending
    
        // currentSending.latitude = "\(self.locationManager.location!.coordinate.latitude)"
        // currentSending.longitude = "\(self.locationManager.location!.coordinate.longitude)"
        
        let mannheimLocation = CLLocation(latitude: 49.484895, longitude: 8.461158)
        
        // let distanceBetweenMeAndMannheim = myLocation.distanceFromLocation(mannheimLocation) / 1000
        
        //local saving for testing again
        messagesArray.append(currentSending)
        
        //ID Generation should happen last, after all Attributes have been initialized. Still ID Generation by the server would really make sense.

    
        /*
        *
        *   SEND -  SEND messages with
        *           text, your deviceID, initial rating = 0 and
        *           your current location
        *
        */
        var message = PFObject(className:"Message")
        
        message["text"] = currentSending.text!
        message["deviceID"] = currentSending.deviceID!
        
        let point = PFGeoPoint(latitude:self.locationManager.location!.coordinate.latitude, longitude:self.locationManager.location!.coordinate.longitude)
        message["location"] = point
        
        message["rating"] = 0
        
        message.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                print("success")
                
                // Don't know if we will need this
                // Counter for database entries
                // Check how many entries are in the database and add +1
                /*
                var query = PFQuery(className:"Count")
                query.getObjectInBackgroundWithId("Tbn5z3H8Kk") {
                    (count: PFObject?, error: NSError?) -> Void in
                    if error != nil {
                        print(error)
                    } else if let new_count = count {
                        
                        var amount = count!["count"] as! Int
                        
                        new_count["count"] = amount + 1
                        
                        new_count.saveInBackground()
                    }
                }
                */
            } else {
                // There was a problem, check error.description
            }
        }
        
        //clear Field should come after succesfull sending
        sended.text = ""
        
        //close Keyboard to enable further use of the app
        self.view.endEditing(true)
        
    }
    
    internal func getArray() -> [String]
    {
        return msgs
    }
 
}

