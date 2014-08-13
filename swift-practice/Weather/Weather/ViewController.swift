//
//  ViewController.swift
//  Weather
//
//  Created by Jing on 7/25/14.
//  Copyright (c) 2014 ___CMU___. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var tv:UITextView
    
    @IBAction func btnPressed(sender: AnyObject) {
        loadWeather()
    }
    
    func loadWeather() {
        //load weather
        
        var URL = NSURL(string: "http://www.weather.com.cn/data/sk/101010100.html")
        
        
        var data = NSData.dataWithContentsOfURL(URL, options: NSDataReadingOptions.DataReadingUncached, error: nil)
        
        //var str = NSString(data: data, encoding: NSUTF8StringEncoding)
        var json: AnyObject! = NSJSONSerialization.JSONObjectWithData(data, options:
            NSJSONReadingOptions.AllowFragments, error: nil)
        
        var weatherInfo: AnyObject! = json.objectForKey("weatherinfo")
        var city: AnyObject! = weatherInfo.objectForKey("city")
        var temp: AnyObject! = weatherInfo.objectForKey("temp")
        var wind: AnyObject! = weatherInfo.objectForKey("WD")
        var ws: AnyObject! = weatherInfo.objectForKey("WS")
        
        tv.text = "城市: \(city) \n温度: \(temp)\n风: \(wind)\n风级: \(ws)"
    }
                            
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        loadWeather()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

