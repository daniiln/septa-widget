//
//  ShareData.swift
//  my-train
//
//  Created by Daniil Nguen on 6/10/15.
//  Copyright (c) 2015 Daniil Nguen. All rights reserved.
//

import Foundation
class ShareData {
    class var sharedInstance: ShareData {
        struct Static {
            static var instance: ShareData?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = ShareData()
        }
        
        return Static.instance!
    }
    
    
    var someString : String! //Some String
    
    var selectedTheme : AnyObject! //Some Object
    
    var someBoolValue : Bool!
}