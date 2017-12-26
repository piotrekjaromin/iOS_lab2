//
//  MessageTableViewCell.swift
//  iOS_lab2
//
//  Created by Admin on 24/12/2017.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var details: UILabel!
    @IBOutlet weak var timestamp: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
