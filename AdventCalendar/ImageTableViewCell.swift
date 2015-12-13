//
//  ImageTableViewCell.swift
//  AdventCalendar
//
//  Created by Romain Pouclet on 2015-12-13.
//  Copyright © 2015 Perfectly-Cooked. All rights reserved.
//

import UIKit

class ImageTableViewCell: UITableViewCell {
    let preview = UIImageView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .None
        
        preview.translatesAutoresizingMaskIntoConstraints = false
        preview.contentMode = .ScaleAspectFit
        contentView.addSubview(preview)

        preview.topAnchor.constraintEqualToAnchor(contentView.topAnchor).active = true
        preview.rightAnchor.constraintEqualToAnchor(contentView.rightAnchor).active = true
        preview.bottomAnchor.constraintEqualToAnchor(contentView.bottomAnchor).active = true
        preview.leftAnchor.constraintEqualToAnchor(contentView.leftAnchor).active = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        preview.image = nil
    }
}
