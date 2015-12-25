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
    
    var keysuit = 4
    var keyrank = 1
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var images = [String]()
    var layout: CircularCollectionViewLayout!
    var lists = [NSMutableArray!](count: 4, repeatedValue: nil)
    var myCards = [Card_CPPWrapper!]()
    var selectedCards = [Card_CPPWrapper!]()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
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
        
        
        if (self.appDelegate.mpcManager.server) {
            
            // *********   Test c++ Code  ********************************//
            let wrapperCard = Card_CPPWrapper()
            wrapperCard.Card_CPPWrapper(3, rank: 12)
            print("String: \(wrapperCard.toString())")
            
            for index in 0...3 {
                lists[index] = NSMutableArray()
            }
            
            let gameprocedure = GameProcedure_CPPWrapper()
            gameprocedure.GameProcedure_CPPWrapper()
            gameprocedure.ShuffleCards(lists[0], pca2: lists[1], pca3: lists[2], pca4: lists[3])
            
            appendImage(0)
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleMPCReceivedDataWithNotification:", name: "receivedMPCDataNotification", object: nil)
        
    }
    
    
    func forwards(c1: Card_CPPWrapper!, c2: Card_CPPWrapper!) -> Bool {
        return c1.compare(c1, to: c2, suit: keysuit, rank: keyrank)
    }
    
    func appendImage(index: Int) {
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
                self.layout.angleOffset = 0
                self.layout.anglePerItem = scale * 233 / 3000  / 1.7 / scale
                self.collectionView.reloadData()
                self.layout.invalidateLayout()
            }
            if(index < 26) {
                self.appendImage(index+1)
            }
        })
    }
    
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView,
        numberOfItemsInSection section: Int) -> Int {
            return myCards.count
    }
    
    func collectionView(collectionView: UICollectionView,
        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CircularCollectionViewCell
            
            //  cell.imageName = images[indexPath.row]
            cell.imageName = "Images/PNG-cards-All/" + myCards[indexPath.row].toString() + ".png"
            return cell
    }
    
    func collectionView(collectionView: UICollectionView,
        didSelectItemAtIndexPath indexPath: NSIndexPath) {
            print(indexPath.row)
            self.layout.selected[indexPath.row] = true
            self.layout.invalidateLayout()
    }
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath:NSIndexPath) {
        self.layout.selected[indexPath.row] = false
        self.layout.invalidateLayout()
    }
    
    
    func assignCard(index: Int, player: Int) -> Bool{
        
        let message = "_assign_card_"
        //    let value = "Images/PNG-cards-All/" + self.lists[player + 1][index].toString() + ".png"
        //    let messageDictionary: [String: String] = ["message": message, "value": value]
        //
        //    let messageData = NSKeyedArchiver.archivedDataWithRootObject(messageDictionary)
        //
        //        do {
        //          try appDelegate.mpcManager.sessions[player].sendData(messageData, toPeers: appDelegate.mpcManager.sessions[player].connectedPeers, withMode: MCSessionSendDataMode.Reliable)
        //        }
        //        catch let error as NSError {
        //          print(error.localizedDescription)
        //          print("Can not send data")
        //          return false
        //        }
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
                self.updateView()
                self.layout.invalidateLayout()
                if(self.myCards.count > 12) {
                    self.layout.angleOffset += self.layout.anglePerItem
                }
                if(self.myCards.count == 27) {
                    self.layout.angleOffset = 0
                    self.layout.anglePerItem = scale * 233 / 3000  / 1.7 / scale
                    self.collectionView.reloadData()
                    self.layout.invalidateLayout()
                }
                
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    self.updateView()
                })
            }
        }
    }
    
    func updateView(){
        self.collectionView.reloadData()
        self.layout.invalidateLayout()
    }
}
