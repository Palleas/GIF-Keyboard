//
//  KeyboardViewController.swift
//  AdventKeyboard
//
//  Created by Romain Pouclet on 2015-11-28.
//  Copyright © 2015 Perfectly-Cooked. All rights reserved.
//

import UIKit
import SwiftGifiOS
import YLGIFImage
import MobileCoreServices;

class KeyboardViewController: UIInputViewController {
    let gifView = UICollectionView(frame: CGRectZero, collectionViewLayout: UICollectionViewFlowLayout())
    var gifs: [NSURL] = []
    let toolbar = UIStackView()
    
    lazy private(set) var directory: NSURL? = {
        let manager = NSFileManager.defaultManager()
        return manager.containerURLForSecurityApplicationGroupIdentifier("group.perfectly-cooked.adventcalendar")!
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        self.gifs = gifsInDirectory(self.directory!, prefix: nil)
        self.gifView.reloadData()
    }
    
    func didTapDeleteButton(sender: UIButton) {
        textDocumentProxy.deleteBackward()
    }
    
    func didTapListButton(sender: UIButton) {
        let vc = DaysTableViewController(directory: directory!) { day in
            self.gifs = gifsInDirectory(self.directory!, prefix: "\(day)-")
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
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            if let data = NSData(contentsOfURL: gif) {
                dispatch_async(dispatch_get_main_queue()) {
                    let localCell = collectionView.cellForItemAtIndexPath(indexPath) as! ImageCell
                    localCell.imageView.image = UIImage(data: data)
                }
            }
        }
        
        return cell
    }
}

func gifsInDirectory(directory: NSURL, prefix: String?) -> [NSURL] {
    let options : NSDirectoryEnumerationOptions = [.SkipsSubdirectoryDescendants, .SkipsHiddenFiles]
    guard let enumerator = NSFileManager.defaultManager().enumeratorAtURL(directory, includingPropertiesForKeys: nil, options: options, errorHandler: nil) else { return [] }
    
    guard let gifs = enumerator.allObjects.filter({ $0.pathExtension == "gif" }) as? [NSURL] else { return [] }
    
    if let prefix = prefix {
        return gifs.filter({ (url) -> Bool in
            guard let filename = url.lastPathComponent else { return false }
            return filename.hasPrefix(prefix)
        })
    }
    
    return gifs
}
