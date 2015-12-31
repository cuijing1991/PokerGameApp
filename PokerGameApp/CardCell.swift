//
//  CardCell.swift
//  PokerGameApp
//
//  Created by Cui Jing on 12/5/15.
//  Copyright © 2015 Jingplusplus. All rights reserved.
//

import UIKit

class CardCell: UICollectionViewCell {
    

   
    @IBOutlet weak var cellImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        cellImage!.contentMode = .ScaleAspectFill
    }
    
    var imageName: String = "" {
        didSet {
            self.cellImage.image = UIImage(named: imageName)
        }
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //contentView.layer.borderColor = UIColor.blackColor().CGColor
        //contentView.layer.borderWidth = 1
        contentView.layer.shouldRasterize = true
        contentView.layer.rasterizationScale = UIScreen.mainScreen().scale
        contentView.clipsToBounds = true
    }


}
