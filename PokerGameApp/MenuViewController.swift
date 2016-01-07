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
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.appDelegate.mpcManager.server = false
        self.appDelegate.mpcManager.advertiser.stopAdvertisingPeer()
        self.appDelegate.mpcManager.browser.startBrowsingForPeers()
        if self.appDelegate.mpcManager.connectedSessionCount > 0 {
            for index in 0...self.appDelegate.mpcManager.connectedSessionCount-1 {
                self.appDelegate.mpcManager.sessions[index].disconnect()
            }
        }
        self.appDelegate.mpcManager.connectedSessionCount = 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

