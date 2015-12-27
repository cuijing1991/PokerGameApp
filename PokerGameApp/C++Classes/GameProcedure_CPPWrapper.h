//
//  GaemProcedure_CPPWrapper.h
//  CircularCollectionView
//
//  Created by Cui Jing on 11/14/15.
//  Copyright © 2015 Jingplusplus. All rights reserved.
//

#ifndef GameProcedure_CPPWrapper_h
#define GameProcedure_CPPWrapper_h


#import <Foundation/Foundation.h>
#import "Card_CPPWrapper.h"

@interface GameProcedure_CPPWrapper : NSObject
- (instancetype)GameProcedure_CPPWrapper;
- (void)ShuffleCards:(NSMutableArray*)pca1 pca2:(NSMutableArray*)pca2 pca3:(NSMutableArray*)pca3 pca4:(NSMutableArray*)pca4;

-(NSArray<Card_CPPWrapper*>*)testStarter:(NSArray<Card_CPPWrapper*>*)cards suit:(NSInteger)suit n:(NSInteger)n;

- (bool)remove: (NSArray<Card_CPPWrapper*>*)removeList n:(NSInteger)n;

@end
#endif /* GameProcedure_CPPWrapper_h */
