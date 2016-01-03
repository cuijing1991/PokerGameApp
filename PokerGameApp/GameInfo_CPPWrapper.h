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
+ (NSInteger) getKeyRank;
+ (NSInteger) getKeySuit;
@end
#endif /* GameInfo_CPPWrapper_h */
