//
//  DayCollectionViewCell.swift
//  AdventCalendar
//
//  Created by Romain Pouclet on 2015-11-30.
//  Copyright © 2015 Perfectly-Cooked. All rights reserved.
//

import UIKit

class DayCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var dayLabel: UILabel! {
        didSet {
            dayLabel.textColor = .whiteColor()
            dayLabel.font = UIFont(name: "PWChristmasfont", size: 50)!
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.layer.borderColor = UIColor.whiteColor().CGColor
        contentView.layer.borderWidth = 1.0
        contentView.layer.cornerRadius = 20
    }
    
    override var selected: Bool {
        didSet {
            if selected {
                contentView.backgroundColor = .whiteColor()
                dayLabel.textColor = .blackColor()
            } else {
                contentView.backgroundColor = .clearColor()
                dayLabel.textColor = .whiteColor()
            }
        }
    }
}
