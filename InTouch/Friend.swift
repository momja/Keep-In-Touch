//
//  Friend.swift
//  InTouch
//
//  Created by Maxwell James Omdal on 6/14/16.
//  Copyright © 2016 Maxwell James Omdal. All rights reserved.
//

import UIKit
import ContactsUI


class Friend: NSObject, NSCoding {
    // MARK: - Properties
    
    var identifier: String
    var frequency: Int
    var dateTime: NSDate
    
    var color: UIColor
    
    var contact : CNContact?
    var phoneNumber: CNPhoneNumber?
    
    struct Color {
        // #329F5B
        static let green = UIColor(red:0.61, green:0.77, blue:0.24, alpha:1.0)
        // #F4E285
        static let yellow = UIColor(red:0.99, green:0.91, blue:0.3, alpha:1.0)
        // #E3655B
        static let red = UIColor(red:0.76, green:0.26, blue:0.25, alpha:1.0)
    }
        
    // MARK: - Archiving Paths
    
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("friends")
    
    // MARK: - Types
    
    struct PropertyKey {
        static let nameKey = "name"
        static let dateTimeKey = "date"
        static let frequencyKey = "frequency"
        static let identifierKey = "identifier"
    }
    
    // MARK: - Initialization
    
    init?(dateTime: NSDate, frequency: Int, identifier: String) {
        
        // Initialize stored properties.
        self.dateTime = dateTime
        self.frequency = frequency
        
        self.color = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        
        self.identifier = identifier
        
        super.init()
        
        self.contact = getContact()
        
        // TODO: - Make it the main number, not just the first one
        if self.phoneNumber != nil {
            self.phoneNumber = self.contact?.phoneNumbers[0].value as? CNPhoneNumber
            print("Phone number of: ", self.contact?.givenName)
        }
        else {
            print ("No phone number for this contact")
        }
        
        // Initialization should fail if there is no name or if the rating is negative.
       
        if identifier.isEmpty {
            return nil
        }
        
        sinceLastContact()
    }
    
    // MARK: - CNContact
    
    func getContact() -> CNContact? {
        var contact: CNContact?
        AppDelegate.getAppDelegate().requestForAccess { (accessGranted) -> Void in
            if accessGranted {
                let store = AppDelegate.getAppDelegate().contactStore
                do {
                    contact = try store.unifiedContactWithIdentifier(self.identifier, keysToFetch: [CNContactFormatter.descriptorForRequiredKeysForStyle(.FullName), CNContactImageDataKey, CNContactPhoneNumbersKey])
                    print("fetching ", contact!.givenName, " contact")
                }
                catch {
                    print("contact is missing information")
                    contact = nil
                }
            }
        }
        return contact
    }
    
    // MARK: - Date Handling
    
    func sinceLastContact() {
        let difference = self.dateTime.timeIntervalSinceNow
        print(self.dateTime)
        print(NSDate())
        print(difference)
        if (-difference < Double(frequency*86400)) {
            print("You have seen \(self.contact?.givenName) fairly recently")
            self.color = Color.green
        }
        else if (-difference < Double(frequency*2*86400)) {
            print("It's been a while since you last saw \(self.contact?.givenName), maybe you should give him a visit")
            self.color = Color.yellow
        }
        else {
            print("You need to visit your friend \(self.contact?.givenName)")
            self.color = Color.red
        }
    }
    
    func updateLastContact() {
        dateTime = NSDate()
        sinceLastContact()
        
        let cal = NSCalendar.currentCalendar()
        
        let dateComps = NSDateComponents()
        dateComps.day = self.frequency
        
        let fireDate: NSDate = cal.dateByAddingComponents(dateComps, toDate: dateTime, options: NSCalendarOptions())!
        
        let notification: UILocalNotification = UILocalNotification()
        
        notification.alertBody = "Hey you haven't seen \((self.contact?.givenName)!) for a while. Reach out to him!"
        notification.fireDate = fireDate
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    // MARK: - NSCoding
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(dateTime, forKey: PropertyKey.dateTimeKey)
        aCoder.encodeInteger(frequency, forKey: PropertyKey.frequencyKey)
        aCoder.encodeObject(identifier, forKey: PropertyKey.identifierKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let dateTime = aDecoder.decodeObjectForKey(PropertyKey.dateTimeKey) as! NSDate
        let frequency = aDecoder.decodeIntegerForKey(PropertyKey.frequencyKey)
        let identifier = aDecoder.decodeObjectForKey(PropertyKey.identifierKey) as! String
        
        self.init(dateTime: dateTime, frequency: frequency, identifier: identifier)
    }
        
}