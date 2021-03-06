//
//  JoinGameViewController.swift
//  PokerGameApp
//
//  Created by Cui Jing on 12/5/15.
//  Copyright © 2015 Jingplusplus. All rights reserved.
//

import UIKit

class JoinGameViewController: UIViewController, MPCManagerDelegate2 {
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate.mpcManager.delegate2 = self
        appDelegate.mpcManager.advertiser.startAdvertisingPeer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.appDelegate.mpcManager.advertiser.startAdvertisingPeer()
        self.appDelegate.mpcManager.browser.stopBrowsingForPeers()
    }
    
    func invitationWasReceived(fromPeer: String) {
        let alert = UIAlertController(title: "", message: "\(fromPeer) invites you to game.", preferredStyle: UIAlertControllerStyle.Alert)
        
        let acceptAction: UIAlertAction = UIAlertAction(title: "Accept", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
                self.appDelegate.mpcManager.invitationHandler!(true, self.appDelegate.mpcManager.sessions[0])
                self.appDelegate.mpcManager.connectedSessionCount += 1
                self.appDelegate.mpcManager.server = false
                self.performSegueWithIdentifier("openPlayboard", sender: self)
            }
        }
        
        let declineAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (alertAction) -> Void in
            self.appDelegate.mpcManager.invitationHandler = nil
            //self.appDelegate.mpcManager.invitationHandler!(false, nil)
        }
        
        alert.addAction(acceptAction)
        alert.addAction(declineAction)
        
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }


    @IBAction func backButtonTapped(sender: UIButton) {
         self.dismissViewControllerAnimated(true, completion: nil)
    }
}
