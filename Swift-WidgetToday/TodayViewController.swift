//
//  TodayViewController.swift
//  Swift-WidgetToday
//
//  Created by Paul Chavarria Podoliako on 9/21/14.
//  Copyright (c) 2014 AnyTap. All rights reserved.
//

import UIKit
import NotificationCenter
import CoreData
import SwiftWidgetKit

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    let context = CoreDataStore.mainQueueContext()
    var counter: Counter?
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        self.fetchData()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - NSWidgetProviding
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        // Update data always to keep it simple..
        self.fetchData()
        completionHandler(NCUpdateResult.NewData)
    }
    

    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        // Change inset to use more space in widget
        let newInsets = UIEdgeInsets(top: defaultMarginInsets.top, left: defaultMarginInsets.left-30,
            bottom: defaultMarginInsets.bottom, right: defaultMarginInsets.right)
        return newInsets
    }
    
    
    // MARK: - IBActions
    
    @IBAction func incrementByOne(sender: AnyObject) {
        // Call update widget
        if let integer = self.counter?.count.integerValue {
            self.counter?.count = integer+1
        }
        
        self.updateData()
        self.saveData()
    }
    
    
    // MARK: - Private Methods
    
    func fetchData () {
        self.context.performBlockAndWait{ () -> Void in
            
            let counter = NSManagedObject.findAllInContext("Counter", context: self.context)
            
            if (counter?.last != nil) {
                self.counter = (counter?.last as! Counter)
            }else{
                // Create new one
                self.counter = (NSEntityDescription.insertNewObjectForEntityForName("Counter", inManagedObjectContext: self.context) as! Counter)
                self.counter?.name = ""
                self.counter?.count = 0
            }
            
            self.updateData()
            
        }
        
    }
    
    func updateData () {
        
        self.titleLabel.text = self.counter?.name
        self.countLabel.text = self.counter?.count.stringValue
    }
    
    func saveData() {
        
        self.counter?.name = self.titleLabel.text!
        let count = self.countLabel.text?.toInt()
        if let integer = count {
            self.counter?.count = integer
        }
        
        // Save in shared user defaults
        let sharedDefaults = NSUserDefaults(suiteName: "group.AnyTap.SwiftWidget")!
        sharedDefaults.setBool(true, forKey: "SwiftWidgetModelChanged")
        sharedDefaults.synchronize()
        
        CoreDataStore.saveContext(self.context)
    }
}
