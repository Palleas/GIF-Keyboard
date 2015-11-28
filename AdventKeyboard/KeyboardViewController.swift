//
//  KeyboardViewController.swift
//  AdventKeyboard
//
//  Created by Romain Pouclet on 2015-11-28.
//  Copyright © 2015 Perfectly-Cooked. All rights reserved.
//

import UIKit
import AdventCalendarKit
import MobileCoreServices

class KeyboardViewController: UIInputViewController {
    let gifView = UICollectionView(frame: CGRectZero, collectionViewLayout: UICollectionViewFlowLayout())

    let client  = GiphyClient(key: "dc6zaTOxFJmzC")
    var gifs: [GiphyClient.Gif] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gifView.registerClass(ImageCell.self, forCellWithReuseIdentifier: "GIFCell")
        gifView.dataSource = self
        gifView.delegate = self

        view.addSubview(gifView)
        gifView.translatesAutoresizingMaskIntoConstraints = false
        gifView.topAnchor.constraintEqualToAnchor(view.topAnchor).active = true
        gifView.leftAnchor.constraintEqualToAnchor(view.leftAnchor).active = true
        gifView.rightAnchor.constraintEqualToAnchor(view.rightAnchor).active = true
        gifView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor).active = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        client.search("doctor who") { (result) -> Void in
            print(result)
            switch result {
            case .Success(let gifs):
                self.gifs = gifs
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.gifView.reloadData()
                })
            case .Error(let error):
                print("Oh noes \(error)")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated
    }

    override func textWillChange(textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
    }

    override func textDidChange(textInput: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.
    
//        var textColor: UIColor
//        let proxy = self.textDocumentProxy
//        if proxy.keyboardAppearance == UIKeyboardAppearance.Dark {
//            textColor = UIColor.whiteColor()
//        } else {
//            textColor = UIColor.blackColor()
//        }
//        self.nextKeyboardButton.setTitleColor(textColor, forState: .Normal)
    }

}

extension KeyboardViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("Copied1 ? ")
        guard let cell = collectionView.cellForItemAtIndexPath(indexPath) as? ImageCell else { return }
        print("Copied2 ? ")
        guard let image = cell.imageView.image else { return }
        
        UIPasteboard.generalPasteboard().image = image
        print("copied")
    }
}

extension KeyboardViewController: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gifs.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("GIFCell", forIndexPath: indexPath) as! ImageCell
        
        let gif = gifs[indexPath.row]
        NSURLSession.sharedSession().dataTaskWithURL(gif) { (data, _, error) -> Void in
            guard let data = data else { return }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let image = UIImage(data: data)
                let cell = self.gifView.cellForItemAtIndexPath(indexPath) as! ImageCell
                cell.imageView.image = image
            })
        }.resume()
        
        return cell
    }
}
