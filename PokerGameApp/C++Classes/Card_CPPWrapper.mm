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
    self.suit = suit;
    self.rank = rank;
    return self;
}

- (NSString*) toString {
    return [NSString stringWithUTF8String:self.card->toString().c_str()];
}

- (bool) compare:(Card_CPPWrapper*)card1 to:(Card_CPPWrapper*)card2 suit:(NSInteger)suit rank:(NSInteger)rank {
    return self.card->compare(*(card1.card), *(card2.card), static_cast<Suits>(suit), static_cast<Ranks>(rank));
}

- (id) initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.suit = [decoder decodeIntegerForKey:@"suit"];
        self.rank = [decoder decodeIntegerForKey:@"rank"];
        self.card = new Card((int)self.suit, (int)self.rank);
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInteger:self.suit forKey:@"suit"];
    [encoder encodeInteger:self.rank forKey:@"rank"];
}

- (NSInteger) value {
    return self.card->value;
}

- (void) dealloc {
    delete self.card;
}

@end
