//
//  TourTableCell.swift
//  CS147HiFi
//
//  Created by clmeiste on 11/30/17.
//  Copyright © 2017 StanfordX. All rights reserved.
//

import UIKit

class TourTableCell: UITableViewCell {

    @IBOutlet weak var tourName: UILabel!
    @IBOutlet weak var tourDuration: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
