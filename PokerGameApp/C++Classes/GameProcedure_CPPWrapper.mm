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
#include <iostream>

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
  
    self.gameProcedure->ShuffleCards(*self.list1, *self.list2, *self.list3, *self.list4);
  
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

-(NSArray<Card_CPPWrapper*>*)testStarter:(NSArray<Card_CPPWrapper*>*)cards suit:(NSInteger)suit n:(NSInteger)n {
    std::list<Card> cards_cpp;
    for(Card_CPPWrapper *c in cards) {
        cards_cpp.push_back(Card((int)c.suit, (int)c.rank));
    }
    list<Card> l = self.gameProcedure->testStarter(cards_cpp, static_cast<Suits>(suit), (int)n);
    NSMutableArray *mutableArray = [[NSMutableArray alloc]init];
    for(Card c : l) {
        Card_CPPWrapper *cardwrapper;
        cardwrapper = [Card_CPPWrapper alloc];
        [cardwrapper Card_CPPWrapper:c.getSuit() rank:c.getRank()];
        [mutableArray addObject:cardwrapper];
        printf("*");
    }
    std::cout << "Test:" << mutableArray.count << std::endl;
    NSArray *array = [NSArray arrayWithArray:mutableArray];
    return array;
}

- (bool)remove: (NSArray<Card_CPPWrapper*>*)removeList n:(NSInteger)n {
    std::list<Card> removeList_cpp;
    for(Card_CPPWrapper *c in removeList) {
        removeList_cpp.push_back(Card((int)c.suit, (int)c.rank));
    }
    return self.gameProcedure->remove(removeList_cpp, (int)n);
}

- (NSInteger) Winner:(NSInteger)ID player0:(NSArray<Card_CPPWrapper*>*)l0 player1:(NSArray<Card_CPPWrapper*>*)l1 player2:(NSArray<Card_CPPWrapper*>*)l2 player3:(NSArray<Card_CPPWrapper*>*)l3 {
    std::list<Card> p0, p1, p2, p3;
    for(Card_CPPWrapper *c in l0) {
        p0.push_back(Card((int)c.suit, (int)c.rank));
    }
    for(Card_CPPWrapper *c in l1) {
        p1.push_back(Card((int)c.suit, (int)c.rank));
    }
    for(Card_CPPWrapper *c in l2) {
        p2.push_back(Card((int)c.suit, (int)c.rank));
    }
    for(Card_CPPWrapper *c in l3) {
        p3.push_back(Card((int)c.suit, (int)c.rank));
    }
    return self.gameProcedure->Winner(ID, p0, p1, p2, p3);
}

- (NSInteger) getScores{
    return self.gameProcedure->scores;
}
@end