//
//  AppDelegate.swift
//  AdventCalendar
//
//  Created by Romain Pouclet on 2015-11-28.
//  Copyright © 2015 Perfectly-Cooked. All rights reserved.
//

import UIKit
import AWSS3
import Keys

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let keys = AdventcalendarKeys()
        
        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: keys.amazonS3AccessKey(), secretKey: keys.amazonS3SecretSecret())
        let configuration = AWSServiceConfiguration(region: .USEast1, credentialsProvider: credentialsProvider)
        AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = configuration


        return true
    }

}

