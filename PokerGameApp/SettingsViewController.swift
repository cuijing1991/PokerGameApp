//
//  SettingsViewController.swift
//  PokerGameApp
//
//  Created by Cui Jing on 11/24/15.
//  Copyright © 2015 Jingplusplus. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    @IBOutlet weak var NoSkip2Switch: UISwitch!
    @IBOutlet weak var NoSkip51013Switch: UISwitch!
    @IBOutlet weak var TableCardsSwitch: UISwitch!
    var pickerDataSource = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pickerView.dataSource = self;
        self.pickerView.delegate = self;

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource.count;
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        let titleData = pickerDataSource[row]
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 26.0)!,NSForegroundColorAttributeName:UIColor.blackColor()])
        pickerLabel.attributedText = myTitle
        let hue = CGFloat(row)/CGFloat(pickerDataSource.count)
        pickerLabel.backgroundColor = UIColor(hue: hue, saturation: 1.0, brightness:1.0, alpha: 1.0)
        pickerLabel.textAlignment = .Center
        return pickerLabel
    }
   
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        GameInfo_CPPWrapper.updateKeyRank(row+2)
        GameInfo_CPPWrapper.updateInitialRank(row+2)
        print(row)
        
    }
    @IBAction func noSkip2Changed(sender: UISwitch) {
        print(sender.on)
        GameInfo_CPPWrapper.updateNoSkip2(sender.on)
    }
    
    @IBAction func noSkip51013Changed(sender: UISwitch) {
        GameInfo_CPPWrapper.updateNoSkip51013(sender.on)
    }
    @IBAction func tableCardsChanged(sender: UISwitch) {
        print(sender.on)
        GameInfo_CPPWrapper.updateChangeTableCards(sender.on)
    }
}
