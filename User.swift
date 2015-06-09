//
//  User.swift
//  my-train
//
//  Created by Daniil Nguen on 6/10/15.
//  Copyright (c) 2015 Daniil Nguen. All rights reserved.
//

import Foundation
class User {
    class var sharedInstance: User {
        struct Static {
            static var instance: User?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = User()
        }
        
        return Static.instance!
    }
    
    var userId: Int = 0
    var name: String = ""
}