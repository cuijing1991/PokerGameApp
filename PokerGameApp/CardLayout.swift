//
//  CardLayout.swift
//  PokerGameApp
//
//  Created by Cui Jing on 1/10/16.
//  Copyright © 2016 Jingplusplus. All rights reserved.
//

import UIKit

class CardLayout: UICollectionViewFlowLayout {
    
    override func prepareLayout() {
        super.prepareLayout()
        let screenHeight = UIScreen.mainScreen().bounds.height
        let height = Int(screenHeight * CGFloat(playCardsRatio))
        let width = Int(height * 233 / 338)
        let minimumInteritemSpacing = -CGFloat(width) / 1.5
        self.minimumInteritemSpacing = minimumInteritemSpacing
        self.itemSize = CGSize(width: width, height: height)
    }
   
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes {
            
        let attributes = super.layoutAttributesForItemAtIndexPath(indexPath)
        self.modifyLayoutAttributes(attributes!)
        return attributes!
    }
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
            
            let allAttributesInRect =
            super.layoutAttributesForElementsInRect(rect)
            
            for cellAttributes in allAttributesInRect! {
                self.modifyLayoutAttributes(cellAttributes)
            }
            return allAttributesInRect!
    }
    func modifyLayoutAttributes(layoutattributes: UICollectionViewLayoutAttributes) {
        layoutattributes.zIndex = layoutattributes.indexPath.row
    }
}
