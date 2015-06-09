//
//  TodayViewController.swift
//  widget
//
//  Created by Daniil Nguen on 6/9/15.
//  Copyright (c) 2015 Daniil Nguen. All rights reserved.
//

import UIKit
import Foundation
import NotificationCenter
import CoreLocation

extension String {
    func replace(target: String, withString: String) -> String {
        return self.stringByReplacingOccurrencesOfString(target, withString: withString, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
}

class TodayViewController: UIViewController, NCWidgetProviding, CLLocationManagerDelegate, UIPickerViewDelegate{
    @IBOutlet weak var lbl: UILabel!
    @IBOutlet weak var Picker: UIPickerView!
    var pickerDataSource = ["White", "Red", "Green", "Blue"];
    var locationManager: CLLocationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var user_latitude: Double = 0.0
    var user_longitude: Double = 0.0
    let sharedData = ShareData.sharedInstance
    let user = User.sharedInstance
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
//        self.Picker.dataSource = self;
        self.Picker.delegate = self;
        
    }
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!)
    {
        currentLocation = locations[locations.count - 1]
            as? CLLocation
    }
    func performWidgetUpdate()
    {
        if currentLocation != nil {
            user_latitude = Double(currentLocation!.coordinate.latitude)
            user_longitude = Double(currentLocation!.coordinate.longitude)
        }   
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    override func viewWillAppear(animated: Bool) {
        performWidgetUpdate()
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource.count;
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return pickerDataSource[row]
    }
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
        performWidgetUpdate()
        
        
        completionHandler(NCUpdateResult.NewData)
        
        var home_station = "Suburban Station"
        completionHandler(NCUpdateResult.NewData)
        var train_set = Set(["a"])
        if let url = NSURL(string: "http://www3.septa.org/hackathon/Arrivals/station_id_name.csv") {
            var error: NSErrorPointer = nil
            // Used external library to parce the .csv file: https://github.com/naoty/SwiftCSV
            if let csv = CSV(contentsOfURL: url, error: error) {
                let columns = csv.columns
                for i in 0...csv.rows.count-1{
                    let station_names = Array(csv.rows[i].values)
                    train_set.insert(station_names[0])
                }
            }
        }
        if user_latitude != 0 || user_longitude != 0 {
            var url_string = "http://www3.septa.org/hackathon/locations/get_locations.php?lon="
            url_string += String(stringInterpolationSegment: user_longitude) + "&lat="
            url_string += String(stringInterpolationSegment: user_latitude) + "&radius=3"
            println(url_string)
            let url = NSURL(string: url_string)
            
            var request = NSURLRequest(URL: url!)
            var data = NSURLConnection.sendSynchronousRequest(request, returningResponse: nil, error: nil)
            var closest_distance = Double(UInt32.max)
            var closest_station = "No Stations found"
            if data != nil {
                // Used external library to parce .json: https://github.com/SwiftyJSON/SwiftyJSON
                var objects = JSON(data: data!)
                for index in 0...objects.count-1{
                    if contains(train_set, String(stringInterpolationSegment: objects[index]["location_name"])){
                        // Calculation of the closest station was done by using Haversine formula http://en.wikipedia.org/wiki/Haversine_formula
                        let cur_latitude = objects[index]["location_lat"].doubleValue
                        let cur_longitude = objects[index]["location_lon"].doubleValue
                        let earthRadius = 6371000
                        let dLat = (cur_latitude-user_latitude)*M_PI/180 //Converting to radians
                        let dLng = (cur_longitude-user_longitude)*M_PI/180
                        let a = Double(sin(dLat/2)) * Double(sin(dLat/2)) + Double(cos(user_latitude*M_PI/180)) * Double(cos(cur_latitude*M_PI/180)) * Double(sin(dLng/2)) * Double(sin(dLng/2))
                        let c = atan2(sqrt(a),sqrt(1-a))
                        let dist = Double(earthRadius) * c
                        if closest_distance > dist{
                            closest_distance = dist
                            closest_station = String(stringInterpolationSegment: objects[index]["location_name"])
                        }
                    }
                }
                
                if closest_station == "No Stations found"{
                    lbl.text=closest_station
                }
                else{
                    let url2 = NSURL(string: "http://www3.septa.org/hackathon/NextToArrive/" + closest_station.replace(" ", withString:"%20") + "/" + home_station.replace(" ", withString:"%20") + "/1")
                    println(url2)
                    var request = NSURLRequest(URL: url2!)
                    var data = NSURLConnection.sendSynchronousRequest(request, returningResponse: nil, error: nil)
                    var 🕐 = "No trains found at the time"
                    var orig_delay = ""
                    if data != nil {
                        var objects = JSON(data: data!)
                        println(objects)
                        for index in 0...objects.count-1{
                            🕐=String(stringInterpolationSegment: objects[index]["orig_departure_time"])
                            orig_delay = String(stringInterpolationSegment: objects[index]["orig_delay"])
                            if orig_delay != "On time" {
                                orig_delay += " late"
                            }
                        }
                    }
                    lbl.text="Closest station: " + closest_station  + ", next train arriving at:" + 🕐 + ", " + orig_delay
                    
                    var manager: OneShotLocationManager?
                    manager = OneShotLocationManager()
                    manager!.fetchWithCompletion {location, error in
                        if let loc = location {
                            println(location)
                        } else if let err = error {
                            println(err.localizedDescription)
                        }
                        
                    }
                }
            }
            else{
                lbl.text = "Can not determine location."
            }
        }
    }
}