//
//  ViewController.swift
//  Swift Weather
//
//  Created by 周伟 on 16/1/25.
//  Copyright © 2016年 chacha. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    let locationManager:CLLocationManager = CLLocationManager()  //定义一个locationManger常量，指定类型为CLLocationManger

    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var temperature: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        if(ios8()){
            locationManager.requestAlwaysAuthorization()
        }
        locationManager.startUpdatingLocation()
    }

    
    func ios8() -> Bool {
        let systemVersion = (UIDevice.currentDevice().systemVersion as NSString).floatValue
        return systemVersion >= 8.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func locationManager(manager: CLLocationManager!, _didUpdateLocations
        locations: [AnyObject]!){      //AnyObject[]是一个可空类型的数组，并且是可选的
            var location:CLLocation = locations[locations.count-1] as! CLLocation   //用as转换当前变量类型
            
            if(location.horizontalAccuracy > 0){
                print(location.coordinate.latitude)
                print(location.coordinate.longitude)
                updateWeatherInfo(location.coordinate.latitude,longitude: location.coordinate.longitude)
                locationManager.stopUpdatingLocation()
            }
            
    }
    
    func updateWeatherInfo(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let manager = AFHTTPRequestOperationManager()
        let url = "http://api.openweathermap.org/data/2.5/weather"
        
        let params = ["lon": longitude, "lat": latitude, "cnt": 0]
        
        manager.GET(url, parameters: params, success: {(operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in print("JSON:"+responseObject.description!)
            
                self.updateUISuccess(responseObject as! NSDictionary!)
            
            },
            failure: {
                (operation: AFHTTPRequestOperation?, error: NSError!) in print("Error:" + error.localizedDescription)
            }
        )
    }
    
    func updateUISuccess(jsonResult: NSDictionary!){
        if let tempResult = jsonResult["main"]?["temp"] as? Double{
            var temperature: Double
            if(jsonResult["sys"]?["country"] as! String == "US"){
                //如果用户在美国，就将温度转化为华氏摄氏度
                temperature = round(((tempResult - 273.15)*1.8) + 32)
            }else{
                temperature = round(tempResult - 273.15)
            }
            self.temperature.text = "\temperature˚"
            self.temperature.backgroundColor = UIColor.grayColor()
            self.temperature.font = UIFont.boldSystemFontOfSize(72)
            
            var name = jsonResult["name"] as! String
            self.location.font = UIFont.boldSystemFontOfSize(28)
            self.location.backgroundColor = UIColor.grayColor()
            self.location.text = "\name"
            
            var condition = (jsonResult["weather"] as! NSArray)[0]["id"] as! Int
            var sunrise = jsonResult["sys"]?["sunrise"] as! Double
            var sunset = jsonResult["sys"]?["sunset"] as! Double
            
            var nightTime = false
            var now = NSDate().timeIntervalSince1970
            
            if(now < sunrise || now > sunset){
                nightTime = true
            }
//            self.updateWeatherIcon(condition, nightTime: nightTime)
        }else{
            
        }
        //!转型的过程中，如果值为空，会报错；?在转型过程中，如果返回值为空，那么这个值就是空
    }
    
//    func updateWeatherIcon(condition: Int,nightTime: Bool){
//        if(condition < 300){
//            if nightTime {
//                self.icon.image = UIImage(named: "天气图标");)
//            }
//        }
//    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }

}

