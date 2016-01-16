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
- (void)ShuffleCards:(NSMutableArray*)pca1 pca2:(NSMutableArray*)pca2 pca3:(NSMutableArray*)pca3 pca4:(NSMutableArray*)pca4 tb:(NSMutableArray*)tbca;

-(NSArray<Card_CPPWrapper*>*)testStarter:(NSArray<Card_CPPWrapper*>*)cards suit:(NSInteger)suit n:(NSInteger)n;

- (bool)remove: (NSArray<Card_CPPWrapper*>*)removeList n:(NSInteger)n;

- (NSInteger) Winner:(NSInteger)ID player0: (NSArray<Card_CPPWrapper*>*)l0 player1:(NSArray<Card_CPPWrapper*>*)l1 player2:(NSArray<Card_CPPWrapper*>*)l2 player3:(NSArray<Card_CPPWrapper*>*)l3;

- (NSInteger) getScores;
- (void) appendTableCards:(NSMutableArray*)cards playerID:(NSInteger)ID;
- (void) removeTableCards:(NSArray<Card_CPPWrapper*>*)cards playerID:(NSInteger)ID;
- (void) constructManager;
- (void) dealloc;
@end
#endif /* GameProcedure_CPPWrapper_h */
