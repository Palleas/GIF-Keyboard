//
//  ViewController.swift
//  AdventCalendar
//
//  Created by Romain Pouclet on 2015-11-28.
//  Copyright © 2015 Perfectly-Cooked. All rights reserved.
//

import UIKit
import Foundation
import AWSS3
import SVProgressHUD
import ReactiveCocoa

class ViewController: UIViewController {
    private(set) var downloadRequests = Array<AWSS3TransferManagerDownloadRequest?>()
    private(set) var downloadFileURLs = Array<NSURL?>()

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

extension ViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        let calendar = NSCalendar.currentCalendar()
        let comps = calendar.components([.Day, .Month, .Year], fromDate: NSDate())
        if comps.year == 2015 && comps.month < 12 {
            return true
        }
        
        if comps.year == 2015 && indexPath.row + 1 > comps.day {
            return false
        }
        
        return true
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            SVProgressHUD.showWithStatus("Downloading...")
        })
        
        let directory = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("group.perfectly-cooked.adventcalendar")!

        listBucketSignalProducer("pcscalendar", prefix: "\(indexPath.row + 1)-")
            .flatMap(.Concat) { (object) -> SignalProducer<NSURL, NSError> in
                return self.downloadObject("pcscalendar", key: object.key, directory: directory)
            }
            .collect()
            .on(failed: { print("Got error: \($0)") })
            .observeOn(UIScheduler())
            .startWithNext { (urls) -> () in
                SVProgressHUD.dismiss()
            }
    }
    
    func downloadObject(bucket: String, key: String, directory: NSURL) -> SignalProducer<NSURL, NSError> {
        return SignalProducer { sink, disposable in
            let downloadRequest = AWSS3TransferManagerDownloadRequest()
            downloadRequest.bucket = bucket
            downloadRequest.key = key
            downloadRequest.downloadingFileURL = directory.URLByAppendingPathComponent(key)
            print(downloadRequest.downloadingFileURL)
            
            let transferManager = AWSS3TransferManager.defaultS3TransferManager()
            transferManager.download(downloadRequest).continueWithBlock({ (task) -> AnyObject! in
                if let error = task.error {
                    sink.sendFailed(error)
                } else {
                    sink.sendNext(downloadRequest.downloadingFileURL)
                    sink.sendCompleted()
                }
                
                return nil
            })
        }
    }
    
    func listBucketSignalProducer(bucket: String, prefix: String) -> SignalProducer<AWSS3Object, NSError> {
        return SignalProducer { sink, disposable in
            let s3 = AWSS3.defaultS3()
            let listObjectsRequest = AWSS3ListObjectsRequest()
            listObjectsRequest.bucket = bucket
            listObjectsRequest.prefix = prefix
            s3.listObjects(listObjectsRequest).continueWithBlock({ (task) -> AnyObject! in
                if let error = task.error {
                    print("listObjects failed: [\(error)]")
                    sink.sendFailed(error)
                }
                
                if let listObjectsOutput = task.result as? AWSS3ListObjectsOutput, let contents = listObjectsOutput.contents as? [AWSS3Object] {
                    contents.forEach({ (object) -> () in
                        sink.sendNext(object)
                    })
                    sink.sendCompleted()
                }

                return nil
            })

        }
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

