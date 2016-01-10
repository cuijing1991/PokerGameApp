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
bool GameInfo::noSkip2 = true;
bool GameInfo::noSkip51013 = true;
int GameInfo::even_odd_Rank[] = {2,2};
bool GameInfo::done2[] = {false, false};
bool GameInfo::done5[] = {false, false};
bool GameInfo::done10[] = {false, false};
bool GameInfo::done13[] = {false, false};