//
//  KeyboardViewController.swift
//  AdventKeyboard
//
//  Created by Romain Pouclet on 2015-11-28.
//  Copyright © 2015 Perfectly-Cooked. All rights reserved.
//

import UIKit
import YLGIFImage
import MobileCoreServices;

class KeyboardViewController: UIInputViewController {
    let gifView = UICollectionView(frame: CGRectZero, collectionViewLayout: UICollectionViewFlowLayout())
    let downloader = INDGIFPreviewDownloader(URLSessionConfiguration: NSURLSessionConfiguration.defaultSessionConfiguration())

    var gifs: [NSURL] = []
    let toolbar = UIStackView()
    var favorites = Set<String>()
    
    lazy private(set) var directory: NSURL? = {
        let manager = NSFileManager.defaultManager()
        return manager.containerURLForSecurityApplicationGroupIdentifier("group.perfectly-cooked.adventcalendar")!
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let path = self.directory?.URLByAppendingPathComponent("favorites.plist").path where NSFileManager.defaultManager().fileExistsAtPath(path) {
            self.favorites = Set<String>(NSArray(contentsOfFile: path) as! [String])
        }
        
        let switchKeyboardButton = UIButton(type: .Custom)
        switchKeyboardButton.setImage(UIImage(named: "switch"), forState: .Normal)
        switchKeyboardButton.imageView?.contentMode = .ScaleAspectFit
        switchKeyboardButton.addTarget(self, action: Selector("didTapSwitchButton:"), forControlEvents: .TouchUpInside)
        switchKeyboardButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        toolbar.addArrangedSubview(switchKeyboardButton)
        
        let deleteKeyboardButton = UIButton(type: .Custom)
        deleteKeyboardButton.setImage(UIImage(named: "delete"), forState: .Normal)
        deleteKeyboardButton.imageView?.contentMode = .ScaleAspectFit
        deleteKeyboardButton.addTarget(self, action: Selector("didTapDeleteButton:"), forControlEvents: .TouchUpInside)
        deleteKeyboardButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        toolbar.addArrangedSubview(deleteKeyboardButton)
        
        let listKeyboardButton = UIButton(type: .Custom)
        listKeyboardButton.setImage(UIImage(named: "list"), forState: .Normal)
        listKeyboardButton.imageView?.contentMode = .ScaleAspectFit
        listKeyboardButton.addTarget(self, action: Selector("didTapListButton:"), forControlEvents: .TouchUpInside)
        toolbar.addArrangedSubview(listKeyboardButton)
        
        view.addSubview(toolbar)
        toolbar.axis = .Horizontal
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.heightAnchor.constraintEqualToConstant(40).active = true
        toolbar.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor).active = true
        toolbar.leftAnchor.constraintEqualToAnchor(view.leftAnchor).active = true
        toolbar.rightAnchor.constraintEqualToAnchor(view.rightAnchor).active = true
        toolbar.distribution = .FillEqually
        let layout = gifView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: 105, height: 60)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        gifView.registerClass(ImageCell.self, forCellWithReuseIdentifier: "GIFCell")
        gifView.dataSource = self
        gifView.delegate = self

        view.addSubview(gifView)
        gifView.translatesAutoresizingMaskIntoConstraints = false
        gifView.topAnchor.constraintEqualToAnchor(view.topAnchor).active = true
        gifView.leftAnchor.constraintEqualToAnchor(view.leftAnchor).active = true
        gifView.rightAnchor.constraintEqualToAnchor(view.rightAnchor).active = true
        gifView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor, constant: -40).active = true
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let predicate: (String -> Bool)?
        if let path = self.directory?.URLByAppendingPathComponent("favorites.plist").path where NSFileManager.defaultManager().fileExistsAtPath(path) {
            let favorites = Set<String>(NSArray(contentsOfFile: path) as! [String])
            predicate = { favorites.contains($0) }
        } else {
            predicate = nil
        }
        
        self.gifs = gifsInDirectory(self.directory!, matchingPredicate: predicate)
        self.gifView.reloadData()
    }
    
    func didTapDeleteButton(sender: UIButton) {
        textDocumentProxy.deleteBackward()
    }
    
    func didTapListButton(sender: UIButton) {
        let vc = FilterSelectTableViewController(directory: directory!) { selection in
            switch selection {
            case .Day(let day):
                self.gifs = gifsInDirectory(self.directory!, matchingPredicate: { $0.hasPrefix("\(day)-") })
            case .Favorites:
                self.gifs = gifsInDirectory(self.directory!, matchingPredicate: { self.favorites.contains($0) })
            }
            
            self.gifView.reloadData()
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        presentViewController(vc, animated: true, completion: nil)
    }
    
    func didTapSwitchButton(sender: UIButton) {
        advanceToNextInputMode()
    }
}

extension KeyboardViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard let cell = collectionView.cellForItemAtIndexPath(indexPath) as? ImageCell else { return }
        
        let gif = gifs[indexPath.row]
        if let data = NSData(contentsOfURL: gif) {
            UIPasteboard.generalPasteboard().setData(data, forPasteboardType: kUTTypeGIF as String)
        }

        cell.showCopied()
    }
}

extension KeyboardViewController: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gifs.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("GIFCell", forIndexPath: indexPath) as! ImageCell
        let gif = gifs[indexPath.row]

        downloader.downloadGIFPreviewFrameAtURL(gif, completionQueue: dispatch_get_main_queue()) { image, error in
            if let image = image {
                let localCell = collectionView.cellForItemAtIndexPath(indexPath) as! ImageCell
                localCell.imageView.image = image
            }
        }

        return cell
    }
}

func gifsInDirectory(directory: NSURL, matchingPredicate: (String -> Bool)?) -> [NSURL] {
    let options : NSDirectoryEnumerationOptions = [.SkipsSubdirectoryDescendants, .SkipsHiddenFiles]
    guard let enumerator = NSFileManager.defaultManager().enumeratorAtURL(directory, includingPropertiesForKeys: nil, options: options, errorHandler: nil) else { return [] }
    
    guard let gifs = enumerator.allObjects.filter({ $0.pathExtension == "gif" }) as? [NSURL] else { return [] }
    
    if let matchingPredicate = matchingPredicate {
        return gifs.filter({ (url) -> Bool in
            guard let filename = url.lastPathComponent else { return false }
            return matchingPredicate(filename)
        })
    }
    
    return gifs
}
