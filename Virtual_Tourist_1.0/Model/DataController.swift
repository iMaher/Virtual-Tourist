//
//  DataController.swift
//  Virtual_Tourist_1.0
//
//  Created by maher malibari on 20/07/2019.
//  Copyright © 2019 maher malibari. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    
    static let sharedObject = DataController()
    
    let persistantContainer = NSPersistentContainer(name: "VTDataModel")
    
    var viewContext: NSManagedObjectContext {
        return persistantContainer.viewContext
    }
    
    func load() {
        persistantContainer.loadPersistentStores { (storeDiscription, error) in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
        }
    }
    
}
