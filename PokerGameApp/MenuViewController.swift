//
//  ViewController.swift
//  PokerGameApp
//
//  Created by Cui Jing on 11/24/15.
//  Copyright © 2015 Jingplusplus. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    


    @IBOutlet weak var newGameButton: UIButton!
    @IBOutlet weak var joinGameButton: UIButton!
    override func viewDidLoad() {
        
        super.viewDidLoad()

        self.appDelegate.mpcManager.server = false
        self.appDelegate.mpcManager.advertiser.stopAdvertisingPeer()
        self.appDelegate.mpcManager.browser.stopBrowsingForPeers()
        self.appDelegate.mpcManager.connectedSessionCount = 0
        GameInfo_CPPWrapper.reset()


        newGameButton.setTitleColor(UIColor(colorLiteralRed: 0.9, green: 0.5, blue: 0.5, alpha: 1), forState: UIControlState.Selected)
        newGameButton.setTitleColor(UIColor.lightGrayColor(), forState: UIControlState.Normal)
        joinGameButton.setTitleColor(UIColor(colorLiteralRed: 0.9, green: 0.5, blue: 0.5, alpha: 1), forState: UIControlState.Selected)
        joinGameButton.setTitleColor(UIColor.lightGrayColor(), forState: UIControlState.Normal)
    }

    override func viewWillAppear(animated:Bool) {
        super.viewWillAppear(animated)
        newGameButton.selected = false
        joinGameButton.selected = false
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func buttonTapped(sender: UIButton) {
        sender.selected = true
    }
}

