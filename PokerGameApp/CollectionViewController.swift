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
let Identifier = "Cellx"
let imageOn = UIImage(named: "Button_On") as UIImage!
let imageOff = UIImage(named: "Button_Off") as UIImage!

class CollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let manager = CardManager_CPPWrapper()
    
    // keysuit can keyrank should be updated while assigning cards
    var keysuit = 0
    var keyrank = 4
    var images = [String]()
    var layout: CircularCollectionViewLayout!
    var myCards = [Card_CPPWrapper]()
    var gameprocedure: GameProcedure_CPPWrapper!
    var playerID = 0
    var myTurn = false
    var enableTest = false
    var keyCardsCount = [NSInteger](count:6, repeatedValue:0)
    var single = false;
    var double = false;
    var lowjoker = false;
    var highjoker = false;
    
    var leftCards = [Card_CPPWrapper]()
    var rightCards = [Card_CPPWrapper]()
    var topCards = [Card_CPPWrapper]()
    var bottomCards = [Card_CPPWrapper]()

    
    // only used for server
    var lists = [NSMutableArray!](count: 4, repeatedValue: nil)
    var playList = [NSArray!](count:4, repeatedValue: nil)
    var currentPlayer = 1
    var playCount = 0
    
   
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var left: UICollectionView!
    @IBOutlet weak var right: UICollectionView!
    @IBOutlet weak var top: UICollectionView!
    @IBOutlet weak var bottom: UICollectionView!
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var spadeButton: UIButton!
    @IBOutlet weak var heartButton: UIButton!
    @IBOutlet weak var clubButton: UIButton!
    @IBOutlet weak var diamondButton: UIButton!
    @IBOutlet weak var jokerButton: UIButton!
    @IBOutlet weak var highjokerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layout = CircularCollectionViewLayout()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.setCollectionViewLayout(self.layout, animated: false)
        collectionView.registerNib(UINib(nibName: "CircularCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.allowsMultipleSelection = true
        //view.addSubview(collectionView)
        view.sendSubviewToBack(collectionView)
        playButton.enabled = false
        playButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        spadeButton.enabled = false
        spadeButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        heartButton.enabled = false
        heartButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        clubButton.enabled = false
        clubButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        diamondButton.enabled = false
        diamondButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        jokerButton.enabled = false
        jokerButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        highjokerButton.enabled = false
        highjokerButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)

        
        
        left.registerNib(UINib(nibName: "CardCell", bundle: nil), forCellWithReuseIdentifier: Identifier)
        right.registerNib(UINib(nibName: "CardCell", bundle: nil), forCellWithReuseIdentifier: Identifier)
        top.registerNib(UINib(nibName: "CardCell", bundle: nil), forCellWithReuseIdentifier: Identifier)
        bottom.registerNib(UINib(nibName: "CardCell", bundle: nil), forCellWithReuseIdentifier: Identifier)
        
        let c1 = Card_CPPWrapper()
        c1.Card_CPPWrapper(1, rank: 5)
        let c2 = Card_CPPWrapper()
        c2.Card_CPPWrapper(2, rank: 11)
        leftCards.append(c2)
        leftCards.append(c2)
        leftCards.append(c2)
        leftCards.append(c2)
        leftCards.append(c2)
        leftCards.append(c1)
        leftCards.append(c1)
        leftCards.append(c1)
        leftCards.append(c1)
        leftCards.append(c1)
        
        rightCards.append(c1)
        topCards.append(c2)
        bottomCards.append(c1)
        
        left.delegate = self
        left.dataSource = self
        right.delegate = self
        right.dataSource = self
        top.delegate = self
        top.dataSource = self
        bottom.delegate = self
        bottom.dataSource = self
        
        let screenHeight = UIScreen.mainScreen().bounds.height
        let height = Int(screenHeight * 0.15)
        let width = Int(height * 233 / 338)
        let minimumInteritemSpacing = -CGFloat(width) / 1.5
        
        let layoutx: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layoutx.itemSize = CGSize(width: width, height: height)
        layoutx.minimumInteritemSpacing = minimumInteritemSpacing


        let layouty: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layouty.itemSize = CGSize(width: width, height: height)
        layouty.minimumInteritemSpacing = minimumInteritemSpacing

        let layoutz: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layoutz.itemSize = CGSize(width: width, height: height)
        layoutz.minimumInteritemSpacing = minimumInteritemSpacing

        let layoutw: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layoutw.itemSize = CGSize(width: width, height: height)
        layoutw.minimumInteritemSpacing = minimumInteritemSpacing
        
        left.setCollectionViewLayout(layoutx, animated: false)
        right.setCollectionViewLayout(layouty, animated: false)
        top.setCollectionViewLayout(layoutz, animated: false)
        bottom.setCollectionViewLayout(layoutw, animated: false)

        /************************************* Server Device  *********************************/
        if (self.appDelegate.mpcManager.server) {
            for index in 0...3 {
                lists[index] = NSMutableArray()
            }
            
            gameprocedure = GameProcedure_CPPWrapper()
            gameprocedure.GameProcedure_CPPWrapper()
            gameprocedure.ShuffleCards(lists[0], pca2: lists[1], pca3: lists[2], pca4: lists[3])
            assignCard_to_all(0)
        }
        /**************************************************************************************/
        
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
            self.updateSuitButton(self.lists[0][index] as! Card_CPPWrapper)
            
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
                self.layout.anglePerItem = scale * 233 / 3000  / 1.7 / scale
                self.collectionView.reloadData()
                self.layout.invalidateLayout()
            }
            if(index < 26) {
                self.assignCard_to_all(index+1)
            }
            else {
                self.manager.CardManager_CPPWrapper(self.myCards)
                self.assignPlayerID(1)
                self.assignPlayerID(2)
                self.assignPlayerID(3)
                self.assignNext(false, player: self.currentPlayer)
            }
        })
    }
    
    //************************************** Collection View *****************************************//
    
    func collectionView(collectionView: UICollectionView,
        numberOfItemsInSection section: Int) -> Int {
            if collectionView == self.collectionView { return myCards.count }
            else if collectionView == self.left {return leftCards.count}
            else if collectionView == self.right {return rightCards.count}
            else if collectionView == self.top {return topCards.count}
            else if collectionView == self.bottom {return bottomCards.count}
            else { return 0 }
    }
    
    
    func collectionView(collectionView: UICollectionView,
        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
            
            if collectionView == self.collectionView {
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CircularCollectionViewCell
                cell.imageName = "Images/PNG-cards-All/" + myCards[indexPath.row].toString() + ".png"
                return cell
            }
            else {
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Identifier, forIndexPath: indexPath) as! CardCell
                if collectionView == self.left {
                    cell.imageName = "Images/PNG-cards-All/" + leftCards[indexPath.row].toString() + ".png"
                }
                else if collectionView == self.right {
                    cell.imageName = "Images/PNG-cards-All/" + rightCards[indexPath.row].toString() + ".png"
                }
                else if collectionView == self.top {
                    cell.imageName = "Images/PNG-cards-All/" + topCards[indexPath.row].toString() + ".png"
                }
                else if collectionView == self.bottom {
                    cell.imageName = "Images/PNG-cards-All/" + bottomCards[indexPath.row].toString() + ".png"
                }
                return cell
            }
            
    }
    
    func collectionView(collectionView: UICollectionView,
        didSelectItemAtIndexPath indexPath: NSIndexPath) {
            print(indexPath.row)
            self.layout.selected[indexPath.row] = true
            self.layout.invalidateLayout()
            self.updateButton()
    }
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath:NSIndexPath) {
        self.layout.selected[indexPath.row] = false
        self.layout.invalidateLayout()
        self.updateButton()
    }
    
    
    //*************************************************************************************************//
    
    
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
        // Get the dictionary containing the data and the source peer from the notification.
        let receivedDataDictionary = notification.object as! Dictionary<String, AnyObject>
        
        // "Extract" the data and the source peer from the received dictionary.
        let data = receivedDataDictionary["data"] as? NSData
        
        // Convert the data (NSData) into a Dictionary object.
        let dataDictionary = NSKeyedUnarchiver.unarchiveObjectWithData(data!) as! Dictionary<String, AnyObject>
        
        
        if let message = dataDictionary["message"] {
            // Check if there's an entry with the "_assign_card_" key.
            if message as! String == "_assign_card_"{
                    NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    let card = dataDictionary["card"] as! Card_CPPWrapper
                    self.myCards.append(card);
                    self.myCards.sortInPlace(self.forwards)
                    self.collectionView.reloadData()
                    self.layout.invalidateLayout()
                    if(self.myCards.count > 12) {
                        self.layout.angleOffset += self.layout.anglePerItem
                    }
                    if(self.myCards.count == 27) {
                        self.layout.anglePerItem = scale * 233 / 3000  / 1.7 / scale
                        self.manager.CardManager_CPPWrapper(self.myCards)
                    }
                    self.collectionView.reloadData()
                    self.layout.invalidateLayout()
                    self.updateSuitButton(card)
                })
            }
            // Check if there's an entry with the "_assign_next_" key.
            if message as! String == "_assign_next_" {
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    self.playButton.setTitleColor(UIColor.redColor(), forState: UIControlState.Normal)
                    self.playButton.setBackgroundImage(imageOn, forState: UIControlState.Normal)
                    self.playButton.enabled = false
                    self.myTurn = true
                    self.enableTest = dataDictionary["flag"] as! Bool
                })
            }
            // Check if there's an entry with the "_broadcast_" key.
            if message as! String == "_broadcast_" {
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    let flag = dataDictionary["flag"] as! Bool
                    if (!flag) {
                        let format = dataDictionary["cards"] as! [Card_CPPWrapper]
                        self.manager.setFormat(format)
                    }
                 })
            }
            // Check if there's an entry with the "_play_cards_" key.
            if message as! String == "_play_cards_" {
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    let flag = dataDictionary["flag"] as! Bool
                    let cards = dataDictionary["cards"] as! [Card_CPPWrapper]
                    let fromplayer = dataDictionary["fromplayer"] as! Int
                    if (flag) {
                        self.broadcast(flag, fromplayer: fromplayer, cards: cards)
                        self.gameprocedure.remove(cards, n: fromplayer)
                        self.playList[self.playCount % 4] = cards
                    }
                    else {
                        let cardsBack = self.gameprocedure.testStarter(cards, suit:cards[0].suit, n:fromplayer);
                        let message = "_play_cards_back_"
                        let messageDictionary: [String: AnyObject] = ["message": message, "cardsback": cardsBack]
                        let messageData = NSKeyedArchiver.archivedDataWithRootObject(messageDictionary)
                        do {
                            try self.appDelegate.mpcManager.sessions[fromplayer-1].sendData(messageData, toPeers: self.appDelegate.mpcManager.sessions[fromplayer-1].connectedPeers, withMode: MCSessionSendDataMode.Reliable)
                        }
                        catch let error as NSError {
                            print(error.localizedDescription)
                            print("Can not send data")
                        }
                        self.broadcast(flag, fromplayer: fromplayer, cards: cardsBack)
                        self.gameprocedure.remove(cardsBack, n: fromplayer)
                        self.playList[self.playCount % 4] = cardsBack
                    }
                    
                    self.playCount++
                    if (self.playCount % 4 != 0) {
                        self.currentPlayer = (self.currentPlayer + 1) % 4
                        self.assignNext(true, player: self.currentPlayer)
                    }
                    else {
                        let winner = self.gameprocedure.Winner(self.playList[0] as! [Card_CPPWrapper], player1:self.playList[1] as! [Card_CPPWrapper], player2: self.playList[2] as! [Card_CPPWrapper], player3: self.playList[3] as! [Card_CPPWrapper])
                        print("winner = ")
                        print(winner)
                        self.currentPlayer = (self.currentPlayer + 1 + winner) % 4
                        self.assignNext(false, player: self.currentPlayer)
                    }
                    
                    
                })
            }
            // Check if there's an entry with the "_play_cards_back_" key.
            if message as! String == "_play_cards_back_" {
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                let cardsBack = dataDictionary["cardsback"] as! [Card_CPPWrapper]
                self.removeCardsBack(cardsBack)
                })
            }
            // Check if there's an entry with the "_player_ID" key.
            if message as! String == "_player_ID_" {
                self.playerID = dataDictionary["playerID"] as! Int
            }
            // Check if there's an entry with the "_change_state_" key.
            if message as! String == "_change_state_" {
                let buttonID = dataDictionary["buttonID"] as! Int
                let state = dataDictionary["state"] as! Int
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    self.changeState(buttonID, state: state)
                })
            }
            // Check if there's an entry with the "_change_state_request_" key.
            if message as! String == "_change_state_request_" {
                let buttonID = dataDictionary["buttonID"] as! Int
                let state = dataDictionary["state"] as! Int
                if ((state == 1 && !single) || state == 2) {
                    NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                        self.changeStateBroadcast(buttonID, state: state)
                    })
                }
            }
        }
    }
    
    func updateButton(){
        self.layout.invalidateLayout()
        var selectedCards = [Card_CPPWrapper]()
        for i in 0...myCards.count-1 {
            if (self.layout.selected[i]) {
                selectedCards.append(myCards[i])
            }
        }

        if (self.enableTest && self.myTurn) {
            if (manager.testCards(selectedCards)) {
                playButton.enabled = true
                playButton.setTitleColor(UIColor.greenColor(), forState: UIControlState.Normal)
                self.playButton.setBackgroundImage(imageOn, forState: UIControlState.Normal)
                print ("cheer")
            }
            else {
                playButton.setTitleColor(UIColor.redColor(), forState: UIControlState.Normal)
                self.playButton.setBackgroundImage(imageOn, forState: UIControlState.Normal)
                playButton.enabled = false
                print ("bad")
            }
        }
        else if(self.myTurn) {
            if (selectedCards.count > 0 && (manager.isUniform(selectedCards) != -1)) {
                if (manager.isUniform(selectedCards) == keysuit && manager.structureSize(selectedCards) != 1) {
                    playButton.enabled = false
                    playButton.setTitleColor(UIColor.redColor(), forState: UIControlState.Normal)
                    self.playButton.setBackgroundImage(imageOn, forState: UIControlState.Normal)
                }
                else {
                    playButton.enabled = true
                    playButton.setTitleColor(UIColor.greenColor(), forState: UIControlState.Normal)
                    self.playButton.setBackgroundImage(imageOn, forState: UIControlState.Normal)
                }
            }
            else {
                playButton.enabled = false
                playButton.setTitleColor(UIColor.redColor(), forState: UIControlState.Normal)
                self.playButton.setBackgroundImage(imageOn, forState: UIControlState.Normal)
            }
        }
    }
    
    @IBAction func playCards(sender: AnyObject) {
        var selectedCards = [Card_CPPWrapper]()
        for i in 0...myCards.count-1 {
            if (self.layout.selected[i]) {
                selectedCards.append(myCards[i])
            }
        }
        if(!self.appDelegate.mpcManager.server) {
            let message = "_play_cards_"
            let messageDictionary: [String: AnyObject] = ["message": message, "flag": enableTest, "fromplayer": self.playerID, "cards": selectedCards]
            let messageData = NSKeyedArchiver.archivedDataWithRootObject(messageDictionary)
            do {
                try appDelegate.mpcManager.sessions[0].sendData(messageData, toPeers: appDelegate.mpcManager.sessions[0].connectedPeers, withMode: MCSessionSendDataMode.Reliable)
            }
            catch let error as NSError {
                print(error.localizedDescription)
                print("Can not send data")
            }
            if (enableTest) {
                for var i = myCards.count-1; i >= 0; i-- {
                    if (self.layout.selected[i]) {
                        manager.remove(myCards[i])
                        myCards.removeAtIndex(i)
                        self.layout.selected.removeAtIndex(i)
                    }
                }
            }
        }

        else {
            if (enableTest) {
                broadcast(true, fromplayer: 0, cards: selectedCards)
                for var i = myCards.count-1; i >= 0; i-- {
                    if (self.layout.selected[i]) {
                        manager.remove(myCards[i])
                        myCards.removeAtIndex(i)
                        self.layout.selected.removeAtIndex(i)
                        self.playList[self.playCount % 4] = selectedCards
                    }
                }
                self.gameprocedure.remove(selectedCards, n: 0) //*****************//
            }
            else {
                let cardsBack = self.gameprocedure.testStarter(selectedCards, suit:selectedCards[0].suit, n:0);
                self.broadcast(false, fromplayer: 0, cards: cardsBack)
                self.gameprocedure.remove(cardsBack, n: 0)
                self.removeCardsBack(cardsBack)
                self.playList[self.playCount % 4] = cardsBack
            }
            
            self.playCount++
            if (self.playCount % 4 != 0) {
                self.currentPlayer = (self.currentPlayer + 1) % 4
                self.assignNext(true, player: self.currentPlayer)
            }
            else {
                let winner = self.gameprocedure.Winner(self.playList[0] as! [Card_CPPWrapper], player1:self.playList[1] as! [Card_CPPWrapper], player2: self.playList[2] as! [Card_CPPWrapper], player3: self.playList[3] as! [Card_CPPWrapper])
                print("winner = ")
                print(winner)
                self.currentPlayer = (self.currentPlayer + 1 + winner) % 4
                self.assignNext(false, player: self.currentPlayer)
            }
        }
        
        playButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        playButton.setBackgroundImage(imageOff, forState: UIControlState.Normal)
        playButton.enabled = false
        self.layout.invalidateLayout()
        self.collectionView.reloadData()
        self.myTurn = false
    }
    
    
    func removeCardsBack(cardsBack:[Card_CPPWrapper]) {
        print("here")
        print(cardsBack.count)
        for var j = 0; j < cardsBack.count; j++ {
            print("suit")
            print(cardsBack[j].suit)
            print("rank")
            print(cardsBack[j].rank)
            for var i = 0; i < myCards.count; i++ {
                if (cardsBack[j].suit == myCards[i].suit &&
                    cardsBack[j].rank == myCards[i].rank) {
                    manager.remove(myCards[i])
                    myCards.removeAtIndex(i)
                    self.layout.selected.removeAtIndex(i)
                    print(i)
                    break;
                }
            }
        }
        self.layout.invalidateLayout()
        self.collectionView.reloadData()
    }
    
    func assignNext(flag: Bool, player: Int) -> Bool{
        if (player != 0 ) {
            let message = "_assign_next_"
            let messageDictionary: [String: AnyObject] = ["message": message, "flag": flag]
            let messageData = NSKeyedArchiver.archivedDataWithRootObject(messageDictionary)
            do {
                try appDelegate.mpcManager.sessions[player-1].sendData(messageData, toPeers: appDelegate.mpcManager.sessions[player-1].connectedPeers, withMode: MCSessionSendDataMode.Reliable)
            }
            catch let error as NSError {
                print(error.localizedDescription)
                print("Can not send data")
                return false
            }
            return true
        }
        else {
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                self.myTurn = true
                self.enableTest = flag
                self.updateButton()
            })
            return true
        }
    }
    
    func assignPlayerID(player: Int) -> Bool {
        let message = "_player_ID_"
        let messageDictionary: [String: AnyObject] = ["message": message, "playerID": player]
        let messageData = NSKeyedArchiver.archivedDataWithRootObject(messageDictionary)
        do {
            try appDelegate.mpcManager.sessions[player-1].sendData(messageData, toPeers: appDelegate.mpcManager.sessions[player-1].connectedPeers, withMode: MCSessionSendDataMode.Reliable)
        }
        catch let error as NSError {
            print(error.localizedDescription)
            print("Can not send data")
            return false
        }
        return true
    }
    
    
    func broadcast(flag: Bool, fromplayer: Int, cards: [Card_CPPWrapper]) -> Bool {
        let message = "_broadcast_"
        let messageDictionary: [String: AnyObject] = ["message": message, "flag": flag, "fromplayer": fromplayer, "cards": cards]
        let messageData = NSKeyedArchiver.archivedDataWithRootObject(messageDictionary)
        if (self.appDelegate.mpcManager.connectedSessionCount > 0) {
            for sessionID in 0...self.appDelegate.mpcManager.connectedSessionCount-1 {
                do {
                    try appDelegate.mpcManager.sessions[sessionID].sendData(messageData, toPeers: appDelegate.mpcManager.sessions[sessionID].connectedPeers, withMode: MCSessionSendDataMode.Reliable)
                }
                catch let error as NSError {
                    print(error.localizedDescription)
                    print("Can not send data")
                    return false
                }
            }
        }
        if(!flag) {
            self.manager.setFormat(cards)
        }
        return true
    }
    
    func changeStateBroadcast(buttonID: Int, state: Int) -> Bool {
        let message = "_change_state_"
        let messageDictionary: [String: AnyObject] = ["message": message, "buttonID": buttonID, "state": state]
        let messageData = NSKeyedArchiver.archivedDataWithRootObject(messageDictionary)
        if (self.appDelegate.mpcManager.connectedSessionCount > 0) {
            for sessionID in 0...self.appDelegate.mpcManager.connectedSessionCount-1 {
                do {
                    try appDelegate.mpcManager.sessions[sessionID].sendData(messageData, toPeers: appDelegate.mpcManager.sessions[sessionID].connectedPeers, withMode: MCSessionSendDataMode.Reliable)
                }
                catch let error as NSError {
                    print(error.localizedDescription)
                    print("Can not send data")
                    return false
                }
            }
        }
        self.changeState(buttonID, state:state)
        return true
    }
    
    func updateSuitButton(card: Card_CPPWrapper) {
        var n : NSInteger
        let color = UIColor.redColor()
        if (card.rank == keyrank) {
            n = ++keyCardsCount[card.suit]
            if ((n==1 && !single) || (n==2 && card.suit > keysuit) || (n==2 && !double)){
                print("change suit button state")
                switch (card.suit) {
                case 0:
                    self.spadeButton.enabled = true
                    self.spadeButton.setTitleColor(color, forState: UIControlState.Normal)
                    break
                case 1:
                    self.heartButton.enabled = true
                    self.heartButton.setTitleColor(color, forState: UIControlState.Normal)
                    break
                case 2:
                    self.clubButton.enabled = true
                    self.clubButton.setTitleColor(color, forState: UIControlState.Normal)
                    break
                case 3:
                    self.diamondButton.enabled = true
                    self.diamondButton.setTitleColor(color, forState: UIControlState.Normal)
                    break
                default:
                    break
                }
            }
            
        }
        if (card.suit == 4) {
            n = ++keyCardsCount[card.rank + 4]
            if (n==2) {
                switch (card.rank) {
                case 0:
                    self.jokerButton.enabled = true
                    self.jokerButton.setTitleColor(color, forState: UIControlState.Normal)
                    break
                case 1:
                    self.highjokerButton.enabled = true
                    self.highjokerButton.setTitleColor(color, forState: UIControlState.Normal)
                    break
                default:
                    break
                }
            }
        }
    }
    
    func changeState(buttonID: Int, state: Int) {
        if (buttonID < 5) {
            keysuit = buttonID
            self.manager.updateKeySuit(buttonID)
        }
        else {
            keysuit = 4
            self.manager.updateKeySuit(buttonID)
        }
        self.myCards.sortInPlace(self.forwards)
        self.collectionView.reloadData()
        self.layout.invalidateLayout()
        let color = UIColor.blackColor()
        if (state == 1){ single = true }
        if (state == 2){ double = true}
        for index in 0...5 {
            if (keyCardsCount[index] == 1 || (keyCardsCount[index] == state && index <= buttonID)) {
                switch (index) {
                case 0:
                    self.spadeButton.enabled = false
                    self.spadeButton.setTitleColor(color, forState: UIControlState.Normal)
                    break
                case 1:
                    self.heartButton.enabled = false
                    self.heartButton.setTitleColor(color, forState: UIControlState.Normal)
                    break
                case 2:
                    self.clubButton.enabled = false
                    self.clubButton.setTitleColor(color, forState: UIControlState.Normal)
                    break
                case 3:
                    self.diamondButton.enabled = false
                    self.diamondButton.setTitleColor(color, forState: UIControlState.Normal)
                    break
                case 4:
                    self.jokerButton.enabled = false
                    self.jokerButton.setTitleColor(color, forState: UIControlState.Normal)
                    break
                case 5:
                    self.highjokerButton.enabled = false
                    self.highjokerButton.setTitleColor(color, forState: UIControlState.Normal)
                    break
                default:
                    break
                }
            }
        }
    }
    
    func changeStateRequest(buttonID: Int) -> Bool {
        var state: Int
        if (single || buttonID > 3) { state = 2 }
        else { state = 1 }
        if(self.appDelegate.mpcManager.server) {
            self.changeStateBroadcast(buttonID, state: state)
            return true;
        }
        else {
            let message = "_change_state_request_"
            let messageDictionary: [String: AnyObject] = ["message": message, "buttonID": buttonID, "state": state]
            let messageData = NSKeyedArchiver.archivedDataWithRootObject(messageDictionary)
            do {
                try appDelegate.mpcManager.sessions[0].sendData(messageData, toPeers: appDelegate.mpcManager.sessions[0].connectedPeers, withMode: MCSessionSendDataMode.Reliable)
            }
            catch let error as NSError {
                print(error.localizedDescription)
                print("Can not send data")
                return false
            }
        }
        return true;
    }
    
    @IBAction func spadesButton(sender: AnyObject) {
        self.changeStateRequest(0)
    }
    
    @IBAction func heartsButton(sender: AnyObject) {
        self.changeStateRequest(1)
    }
    
    @IBAction func clubsButton(sender: AnyObject) {
        self.changeStateRequest(2)
    }
    
    @IBAction func diamondsButton(sender: AnyObject) {
        self.changeStateRequest(3)
    }
    
    @IBAction func jokersButton(sender: AnyObject) {
        self.changeStateRequest(4)
    }
    
    @IBAction func highjokersButton(sender: AnyObject) {
        self.changeStateRequest(5)
    }
}


