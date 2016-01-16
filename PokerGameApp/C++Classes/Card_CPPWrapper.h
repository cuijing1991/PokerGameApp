//
//  Card_CPPWrapper.h
//  CircularCollectionView
//
//  Created by Cui Jing on 11/10/15.
//  Copyright © 2015 Jingplusplus. All rights reserved.
//

#ifndef Card_CPPWrapper_h
#define Card_CPPWrapper_h

#import <Foundation/Foundation.h>


@interface Card_CPPWrapper : NSObject <NSCoding>
@property NSInteger suit;
@property NSInteger rank;
- (instancetype) Card_CPPWrapper:(NSInteger)suit rank:(NSInteger)rank;
- (NSString*) toString;
- (bool) compare:(Card_CPPWrapper*)card1 to:(Card_CPPWrapper*)card2 suit:(NSInteger)suit rank:(NSInteger)rank;
- (NSInteger) value;
- (void) dealloc;
@end

#endif /* Gard_CPPWrapper_h */