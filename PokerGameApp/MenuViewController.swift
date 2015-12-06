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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

