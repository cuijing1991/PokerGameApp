/*****************************************************
 *  CardManager_CPPWrapper.h
 *  PokerGameApp
 *
 *  Created by Cui Jing on 12/25/15.
 *  Copyright © 2015 Jingplusplus. All rights reserved.
 ******************************************************/

#ifndef CardManager_CPPWrapper_h
#define CardManager_CPPWrapper_h

#import <Foundation/Foundation.h>
#import "Card_CPPWrapper.h"

@interface CardManager_CPPWrapper : NSObject
- (instancetype)CardManager_CPPWrapper;
- (instancetype)CardManager_CPPWrapper:(NSArray<Card_CPPWrapper*>*)cards;
- (bool) testCards: (NSInteger)suit format: (NSArray<Card_CPPWrapper*>*)format cards: (NSArray<Card_CPPWrapper*>*)cards;
- (bool) testCards: (NSArray<Card_CPPWrapper*>*)cards;
- (bool) remove: (Card_CPPWrapper*)card;
- (void) setFormat: (NSArray<Card_CPPWrapper*>*)format;

@end


#endif /* CardManager_CPPWrapper_h */
