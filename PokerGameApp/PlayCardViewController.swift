//
//  PlayCardViewController.swift
//  PokerGameApp
//
//  Created by Cui Jing on 12/5/15.
//  Copyright © 2015 Jingplusplus. All rights reserved.
//

import UIKit

class PlayCardViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    
    var images: [String] = ["Images/PNG-cards-All/jack_of_spades.png", "Images/PNG-cards-All/2_of_diamonds.png", "Images/PNG-cards-All/queen_of_spades.png", "Images/PNG-cards-All/10_of_hearts.png", "Images/PNG-cards-All/9_of_clubs.png", "Images/PNG-cards-All/jack_of_hearts.png", "Images/PNG-cards-All/3_of_spades.png"]
    
    @IBOutlet weak var cardsCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = -15
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: UIScreen.mainScreen().bounds.width * 233 / 5000, height: UIScreen.mainScreen().bounds.width * 338 / 5000)
        
        cardsCollectionView.setCollectionViewLayout(layout, animated: false)
        cardsCollectionView.delegate = self
        cardsCollectionView.dataSource = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    func collectionView(collectionView: UICollectionView,
        numberOfItemsInSection section: Int) -> Int {
            return images.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: CardCell = collectionView.dequeueReusableCellWithReuseIdentifier("cardCell", forIndexPath: indexPath) as! CardCell
        cell.cellImage.image = UIImage(named: images[indexPath.row])
        return cell
    }
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    }
}
