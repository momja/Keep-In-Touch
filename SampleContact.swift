//
//  sampleContact.swift
//  InTouch
//
//  Created by Maxwell James Omdal on 6/25/16.
//  Copyright © 2016 Maxwell James Omdal. All rights reserved.
//

import Contacts

class SampleContact: CNMutableContact {
    
    override init() {
        
        super.init()
        
        self.givenName = "John"
        self.familyName = "Appleseed"
        
        let homeEmail = CNLabeledValue(label:CNLabelHome, value:"john@example.com")
        let workEmail = CNLabeledValue(label:CNLabelWork, value:"j.appleseed@icloud.com")
        self.emailAddresses = [homeEmail, workEmail]
        
        self.phoneNumbers = [CNLabeledValue(label:CNLabelPhoneNumberiPhone,value:CNPhoneNumber(stringValue:"(408) 555-0126"))]
        
        let homeAddress = CNMutablePostalAddress()
        homeAddress.street = "1 Infinite Loop"
        homeAddress.city = "Cupertino"
        homeAddress.state = "CA"
        homeAddress.postalCode = "95014"
        self.postalAddresses = [CNLabeledValue(label:CNLabelHome, value:homeAddress)]
        
        let birthday = NSDateComponents()
        birthday.day = 1
        birthday.month = 4
        birthday.year = 1988  // You can omit the year value for a yearless birthday
        self.birthday = birthday
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}