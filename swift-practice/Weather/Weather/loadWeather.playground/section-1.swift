// Playground - noun: a place where people can play

import UIKit

//load weather

var URL = NSURL(string: "http://www.weather.com.cn/data/sk/101010100.html")


var data = NSData.dataWithContentsOfURL(URL, options: NSDataReadingOptions.DataReadingUncached, error: nil)

//var str = NSString(data: data, encoding: NSUTF8StringEncoding)
var json: AnyObject! = NSJSONSerialization.JSONObjectWithData(data, options:
    NSJSONReadingOptions.AllowFragments, error: nil)

var weatherInfo = json.objectForKey("weatherinfo")
var city = weatherInfo.objectForKey("city")
var temp = weatherInfo.objectForKey("temp")