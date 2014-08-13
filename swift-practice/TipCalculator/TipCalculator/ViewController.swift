//
//  ViewController.swift
//  TipCalculator
//
//  Created by Jing on 7/21/14.
//  Copyright (c) 2014 ___CMU___. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var totalTextField : UITextField
    @IBOutlet var taxPctSlider: UISlider
    @IBOutlet var taxPctLabel: UILabel
    @IBOutlet var resultTextView: UITextView
    
    let tipCalc = TipCalculatorModel(total: 0,  taxPct: 0.06)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        taxPctLabel.text = "Tax Percentage (\(Int(taxPctSlider.value))%)"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func calculateTapped(sender : AnyObject) {
        tipCalc.total = Double(totalTextField.text.bridgeToObjectiveC().doubleValue)
        let possibleTips = tipCalc.returnPossibleTips()
        var results = ""
            
        for(tipPct, tipValue) in possibleTips {
            results += "\(tipPct)%: \(tipValue)\n"
        }
        resultTextView.text = results
    }
    
    @IBAction func taxPercentageChanged(sender : AnyObject) {
        tipCalc.taxPct = Double(taxPctSlider.value) / 100.0
        refreshUI()
    }
    
    @IBAction func viewTapped(sender : AnyObject) {
        totalTextField.resignFirstResponder()
    }
    
    func refreshUI() {
        taxPctSlider.value = Float(tipCalc.taxPct) * 100.0
        taxPctLabel.text = "Tax Percentage (\(Int(taxPctSlider.value))%)"
        resultTextView.text = ""
    }

}

