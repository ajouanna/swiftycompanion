//
//  Project.swift
//  swiftycompanion
//
//  Created by Antoine JOUANNAIS on 4/24/17.
//  Copyright © 2017 Antoine JOUANNAIS. All rights reserved.
//

import Foundation

struct Project {
    var name : String
    var status : String = "finished"
    var validated : Bool = true
    
    init(name : String) {
        self.name = name
    }
}
