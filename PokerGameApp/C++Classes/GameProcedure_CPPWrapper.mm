//
//  GameProcedure_CPPWrapper.m
//  CircularCollectionView
//
//  Created by Cui Jing on 11/14/15.
//  Copyright © 2015 Jingplusplus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameProcedure_CPPWrapper.h"
#import "Card_CPPWrapper.h"
#include "Card.hpp"
#include "GameProcedure.hpp"

@interface GameProcedure_CPPWrapper()
@property GameProcedure *gameProcedure;
@property std::list<Card> *list1, *list2, *list3, *list4;
@end



@implementation GameProcedure_CPPWrapper
- (instancetype)GameProcedure_CPPWrapper {
  self.gameProcedure = new GameProcedure();
  self.list1 = new std::list<Card>();
  self.list2 = new std::list<Card>();
  self.list3 = new std::list<Card>();
  self.list4 = new std::list<Card>();

  return self;
}

-(void)ShuffleCards:(NSMutableArray *)pca1 pca2:(NSMutableArray *)pca2 pca3:(NSMutableArray *)pca3 pca4:(NSMutableArray *)pca4 {
  
    self.gameProcedure->ShuffleCards(self.list1, self.list2, self.list3, self.list4);
  
    for(Card c : *self.list1) {
      Card_CPPWrapper *cardwrapper;
      cardwrapper = [Card_CPPWrapper alloc];
      [cardwrapper Card_CPPWrapper:c.getSuit() rank:c.getRank()];
      [pca1 addObject: cardwrapper];
    }
  
  
    for(Card c : *self.list2) {
      Card_CPPWrapper *cardwrapper;
      cardwrapper = [Card_CPPWrapper alloc];
      [cardwrapper Card_CPPWrapper:c.getSuit() rank:c.getRank()];
      [pca2 addObject:cardwrapper];
    }
    for(Card c : *self.list3) {
      Card_CPPWrapper *cardwrapper ;
      cardwrapper = [Card_CPPWrapper alloc];
      [cardwrapper Card_CPPWrapper:c.getSuit() rank:c.getRank()];
      [pca3 addObject:cardwrapper];
    }
    for(Card c : *self.list4) {
      Card_CPPWrapper *cardwrapper;
      cardwrapper = [Card_CPPWrapper alloc];
      [cardwrapper Card_CPPWrapper:c.getSuit() rank:c.getRank()];
      [pca4 addObject:cardwrapper];
    }
    
}
@end