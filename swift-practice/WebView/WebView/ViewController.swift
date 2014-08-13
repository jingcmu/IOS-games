//
//  ViewController.swift
//  WebView
//
//  Created by Jing on 7/25/14.
//  Copyright (c) 2014 ___CMU___. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var wv:UIWebView
                            
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        wv.loadRequest(NSURLRequest(URL:NSURL(string:"http://jikexueyuan.com")))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

