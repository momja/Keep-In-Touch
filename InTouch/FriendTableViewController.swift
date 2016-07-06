//
//  FriendTableViewController.swift
//  InTouch
//
//  Created by Maxwell James Omdal on 6/14/16.
//  Copyright © 2016 Maxwell James Omdal. All rights reserved.
//

import UIKit
import MessageUI

class FriendTableViewController: UITableViewController, UIGestureRecognizerDelegate, MFMessageComposeViewControllerDelegate {
    
    // MARK: Properties
    
    var indexEdit : NSIndexPath?
    
    var friends = [Friend]()
    
    // MARK: - Initialization

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        
        // Make a long press gesture to recognize edits.
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(self.longTap))
        gesture.minimumPressDuration = 0.2
        self.tableView.addGestureRecognizer(gesture)
        
        // Load any saved friends, otherwise, load sample data.
        AppDelegate.getAppDelegate().requestForAccess { (accessGranted) -> Void in
            if accessGranted {
                if let savedFriends = self.loadFriends() {
                    self.friends += savedFriends
                }
            }
            else {
                print("cannot access contacts. Using sample contacts")
                //Load sample data if there is no saved data.
                self.loadSampleFriends()
            }
        }
        
    }
    
    func loadSampleFriends() {
        let sample = SampleContact()
        let friend1 = Friend(dateTime: NSDate(), frequency: 3, identifier: sample.identifier)!
        
        friends += [friend1]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return friends.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("friendCell", forIndexPath: indexPath) as! FriendTableViewCell
        
        let friend = friends[indexPath.row]
        
        if let lastName = friend.contact?.familyName {
            print(Array(arrayLiteral: lastName)[0])
            cell.nameLabel.text = (friend.contact?.givenName)! + " " + String(Array(lastName.characters)[0]) + "."
        }
        else {
            cell.nameLabel.text = friend.contact?.givenName
        }
        
        if let imageData = friend.contact?.imageData {
            cell.contactImage.image = UIImage(data: imageData)
        }
        else {
            cell.contactImage.image = UIImage(named: "Default_Contact_Photo")
        }
        // TODO: Change colors
        cell.messageButton.tag = indexPath.row
        cell.messageButton.addTarget(self, action: #selector(self.didClickMessage), forControlEvents: UIControlEvents.TouchUpInside)

        // Configure the cell...

        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        let editAction = UITableViewRowAction(style: .Normal, title: "Delete") {
            (action: UITableViewRowAction!, indexPath: NSIndexPath!) -> Void in
            
            print("Deleting Cell")
            self.friends.removeAtIndex(indexPath.row)
            self.saveFriends()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            tableView.reloadData()
        }
        
        editAction.backgroundColor = UIColor.redColor()
        
        return [editAction]
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let friend = self.friends[indexPath.row]
        friend.updateLastContact()
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! FriendTableViewCell
        // TODO: - Color
    }
    
    // MARK: - Navigation
        
    func didClickMessage(sender: UIButton) {
        let composeVC = MFMessageComposeViewController()
        composeVC.messageComposeDelegate = self
        // Make sure the device can send text messages
        if (MFMessageComposeViewController.canSendText()) {
            // Obtain a configured MFMessageComposeViewController
            
            let number = friends[sender.tag].phoneNumber?.stringValue
            // Configure the fields of the interface.
            if number != nil {
                composeVC.recipients = [number!]
                composeVC.body = "Hey how's it going! \r\n (Sent via Keep In Touch App)"
            }
            else {
                print ("you cannot send messages to \(friends[sender.tag]) because there is no number associated with this contact")
            }
            
            // Present the view controller modally.
            self.presentViewController(composeVC, animated: true, completion: nil)
        }
        else {
            print("Message failed")
            // TODO: - Let the user know if his/her device isn't able to send text messages
        }
    }
    
    // MFMessageComposeViewControllerDelegate callback - dismisses the view controller when the user is finished with it
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        // Dismiss the mail compose view controller.
        controller.dismissViewControllerAnimated(true, completion: nil)
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        if segue.identifier == "ShowDetail" {
            let friendDetailViewController = segue.destinationViewController as! NewFriendViewController
            // Get the cell that generated this segue.
            if let selectedFriendCell = sender as? FriendTableViewCell {
                let indexPath = tableView.indexPathForCell(selectedFriendCell)!
                let selectedFriend = friends[indexPath.row]
                friendDetailViewController.friend = selectedFriend
                friendDetailViewController.friend?.dateTime = selectedFriend.dateTime
            }
        }
        else if segue.identifier == "AddItem" {
            print("Adding new Friend")
        }
    }
    
    @IBAction func unwindToFriendsList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.sourceViewController as? NewFriendViewController, friend = sourceViewController.friend {
            
            if let selectedIndexpath = self.indexEdit {
                //Edit an existing friend
                friends[selectedIndexpath.row] = friend
                print(friend.contact?.givenName)
                tableView.reloadRowsAtIndexPaths([selectedIndexpath], withRowAnimation: .None)
                print("Edits Made")
                self.indexEdit = nil
            }
                
            else {
                // Add a new friend.
                print("Adding friend...")
                let newIndexPath = NSIndexPath(forRow: friends.count, inSection: 0)
                friends.append(friend)
                tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Bottom)
                print("Friend added")
            }
            
            //Save Friends
            saveFriends()
        }
    }
    
    func longTap(recognizer: UIGestureRecognizer) {
        if recognizer.state == UIGestureRecognizerState.Began {
            
            let tapLocation = recognizer.locationInView(self.tableView)
            if let tapIndexPath = tableView.indexPathForRowAtPoint(tapLocation) {
                if let tappedCell = self.tableView.cellForRowAtIndexPath(tapIndexPath) {
                    // Swipe happened. Do stuff!
                    indexEdit = tableView.indexPathForCell(tappedCell)!
                    self.performSegueWithIdentifier("ShowDetail", sender: tappedCell)
                }
            }
        }
    }
    
    // MARK: - NSCoding
    
    func saveFriends() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(friends, toFile: Friend.ArchiveURL.path!)
        
        if !isSuccessfulSave {
            print("Failed to save friend")
        }
    }
    
    func loadFriends() -> [Friend]? {
        return (NSKeyedUnarchiver.unarchiveObjectWithFile(Friend.ArchiveURL.path!) as? [Friend])
    }

}
