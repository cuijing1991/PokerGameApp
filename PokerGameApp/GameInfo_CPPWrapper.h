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
@end
#endif /* GameInfo_CPPWrapper_h */
