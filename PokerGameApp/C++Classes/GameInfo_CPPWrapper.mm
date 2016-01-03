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

@implementation GameInfo_CPPWrapper
+ (void) updateKeySuit: (NSInteger)keysuit {
    GameInfo::keySuit = static_cast<Suits>((int)keysuit);
}
+ (void) updateKeyRank: (NSInteger)keyrank {
    GameInfo::keyRank = static_cast<Ranks>((int)keyrank);
}

+ (NSInteger) getKeyRank {
    return static_cast<int>(GameInfo::keyRank);
}
+ (NSInteger) getKeySuit{
    return static_cast<int>(GameInfo::keySuit);
}
@end