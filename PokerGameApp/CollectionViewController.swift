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
let reuseIdentifierx = "Cellx"
let imageOn = UIImage(named: "Button_On") as UIImage!
let imageOff = UIImage(named: "Button_Off") as UIImage!
let imageRed = UIImage(named: "Button_Red") as UIImage!
let _assign_card_ = "_assign_card_"
let _assign_next_ = "_assign_next_ "
let _broadcast_ = "_broadcast_"
let _play_cards_ = "_play_cards_"
let _play_cards_back_ = "_play_cards_back_"
let _player_ID_ = "_player_ID_"
let _stop_assigning_cards_ = "_stop_assigning_cards_"
let _change_keysuit_ = "_change_keysuit_"
let _change_keysuit_request_ = "_change_keysuit_request_"
let _update_scores_ = "_update_scores_"
let _declare_gameinfo_ = "_declare_gameinfo_"
let _assign_table_cards_ = "_assign_table_cards_"
let _remove_table_cards_ = "_remove_table_cards_"
let _inquire_suit_ = "_inquire_suit_"
let _skip_ = "_skip_"
let _final_result_ = "_final_result_"
let _new_game_ = "_new_game_"
let endNum = 25
let playCardsRatio = 0.15
let imageSet : [UIImage] = [UIImage(named:"4")!, UIImage(named:"8")!, UIImage(named:"11")!, UIImage(named:"6")! ]
let imageSetLord : [UIImage] = [UIImage(named:"4x")!, UIImage(named:"8x")!, UIImage(named:"11x")!, UIImage(named:"6x")! ]

enum Flag {
    case None
    case PlayCards
    case TableCards
    case InquireSuit
    case Lord
}

class CollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let manager = CardManager_CPPWrapper()

    var keysuit = GameInfo_CPPWrapper.getKeySuit()
    var keyrank = GameInfo_CPPWrapper.getKeyRank() {
        didSet {
            if(keyrank < 11 && keyrank > 1) {
                keyrankLabel.text = String(keyrank)
            }
            else if(keyrank == 11) {
                keyrankLabel.text = "J"
            }
            else if(keyrank == 12) {
                keyrankLabel.text = "Q"
            }
            else if(keyrank == 13) {
                keyrankLabel.text = "K"
            }
            else if(keyrank == 14) {
                keyrankLabel.text = "A"
            }
            else {
                keyrankLabel.text = ""
            }
        }
    }
    var lordID = GameInfo_CPPWrapper.getLordID() {
        didSet {
            if (lordID >= 0) {
                switch((lordID - playerID + 4) % 4) {
                case 0:
                    bottomImage.image = imageSetLord[playerID]
                    break
                case 1:
                    rightImage.image = imageSetLord[(playerID+1) % 4]
                    break
                case 2:
                    topImage.image = imageSetLord[(playerID+2) % 4]
                    break
                case 3:
                    leftImage.image = imageSetLord[(playerID+3) % 4]
                    break
                default:
                    break
                }
                if(appDelegate.mpcManager.server) {
                    self.serverDeclareGameInfo()
                }
            }
        }
    }
    
    let changeTableCards = GameInfo_CPPWrapper.getChangeTableCards()
   
    var myCards = [Card_CPPWrapper]()
    var playerID = 0
    var enableTest = false
    var single = false
    var double = false
    var joker = false
    var keyCardsCount = [NSInteger](count:6, repeatedValue:0)
    
    
    var sorted = false
    var starting = true
    var keySuitCaller = -1
    var flag = Flag.None
    var playCount = 0
    
    var leftCards = [Card_CPPWrapper]()
    var rightCards = [Card_CPPWrapper]()
    var topCards = [Card_CPPWrapper]()
    var bottomCards = [Card_CPPWrapper]()

    let layoutx: UICollectionViewFlowLayout = CardLayout()
    let layouty: UICollectionViewFlowLayout = CardLayout()
    let layoutz: UICollectionViewFlowLayout = CardLayout()
    let layoutw: UICollectionViewFlowLayout = CardLayout()
    
    let layout: CircularCollectionViewLayout = CircularCollectionViewLayout()
    
    // only used for server
    var gameprocedure: GameProcedure_CPPWrapper!
    var lists = [NSMutableArray!](count: 5, repeatedValue: nil)
    var playList = [NSArray!](count:4, repeatedValue: nil)
    var currentPlayer = 0
    var playCardCount = 0 {
        didSet {
            if (playCardCount == endNum * 4) {
                self.gameEnd = true
                self.nextGameButton.enabled = true
            }
        }
    }
    var gameEnd = false;
    var cancelled = false;
    var skippedNum = 0;
    
   
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
    
    @IBOutlet weak var leftImage: UIImageView!
    @IBOutlet weak var bottomImage: UIImageView!
    @IBOutlet weak var rightImage: UIImageView!
    @IBOutlet weak var topImage: UIImageView!
    
    @IBOutlet weak var scores: UILabel!
    @IBOutlet weak var nextGameButton: UIButton!
    
    @IBOutlet weak var keysuitImage: UIImageView!
    @IBOutlet weak var keyrankLabel: UILabel!
    
    override func viewDidLoad() {
        
        self.appDelegate.mpcManager.advertiser.stopAdvertisingPeer()
        self.appDelegate.mpcManager.browser.stopBrowsingForPeers()
        
        myCards.removeAll()
        leftCards.removeAll()
        rightCards.removeAll()
        topCards.removeAll()
        bottomCards.removeAll()
        top.reloadData()
        bottom.reloadData()
        right.reloadData()
        left.reloadData()
        collectionView.reloadData()
        
        enableTest = false
        single = false
        double = false
        joker = false
        keyCardsCount = [NSInteger](count:6, repeatedValue:0)
        
        sorted = false
        starting = true
        keySuitCaller = -1
        flag = Flag.None
        
        playCount = 0
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.setCollectionViewLayout(self.layout, animated: false)
        collectionView.registerNib(UINib(nibName: "CircularCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.allowsSelection = false
        collectionView.allowsMultipleSelection = true
        view.sendSubviewToBack(collectionView)
        playButton.enabled = false
        playButton.setBackgroundImage(imageOff, forState: UIControlState.Normal)
        spadeButton.enabled = false
        heartButton.enabled = false
        clubButton.enabled = false
        diamondButton.enabled = false
        jokerButton.enabled = false
        highjokerButton.enabled = false
        
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
        keyrankLabel.text = ""
        keysuitImage.image = nil
        nextGameButton.enabled = false
        
        left.registerNib(UINib(nibName: "CardCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifierx)
        right.registerNib(UINib(nibName: "CardCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifierx)
        top.registerNib(UINib(nibName: "CardCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifierx)
        bottom.registerNib(UINib(nibName: "CardCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifierx)
        
        left.delegate = self
        left.dataSource = self
        right.delegate = self
        right.dataSource = self
        top.delegate = self
        top.dataSource = self
        bottom.delegate = self
        bottom.dataSource = self
        
        left.setCollectionViewLayout(layoutx, animated: false)
        right.setCollectionViewLayout(layouty, animated: false)
        top.setCollectionViewLayout(layoutz, animated: false)
        bottom.setCollectionViewLayout(layoutw, animated: false)

        /************************************* Server Device  *********************************/
        if (self.appDelegate.mpcManager.server) {
            
            lists = [NSMutableArray!](count: 5, repeatedValue: nil)
            playList = [NSArray!](count:4, repeatedValue: nil)
            currentPlayer = 0
            playCardCount = 0
            gameEnd = false;
            cancelled = false;
            skippedNum = 0;
            
            for index in 0...4 {
                lists[index] = NSMutableArray()
            }
            
            gameprocedure = GameProcedure_CPPWrapper()
            gameprocedure.GameProcedure_CPPWrapper()
            gameprocedure.ShuffleCards(lists[0], pca2: lists[1], pca3: lists[2], pca4: lists[3], tb: lists[4])
            
            
            let delaytime = dispatch_time(DISPATCH_TIME_NOW, 3 * Int64(NSEC_PER_SEC))
            dispatch_after(delaytime, dispatch_get_main_queue(), {
                self.bottomImage.image = imageSet[self.playerID]
                self.rightImage.image = imageSet[(self.playerID+1)%4]
                self.topImage.image = imageSet[(self.playerID+2)%4]
                self.leftImage.image = imageSet[(self.playerID+3)%4]
                self.keyrank = GameInfo_CPPWrapper.getKeyRank()
                self.keysuit = GameInfo_CPPWrapper.getKeySuit()
                self.lordID = GameInfo_CPPWrapper.getLordID()
                self.assignPlayerID(1)
                self.assignPlayerID(2)
                self.assignPlayerID(3)
                self.serverDeclareGameInfo()
                self.assignCard_to_all(0)
            })
        }
        /**************************************************************************************/
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: #selector(CollectionViewController.handleMPCReceivedDataWithNotification(_:)),
            name: "receivedMPCDataNotification", object: nil)
    }
    
    
    func forwards(c1: Card_CPPWrapper!, c2: Card_CPPWrapper!) -> Bool {
        return c1.compare(c1, to: c2, suit: keysuit, rank: keyrank)
    }
    
    func assignCard_to_all(index: Int) {
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
        dispatch_after(time, dispatch_get_main_queue(), {
            if (!self.cancelled) {
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
                    
                    NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                        self.spadeButton.enabled = false;
                        self.heartButton.enabled = false;
                        self.clubButton.enabled = false;
                        self.diamondButton.enabled = false;
                        self.jokerButton.enabled = false;
                        self.highjokerButton.enabled = false;
                        
                        self.collectionView.allowsSelection = true
                    })
                    
                    self.stopAssigningCards(1)
                    self.stopAssigningCards(2)
                    self.stopAssigningCards(3)
                    
                    self.nextGameButton.enabled = true ///************** remove this line **************//
                    if (self.lordID != -1) {
                        self.assignInquireSuit(self.lordID)
                    }
                    else {
                        self.lordID = 0
                        self.assignInquireSuit(self.lordID)
                        GameInfo_CPPWrapper.updateLordID(0)
                    }
                }
            }
        })
    }
    
    func assignCard(index: Int, playerID: Int, listID: Int){
        
        if (playerID==0) {
            
            let card = self.lists[listID][index] as! Card_CPPWrapper
            self.appendNewCard(card)
        }
        else {
            let message = "_assign_card_"
            let card = self.lists[listID][index] as! Card_CPPWrapper
            let messageDictionary: [String: AnyObject] = ["message": message, "card": card]
        
            let messageData = NSKeyedArchiver.archivedDataWithRootObject(messageDictionary)
            self.sendMessagetoOne(messageData, toPlayer: playerID)
        }
    }
    
    func assignTableCards(playerID: Int) {
        if (playerID == 0) {
            self.appendTableCards(lists[4])
        }
        else {
            let message = "_assign_table_cards_"
            let messageDictionary: [String: AnyObject] = ["message": message, "cards": lists[4]]
            let messageData = NSKeyedArchiver.archivedDataWithRootObject(messageDictionary)
            sendMessagetoOne(messageData, toPlayer: playerID)
        }
        self.gameprocedure.appendTableCards(lists[4], playerID: playerID)
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
            self.collectionView.allowsSelection = true
        }
        self.collectionView.reloadData()
        self.layout.invalidateLayout()
        if (card.rank == keyrank) {
            keyCardsCount[card.suit] += 1
        }
        if (card.suit == 4) {
            keyCardsCount[card.rank + 4] += 1
        }
        self.updateSuitButton()
    }
    
    func appendTableCards(cards: NSMutableArray!) {
        self.flag = Flag.TableCards
        self.sorted = false
        let delaytime = dispatch_time(DISPATCH_TIME_NOW, 1 * Int64(NSEC_PER_SEC))
        dispatch_after(delaytime, dispatch_get_main_queue(), {
            for i in 0...7 {
                self.myCards.append(cards[i] as! Card_CPPWrapper);
            }
            self.collectionView.reloadData()
            self.layout.rotateBack()
            self.layout.invalidateLayout()
            self.manager.CardManager_CPPWrapper(self.myCards)
            self.playButton.setBackgroundImage(imageRed, forState: UIControlState.Normal)
            self.playButton.enabled = true
       })
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
            if message as! String == _assign_card_{
                    NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    let card = dataDictionary["card"] as! Card_CPPWrapper
                    self.appendNewCard(card)
                })
            }
            // Check if there's an entry with the "_assign_next_" key.
            if message as! String == _assign_next_ {
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    self.playButton.setTitleColor(UIColor.redColor(), forState: UIControlState.Normal)
                    self.playButton.setBackgroundImage(imageOn, forState: UIControlState.Normal)
                    self.playButton.enabled = false
                    self.flag = Flag.PlayCards
                    self.enableTest = dataDictionary["flag"] as! Bool
                    self.updateButton()
                })
            }
            // Check if there's an entry with the "_broadcast_" key.
            if message as! String == _broadcast_ {
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    let flag = dataDictionary["flag"] as! Bool
                    let fromplayer = dataDictionary["fromplayer"] as! Int
                    let cards = dataDictionary["cards"] as! [Card_CPPWrapper]
                    if (!flag) {
                        let format = dataDictionary["cards"] as! [Card_CPPWrapper]
                        self.manager.setFormat(format)
                    }
                    self.updateTable((fromplayer - self.playerID + 4) % 4,cards: cards)
                    self.playCount += 1
                    print("receive broadcast")
                 })
                
            }
            // Check if there's an entry with the "_play_cards_" key.
            if message as! String == _play_cards_ {

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
            if message as! String == _play_cards_back_ {
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                let cardsBack = dataDictionary["cardsback"] as! [Card_CPPWrapper]
                self.removeCardsBack(cardsBack)
                })
            }
            // Check if there's an entry with the "_player_ID" key.
            if message as! String == _player_ID_ {
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    self.playerID = dataDictionary["playerID"] as! Int
                    self.bottomImage.image = imageSet[self.playerID]
                    self.rightImage.image = imageSet[(self.playerID+1)%4]
                    self.topImage.image = imageSet[(self.playerID+2)%4]
                    self.leftImage.image = imageSet[(self.playerID+3)%4]
                    self.spadeButton.enabled = false;
                    self.heartButton.enabled = false;
                    self.clubButton.enabled = false;
                    self.diamondButton.enabled = false;
                    self.jokerButton.enabled = false;
                    self.highjokerButton.enabled = false;
                })
            }
            // Check if there's an entry with the "_stop_assigning_cards_" key.
            if message as! String == _stop_assigning_cards_ {
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    self.spadeButton.enabled = false;
                    self.heartButton.enabled = false;
                    self.clubButton.enabled = false;
                    self.diamondButton.enabled = false;
                    self.jokerButton.enabled = false;
                    self.highjokerButton.enabled = false;
                })
            }
            
            // Check if there's an entry with the "_change_keysuit_" key.
            if message as! String == _change_keysuit_ {
                let buttonID = dataDictionary["buttonID"] as! Int
                let state = dataDictionary["state"] as! Int
                let fromplayer = dataDictionary["fromplayer"] as! Int
                let inquireSuit = dataDictionary["inquireSuit"] as! Bool
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    self.changeKeysuit(buttonID, state: state, fromplayer: fromplayer, update: !inquireSuit)
                })
            }
            // Check if there's an entry with the "_change_keysuit_request_" key.
            if message as! String == _change_keysuit_request_ {
                let buttonID = dataDictionary["buttonID"] as! Int
                let state = dataDictionary["state"] as! Int
                let fromplayer = dataDictionary["fromplayer"] as! Int
                let inquireSuit = dataDictionary["inquireSuit"] as! Bool
                if ((state == 1 && !single) || state == 2) {
                    NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                        self.serverChangeKeysuitBroadcast(buttonID, state: state, fromplayer: fromplayer, inquireSuit: inquireSuit)
                        print("fromplayer : ")
                        print(fromplayer)
                        print(buttonID)
                        print(state)
                    })
                }
                if (inquireSuit && self.changeTableCards) {
                    skippedNum = 0
                    assignTableCards(fromplayer)
                    starting = false
                }
                if (inquireSuit && !self.changeTableCards) {
                    skippedNum = 0
                    assignInquireSuit((fromplayer + 1) % 4)
                }
            }
            // Check if there's an entry with the "_update_scores_" key.
            if message as! String == _update_scores_ {
                let scores = dataDictionary["scores"] as! Int
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    self.scores.text = String(scores)
                })
            }
            // Check if there's an entry with the "_declare_gameinfo_" key.
            if message as! String == _declare_gameinfo_ {
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    let keyRank = dataDictionary["keyRank"] as! Int
                    let lordID = dataDictionary["lordID"] as! Int
                    self.keyrank = keyRank
                    self.lordID = lordID
                    GameInfo_CPPWrapper.updateKeyRank(keyRank)
                })
            }
            // Check if there's an entry with the "_assign_table_cards_" key.
            if message as! String == _assign_table_cards_ {
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    let cards = dataDictionary["cards"] as! NSMutableArray
                    self.appendTableCards(cards)
                })
            }
            // Check if there's an entry with the "_remove_table_cards_" key.
            if message as! String == _remove_table_cards_ {
                let cards = dataDictionary["cards"] as! [Card_CPPWrapper]
                let fromplayer = dataDictionary["fromplayer"] as! Int
                self.lists[4].removeAllObjects()
                for card in cards {
                    self.lists[4].addObject(card)
                }
                self.gameprocedure.removeTableCards(cards, playerID: fromplayer)
                if (self.changeTableCards) {
                    self.assignInquireSuit((fromplayer+1)%4)
                }
                else {
                    self.gameprocedure.constructManager()
                    self.assignNext(false, player: self.currentPlayer)
                }
            }
            // Check if there's an entry with the "_inquire_suit_" key.
            if message as! String == _inquire_suit_ {
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    self.inquireSuit()
                })
            }
            // Check if there's an entry with the "_skip_" key.
            if message as! String == _skip_ {
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    if (self.changeTableCards) {
                        if (!self.starting) {
                            let fromplayer = dataDictionary["fromplayer"] as! Int
                            self.skippedNum += 1
                            if (self.skippedNum < 3) {
                                self.assignInquireSuit((fromplayer+1)%4)
                            }
                            else {
                                self.gameprocedure.constructManager()
                                self.assignNext(false, player: self.currentPlayer)
                            }
                        }
                        else {
                            self.starting = false
                            self.assignTableCards(self.lordID)
                        }
                    }
                    else {
                        let fromplayer = dataDictionary["fromplayer"] as! Int
                        self.skippedNum += 1
                        if (self.skippedNum < 4) {
                            self.assignInquireSuit( (fromplayer+1) % 4)
                        }
                        else {
                            self.assignTableCards(self.lordID)
                        }

                    }
                })
            }
            // Check if there's an entry with the "_final_result_" key.
            if message as! String == _final_result_ {
                let scores = dataDictionary["scores"] as! Int
                let tableCards = dataDictionary["tableCards"] as! NSMutableArray
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    self.scores.text = String(scores)
                    for i in 0...7 {
                        self.myCards.append(tableCards[i] as! Card_CPPWrapper);
                    }
                    self.collectionView.reloadData()
                    self.layout.rotateBack()
                    self.layout.invalidateLayout()

                })
            }
            // Check if there's an entry with the "_new_game_" key.
            if message as! String == _new_game_ {
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    NSNotificationCenter.defaultCenter().removeObserver(self)
                    self.viewDidLoad()
                })
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

        if (self.flag == Flag.PlayCards) {
            if (self.enableTest) {
                if (manager.testCards(selectedCards)) {
                    playButton.enabled = true
                    self.playButton.setBackgroundImage(imageOn, forState: UIControlState.Normal)
                    print ("cheer")
                }
                else {
                    playButton.enabled = false
                    self.playButton.setBackgroundImage(imageOn, forState: UIControlState.Normal)
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
        else if (self.flag == Flag.TableCards) {
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
        else if (self.flag == Flag.InquireSuit) {
            playButton.enabled = true
            self.playButton.setBackgroundImage(imageRed, forState: UIControlState.Normal)
        }
    }
    
    @IBAction func playCards(sender: AnyObject) {
        print(self.flag)
        if(self.flag == Flag.PlayCards) {
            var selectedCards = [Card_CPPWrapper]()
            for i in 0...myCards.count-1 {
                if (self.layout.selected[i]) {
                    selectedCards.append(myCards[i])
                }
            }
            if(!self.appDelegate.mpcManager.server) {
                let message = _play_cards_
                let messageDictionary: [String: AnyObject] = ["message": message, "flag": enableTest, "fromplayer": self.playerID, "cards": selectedCards]
                let messageData = NSKeyedArchiver.archivedDataWithRootObject(messageDictionary)
                self.sendMessagetoServer(messageData)
                if (enableTest) {
                    for var i = myCards.count-1; i >= 0; i -= 1 {
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
                    for var i = myCards.count-1; i >= 0; i -= 1 {
                        if (self.layout.selected[i]) {
                            manager.remove(myCards[i])
                            myCards.removeAtIndex(i)
                            self.layout.selected.removeAtIndex(i)
                            
                        }
                    }
                    self.playList[self.playCount % 4] = selectedCards
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
            self.collectionView.reloadData()
            self.layout.rotateBack()
            self.layout.invalidateLayout()
            self.flag = Flag.None
        }
        else if(self.flag == Flag.TableCards) {
            if(!self.sorted) {
                self.myCards.sortInPlace(self.forwards)
                self.playButton.enabled = false
                self.collectionView.reloadData()
                self.layout.rotateBack()
                self.layout.invalidateLayout()
                self.layout.selected = [Bool](count: 100, repeatedValue: false)
                self.sorted = true
            }
            else {
                removeTableCards()
                self.playButton.setBackgroundImage(imageOff, forState: UIControlState.Normal)
                self.playButton.enabled = false
                self.flag = Flag.None
            }
        }
        else if(self.flag == Flag.InquireSuit) {
            self.skip()
            self.playButton.setBackgroundImage(imageOff, forState: UIControlState.Normal)
            self.playButton.enabled = false
        }
    }
    
    func removeSelectedCards() {
        for var i = myCards.count-1; i >= 0; i -= 1 {
            if (self.layout.selected[i]) {
                manager.remove(myCards[i])
                myCards.removeAtIndex(i)
                self.layout.selected.removeAtIndex(i)
            }
        }
        self.collectionView.reloadData()
        self.layout.rotateBack()
        self.layout.invalidateLayout()
        self.manager.CardManager_CPPWrapper(self.myCards)
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
            self.gameprocedure.removeTableCards(selectedCards, playerID: 0)
            
            if (self.changeTableCards) {
                self.assignInquireSuit(1)
            }
            else {
                self.gameprocedure.constructManager()
                self.assignNext(false, player: self.currentPlayer)
            }
            
        }
        else {
            var selectedCards = [Card_CPPWrapper]()
            for i in 0...myCards.count-1 {
                if (self.layout.selected[i]) {
                    selectedCards.append(myCards[i])
                }
            }
            let message = _remove_table_cards_
            let messageDictionary: [String: AnyObject] = ["message": message, "cards": selectedCards, "fromplayer": self.playerID]
            let messageData = NSKeyedArchiver.archivedDataWithRootObject(messageDictionary)
            self.sendMessagetoServer(messageData)
            self.removeSelectedCards()
        }
        
    }
    
    func skip() {
        self.flag = Flag.None
        self.updateButton()
        self.spadeButton.enabled = false
        self.heartButton.enabled = false
        self.clubButton.enabled = false
        self.diamondButton.enabled = false
        self.jokerButton.enabled = false
        self.highjokerButton.enabled = false
        if (playerID == 0) {
            if (self.changeTableCards) {
                if (!self.starting) {
                    self.skippedNum += 1
                    print(self.skippedNum)
                    if (self.skippedNum < 3) {
                        self.assignInquireSuit(1)
                    }
                    else {
                        self.gameprocedure.constructManager()
                        self.assignNext(false, player: self.currentPlayer)
                    }
                }
                else {
                    self.starting = false
                    self.assignTableCards(self.lordID)
                }
            }
            else {
                self.skippedNum += 1
                if (self.skippedNum < 4) {
                    self.assignInquireSuit(1)
                }
                else {
                    self.assignTableCards(self.lordID)
                }
            }
        }
        else {
            let message = _skip_
            let messageDictionary: [String: AnyObject] = ["message": message, "fromplayer": playerID]
            let messageData = NSKeyedArchiver.archivedDataWithRootObject(messageDictionary)
            self.sendMessagetoServer(messageData)
        }
    }
    
    func assignInquireSuit(playerID: Int) {
        if (playerID == 0) {
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                self.inquireSuit()
            })
        }
        else {
            let message = _inquire_suit_
            let messageDictionary: [String: AnyObject] = ["message": message]
            let messageData = NSKeyedArchiver.archivedDataWithRootObject(messageDictionary)
            self.sendMessagetoOne(messageData, toPlayer: playerID)
        }
    }
    
    func inquireSuit() {
        self.flag = Flag.InquireSuit
        self.updateSuitButton()
        self.updateButton()
    }
    
    func removeCardsBack(cardsBack:[Card_CPPWrapper]) {
        print(cardsBack.count)
        for j in 0 ..< cardsBack.count {
            print("suit")
            print(cardsBack[j].suit)
            print("rank")
            print(cardsBack[j].rank)
            for i in 0 ..< myCards.count {
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
        self.collectionView.reloadData()
        self.layout.rotateBack()
        self.layout.invalidateLayout()

    }
    
    func assignNext(flag: Bool, player: Int) {
        if (player != 0 ) {
            let message = _assign_next_
            let messageDictionary: [String: AnyObject] = ["message": message, "flag": flag]
            let messageData = NSKeyedArchiver.archivedDataWithRootObject(messageDictionary)
            sendMessagetoOne(messageData, toPlayer: player)
        }
        else {
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                self.flag = Flag.PlayCards
                self.enableTest = flag
                self.updateButton()
            })
        }
    }
    
    func assignPlayerID(player: Int){
        let message = _player_ID_
        let messageDictionary: [String: AnyObject] = ["message": message, "playerID": player]
        let messageData = NSKeyedArchiver.archivedDataWithRootObject(messageDictionary)
        sendMessagetoOne(messageData, toPlayer: player)
    }
    
    func stopAssigningCards(player: Int) {
        let message = _stop_assigning_cards_
        let messageDictionary: [String: AnyObject] = ["message": message]
        let messageData = NSKeyedArchiver.archivedDataWithRootObject(messageDictionary)
        sendMessagetoOne(messageData, toPlayer: player)
    }
    
    
    func serverUpdateScores(scores: Int) {
        print("run server updatescores")
        self.scores.text = String(scores)
        let message = _update_scores_
        let messageDictionary: [String: AnyObject] = ["message": message, "scores": scores]
        let messageData = NSKeyedArchiver.archivedDataWithRootObject(messageDictionary)
        sendMessagetoAll(messageData)
    }
    
    func serverBroadcastCards(flag: Bool, fromplayer: Int, cards: [Card_CPPWrapper]) {
        self.updateTable(fromplayer, cards: cards)
        let message = _broadcast_
        let messageDictionary: [String: AnyObject] = ["message": message, "flag": flag, "fromplayer": fromplayer, "cards": cards]
        let messageData = NSKeyedArchiver.archivedDataWithRootObject(messageDictionary)
        self.sendMessagetoAll(messageData)
        if(!flag) {
            self.manager.setFormat(cards)
        }
        self.playCardCount += cards.count
    }
    
    func updateTable(label: Int, cards: [Card_CPPWrapper]) {
        
        if (self.playCount % 4 == 0) {
            self.bottomCards.removeAll()
            self.rightCards.removeAll()
            self.topCards.removeAll()
            self.leftCards.removeAll()            
            
            self.bottom.reloadData()
            self.right.reloadData()
            self.top.reloadData()
            self.left.reloadData()
        }
        
        switch(label) {
        case 0:
            bottomCards.appendContentsOf(cards)
            bottom.reloadData()
            break
        case 1:
            rightCards.appendContentsOf(cards)
            right.reloadData()
            break
        case 2:
            topCards.appendContentsOf(cards)
            top.reloadData()
            break
        case 3:
            leftCards.appendContentsOf(cards)
            left.reloadData()
            break
        default:
            break
        }
        
    }
    
    func serverChangeKeysuitBroadcast(buttonID: Int, state: Int, fromplayer: Int, inquireSuit: Bool) {

        let message = _change_keysuit_
        let messageDictionary: [String: AnyObject] = ["message": message, "buttonID": buttonID, "state": state, "fromplayer": fromplayer, "inquireSuit": inquireSuit]
        let messageData = NSKeyedArchiver.archivedDataWithRootObject(messageDictionary)
        
        self.changeKeysuit(buttonID, state:state, fromplayer: fromplayer, update: !inquireSuit)
        
        self.sendMessagetoAll(messageData)
    }
    
    
    func updateSuitButton() {
        
        if((keyCardsCount[0]==1 && !single && !joker) || (keyCardsCount[0]==2 && (!double || self.keysuit < 0) && (self.keySuitCaller != self.playerID || keysuit == 0))) {
            diamondButton.enabled = true
        }
        else {
            diamondButton.enabled = false
        }
        if((keyCardsCount[1]==1 && !single && !joker) || (keyCardsCount[1]==2 && (!double || keysuit < 1) && (keySuitCaller != self.playerID || keysuit == 1))) {
            clubButton.enabled = true
        }
        else {
            clubButton.enabled = false
        }
        if((keyCardsCount[2]==1 && !single && !joker) || (keyCardsCount[2]==2 && (!double || keysuit < 2) && (keySuitCaller != self.playerID || keysuit == 2))) {
            heartButton.enabled = true
        }
        else {
            heartButton.enabled = false
        }
        if((keyCardsCount[3]==1 && !single && !joker) || (keyCardsCount[3]==2 && (!double || keysuit < 3) && (keySuitCaller != self.playerID || keysuit == 3))) {
            spadeButton.enabled = true
        }
        else {
            spadeButton.enabled = false
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
    
    func changeKeysuit(buttonID: Int, state: Int, fromplayer: Int, update: Bool) {
        if (self.lordID == -1) {
            self.lordID = fromplayer
            if(self.appDelegate.mpcManager.server) {
                GameInfo_CPPWrapper.updateLordID(fromplayer)
            }
        }
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

        self.bottomCards.removeAll()
        self.topCards.removeAll()
        self.leftCards.removeAll()
        self.rightCards.removeAll()
        
        let spadeCards = Card_CPPWrapper()
        spadeCards.Card_CPPWrapper(3, rank: self.keyrank)
        let heartCards = Card_CPPWrapper()
        heartCards.Card_CPPWrapper(2, rank: self.keyrank)
        let clubCards = Card_CPPWrapper()
        clubCards.Card_CPPWrapper(1, rank: self.keyrank)
        let diamondCards = Card_CPPWrapper()
        diamondCards.Card_CPPWrapper(0, rank: self.keyrank)
        let jokerCards = Card_CPPWrapper()
        jokerCards.Card_CPPWrapper(4, rank: 0)
        let highjokerCards = Card_CPPWrapper()
        highjokerCards.Card_CPPWrapper(4, rank: 1)
        
        var showCards = [Card_CPPWrapper]()
        
        
        for _ in 1...state {
            switch(buttonID) {
            case 3 :
                showCards.append(spadeCards)
                self.keysuitImage.image = UIImage(named: "spadesButton2")
                break
            case 2 :
                showCards.append(heartCards)
                self.keysuitImage.image = UIImage(named: "heartsButton")
                break
            case 1 :
                showCards.append(clubCards)
                self.keysuitImage.image = UIImage(named: "clubsButton2")
                break
            case 0 :
                showCards.append(diamondCards)
                self.keysuitImage.image = UIImage(named: "diamondsButton")
                break
            case 4 :
                showCards.append(jokerCards)
                self.keysuitImage.image = UIImage(named: "jokerButton")
                break
            case 5 :
                showCards.append(highjokerCards)
                self.keysuitImage.image = UIImage(named: "jokerButton")
            default:
                break
            }
        }
        
        switch((fromplayer - self.playerID + 4) % 4) {
        case 0:
            bottomCards = showCards
            break
        case 1:
            rightCards = showCards
            break
        case 2:
            topCards = showCards
            break
        case 3:
            leftCards = showCards
            break
        default:
            break
        }
        
        bottom.reloadData()
        right.reloadData()
        top.reloadData()
        left.reloadData()

        self.myCards.sortInPlace(self.forwards)
        self.collectionView.reloadData()
        self.layout.invalidateLayout()
        if (state == 1){ single = true }
        if (state == 2){ double = true}
        self.manager.CardManager_CPPWrapper(self.myCards)
        if (update) {
            updateSuitButton()
        }
        else {
            if(self.keySuitCaller == self.playerID) {
                updateSuitButton()
            }
        }
    }
    
    func serverNext() {
        print("run server Next")
        self.playCount += 1
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
            
            self.serverUpdateScores(self.gameprocedure.getScores())
            self.currentPlayer = (self.currentPlayer + 1 + winner) % 4
            if (!self.gameEnd) {
                self.assignNext(false, player: self.currentPlayer)
            }
            else {
                print("Game End")
                let multiplier = manager.getMultiplier(self.playList[0] as! [Card_CPPWrapper])
                print("Mutliplier = ")
                print(multiplier)
                self.serverBroadcastFinalResult(self.currentPlayer, multiplier: multiplier)
            }
        }
    }
    
    func changeKeysuitRequest(buttonID: Int) {
        var state: Int
        if (single || buttonID > 3) { state = 2 }
        else { state = 1 }
        if(self.appDelegate.mpcManager.server) {
            self.serverChangeKeysuitBroadcast(buttonID, state: state, fromplayer: 0, inquireSuit: self.flag == Flag.InquireSuit)
            if(self.flag == Flag.InquireSuit && self.changeTableCards) {
                self.starting = false;
                self.skippedNum = 0;
                assignTableCards(0)
            }
            if (self.flag == Flag.InquireSuit && !self.changeTableCards) {
                skippedNum = 0
                assignInquireSuit(1)
            }
        }
        else {

            let message = _change_keysuit_request_
            let messageDictionary: [String: AnyObject] = ["message": message, "buttonID": buttonID, "state": state, "fromplayer": self.playerID, "inquireSuit": (self.flag == Flag.InquireSuit)]
            let messageData = NSKeyedArchiver.archivedDataWithRootObject(messageDictionary)
            sendMessagetoServer(messageData)
        }
        
        self.playButton.enabled = false
        self.playButton.setBackgroundImage(imageOff, forState: UIControlState.Normal)
    }
    
    func serverDeclareGameInfo() {
        let message = _declare_gameinfo_
        let messageDictionary: [String: AnyObject] = ["message": message, "keyRank": GameInfo_CPPWrapper.getKeyRank(), "lordID": self.lordID]
        let messageData = NSKeyedArchiver.archivedDataWithRootObject(messageDictionary)
        self.sendMessagetoAll(messageData)
        self.currentPlayer = self.lordID //************** Test **************//
    }
    
    func serverBroadcastFinalResult(winner: Int, multiplier: Int) {
        var finalScores = self.gameprocedure.getScores()
        if (winner % 2 != self.lordID % 2) {
            for index in 0...7 {
                finalScores = finalScores + lists[4][index].value() * multiplier * 2
            }
        }
        for i in 0...7 {
            self.myCards.append(lists[4][i] as! Card_CPPWrapper);
        }
        self.collectionView.reloadData()
        self.layout.rotateBack()
        self.layout.invalidateLayout()

        self.scores.text = String(finalScores)
        GameInfo_CPPWrapper.nextLordandRank(finalScores)
        let message = _final_result_
        let messageDictionary: [String: AnyObject] = ["message": message, "scores": finalScores, "tableCards": self.lists[4]]
        let messageData = NSKeyedArchiver.archivedDataWithRootObject(messageDictionary)
        self.sendMessagetoAll(messageData)
    }
    
    
    func serverNewGameNotification() {
        let message = _new_game_
        let messageDictionary: [String: AnyObject] = ["message": message]
        let messageData = NSKeyedArchiver.archivedDataWithRootObject(messageDictionary)
        self.sendMessagetoAll(messageData)
    }
    
    
    func sendMessagetoAll(messageData: NSData) -> Bool {
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
    
    func sendMessagetoOne(messageData: NSData, toPlayer: Int) -> Bool {
        do {
            try appDelegate.mpcManager.sessions[toPlayer - 1].sendData(messageData, toPeers: appDelegate.mpcManager.sessions[toPlayer - 1].connectedPeers, withMode: MCSessionSendDataMode.Reliable)
        }
        catch let error as NSError {
            print(error.localizedDescription)
            print("Can not send data")
            return false
        }
        return true
    }
    
    func sendMessagetoServer(messageData: NSData) -> Bool {
        do {
            try appDelegate.mpcManager.sessions[0].sendData(messageData, toPeers: appDelegate.mpcManager.sessions[0].connectedPeers, withMode: MCSessionSendDataMode.Reliable)
        }
        catch let error as NSError {
            print(error.localizedDescription)
            print("Can not send data")
            return false
        }
        return true
    }
    
    @IBAction func nextGame(sender: AnyObject) {
        self.serverNewGameNotification()
        NSNotificationCenter.defaultCenter().removeObserver(self)
        self.viewDidLoad()
    }
    
    @IBAction func spadesButton(sender: AnyObject) {
        self.changeKeysuitRequest(3)
    }
    
    @IBAction func heartsButton(sender: AnyObject) {
        self.changeKeysuitRequest(2)
    }
    
    @IBAction func clubsButton(sender: AnyObject) {
        self.changeKeysuitRequest(1)
    }
    
    @IBAction func diamondsButton(sender: AnyObject) {
        self.changeKeysuitRequest(0)
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
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifierx, forIndexPath: indexPath) as! CardCell
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
    
    @IBAction func endGame(sender: AnyObject) {
        self.cancelled = true
        NSNotificationCenter.defaultCenter().removeObserver(self)
        NSOperationQueue.mainQueue().cancelAllOperations()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}


