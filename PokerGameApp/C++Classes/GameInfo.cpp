//
//  GameInfo.cpp
//  PokerGameApp
//
//  Created by Cui Jing on 12/25/15.
//  Copyright © 2015 Jingplusplus. All rights reserved.
//

#include "GameInfo.hpp"
#include "Constants.hpp"
#include "Card.hpp"
#include <list>

Ranks GameInfo::keyRank = Two;
Suits GameInfo::keySuit = Joker;
Suits GameInfo::currentSuit = Diamond;
std::list<Card> GameInfo::format = std::list<Card>();
int GameInfo::lordID = -1;