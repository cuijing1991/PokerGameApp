//
//  CircularCollectionViewLayout.swift
//  CircularCollectionView
//
//  Created by Cui Jing on 11/5/15.
//  Copyright © 2015 Rounak Jain. All rights reserved.
//

import UIKit


class CircularCollectionViewLayoutAttributes: UICollectionViewLayoutAttributes {
  // 1
  var anchorPoint = CGPoint(x: 0.5, y: 0.5)
  var angle: CGFloat = 0 {
    // 2
    didSet {
      zIndex = Int(angle * 1000000)
      transform = CGAffineTransformMakeRotation(angle)
    }
  }
  // 3
  override func copyWithZone(zone: NSZone) -> AnyObject {
    let copiedAttributes: CircularCollectionViewLayoutAttributes =
    super.copyWithZone(zone) as! CircularCollectionViewLayoutAttributes
    copiedAttributes.anchorPoint = self.anchorPoint
    copiedAttributes.angle = self.angle
    return copiedAttributes
  }
}



class CircularCollectionViewLayout: UICollectionViewLayout {

  var selected = [Bool](count: 100, repeatedValue: false)
  
  let itemSize = CGSize(width: UIScreen.mainScreen().bounds.width * 233 / 2500, height: UIScreen.mainScreen().bounds.width * 338 / 2500)
  let itemSize2 = CGSize(width: UIScreen.mainScreen().bounds.width * 233 / 2000, height: UIScreen.mainScreen().bounds.width * 338 / 2000)
  
  var angleAtExtreme: CGFloat {
    return collectionView!.numberOfItemsInSection(0) > 0 ?
      -CGFloat(collectionView!.numberOfItemsInSection(0) - 1) * anglePerItem : 0
  }
  var angle: CGFloat {
    return angleAtExtreme * collectionView!.contentOffset.x / (collectionViewContentSize().width -
      CGRectGetWidth(collectionView!.bounds))
  }
  
  var angleOffset: CGFloat = 0
  
  
  var radius: CGFloat = 600 {
    didSet {
      invalidateLayout()
    }
  }
  
  var anglePerItem: CGFloat {
    return atan(itemSize.width/2 / radius)
  }
  
  var attributesList = [CircularCollectionViewLayoutAttributes]()

  
  override func collectionViewContentSize() -> CGSize {
    return CGSize(width: CGFloat(collectionView!.numberOfItemsInSection(0)) * itemSize.width,
      height: CGRectGetHeight(collectionView!.bounds))
  }
  
  override class func layoutAttributesClass() -> AnyClass {
    return CircularCollectionViewLayoutAttributes.self
  }
  
  override func prepareLayout() {
    super.prepareLayout()
    
    let centerX = collectionView!.contentOffset.x + (CGRectGetWidth(collectionView!.bounds) / 2.0)
    let anchorPointY = ((itemSize.height / 2.0) + radius) / itemSize.height
    
    let anchorPointY2 = ((itemSize2.height / 2.0) + radius) / itemSize2.height
    
    attributesList = (0..<collectionView!.numberOfItemsInSection(0)).map { (i)
      -> CircularCollectionViewLayoutAttributes in
    
      let attributes = CircularCollectionViewLayoutAttributes(forCellWithIndexPath: NSIndexPath(forItem: i,
        inSection: 0))
      if(!self.selected[i]) {
        attributes.size = self.itemSize
        attributes.anchorPoint = CGPoint(x: 0.5, y: anchorPointY)
      }
      else {
        attributes.size = self.itemSize2
        attributes.anchorPoint = CGPoint(x: 0.5, y: anchorPointY2)
      }

      attributes.center = CGPoint(x: centerX, y: CGRectGetMidY(self.collectionView!.bounds) * 0.9)

      attributes.angle = self.angle + (self.anglePerItem * CGFloat(i)) - self.angleOffset
  
      
      return attributes
    }
  }
  
  override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    return attributesList
  }
  
  override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath)
    -> UICollectionViewLayoutAttributes? {
      return attributesList[indexPath.row]
  }
  
  override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
    return true
  }
  
}
