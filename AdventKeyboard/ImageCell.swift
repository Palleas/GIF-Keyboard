//
//  ImageCell.swift
//  AdventCalendar
//
//  Created by Romain Pouclet on 2015-11-28.
//  Copyright © 2015 Perfectly-Cooked. All rights reserved.
//

import UIKit
import YLGIFImage

class ImageCell: UICollectionViewCell {
    let imageView = YLImageView()
    let copiedView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .ScaleAspectFit
        imageView.topAnchor.constraintEqualToAnchor(contentView.topAnchor).active = true
        imageView.bottomAnchor.constraintEqualToAnchor(contentView.bottomAnchor).active = true
        imageView.leftAnchor.constraintEqualToAnchor(contentView.leftAnchor).active = true
        imageView.rightAnchor.constraintEqualToAnchor(contentView.rightAnchor).active = true
        
        contentView.addSubview(copiedView)
        copiedView.translatesAutoresizingMaskIntoConstraints = false
        copiedView.topAnchor.constraintEqualToAnchor(contentView.topAnchor).active = true
        copiedView.bottomAnchor.constraintEqualToAnchor(contentView.bottomAnchor).active = true
        copiedView.leftAnchor.constraintEqualToAnchor(contentView.leftAnchor).active = true
        copiedView.rightAnchor.constraintEqualToAnchor(contentView.rightAnchor).active = true
        copiedView.backgroundColor = UIColor.blueColor().colorWithAlphaComponent(0.5)
        copiedView.alpha = 0
        
        let copiedImage = UIImageView(image: UIImage(named: "copied")?.imageWithRenderingMode(.AlwaysTemplate))
        copiedImage.tintColor = .whiteColor()
        copiedView.addSubview(copiedImage)
        copiedImage.contentMode = .ScaleAspectFit
        copiedImage.translatesAutoresizingMaskIntoConstraints = false
        copiedImage.centerXAnchor.constraintEqualToAnchor(contentView.centerXAnchor).active = true
        copiedImage.centerYAnchor.constraintEqualToAnchor(contentView.centerYAnchor).active = true
        copiedImage.heightAnchor.constraintEqualToAnchor(contentView.heightAnchor, multiplier: 0.5).active = true
    }
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showCopied() {
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.copiedView.alpha = 1
        }) { (_) -> Void in
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.copiedView.alpha = 0
            })
        }
    }
    

}
