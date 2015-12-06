//
//  GameProcedure.hpp
//  CircularCollectionView
//
//  Created by Cui Jing on 11/14/15.
//  Copyright © 2015 Jingplusplus. All rights reserved.
//

/**
 * GameProcedure: Controls Game Process.
 * Constructor Parameter List:
 */

#ifndef GAMEPROCEDURE_H
#define GAMEPROCEDURE_H

#include <list>
#include "Card.hpp"
using std::list;


class GameProcedure {
public:
  GameProcedure () {};
  void ShuffleCards ( list<Card> *pc1, list<Card> *pc2, list<Card> *pc3, list<Card> *pc4);
  
};

#endif


