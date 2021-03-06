//
//  Friend.swift
//  InTouch
//
//  Created by Maxwell James Omdal on 6/14/16.
//  Copyright © 2016 Maxwell James Omdal. All rights reserved.
//

import UIKit

class FriendTableViewCell: UITableViewCell {
    
    // MARK: Properties
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var contactImage: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        nameLabel.adjustsFontSizeToFitWidth = true
        contactImage.layer.cornerRadius = contactImage.layer.frame.width/2
        contactImage.layer.masksToBounds = true
        contactImage.layer.borderWidth = 0
        self.backgroundColor = UIColor.clearColor()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
