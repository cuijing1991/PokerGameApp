//
//  AddFriendsViewController.swift
//  PokerGameApp
//
//  Created by Cui Jing on 11/25/15.
//  Copyright © 2015 Jingplusplus. All rights reserved.
//

import UIKit

class AddFriendsViewController: UIViewController,  UITableViewDelegate, UITableViewDataSource{

    
    @IBOutlet weak var friendsTable: UITableView!
    var connectedFriends = 0
    var images = ["Spades", "Hearts", "Clubs", "Diamonds"]
    var data = ["1", "2", "3", "4"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        friendsTable.delegate = self
        friendsTable.dataSource = self
        self.friendsTable.separatorStyle = UITableViewCellSeparatorStyle.None
        
        // friendsTable.dataSource = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UITableView related method implementation
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (data.count)
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50.0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("onefriend") as! AddFriendsTableViewCell
        cell.username?.text = data[indexPath.row]
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
        }
        else {
            cell.pokerImage.image = nil
            self.connectedFriends -= 1
        }
        friendsTable.reloadData()
    }
    
 }
