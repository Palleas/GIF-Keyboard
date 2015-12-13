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
    let favoriteImage: UIImageView = {
        let star = UIImageView(image: UIImage(named: "favorite")?.imageWithRenderingMode(.AlwaysTemplate))
        star.hidden = true
        star.tintColor = .redColor()
        star.translatesAutoresizingMaskIntoConstraints = false

        return star
    }()
    
    var favorite: Bool = false {
        didSet {
            favoriteImage.hidden = !favorite
        }
    }
    
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
        
        contentView.addSubview(favoriteImage)
        favoriteImage.widthAnchor.constraintEqualToConstant(20).active = true
        favoriteImage.heightAnchor.constraintEqualToConstant(20).active = true
        favoriteImage.topAnchor.constraintEqualToAnchor(contentView.topAnchor, constant: 20).active = true
        favoriteImage.leftAnchor.constraintEqualToAnchor(contentView.leftAnchor, constant: 20).active = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        preview.image = nil
    }
}
