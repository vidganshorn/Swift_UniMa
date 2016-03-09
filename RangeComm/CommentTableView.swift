//
//  CommentTableView.swift
//  RangeComm
//
//  Created by David Ganshorn on 11/24/15.
//  Copyright © 2015 Christoph Mueller. All rights reserved.
//

import Foundation
import UIKit

import Parse
import Bolts

class CommentTableView: UITableViewController {
    
    // Store comments from the server in this array
    var comments = [String]()
    
    // Store temporary comments from the server in this array
    var commentObjects = [PFObject]()
    
    // Store temporary comments from the server in this array
    var objects = [PFObject]()
    
    // MessageId for comment
    var messageID = String()
    
    var messageIdForComment = String()
    
    // Definition of colors for cells
    let appRedColor = UIColor(hexString: "#fa8072ff")
    let appGreenColor = UIColor(hexString: "#79b1a0ff")
    let appBlueColor = UIColor(hexString: "#1b91bfff")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Comment view: " + messageID)
        
        getComments()
        
        self.refreshControl?.addTarget(self, action: "reloadComments:", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // number of cells
        var count = Int()
        
        if(objects.count == 0) {
            count = 1
        }
        else {
            count = objects.count
        }
 
        return count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("commentCell", forIndexPath: indexPath) as! CommentCell

        cell.commentLabel.textColor = UIColor.whiteColor()
        cell.createdAtLabel.textColor = UIColor.whiteColor()        
        
        cell.backgroundColor = UIColor.lightGrayColor()
        
        cell.contentView.layer.borderColor = UIColor.whiteColor().CGColor;
        cell.contentView.layer.borderWidth = 5.0
        
        var int = 0
        
        let count = objects.count
        
        // Placeholder if comments aren't available
        if(count == 0 ) {
            
            cell.commentLabel.text = "No comments available" as String
            cell.createdAtLabel.text = ""
            
            cell.backgroundColor = appRedColor
        }
        else {
            
            // Fill cells with messages
            for comment in objects {
           
                    // add comment to a cell
                    if (indexPath.row == int){
                
                        cell.commentLabel.text = comment.objectForKey("commentText") as! String

                        // get actual date
                        let dateFormatter = NSDateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                
                        let currentDate = NSDate()
                        let createdAt = comment.createdAt!
                
                        let diffDateComponents = NSCalendar.currentCalendar().components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day, NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second], fromDate: createdAt, toDate: currentDate, options: NSCalendarOptions.init(rawValue: 0))
                
                        // difference between comment time and actual time
                        if(diffDateComponents.year != 0) {
                    
                            if(diffDateComponents.year == 1) {
                                cell.createdAtLabel.text = "\(diffDateComponents.year) year ago"
                            }
                            else {
                                cell.createdAtLabel.text = "\(diffDateComponents.year) years ago"
                            }
                        }
                        else if(diffDateComponents.month != 0) {
                    
                            if(diffDateComponents.month == 1) {
                                cell.createdAtLabel.text = "\(diffDateComponents.month) month ago"
                            }
                            else {
                            cell.createdAtLabel.text = "\(diffDateComponents.month) months ago"
                            }
                        }
                        else if(diffDateComponents.hour != 0) {
                    
                            if(diffDateComponents.hour == 1) {
                                cell.createdAtLabel.text = "\(diffDateComponents.hour) hour ago"
                            }
                            else {
                                cell.createdAtLabel.text = "\(diffDateComponents.hour) hours ago"
                            }
                        }
                        else if(diffDateComponents.minute != 0) {
                    
                            if(diffDateComponents.minute == 1) {
                                cell.createdAtLabel.text = "\(diffDateComponents.minute) minute ago"
                            }
                            else {
                                cell.createdAtLabel.text = "\(diffDateComponents.minute) minutes ago"
                            }
                        }
                        else {
                    
                            if(diffDateComponents.second > 10) {
                                cell.createdAtLabel.text = "\(diffDateComponents.second) seconds"
                            }
                            else {
                                cell.createdAtLabel.text = "now"
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
        }
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "writeCommentSegue" {
            let vc : WriteCommentViewController = segue.destinationViewController as! WriteCommentViewController
            
            vc.messageID = messageID
            
            commentObjects.removeAll()
        }
    }
    
    
    /*
    *
    *   Function -  GET messages nearby
    *               based on your current location
    *
    */
    func getComments() -> [PFObject] {
        
        // Create a query for messages
        let query = PFQuery(className:"Comment")
        
        // Interested in messages within 10km near to user.
        query.whereKey("messageID", equalTo: messageID)
        
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
    *   Function -  GET messages nearby
    *               based on your current location
    *
    */
    func reloadComments(refreshControl: UIRefreshControl) -> [PFObject] {
        
        objects.removeAll()
        
        // Create a query for messages
        let query = PFQuery(className:"Comment")
        
        // Interested in comments which belong to message with messageID.
        query.whereKey("messageID", equalTo: messageID)
        
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
        
        self.tableView.reloadData()
        self.refreshControl!.endRefreshing()
        
        
        /*
        // SEND Request and GET final list of objects
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                
                for object in objects as [PFObject]! {
                    //self.comments.append(object.objectForKey("commentText") as! String)
                    
                    print(object)
                }
                
                self.tableView.reloadData()
                self.refreshControl!.endRefreshing()
            }
            else {}
            
           self.objects = objects!
        }
        */
        
        return self.objects
    }
}

