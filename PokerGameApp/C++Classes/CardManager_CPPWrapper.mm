/*****************************************************
 * CardManager_CPPWrapper.m
 * PokerGameApp
 *
 *  Created by Cui Jing on 12/25/15.
 *  Copyright © 2015 Jingplusplus. All rights reserved.
 ******************************************************/

#import <Foundation/Foundation.h>
#import "CardManager_CPPWrapper.h"
#import "Card_CPPWrapper.h"
#include "Card.hpp"
#include "CardManager.hpp"
#include "GameInfo.hpp"
#include <list>
#include <iostream>

@interface CardManager_CPPWrapper()
@property CardManager* manager;
@end


@implementation CardManager_CPPWrapper
- (instancetype)CardManager_CPPWrapper {
    self.manager = new CardManager();
    return self;
}

- (instancetype)CardManager_CPPWrapper:(NSArray<Card_CPPWrapper*>*)cards {
    std::list<Card> cards_cpp;
    for(Card_CPPWrapper *c in cards) {
        cards_cpp.push_back(Card((int)c.suit, (int)c.rank));
    }
    self.manager = new CardManager((cards_cpp));
    return self;
}

- (bool) testCards: (NSInteger)suit format: (NSArray<Card_CPPWrapper*>*)format cards: (NSArray<Card_CPPWrapper*>*)cards; {
    std::list<Card> format_cpp;
    std::list<Card> cards_cpp;
    for(Card_CPPWrapper *c in format) {
        format_cpp.push_back(Card((int)c.suit, (int)c.rank));
    }
    for(Card_CPPWrapper *c in cards) {
        cards_cpp.push_back(Card((int)c.suit, (int)c.rank));
    }
    return self.manager->testCards(static_cast<Suits>(suit), format_cpp, cards_cpp);
}
- (bool) testCards: (NSArray<Card_CPPWrapper*>*)cards {
    std::list<Card> cards_cpp;
    for(Card_CPPWrapper *c in cards) {
        cards_cpp.push_back(Card((int)c.suit, (int)c.rank));
    }
    return self.manager->testCards(static_cast<Suits>(GameInfo::format.begin()->getSuit()), GameInfo::format, cards_cpp);
}

- (void) setFormat: (NSArray<Card_CPPWrapper*>*)format {
    std::list<Card> format_cpp;
    for(Card_CPPWrapper *c in format) {
        format_cpp.push_back(Card((int)c.suit, (int)c.rank));
    }
    GameInfo::format = format_cpp;
}

- (bool) remove: (Card_CPPWrapper*)card {
    Card card_cpp((int)card.suit, (int)card.rank);
    self.manager->remove(card_cpp);
    std::cout << self.manager->getList(Diamond).size() << std::endl;
    return true;
}
@end

