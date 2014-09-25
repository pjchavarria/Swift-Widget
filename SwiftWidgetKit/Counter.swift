//
//  Note.swift
//  Swift-Widget
//
//  Created by Paul Chavarria Podoliako on 9/21/14.
//  Copyright (c) 2014 AnyTap. All rights reserved.
//

import Foundation
import CoreData

@objc(Counter)
public class Counter: NSManagedObject {

    @NSManaged public var name: String
    @NSManaged public var count: NSNumber

}
