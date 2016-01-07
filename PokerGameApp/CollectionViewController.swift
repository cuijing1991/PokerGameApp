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
let imageRed = UIImage(named: "Button_Red") as UIImage!
let endNum = 25
let playCardsRatio = 0.15

class CollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let manager = CardManager_CPPWrapper()
    
    // keysuit can keyrank should be updated while assigning cards
    var keysuit = GameInfo_CPPWrapper.getKeySuit()
    var keyrank = GameInfo_CPPWrapper.getKeyRank()
    var lord = 1
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
    var joker = false;
    var imageSet = [UIImage]()
    var myTable = false
    var sorted = false
    var keySuitCaller = -1
    var myInquireSuit = false
    
    var leftCards = [Card_CPPWrapper]()
    var rightCards = [Card_CPPWrapper]()
    var topCards = [Card_CPPWrapper]()
    var bottomCards = [Card_CPPWrapper]()

    var playCount = 0
    
    // only used for server
    var lists = [NSMutableArray!](count: 5, repeatedValue: nil)
    var playList = [NSArray!](count:4, repeatedValue: nil)
    var currentPlayer = 0
    var playCardCount = 0 {
        didSet {
            if (playCardCount == endNum * 4) {
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    self.gameEnd = true;
                    self.nextGameButton.enabled = true;
                })
            }
        }
    }
    var gameEnd = false;
    var skippedNum = 0;
    
   
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var left: UICollectionView!
    @IBOutlet weak var right: UICollectionView!
    @IBOutlet weak var top: UICollectionView!
    @IBOutlet weak var bottom: UICollectionView!
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var tableButton: UIButton!
    
    @IBOutlet weak var spadeButton: UIButton!
    @IBOutlet weak var heartButton: UIButton!
    @IBOutlet weak var clubButton: UIButton!
    @IBOutlet weak var diamondButton: UIButton!
    @IBOutlet weak var jokerButton: UIButton!
    @IBOutlet weak var highjokerButton: UIButton!
    
    @IBOutlet weak var leftImage: UIImageView!
    @IBOutlet weak var bottomImage: UIImageView!
    @IBOutlet weak var rightImage: UIImageView!
    @IBOutlet weak var topImage: UIImageView!
    
    @IBOutlet weak var scores: UILabel!
    @IBOutlet weak var nextGameButton: UIButton!
    
    
    override func viewDidLoad() {
        layout = CircularCollectionViewLayout()
        
        if self.appDelegate.mpcManager.connectedSessionCount > 0 {
            for index in 0...self.appDelegate.mpcManager.connectedSessionCount-1 {
                print("connected peer count")
                print(self.appDelegate.mpcManager.sessions[index].connectedPeers.count)
            }
        }
        
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.setCollectionViewLayout(self.layout, animated: false)
        collectionView.registerNib(UINib(nibName: "CircularCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.allowsMultipleSelection = true
        //view.addSubview(collectionView)
        view.sendSubviewToBack(collectionView)
        playButton.enabled = false
        tableButton.enabled = false
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

        imageSet.append(UIImage(named:"4.jpg")!)
        imageSet.append(UIImage(named:"8.jpg")!)
        imageSet.append(UIImage(named:"11.jpg")!)
        imageSet.append(UIImage(named:"6.jpg")!)
        
        leftImage.image = nil
        topImage.image = nil
        bottomImage.image = nil
        rightImage.image = nil
        leftImage.layer.cornerRadius = leftImage.bounds.width/8
        topImage.layer.cornerRadius = leftImage.bounds.width/8
        bottomImage.layer.cornerRadius = leftImage.bounds.width/8
        rightImage.layer.cornerRadius = leftImage.bounds.width/8
        leftImage.clipsToBounds = true
        rightImage.clipsToBounds = true
        topImage.clipsToBounds = true
        bottomImage.clipsToBounds = true
        scores.text = "0"
        
        nextGameButton.enabled = false
        
        left.registerNib(UINib(nibName: "CardCell", bundle: nil), forCellWithReuseIdentifier: Identifier)
        right.registerNib(UINib(nibName: "CardCell", bundle: nil), forCellWithReuseIdentifier: Identifier)
        top.registerNib(UINib(nibName: "CardCell", bundle: nil), forCellWithReuseIdentifier: Identifier)
        bottom.registerNib(UINib(nibName: "CardCell", bundle: nil), forCellWithReuseIdentifier: Identifier)
        
        left.delegate = self
        left.dataSource = self
        right.delegate = self
        right.dataSource = self
        top.delegate = self
        top.dataSource = self
        bottom.delegate = self
        bottom.dataSource = self
        ////////////////////////////////////////////
        leftCards = [Card_CPPWrapper]()
        rightCards = [Card_CPPWrapper]()
        topCards = [Card_CPPWrapper]()
        bottomCards = [Card_CPPWrapper]()
       
        playCount = 0
        ////////////////////////////////////////////
        let screenHeight = UIScreen.mainScreen().bounds.height
        let height = Int(screenHeight * CGFloat(playCardsRatio))
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
            for index in 0...4 {
                lists[index] = NSMutableArray()
            }
            
            gameprocedure = GameProcedure_CPPWrapper()
            gameprocedure.GameProcedure_CPPWrapper()
            gameprocedure.ShuffleCards(lists[0], pca2: lists[1], pca3: lists[2], pca4: lists[3], tb: lists[4])
            
            self.assignPlayerID(1)
            self.assignPlayerID(2)
            self.assignPlayerID(3)
            
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

            self.assignCard(index, playerID: 0, listID: 0)
            
            if (self.appDelegate.mpcManager.connectedSessionCount > 0) {
                for playerID in 1...self.appDelegate.mpcManager.connectedSessionCount {
                    self.assignCard(index, playerID: playerID, listID: playerID)
                }
            }
            
            if(index < endNum-1) {
                self.assignCard_to_all(index+1)
            }
            else if(index == endNum-1) {
                
                self.manager.CardManager_CPPWrapper(self.myCards)
                self.bottomImage.image = self.imageSet[self.playerID]
                self.rightImage.image = self.imageSet[(self.playerID+1)%4]
                self.topImage.image = self.imageSet[(self.playerID+2)%4]
                self.leftImage.image = self.imageSet[(self.playerID+3)%4]

                self.spadeButton.enabled = false;
                self.heartButton.enabled = false;
                self.clubButton.enabled = false;
                self.diamondButton.enabled = false;
                self.jokerButton.enabled = false;
                self.highjokerButton.enabled = false;
                
                
                self.serverDeclareGameInfo()
                
                self.assignTableCards(self.lord)
                
                //self.assignNext(false, player: self.currentPlayer)
            }
        })
    }
    
    
    
    func assignCard(index: Int, playerID: Int, listID: Int) -> Bool{
        
        if (playerID==0) {
            
            let card = self.lists[listID][index] as! Card_CPPWrapper
            self.appendNewCard(card)
        }
        else {
            let message = "_assign_card_"
            let card = self.lists[listID][index] as! Card_CPPWrapper
            let messageDictionary: [String: AnyObject] = ["message": message, "card": card]
        
            let messageData = NSKeyedArchiver.archivedDataWithRootObject(messageDictionary)
        
            do {
            try appDelegate.mpcManager.sessions[playerID-1].sendData(messageData, toPeers: appDelegate.mpcManager.sessions[playerID-1].connectedPeers, withMode: MCSessionSendDataMode.Reliable)
            }
            catch let error as NSError {
                print(error.localizedDescription)
                print("Can not send data : assignCard")
                return false
            }
        }
        return true
    }
    
    func assignTableCards(playerID: Int) {
        if (playerID == 0) {
            self.appendTableCards(lists[4])
        }
        else {
            let message = "_assign_table_cards_"
            let messageDictionary: [String: AnyObject] = ["message": message, "cards": lists[4]]
            let messageData = NSKeyedArchiver.archivedDataWithRootObject(messageDictionary)
            do {
                try appDelegate.mpcManager.sessions[playerID-1].sendData(messageData, toPeers: appDelegate.mpcManager.sessions[playerID-1].connectedPeers, withMode: MCSessionSendDataMode.Reliable)
            }
            catch let error as NSError {
                print(error.localizedDescription)
                print("Can not send data: assignTableCards")
            }
        }
    }
    
    func appendNewCard(card: Card_CPPWrapper) {
        self.myCards.append(card);
        self.myCards.sortInPlace(self.forwards)
        if(self.myCards.count > 1) {
            self.layout.rotate()
        }
        if(self.myCards.count == endNum) {
            self.layout.rotateBack()
            self.manager.CardManager_CPPWrapper(self.myCards)
        }
        self.collectionView.reloadData()
        self.layout.invalidateLayout()
        //self.updateSuitButton(card)
        if (card.rank == keyrank) {
            keyCardsCount[card.suit]++
        }
        if (card.suit == 4) {
            keyCardsCount[card.rank + 4]++
        }
        self.updateSuitButton()
    }
    
    func appendTableCards(cards: NSMutableArray!) {
        for i in 0...7 {
            self.myCards.append(cards[i] as! Card_CPPWrapper);
        }
        self.playButton.setBackgroundImage(imageRed, forState: UIControlState.Normal)
        self.playButton.enabled = true
        self.myTable = true
        self.sorted = false
        self.collectionView.reloadData()
        self.layout.rotateBack()
        self.layout.invalidateLayout()
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
                    self.appendNewCard(card)
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
                    let fromplayer = dataDictionary["fromplayer"] as! Int
                    let cards = dataDictionary["cards"] as! [Card_CPPWrapper]
                    if (!flag) {
                        let format = dataDictionary["cards"] as! [Card_CPPWrapper]
                        self.manager.setFormat(format)
                    }
                    self.updateTable((fromplayer - self.playerID + 4) % 4,cards: cards)
                    self.playCount++
                    print("receive broadcast")
                 })
                
            }
            // Check if there's an entry with the "_play_cards_" key.
            if message as! String == "_play_cards_" {
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    print("server: receive _play_cards_")
                    let flag = dataDictionary["flag"] as! Bool
                    let cards = dataDictionary["cards"] as! [Card_CPPWrapper]
                    let fromplayer = dataDictionary["fromplayer"] as! Int
                    if (flag) {
                        self.serverBroadcastCards(flag, fromplayer: fromplayer, cards: cards)
                        self.gameprocedure.remove(cards, n: fromplayer)
                        self.playList[self.playCount % 4] = cards
                    }
                    else {
                        var cardsBack: [Card_CPPWrapper];
                        if (cards[0].suit == self.keysuit || cards[0].suit == 4 || cards[0].rank == self.keyrank) {
                            cardsBack = self.gameprocedure.testStarter(cards, suit:self.keysuit, n:fromplayer);
                        }
                        else {
                            cardsBack = self.gameprocedure.testStarter(cards, suit:cards[0].suit, n:fromplayer);
                        }
                        //let cardsBack = self.gameprocedure.testStarter(cards, suit:cards[0].suit, n:fromplayer);
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
                        self.serverBroadcastCards(flag, fromplayer: fromplayer, cards: cardsBack)
                        self.gameprocedure.remove(cardsBack, n: fromplayer)
                        self.playList[self.playCount % 4] = cardsBack
                    }
                    
                    self.serverNext()
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
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    self.playerID = dataDictionary["playerID"] as! Int
                    self.bottomImage.image = self.imageSet[self.playerID]
                    self.rightImage.image = self.imageSet[(self.playerID+1)%4]
                    self.topImage.image = self.imageSet[(self.playerID+2)%4]
                    self.leftImage.image = self.imageSet[(self.playerID+3)%4]
                    self.spadeButton.enabled = false;
                    self.heartButton.enabled = false;
                    self.clubButton.enabled = false;
                    self.diamondButton.enabled = false;
                    self.jokerButton.enabled = false;
                    self.highjokerButton.enabled = false;
                })
            }
            // Check if there's an entry with the "_change_keysuit_" key.
            if message as! String == "_change_keysuit_" {
                let buttonID = dataDictionary["buttonID"] as! Int
                let state = dataDictionary["state"] as! Int
                let fromplayer = dataDictionary["fromplayer"] as! Int
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    self.changeKeysuit(buttonID, state: state, fromplayer: fromplayer)
                })
            }
            // Check if there's an entry with the "_change_keysuit_request_" key.
            if message as! String == "_change_keysuit_request_" {
                let buttonID = dataDictionary["buttonID"] as! Int
                let state = dataDictionary["state"] as! Int
                let fromplayer = dataDictionary["fromplayer"] as! Int
                let inquireSuit = dataDictionary["inquireSuit"] as! Bool
                if ((state == 1 && !single) || state == 2) {
                    NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                        self.serverChangeKeysuitBroadcast(buttonID, state: state, fromplayer: fromplayer)
                        print("fromplayer : ")
                        print(fromplayer)
                        print(buttonID)
                        print(state)
                    })
                }
                if (inquireSuit) {
                    skippedNum = 0
                    assignTableCards(fromplayer)
                }
            }
            // Check if there's an entry with the "_update_scores_" key.
            if message as! String == "_update_scores_" {
                let scores = dataDictionary["scores"] as! Int
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    self.scores.text = String(scores)
                })
            }
            // Check if there's an entry with the "_declare_gameinfo_" key.
            if message as! String == "_declare_gameinfo_" {
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    let keyRank = dataDictionary["keyRank"] as! Int
                    self.keyrank = keyRank
                    GameInfo_CPPWrapper.updateKeyRank(keyRank)
                })
            }
            // Check if there's an entry with the "_assign_table_cards_" key.
            if message as! String == "_assign_table_cards_" {
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    let cards = dataDictionary["cards"] as! NSMutableArray
                    self.appendTableCards(cards)
                })
            }
            // Check if there's an entry with the "_remove_table_cards_" key.
            if message as! String == "_remove_table_cards_" {
                let cards = dataDictionary["cards"] as! [Card_CPPWrapper]
                let fromplayer = dataDictionary["fromplayer"] as! Int
                self.lists[4].removeAllObjects()
                for card in cards {
                    self.lists[4].addObject(card)
                }
                self.gameprocedure.remove(cards, n: fromplayer)
                self.assignInquireSuit((fromplayer+1)%4)
            }
            // Check if there's an entry with the "_inquire_suit_" key.
            if message as! String == "_inquire_suit_" {
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    self.inquireSuit()
                })
            }
            // Check if there's an entry with the "_skip_" key.
            if message as! String == "_skip_" {
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    let fromplayer = dataDictionary["fromplayer"] as! Int
                    self.skippedNum++
                    print(self.skippedNum)
                    if (self.skippedNum < 3) {
                        self.assignInquireSuit((fromplayer+1)%4)
                    }
                    else {
                        self.assignNext(false, player: self.currentPlayer)
                    }
                })
            }
        }
    }
    
    func updateButton(){
        self.layout.invalidateLayout()
        var selectedCards = [Card_CPPWrapper]()
        print("debug----updateButton():myCards.count = ")
        print(myCards.count)
        for i in 0...myCards.count-1 {
            if (self.layout.selected[i]) {
                selectedCards.append(myCards[i])
            }
        }

        if (self.myTurn) {
            if (self.enableTest) {
                if (manager.testCards(selectedCards)) {
                    playButton.enabled = true
                    self.playButton.setBackgroundImage(imageOn, forState: UIControlState.Normal)
                    print ("cheer")
                }
                else {
                    self.playButton.setBackgroundImage(imageOn, forState: UIControlState.Normal)
                    playButton.enabled = false
                    print ("bad")
                }
            }
            else {
                if (selectedCards.count > 0 && (manager.isUniform(selectedCards) != -1)) {
                    if (manager.isUniform(selectedCards) == keysuit && manager.structureSize(selectedCards) != 1) {
                        playButton.enabled = false
                        self.playButton.setBackgroundImage(imageOn, forState: UIControlState.Normal)
                    }
                    else {
                        playButton.enabled = true
                        self.playButton.setBackgroundImage(imageOn, forState: UIControlState.Normal)
                    }
                }
                else {
                    playButton.enabled = false
                    self.playButton.setBackgroundImage(imageOn, forState: UIControlState.Normal)
                }
            }
        }
        else if (self.myTable) {
            if (!self.sorted) {
                playButton.enabled = true
                self.playButton.setBackgroundImage(imageRed, forState: UIControlState.Normal)
            }
            else {
                if(selectedCards.count == 8) {
                    playButton.enabled = true
                    self.playButton.setBackgroundImage(imageRed, forState: UIControlState.Normal)
                }
                else {
                    playButton.enabled = false
                    self.playButton.setBackgroundImage(imageRed, forState: UIControlState.Normal)
                }
            }
        }
        else if (self.myInquireSuit) {
            playButton.enabled = true
            self.playButton.setBackgroundImage(imageRed, forState: UIControlState.Normal)
        }
    }
    
    @IBAction func playCards(sender: AnyObject) {
        
        print("play button clicked")
        if(self.myTurn) {
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
                    self.serverBroadcastCards(true, fromplayer: 0, cards: selectedCards)
                    for var i = myCards.count-1; i >= 0; i-- {
                        if (self.layout.selected[i]) {
                            manager.remove(myCards[i])
                            myCards.removeAtIndex(i)
                            self.layout.selected.removeAtIndex(i)
                            
                        }
                    }
                    self.playList[self.playCount % 4] = selectedCards //************//
                    self.gameprocedure.remove(selectedCards, n: 0)
                }
                else {
                    var cardsBack: [Card_CPPWrapper];
                    if (selectedCards[0].suit == self.keysuit || selectedCards[0].suit == 4 || selectedCards[0].rank == self.keyrank) {
                        cardsBack = self.gameprocedure.testStarter(selectedCards, suit:self.keysuit, n:0);
                    }
                    else {
                        cardsBack = self.gameprocedure.testStarter(selectedCards, suit:selectedCards[0].suit, n:0);
                    }
                    self.serverBroadcastCards(false, fromplayer: 0, cards: cardsBack)
                    self.gameprocedure.remove(cardsBack, n: 0)
                    self.removeCardsBack(cardsBack)
                    self.playList[self.playCount % 4] = cardsBack
                }
                
                self.serverNext()
            }
            
            playButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            playButton.setBackgroundImage(imageOff, forState: UIControlState.Normal)
            playButton.enabled = false
            self.layout.rotateBack()
            self.layout.invalidateLayout()
            self.collectionView.reloadData()
            self.myTurn = false
        }
        else if(self.myTable) {
            if(!self.sorted) {
                self.myCards.sortInPlace(self.forwards)
                self.playButton.enabled = false
                self.collectionView.reloadData()
                self.layout.invalidateLayout()
                self.layout.selected = [Bool](count: 100, repeatedValue: false)
                self.sorted = true
            }
            else {
                removeTableCards()
                self.playButton.setBackgroundImage(imageOff, forState: UIControlState.Normal)
                self.playButton.enabled = false
                self.myTable = false
            }
        }
        else if(self.myInquireSuit) {
            self.skip()
            self.playButton.setBackgroundImage(imageOff, forState: UIControlState.Normal)
            self.playButton.enabled = false
        }
    }
    
    func removeSelectedCards() {
        for var i = myCards.count-1; i >= 0; i-- {
            if (self.layout.selected[i]) {
                manager.remove(myCards[i])
                myCards.removeAtIndex(i)
                self.layout.selected.removeAtIndex(i)
            }
        }
        self.collectionView.reloadData()
        self.layout.rotateBack()
        self.layout.invalidateLayout()
    }
    
    func removeTableCards() {
        
        if (playerID == 0) {
            var selectedCards = [Card_CPPWrapper]()
            self.lists[4].removeAllObjects()
            for i in 0...myCards.count-1 {
                if (self.layout.selected[i]) {
                    selectedCards.append(myCards[i])
                    lists[4].addObject(myCards[i])
                }
            }
            self.removeSelectedCards()
            self.gameprocedure.remove(selectedCards, n: 0)
        }
        else {
            var selectedCards = [Card_CPPWrapper]()
            for i in 0...myCards.count-1 {
                if (self.layout.selected[i]) {
                    selectedCards.append(myCards[i])
                }
            }
            let message = "_remove_table_cards_"
            let messageDictionary: [String: AnyObject] = ["message": message, "cards": selectedCards, "fromplayer": self.playerID]
            let messageData = NSKeyedArchiver.archivedDataWithRootObject(messageDictionary)
            do {
                try appDelegate.mpcManager.sessions[0].sendData(messageData, toPeers: appDelegate.mpcManager.sessions[0].connectedPeers, withMode: MCSessionSendDataMode.Reliable)
            }
            catch let error as NSError {
                print(error.localizedDescription)
                print("Can not send data: removeTableCards")
            }
            self.removeSelectedCards()
        }
        
    }
    
    func skip() {
        if (playerID == 0) {
            self.skippedNum++
            if(skippedNum < 3) {
                self.assignInquireSuit(1)
            }
            else {
                self.assignNext(false, player: self.currentPlayer)
            }
        }
        else {
            let message = "_skip_"
            let messageDictionary: [String: AnyObject] = ["message": message, "fromplayer": playerID]
            let messageData = NSKeyedArchiver.archivedDataWithRootObject(messageDictionary)
            do {
                try appDelegate.mpcManager.sessions[0].sendData(messageData, toPeers: appDelegate.mpcManager.sessions[0].connectedPeers, withMode: MCSessionSendDataMode.Reliable)
            }
            catch let error as NSError {
                print(error.localizedDescription)
                print("Can not send data: skip")
            }
        }
        self.myInquireSuit = false
        self.updateButton()
    }
    
    func assignInquireSuit(playerID: Int) {
        if (playerID == 0) {
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                self.inquireSuit()
            })
        }
        else {
            let message = "_inquire_suit_"
            let messageDictionary: [String: AnyObject] = ["message": message]
            let messageData = NSKeyedArchiver.archivedDataWithRootObject(messageDictionary)
            do {
                try appDelegate.mpcManager.sessions[playerID-1].sendData(messageData, toPeers: appDelegate.mpcManager.sessions[playerID-1].connectedPeers, withMode: MCSessionSendDataMode.Reliable)
            }
            catch let error as NSError {
                print(error.localizedDescription)
                print("Can not send data: skip")
            }
        }
    }
    
    func inquireSuit() {
        self.myInquireSuit = true
        self.updateSuitButton()
        self.updateButton()
    }
    
    func removeCardsBack(cardsBack:[Card_CPPWrapper]) {
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
    
    
    func serverUpdateScores() -> Bool {
        self.scores.text = String(self.gameprocedure.getScores())
        let message = "_update_scores_"
        let messageDictionary: [String: AnyObject] = ["message": message, "scores": self.gameprocedure.getScores()]
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
        return true
    }
    
    func serverBroadcastCards(flag: Bool, fromplayer: Int, cards: [Card_CPPWrapper]) -> Bool {
        self.updateTable(fromplayer, cards: cards)
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
        self.playCardCount += cards.count
        print(cards.count)
        print("server: broadcast cards")
        return true
    }
    
    func updateTable(label: Int, cards: [Card_CPPWrapper]) {
        
        if (self.playCount % 4 == 0) {
            bottomCards.removeAll()
            rightCards.removeAll()
            topCards.removeAll()
            leftCards.removeAll()
            bottom.reloadData()
            right.reloadData()
            top.reloadData()
            left.reloadData()
        }
        
        switch(label) {
        case 0:
            bottomCards.appendContentsOf(cards)
            bottom.reloadData()
        case 1:
            rightCards.appendContentsOf(cards)
            right.reloadData()
        case 2:
            topCards.appendContentsOf(cards)
            top.reloadData()
        case 3:
            leftCards.appendContentsOf(cards)
            left.reloadData()
        default: print ("Error in updateTable()")
        }
        
    }
    
    func serverChangeKeysuitBroadcast(buttonID: Int, state: Int, fromplayer: Int) -> Bool {
        let message = "_change_keysuit_"
        let messageDictionary: [String: AnyObject] = ["message": message, "buttonID": buttonID, "state": state, "fromplayer": fromplayer]
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
        self.changeKeysuit(buttonID, state:state, fromplayer: fromplayer)
        return true
    }
    
    
    func updateSuitButton() {
        
        if((keyCardsCount[0]==1 && !single && !joker) || (keyCardsCount[0]==2 && (!double || self.keysuit < 0) && (self.keySuitCaller != self.playerID || keysuit == 0))) {
            spadeButton.enabled = true
        }
        else {
            spadeButton.enabled = false
        }
        if((keyCardsCount[1]==1 && !single && !joker) || (keyCardsCount[1]==2 && (!double || keysuit < 1) && (keySuitCaller != self.playerID || keysuit == 1))) {
            heartButton.enabled = true
        }
        else {
            heartButton.enabled = false
        }
        if((keyCardsCount[2]==1 && !single && !joker) || (keyCardsCount[2]==2 && (!double || keysuit < 2) && (keySuitCaller != self.playerID || keysuit == 2))) {
            clubButton.enabled = true
        }
        else {
            clubButton.enabled = false
        }
        if((keyCardsCount[3]==1 && !single && !joker) || (keyCardsCount[3]==2 && (!double || keysuit < 3) && (keySuitCaller != self.playerID || keysuit == 3))) {
            diamondButton.enabled = true
        }
        else {
            diamondButton.enabled = false
        }
        if(keyCardsCount[4]==2 && !joker && keySuitCaller != self.playerID ) {
            jokerButton.enabled = true
        }
        else {
            jokerButton.enabled = false
        }
        if(keyCardsCount[5]==2 && keySuitCaller != self.playerID ) {
            highjokerButton.enabled = true
        }
        else {
            highjokerButton.enabled = false
        }
    }
    
    func changeKeysuit(buttonID: Int, state: Int, fromplayer: Int) {
        self.keySuitCaller = fromplayer
        if (buttonID < 4) {
            keysuit = buttonID
            GameInfo_CPPWrapper.updateKeySuit(keysuit)
        }
        else {
            keysuit = 4
            GameInfo_CPPWrapper.updateKeySuit(keysuit)
            joker = true
        }

        self.myCards.sortInPlace(self.forwards)
        self.collectionView.reloadData()
        self.layout.invalidateLayout()
        if (state == 1){ single = true }
        if (state == 2){ double = true}
        updateSuitButton()
    }
    
    func serverNext() {
        self.playCount++
        if (self.playCount % 4 != 0) {
            self.currentPlayer = (self.currentPlayer + 1) % 4
            if (!self.gameEnd) {
                self.assignNext(true, player: self.currentPlayer)
            }
        }
        else {
            let winner = self.gameprocedure.Winner((self.currentPlayer + 1) % 4, player0: self.playList[0] as! [Card_CPPWrapper], player1:self.playList[1] as! [Card_CPPWrapper], player2: self.playList[2] as! [Card_CPPWrapper], player3: self.playList[3] as! [Card_CPPWrapper])
            print("winner = ")
            print(winner)
            self.serverUpdateScores()
            self.currentPlayer = (self.currentPlayer + 1 + winner) % 4
            if (!self.gameEnd) {
                self.assignNext(false, player: self.currentPlayer)
            }
        }
    }
    
    func changeKeysuitRequest(buttonID: Int) -> Bool {
        var state: Int
        if (single || buttonID > 3) { state = 2 }
        else { state = 1 }
        if(self.appDelegate.mpcManager.server) {
            self.serverChangeKeysuitBroadcast(buttonID, state: state, fromplayer: 0)
            if(self.myInquireSuit) {
                self.skippedNum = 0;
                assignTableCards(0)
            }
            return true;
        }
        else {

            let message = "_change_keysuit_request_"
            let messageDictionary: [String: AnyObject] = ["message": message, "buttonID": buttonID, "state": state, "fromplayer": self.playerID, "inquireSuit": myInquireSuit]
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
        self.myInquireSuit = false
        return true;
    }
    
    func serverDeclareGameInfo() -> Bool {
        let message = "_declare_gameinfo_"
        let messageDictionary: [String: AnyObject] = ["message": message, "keyRank": GameInfo_CPPWrapper.getKeyRank()]
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
        return true
    }
    
    @IBAction func spadesButton(sender: AnyObject) {
        self.changeKeysuitRequest(0)
    }
    
    @IBAction func heartsButton(sender: AnyObject) {
        self.changeKeysuitRequest(1)
    }
    
    @IBAction func clubsButton(sender: AnyObject) {
        self.changeKeysuitRequest(2)
    }
    
    @IBAction func diamondsButton(sender: AnyObject) {
        self.changeKeysuitRequest(3)
    }
    
    @IBAction func jokersButton(sender: AnyObject) {
        self.changeKeysuitRequest(4)
    }
    
    @IBAction func highjokersButton(sender: AnyObject) {
        self.changeKeysuitRequest(5)
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
                
                collectionView.collectionViewLayout.layoutAttributesForItemAtIndexPath(indexPath)!.zIndex = indexPath.row // ******************************************** //
                
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
    
    @IBAction func endGame(sender: AnyObject) {
        self.myTurn = false
        self.myTable = false
        self.myInquireSuit = false
        NSNotificationCenter.defaultCenter().removeObserver(self)
        NSOperationQueue.mainQueue().cancelAllOperations()
        self.performSegueWithIdentifier("endGame", sender: self)
        //self.dismissViewControllerAnimated(true, completion: { self.performSegueWithIdentifier("endGame", sender: self)})
        
    }
}


