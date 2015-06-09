//
//  SharedData.swift
//  my-train
//
//  Created by Daniil Nguen on 6/10/15.
//  Copyright (c) 2015 Daniil Nguen. All rights reserved.
//

import Foundation


class SharedData {
    class var sharedInstance: SharedData {
        struct Static {
            static var instance: SharedData?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = SharedData()
        }
        
        return Static.instance!
    }
    
    var userId: Int
    var name: String
}