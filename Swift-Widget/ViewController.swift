//
//  ViewController.swift
//  Swift-Widget
//
//  Created by Paul Chavarria Podoliako on 9/21/14.
//  Copyright (c) 2014 AnyTap. All rights reserved.
//

import UIKit
import SwiftWidgetKit
import CoreData

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var countLabel: UILabel!
    
    var counter: Counter?
    let context = CoreDataStore.mainQueueContext()
    
    
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        self.context.performBlockAndWait{ () -> Void in
            
            let counter = NSManagedObject.findAllInContext("Counter", context: self.context)
            
            if (counter?.last != nil) {
                // Use existing
                self.counter = (counter?.last as! Counter)
            }else{
                // Create new one
                self.counter = (NSEntityDescription.insertNewObjectForEntityForName("Counter", inManagedObjectContext: self.context) as! Counter)
                self.counter?.name = "Counter 1"
                self.counter?.count = 0
            }
            
            self.fillData()
        }
        // Subscribe for change notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "contextShouldReset:", name: "SwiftWidgetModelChangedNotification", object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // Save new title
        self.saveData()
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - Notification Methods
    
    func contextShouldReset(notification: NSNotification) {
        
        // Reset changed context
        self.context.reset()
        
        // Fetch data and reflect changes on UI
        let counter = NSManagedObject.findAllInContext("Counter", context: self.context)
        self.counter = (counter?.last as! Counter)
        self.fillData()
    }
    
    // MARK: - IBActions
    
    @IBAction func incrementPressed(sender: AnyObject) {
        // Increment value and save
        if let integer = self.counter?.count.integerValue {
            self.counter?.count = integer + 1
        }

        self.fillData()
        self.saveData()
    }
    
    
    // MARK: - Private Methods
    
    func fillData() {
        self.titleTextField.text = self.counter?.name
        self.countLabel.text = self.counter?.count.stringValue
    }
    
    func saveData() {
        
        self.counter?.name = self.titleTextField.text
        let count = self.countLabel.text?.toInt()
        if let integer = count {
            self.counter?.count = integer
        }
        
        CoreDataStore.saveContext(self.context)
    }
    
}

