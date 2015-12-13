//
//  DaysTableViewController.swift
//  AdventCalendar
//
//  Created by Romain Pouclet on 2015-12-09.
//  Copyright © 2015 Perfectly-Cooked. All rights reserved.
//

import UIKit

class DaysTableViewController: UITableViewController {
    typealias Completion = (day: String) -> Void
    
    let directory: NSURL
    let completion: Completion
    private(set) var manifest: [String: String] = [:]
    
    init(directory: NSURL, completion: Completion) {
        self.directory = directory
        self.completion = completion
        
        super.init(style: .Plain)
        
        let manifestURL = directory.URLByAppendingPathComponent("manifest.json")
        let data = NSData(contentsOfURL: manifestURL)!
        manifest = try! NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! [String: String]
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "DayCell")
        tableView.reloadData()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return manifest.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DayCell", forIndexPath: indexPath)
        cell.textLabel?.text = Array(manifest.values)[indexPath.row]

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        completion(day: Array(manifest.keys)[indexPath.row])
    }

}
