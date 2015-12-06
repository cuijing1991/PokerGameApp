//
//  Card_CPPWrapper.m
//  CircularCollectionView
//
//  Created by Cui Jing on 11/10/15.
//  Copyright © 2015 Jingplusplus. All rights reserved.
//

#import "Card_CPPWrapper.h"
#include "Card.hpp"

@interface Card_CPPWrapper()
@property Card *card;
@end

@implementation Card_CPPWrapper
- (instancetype)Card_CPPWrapper:(NSInteger)suit rank:(NSInteger)rank {
  self.card = new Card((int)suit, (int)rank);
  return self;
}

- (NSString*)toString {
  return [NSString stringWithUTF8String:self.card->toString().c_str()];
}
@end
