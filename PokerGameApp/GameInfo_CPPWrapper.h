//
//  GameInfo_CPPWrapper.h
//  PokerGameApp
//
//  Created by Cui Jing on 1/2/16.
//  Copyright © 2016 Jingplusplus. All rights reserved.
//

#ifndef GameInfo_CPPWrapper_h
#define GameInfo_CPPWrapper_h
@interface GameInfo_CPPWrapper : NSObject
+ (void) updateKeySuit: (NSInteger)keysuit;
+ (void) updateKeyRank: (NSInteger)keyrank;
+ (void) updateLordID: (NSInteger)lordID;
+ (NSInteger) getKeyRank;
+ (NSInteger) getKeySuit;
+ (NSInteger) getLordID;
+ (void) reset;
+ (void) nextLordandRank: (NSInteger)scores;
+ (void) updateNoSkip2: (bool)noSkip;
+ (void) updateNoSkip51013: (bool)noSkip;
+ (void) updateChangeTableCards: (bool)changeTableCards;
+ (bool) getChangeTableCards;
+ (void) updateInitialRank: (NSInteger)rank;
@end
#endif /* GameInfo_CPPWrapper_h */
