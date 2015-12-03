//
//  CollectionViewController.swift
//  CircularCollectionView
//
//  Created by Rounak Jain on 10/05/15.
//  Copyright (c) 2015 Rounak Jain. All rights reserved.
//
import Foundation
import UIKit
import MultipeerConnectivity

let reuseIdentifier = "Cell"

class CollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
  
  var images: [String] = NSBundle.mainBundle().pathsForResourcesOfType("png", inDirectory: "Images/PNG-cards-Part")
//  let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
  
//  var images = [String]()
  var layout: CircularCollectionViewLayout!
  var lists = [NSMutableArray!](count: 4, repeatedValue: nil)
  

    
    @IBOutlet weak var collectionView: UICollectionView!

  override func viewDidLoad() {
    super.viewDidLoad()
    // Register cell classes
    layout = CircularCollectionViewLayout()
    
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.setCollectionViewLayout(layout, animated: false)
    
    collectionView.registerNib(UINib(nibName: "CircularCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
    let imageView = UIImageView(image: UIImage(named: "bg-dark.jpg"))
    imageView.contentMode = UIViewContentMode.ScaleAspectFill
    collectionView.backgroundView = imageView
    collectionView.allowsMultipleSelection = true
    view.addSubview(collectionView)
    view.sendSubviewToBack(collectionView)
    print(images.count)
    
//    if (self.appDelegate.mpcManager.server) {
//    
//    // *********   Test c++ Code  ********************************//
//      let wrapperCard = Card_CPPWrapper()
//      wrapperCard.Card_CPPWrapper(3, rank: 12)
//      print("String: \(wrapperCard.toString())")
//      
//      for index in 0...3 {
//        lists[index] = NSMutableArray()
//      }
//      
//      let gameprocedure = GameProcedure_CPPWrapper()
//      gameprocedure.GameProcedure_CPPWrapper()
//      gameprocedure.ShuffleCards(lists[0], pca2: lists[1], pca3: lists[2], pca4: lists[3])
//      
//      appendImage(0)
//      
//    }
//   
//    NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleMPCReceivedDataWithNotification:", name: "receivedMPCDataNotification", object: nil)
//    
  }
  
//  func appendImage(index: Int) {
//    let time = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC))
//    dispatch_after(time, dispatch_get_main_queue(), {
//      self.images.append("Images/PNG-cards-All/" + self.lists[0][index].toString() + ".png")
//      
//      if (self.appDelegate.mpcManager.connectedSessionCount > 0) {
//        for playerID in 0...self.appDelegate.mpcManager.connectedSessionCount-1 {
//          self.assignCard(index, player: playerID)
//        }
//      }
//      if(index > 3) {
//        self.layout.angleOffset += self.layout.anglePerItem
//      }
//      self.collectionView.reloadData()
//      self.layout.invalidateLayout()
//      if(index == self.lists[0].count-1) {
//        self.layout.angleOffset = 0
//        self.collectionView.reloadData()
//        self.layout.invalidateLayout()
//      }
//      if(index < 26) {
//        self.appendImage(index+1)
//      }
//    })
//  }
  
  
  // MARK: UICollectionViewDataSource
  
  func collectionView(collectionView: UICollectionView,
    numberOfItemsInSection section: Int) -> Int {
      return images.count
  }
  
  func collectionView(collectionView: UICollectionView,
    cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
      let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CircularCollectionViewCell
      cell.imageName = images[indexPath.row]
      return cell
  }
  
  func collectionView(collectionView: UICollectionView,
    didSelectItemAtIndexPath indexPath: NSIndexPath) {
      print(indexPath.row)
      self.layout.selected[indexPath.row] = true
     
      layout.invalidateLayout()
  }
  func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath:NSIndexPath) {
    self.layout.selected[indexPath.row] = false
    layout.invalidateLayout()
  }
  
  
  
  
//  func assignCard(index: Int, player: Int) -> Bool{
//  
//    let message = "_assign_card_"
//    let value = "Images/PNG-cards-All/" + self.lists[player + 1][index].toString() + ".png"
//    
//    let messageDictionary: [String: String] = ["message": message, "value": value]
//    
//    let messageData = NSKeyedArchiver.archivedDataWithRootObject(messageDictionary)
//    
//
//        do {
//          try appDelegate.mpcManager.sessions[player].sendData(messageData, toPeers: appDelegate.mpcManager.sessions[player].connectedPeers, withMode: MCSessionSendDataMode.Reliable)
//        }
//        catch let error as NSError {
//          print(error.localizedDescription)
//          print("Can not send data")
//          return false
//        }
//    return true
//  }
  
  
  
  func handleMPCReceivedDataWithNotification(notification: NSNotification) {
    print("yes")
    // Get the dictionary containing the data and the source peer from the notification.
    let receivedDataDictionary = notification.object as! Dictionary<String, AnyObject>
    
    // "Extract" the data and the source peer from the received dictionary.
    let data = receivedDataDictionary["data"] as? NSData
    
    // Convert the data (NSData) into a Dictionary object.
    let dataDictionary = NSKeyedUnarchiver.unarchiveObjectWithData(data!) as! Dictionary<String, String>
    
    // Check if there's an entry with the "message" key.
    if let message = dataDictionary["message"] {
      // Make sure that the message is other than "_end_chat_".
      if message == "_assign_card_"{
        // Create a new dictionary and set the sender and the received message to it.
        let value = dataDictionary["value"]
        self.images.append(value!);
        self.collectionView.reloadData()
        self.layout.invalidateLayout()
        if(self.images.count > 3) {
          self.layout.angleOffset += self.layout.anglePerItem
        }
        if(self.images.count == 27) {
          self.layout.angleOffset = 0
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
