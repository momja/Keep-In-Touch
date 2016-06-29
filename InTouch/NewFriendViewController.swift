//
//  Settings.swift
//  InTouch
//
//  Created by Maxwell James Omdal on 6/15/16.
//  Copyright © 2016 Maxwell James Omdal. All rights reserved.
//

import UIKit
import ContactsUI

class NewFriendViewController: UIViewController, UINavigationControllerDelegate, CNContactPickerDelegate {
    
    // MARK: - Actions
    
    @IBOutlet weak var alertSwitch: UISwitch!
    @IBOutlet weak var nameTextField: UILabel!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var addExisting: UIButton!
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        let isPresentingInAddFriendMode = presentingViewController is UINavigationController
        if isPresentingInAddFriendMode {
            dismissViewControllerAnimated(true, completion: nil)
        }
        else {
            navigationController!.popViewControllerAnimated(true)
        }
    }
    
    // MARK: - Initialization
    
    var friend: Friend?
    var contact: CNContact?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addExisting.addTarget(self, action: #selector(addExistingContact), forControlEvents: UIControlEvents.TouchUpInside)
        
        if let friend = friend {
            if (((friend.contact?.familyName) == nil)) {
                nameTextField.text = friend.contact?.givenName
            }
            else {
                nameTextField.text = (friend.contact?.givenName)! + " " + (friend.contact?.familyName)!
            }
            segmentedControl.selectedSegmentIndex = friend.frequency
        }
        
        checkValidFriendName()
        
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        // Hide the keyboard
        
        textField.resignFirstResponder()
        return true
        
    }
    
    func checkValidFriendName() {
        // Disable the Save button if the text field is empty.
        let text = nameTextField.text ?? ""
        saveButton.enabled = !text.isEmpty
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        checkValidFriendName()
    }
    
    
    
    // MARK: - Navigation
    
    func addExistingContact() {
        let contactPicker = CNContactPickerViewController()
        contactPicker.delegate = self
        self.presentViewController(contactPicker, animated: true, completion: nil)
    }
    
    func contactPicker(picker: CNContactPickerViewController, didSelectContact contact: CNContact) {
        nameTextField.text = contact.givenName + " " + contact.familyName
        
        // TODO: - Figure out how to find the main phone number and link to button on main screen
        //friend?.phoneNumber = contact.phoneNumbers.indexOf(CNLabelPhoneNumberMain)
        
        self.contact = contact
        
        checkValidFriendName()
        
    }
    
    // This method lets you configure a view controller before it's presented.
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if saveButton === sender {
            var frequency: Int {
                switch segmentedControl.selectedSegmentIndex {
                case 0:
                    return 1
                case 1:
                    return 3
                case 2:
                    return 7
                case 3:
                    return 15
                case 4:
                    return 30
                default:
                    return 1
                }
            }
            
            // TODO: - is nil when runs
            let identifier = self.contact?.identifier
            
            if (self.friend?.dateTime == nil) {
                let date = NSDate()
                
                // Set the friend to be passed to MealListTableViewController after the unwind segue.
                friend = Friend(dateTime: date, frequency: frequency, identifier: identifier!)
                
                friend?.updateLastContact()
            }
            
            else {
                // Set the friend to be passed to MealListTableViewController after the unwind segue.
                friend = Friend(dateTime: (friend?.dateTime)!, frequency: frequency, identifier: (self.friend?.contact?.identifier)!)
            }
        }
    }
}
