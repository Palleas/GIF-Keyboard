//
//  ViewController.swift
//  AdventCalendar
//
//  Created by Romain Pouclet on 2015-11-28.
//  Copyright © 2015 Perfectly-Cooked. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let background = UIImageView(image: UIImage(named: "background")!)
        background.contentMode = .Top
        background.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(background, atIndex: 0)
        background.topAnchor.constraintEqualToAnchor(view.topAnchor).active = true
        background.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor).active = true
        background.leftAnchor.constraintEqualToAnchor(view.leftAnchor).active = true
        background.rightAnchor.constraintEqualToAnchor(view.rightAnchor).active = true
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 24
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("DayCell", forIndexPath: indexPath) as! DayCollectionViewCell
        cell.dayLabel.text = "\(indexPath.row + 1)"
        
        return cell
    }
}

