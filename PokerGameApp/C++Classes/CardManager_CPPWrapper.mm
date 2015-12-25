//
//  CardManager_CPPWrapper.m
//  PokerGameApp
//
//  Created by Cui Jing on 12/25/15.
//  Copyright © 2015 Jingplusplus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CardManager_CPPWrapper.h"
#import "Card_CPPWrapper.h"
#include "Card.hpp"
#include "CardManager.hpp"
#include <list>

@interface CardManager_CPPWrapper()
@property CardManager *manager;
@property std::list<Card> *cards_cpp;
@end



@implementation CardManager_CPPWrapper
- (instancetype)CardManager_CPPWrapper {
    self.manager = new CardManager();
    return self;
}

- (instancetype)CardManager_CPPWrapper:(NSMutableArray*)cards {
    self.cards_cpp = new std::list<Card>();
    for(Card_CPPWrapper *c in cards) {
        self.cards_cpp->push_back(Card((int)c.suit, (int)c.rank));
    }
    self.manager = new CardManager(*(self.cards_cpp));
    return self;
}
@end

