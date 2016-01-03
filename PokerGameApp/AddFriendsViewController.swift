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
    @IBOutlet weak var addFriendsButton: UIButton!
    @IBOutlet weak var startGameButton: UIButton!
    
    var refreshControl: UIRefreshControl!
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var connectedFriends = 0
    var avilable = [1, 2, 3]
    var images = ["Spades", "Hearts", "Clubs", "Diamonds"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        friendsTable.delegate = self
        friendsTable.dataSource = self
        
        addFriendsButton.enabled = false
        startGameButton.enabled = false
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
        return UIScreen.mainScreen().bounds.height / 8
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("onefriend") as! AddFriendsTableViewCell
        cell.username?.text = appDelegate.mpcManager.foundPeers[indexPath.row].displayName
        cell.selectionStyle = .None
        cell.backgroundColor = UIColor.blackColor()
        cell.cellselected = false
        if cell.cellselected {
            cell.accessoryType = .Checkmark
        }
        else {
            cell.accessoryType = .None
        }
        return cell
    }
 
// ***************************************************************************//
// ************ Below is the original version *****************//
// ******   DO NOT DELETE for now ***************//
// **********************************//
// **********************//
// ************//
// ***//
    
    
    
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        if(connectedFriends < 3) {
//            let cell = self.friendsTable.cellForRowAtIndexPath(indexPath) as! AddFriendsTableViewCell
//            cell.cellselected = !cell.cellselected
//            if cell.cellselected {
//                cell.pokerImage.image = UIImage(named: images[avilable[0]])!
//                self.connectedFriends += 1
//                let selectedPeer = appDelegate.mpcManager.foundPeers[indexPath.row] as MCPeerID
//                cell.sessionIndex = avilable[0] - 1
//                appDelegate.mpcManager.browser.invitePeer(selectedPeer, toSession: appDelegate.mpcManager.sessions[avilable[0]-1], withContext: nil, timeout: 200)
//                appDelegate.mpcManager.connectedSessionCount += 1
//                avilable.removeAtIndex(0)
//
//            }
//            else {
//                cell.pokerImage.image = nil
//                self.connectedFriends -= 1
//                self.appDelegate.mpcManager.sessions[cell.sessionIndex].disconnect()
//                avilable.append(cell.sessionIndex+1)
//                avilable.sortInPlace()
//                appDelegate.mpcManager.connectedSessionCount -= 1
//            }
//            friendsTable.reloadData()
//        }
//    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = self.friendsTable.cellForRowAtIndexPath(indexPath) as! AddFriendsTableViewCell
        if cell.cellselected {
            self.connectedFriends -= 1
            cell.accessoryType = .None
            cell.cellselected = false
        }
        else {
            self.connectedFriends += 1
            cell.accessoryType = .Checkmark
            cell.cellselected = true
        }
        self.updateAddFriendsButtonState()
    }
    
    
    func reload() {
        friendsTable.reloadData()
        self.updateAddFriendsButtonState()
    }
    
    func updateAddFriendsButtonState() {
        if self.connectedFriends == 3 {
            addFriendsButton.enabled = true
        }
        else {
            addFriendsButton.enabled = false
        }
    }
    
    // MARK: MPCManagerDelegate method implementation
    func foundPeer() {
        self.reload()
    }
    
    
    func lostPeer() {
        self.reload()
    }

    func connectedWithPeer(peerID: MCPeerID) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.friendsTable.reloadData()
        })
        
        print("Connected")
    }
    
    func enableStartGame() {
        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
            self.startGameButton.enabled = true
        })
    }
    
    @IBAction func addThreeFriends(sender: AnyObject) {
        var selectedPeer: MCPeerID
        var cell: AddFriendsTableViewCell
        var count = 0
        for index in 0...self.friendsTable.numberOfRowsInSection(0)-1 {
            cell = self.friendsTable.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0)) as! AddFriendsTableViewCell
            if (cell.cellselected) {
                selectedPeer = appDelegate.mpcManager.foundPeers[index] as MCPeerID
                appDelegate.mpcManager.browser.invitePeer(selectedPeer, toSession: appDelegate.mpcManager.sessions[count], withContext: nil, timeout: 30)
                count += 1
            }
        }
        self.addFriendsButton.enabled = false
    }
 }
