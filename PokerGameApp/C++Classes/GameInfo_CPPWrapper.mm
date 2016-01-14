//
//  GameInfo_CPPWrapper.m
//  PokerGameApp
//
//  Created by Cui Jing on 1/2/16.
//  Copyright © 2016 Jingplusplus. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "GameInfo_CPPWrapper.h"
#include "GameInfo.hpp"
#include "Constants.hpp"
#include "GameProcedure.hpp"
#include <list>

@implementation GameInfo_CPPWrapper
+ (void) updateKeySuit: (NSInteger)keysuit {
    GameInfo::keySuit = static_cast<Suits>((int)keysuit);
}
+ (void) updateKeyRank: (NSInteger)keyrank {
    GameInfo::keyRank = static_cast<Ranks>((int)keyrank);
}
+ (void) updateLordID: (NSInteger)lordID {
    GameInfo::lordID = (int)lordID;
}
+ (NSInteger) getKeyRank {
    return static_cast<int>(GameInfo::keyRank);
}
+ (NSInteger) getKeySuit {
    return static_cast<int>(GameInfo::keySuit);
}
+ (NSInteger) getLordID {
    return GameInfo::lordID;
}
+ (void) reset {
    GameInfo::noSkip51013 = true;
    GameInfo::noSkip2 = true;
    GameInfo::changeTableCards = true;
    GameInfo::keyRank = Two;
    GameInfo::keySuit = Joker;
    GameInfo::currentSuit = Diamond;
    GameInfo::format = std::list<Card>();
    GameInfo::lordID = -1;
    for (int i = 0; i < 2; i++) {
        GameInfo::even_odd_Rank[i] = 2;
        GameInfo::done2[i] = false;
        GameInfo::done5[i] = false;
        GameInfo::done10[i] = false;
        GameInfo::done13[i] = false;
    }
}
+ (void) nextLordandRank: (NSInteger)scores {
    GameProcedure::nextLordandRank((int)scores);
}
+ (void) updateNoSkip2: (bool)noSkip {
    GameInfo::noSkip2 = noSkip;
}
+ (void) updateNoSkip51013: (bool)noSkip {
    GameInfo::noSkip51013 = noSkip;
}
+ (void) updateChangeTableCards: (bool)changeTableCards {
    GameInfo::changeTableCards = changeTableCards;
}
+ (bool) getChangeTableCards {
    return GameInfo::changeTableCards;
}
+ (void) updateInitialRank: (NSInteger)rank {
    GameInfo::even_odd_Rank[0] = (int)rank;
    GameInfo::even_odd_Rank[1] = (int)rank;
}
@end