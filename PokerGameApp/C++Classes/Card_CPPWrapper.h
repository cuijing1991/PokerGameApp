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


@interface Card_CPPWrapper : NSObject
- (instancetype)Card_CPPWrapper:(NSInteger)suit rank:(NSInteger)rank;
- (NSString*)toString;
@end

#endif /* Gard_CPPWrapper_h */