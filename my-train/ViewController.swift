//
//  ViewController.swift
//  my-train
//
//  Created by Daniil Nguen on 6/9/15.
//  Copyright (c) 2015 Daniil Nguen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var lbl: UILabel!
    @IBOutlet weak var btn: UIButton!
    let sharedData = ShareData.sharedInstance
    let user = User.sharedInstance
    
    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Do any additional setup after loading the view, typically from a nib.
//        let prefs = NSUserDefaults.standardUserDefaults()
//        prefs.setValue("Berlin", forKey: "userCity")
        println("Hello world")
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        let prefs = NSUserDefaults.standardUserDefaults()
        prefs.setValue("Berlin2", forKey: "userCity")
        
        println("Daniil")
        lbl.text="OOOOO"
        self.sharedData.someString = "Data from first object"
        lbl.text=self.sharedData.someString
        self.user.name = "Anthoni Giskegjerde"
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func buttonPressed(sender: AnyObject) {
       lbl.text="ASD"
    }
}

