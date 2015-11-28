
//
//  GiphyClient.swift
//  AdventCalendar
//
//  Created by Romain Pouclet on 2015-11-28.
//  Copyright © 2015 Perfectly-Cooked. All rights reserved.
//

import UIKit
import SwiftyJSON

public class GiphyClient: NSObject {
    public typealias Gif = NSURL
    
    public enum Result {
        case Success([Gif])
        case Error(NSError)
    }
    
    public typealias Completion = (result: Result) -> Void
    
    let key: String
    public init(key: String) {
        self.key = key

        super.init()
    }
    
    public func search(query: String, completion: Completion) {
        let comps = NSURLComponents(URL: NSURL(string: "https://api.giphy.com/v1/gifs/search")!, resolvingAgainstBaseURL: false)!
        comps.queryItems = [NSURLQueryItem(name: "api_key", value: key), NSURLQueryItem(name: "q", value: query)]
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(comps.URL!) { (data, _, error) -> Void in
            if let error = error {
                completion(result: .Error(error))
                return
            }
            
            guard let data = data else {
                completion(result: .Success([]))
                return
            }
            
            let payload = JSON(data: data)

            let imageNodes = payload["data"].array?.map({ (imageNode) -> NSURL? in
                if let urlString = imageNode["images"]["downsized"]["url"].string, let url = NSURL(string: urlString) {
                    return url
                }
                
                return nil
            }).filter({ $0 != nil }).map({ $0! })
            completion(result: .Success(imageNodes ?? []))
        }
        
        task.resume()
    }
}
