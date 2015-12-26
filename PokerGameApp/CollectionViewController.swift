//
//  CollectionViewController.swift
//  CircularCollectionView
//
//  Created by Cui Jing on 12/4/15.
//  Copyright © 2015 Jingplusplus. All rights reserved.
//
import Foundation
import UIKit
import MultipeerConnectivity

let reuseIdentifier = "Cell"

class CollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let manager = CardManager_CPPWrapper()
    
    var keysuit = 0
    var keyrank = 4
    var images = [String]()
    var layout: CircularCollectionViewLayout!
    var lists = [NSMutableArray!](count: 4, repeatedValue: nil)
    var myCards = [Card_CPPWrapper]()
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var playButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layout = CircularCollectionViewLayout()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.setCollectionViewLayout(self.layout, animated: false)
        
        collectionView.registerNib(UINib(nibName: "CircularCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.allowsMultipleSelection = true
        view.addSubview(collectionView)
        view.sendSubviewToBack(collectionView)
        playButton.enabled = false
        
        if (self.appDelegate.mpcManager.server) {
            
            /***********************   Server Device  **********************/
            for index in 0...3 {
                lists[index] = NSMutableArray()
            }
            
            let gameprocedure = GameProcedure_CPPWrapper()
            gameprocedure.GameProcedure_CPPWrapper()
            gameprocedure.ShuffleCards(lists[0], pca2: lists[1], pca3: lists[2], pca4: lists[3])
            assignCard_to_all(0)
        }
        
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "handleMPCReceivedDataWithNotification:",
            name: "receivedMPCDataNotification", object: nil)
    }
    
    
    func forwards(c1: Card_CPPWrapper!, c2: Card_CPPWrapper!) -> Bool {
        return c1.compare(c1, to: c2, suit: keysuit, rank: keyrank)
    }
    
    func assignCard_to_all(index: Int) {
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC))
        dispatch_after(time, dispatch_get_main_queue(), {
            self.images.append("Images/PNG-cards-All/" + self.lists[0][index].toString() + ".png")
            self.myCards.append(self.lists[0][index] as! Card_CPPWrapper)
            self.myCards.sortInPlace(self.forwards)
            
            if (self.appDelegate.mpcManager.connectedSessionCount > 0) {
                for playerID in 0...self.appDelegate.mpcManager.connectedSessionCount-1 {
                    self.assignCard(index, player: playerID)
                }
            }
            if(index > 12) {
                self.layout.angleOffset += self.layout.anglePerItem
            }
            self.collectionView.reloadData()
            self.layout.invalidateLayout()
            if(index == self.lists[0].count-1) {
                //self.layout.angleOffset = 0
                self.layout.anglePerItem = scale * 233 / 3000  / 1.7 / scale
                self.collectionView.reloadData()
                self.layout.invalidateLayout()
            }
            if(index < 26) {
                self.assignCard_to_all(index+1)
            }
            else {
                self.manager.CardManager_CPPWrapper(self.myCards)
            }
        })
    }
    
    
    
    func collectionView(collectionView: UICollectionView,
        numberOfItemsInSection section: Int) -> Int {
            return myCards.count
    }
    
    func collectionView(collectionView: UICollectionView,
        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CircularCollectionViewCell
            cell.imageName = "Images/PNG-cards-All/" + myCards[indexPath.row].toString() + ".png"
            return cell
    }
    
    func collectionView(collectionView: UICollectionView,
        didSelectItemAtIndexPath indexPath: NSIndexPath) {
            print(indexPath.row)
            self.layout.selected[indexPath.row] = true
            self.layout.invalidateLayout()
            self.updateView()
    }
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath:NSIndexPath) {
        self.layout.selected[indexPath.row] = false
        self.layout.invalidateLayout()
        self.updateView()
    }
    
    
    func assignCard(index: Int, player: Int) -> Bool{
        
        let message = "_assign_card_"
        let card = self.lists[player + 1][index] as! Card_CPPWrapper
        let messageDictionary: [String: AnyObject] = ["message": message, "card": card]
        
        let messageData = NSKeyedArchiver.archivedDataWithRootObject(messageDictionary)
        
        do {
            try appDelegate.mpcManager.sessions[player].sendData(messageData, toPeers: appDelegate.mpcManager.sessions[player].connectedPeers, withMode: MCSessionSendDataMode.Reliable)
        }
        catch let error as NSError {
            print(error.localizedDescription)
            print("Can not send data")
            return false
        }
        
        return true
    }
    
    func handleMPCReceivedDataWithNotification(notification: NSNotification) {
        print("yes")
        // Get the dictionary containing the data and the source peer from the notification.
        let receivedDataDictionary = notification.object as! Dictionary<String, AnyObject>
        
        // "Extract" the data and the source peer from the received dictionary.
        let data = receivedDataDictionary["data"] as? NSData
        
        // Convert the data (NSData) into a Dictionary object.
        let dataDictionary = NSKeyedUnarchiver.unarchiveObjectWithData(data!) as! Dictionary<String, AnyObject>
        
        // Check if there's an entry with the "message" key.
        if let message = dataDictionary["message"] {
            if message as! String == "_assign_card_"{
                let card = dataDictionary["card"] as! Card_CPPWrapper
                print(card.toString())
                self.myCards.append(card);
                self.myCards.sortInPlace(self.forwards)
                print(myCards.count)
                self.collectionView.reloadData()
                self.layout.invalidateLayout()
                if(self.myCards.count > 12) {
                    self.layout.angleOffset += self.layout.anglePerItem
                }
                if(self.myCards.count == 27) {
                    //self.layout.angleOffset = 0
                    self.layout.anglePerItem = scale * 233 / 3000  / 1.7 / scale
                    self.collectionView.reloadData()
                    self.layout.invalidateLayout()
                    self.manager.CardManager_CPPWrapper(self.myCards)
                }
                
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    self.collectionView.reloadData()
                    self.layout.invalidateLayout()
                })
            }
        }
    }
    
    func updateView(){
        self.layout.invalidateLayout()
        var selectedCards = [Card_CPPWrapper]()
        for i in 0...myCards.count-1 {
            if (self.layout.selected[i]) {
                selectedCards.append(myCards[i])
            }
        }
        var format = [Card_CPPWrapper]();
        let c1 = Card_CPPWrapper()
        c1.Card_CPPWrapper(3,rank:3)
        format.append(c1);
        let c2 = Card_CPPWrapper()
        c2.Card_CPPWrapper(3,rank:3)
        format.append(c2);
        let c3 = Card_CPPWrapper()
        c3.Card_CPPWrapper(3,rank:10)
        format.append(c3);

        if(manager.testCards(3, format:format, cards:selectedCards)) {
            playButton.enabled = true
            playButton.setTitleColor(UIColor.greenColor(), forState: UIControlState.Normal)
            print ("cheer")
        }
        else {
            playButton.enabled = false
            playButton.setTitleColor(UIColor.redColor(), forState: UIControlState.Normal)
            print ("bad")
        }
    }
    
    @IBAction func playCards(sender: AnyObject) {
        for var i = myCards.count-1; i >= 0; i-- {
            if (self.layout.selected[i]) {
                manager.remove(myCards[i])
                myCards.removeAtIndex(i)
                self.layout.selected.removeAtIndex(i)
            }
        }
        //playButton.enabled = false
        //playButton.setTitleColor(UIColor.redColor(), forState: UIControlState.Normal)

        self.layout.invalidateLayout()
        self.collectionView.reloadData()
        
    }
}
