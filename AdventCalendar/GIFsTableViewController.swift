//
//  GIFsTableViewController.swift
//  AdventCalendar
//
//  Created by Romain Pouclet on 2015-12-13.
//  Copyright © 2015 Perfectly-Cooked. All rights reserved.
//

import UIKit
import SwiftGifOrigin

class GIFsTableViewController: UITableViewController {
    typealias Completion = () -> ()
    
    let directory: NSURL
    let completion: Completion
    var favorites = Set<String>()
    
    private var images = [NSURL]()
    
    init(directory: NSURL, completion: Completion) {
        self.directory = directory
        self.completion = completion
        
        super.init(style: .Plain)

        if let path = directory.URLByAppendingPathComponent("favorites.plist").path where NSFileManager.defaultManager().fileExistsAtPath(path) {
            self.favorites = Set(NSArray(contentsOfFile: path) as! [String])
            print(favorites)
        }
        
        tableView.separatorStyle = .None
        tableView.registerClass(ImageTableViewCell.self, forCellReuseIdentifier: "ImageCell")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let options : NSDirectoryEnumerationOptions = [.SkipsSubdirectoryDescendants, .SkipsHiddenFiles]
        guard let enumerator = NSFileManager.defaultManager().enumeratorAtURL(directory, includingPropertiesForKeys: nil, options: options, errorHandler: nil) else { return }
        
        guard let gifs = enumerator.allObjects.filter({ $0.pathExtension == "gif" }) as? [NSURL] else { return }
        
        self.images = gifs
        self.tableView.reloadData()
        
        navigationController?.navigationBar.tintColor = .blueColor()
        
        let done = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: Selector("didTapDone"))
        navigationItem.rightBarButtonItem = done
    }
    
    func didTapDone() {
        NSArray(array: Array(favorites)).writeToURL(directory.URLByAppendingPathComponent("favorites.plist"), atomically: true)
        self.completion()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ImageCell", forIndexPath: indexPath)
        let gif = images[indexPath.row]
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            if let data = NSData(contentsOfURL: gif) {
                dispatch_async(dispatch_get_main_queue()) {
                    let localCell = tableView.cellForRowAtIndexPath(indexPath) as! ImageTableViewCell
                    localCell.preview.image = UIImage.gifWithData(data)
                    
                    if let filename = gif.lastPathComponent where self.favorites.contains(filename) {
                        localCell.favorite = true
                    } else {
                        localCell.favorite = false
                    }
                }
            }
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 150
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let image = images[indexPath.row].lastPathComponent else { return }
        
        if favorites.contains(image) {
            favorites.remove(image)
        } else {
            favorites.insert(image)
        }
        
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
}
