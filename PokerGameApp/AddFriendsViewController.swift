//
//  AddFriendsViewController.swift
//  PokerGameApp
//
//  Created by Cui Jing on 11/25/15.
//  Copyright © 2015 Jingplusplus. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class AddFriendsViewController: UIViewController,  UITableViewDelegate, UITableViewDataSource, MPCManagerDelegate1 {

    @IBOutlet weak var friendsTable: UITableView!
    var refreshControl: UIRefreshControl!
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var connectedFriends = 0
    var waitingList = [String: Int]()
    var images = ["Spades", "Hearts", "Clubs", "Diamonds"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        friendsTable.delegate = self
        friendsTable.dataSource = self
        
        appDelegate.mpcManager.delegate1 = self
        appDelegate.mpcManager.browser.startBrowsingForPeers()
        appDelegate.mpcManager.advertiser.stopAdvertisingPeer()
        
        self.friendsTable.separatorStyle = UITableViewCellSeparatorStyle.None
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.friendsTable.addSubview(refreshControl)
        self.appDelegate.mpcManager.server = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: UITableView related method implementation
    
    func refresh(refreshControl: UIRefreshControl) {
        friendsTable.reloadData()
        refreshControl.endRefreshing()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (appDelegate.mpcManager.foundPeers.count)
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50.0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("onefriend") as! AddFriendsTableViewCell
        cell.username?.text = appDelegate.mpcManager.foundPeers[indexPath.row].displayName
        cell.selectionStyle = .None
        if cell.cellselected {
            cell.accessoryType = .Checkmark
        }
        else {
            cell.accessoryType = .None
        }
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = self.friendsTable.cellForRowAtIndexPath(indexPath) as! AddFriendsTableViewCell
        cell.cellselected = !cell.cellselected
        if cell.cellselected {
            cell.pokerImage.image = UIImage(named: images[connectedFriends])!
            self.connectedFriends += 1
            let selectedPeer = appDelegate.mpcManager.foundPeers[indexPath.row] as MCPeerID
            cell.sessionIndex = appDelegate.mpcManager.connectedSessionCount
            appDelegate.mpcManager.browser.invitePeer(selectedPeer, toSession: appDelegate.mpcManager.sessions[appDelegate.mpcManager.connectedSessionCount], withContext: nil, timeout: 20)
            appDelegate.mpcManager.connectedSessionCount += 1

        }
        else {
            cell.pokerImage.image = nil
            self.connectedFriends -= 1            
            self.appDelegate.mpcManager.sessions[cell.sessionIndex].disconnect()
            appDelegate.mpcManager.connectedSessionCount -= 1
        }
        friendsTable.reloadData()
    }
    
    // MARK: MPCManagerDelegate method implementation
    
    func foundPeer() {
        friendsTable.reloadData()
    }
    
    
    func lostPeer() {
        friendsTable.reloadData()
    }
    
    func invitationWasReceived(fromPeer: String) {
        let alert = UIAlertController(title: "", message: "\(fromPeer) wants to chat with you.", preferredStyle: UIAlertControllerStyle.Alert)
        
        let acceptAction: UIAlertAction = UIAlertAction(title: "Accept", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            self.appDelegate.mpcManager.invitationHandler!(true, self.appDelegate.mpcManager.sessions[0])
            self.appDelegate.mpcManager.connectedSessionCount += 1
            self.appDelegate.mpcManager.server = false
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

    func connectedWithPeer(peerID: MCPeerID) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.friendsTable.reloadData()
        })
        
        print("Connected")
        /*
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
        self.performSegueWithIdentifier("idSegueChat", sender: self)
        }
        */
    }
 }
