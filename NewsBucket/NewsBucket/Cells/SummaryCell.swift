//
//  SummaryCell.swift
//  NewsBucket
//
//  Created by Peter Du on 14/4/20.
//  Copyright © 2020 Peter Du. All rights reserved.
//

import UIKit

class SummaryCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var imageMode: UIImageView!
    
    var selectedMode: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
        if selectedMode == 0 {
            imageMode.image = UIImage(systemName: "chevron.right")
            imageMode.tintColor = UIColor.systemYellow
        } else {
            imageMode.image = UIImage(systemName: "minus.circle.fill")
            imageMode.tintColor = UIColor.systemRed
        }
    }
    
}
