//
//  AddFriendsTableViewCell.swift
//  PokerGameApp
//
//  Created by Cui Jing on 12/1/15.
//  Copyright © 2015 Jingplusplus. All rights reserved.
//

import UIKit

class AddFriendsTableViewCell: UITableViewCell {

    
    @IBOutlet weak var pokerImage: UIImageView!
    
    @IBOutlet weak var username: UITextField!
    var cellselected : Bool = false
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
