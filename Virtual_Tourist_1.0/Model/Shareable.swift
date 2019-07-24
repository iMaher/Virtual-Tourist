//
//  Shareable.swift
//  Virtual_Tourist_1.0
//
//  Created by maher malibari on 24/07/2019.
//  Copyright © 2019 maher malibari. All rights reserved.
//

import Foundation

class Shareable {
    static let shared = Shareable()
    var locations: [StudentLocation]?
}

class UserData {
    static var loginKey = ""
    static var randomFirstName = ""
    static var randomLastName = ""
    static var location = ""
    
    static var randomName: String {
        return randomFirstName + " " + randomLastName
    }
}
