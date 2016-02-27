//
//  WriteCommentViewController.swift
//  Jodel2
//
//  Created by David Ganshorn on 12/6/15.
//  Copyright © 2015 Christoph Mueller. All rights reserved.
//

import UIKit
import CoreLocation
import Parse
import Bolts

class WriteCommentViewController: UIViewController, UITextViewDelegate {
    
    // MessageId for comment
    var messageID = String()
    
    @IBOutlet var sended: UITextView!
    
    var msgs = [String]() //stores only all messages sent inside a local array
    var messagesArray = [Message]() //stores the messages sent as well as the device ID
    
    
    @IBOutlet weak var sendMessageBarButton: UIBarButtonItem!

    override func viewDidLoad() {
        sended.delegate = self
        
        super.viewDidLoad()
    }
    
    @IBAction func sendMessage(sender: UIBarButtonItem) {

        //store text in variable
        let inputMsg = sended.text
        
        /*
        *
        *   SEND -  SEND comment with
        *           text, your deviceID, initial rating = 0 and
        *           your current location
        *
        */
        var comment = PFObject(className:"Comment")
        
        comment["commentText"] = inputMsg
        
        comment["messageID"] = messageID
        
        comment.saveInBackgroundWithBlock {
            
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                print("success")
                
                let alertController = UIAlertController(title: "My Jodel", message:
                    "May the force be with you!", preferredStyle: UIAlertControllerStyle.Alert)
                
                alertController.addAction(UIAlertAction(title: "Success", style: UIAlertActionStyle.Default,handler: nil))
                
                self.presentViewController(alertController, animated: true, completion: nil)
                
                // clear Field should come after succesfull sending
                self.sended.text = "Tell us another Story...."
            }
            else {
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
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        sended.text=""
    }
    
    override func didMoveToParentViewController(parent: UIViewController?) {
        if (!(parent?.isEqual(self.parentViewController) ?? false)) {
           // print("Back Button Pressed!")
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
