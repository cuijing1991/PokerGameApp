//
//  GameInfo.hpp
//  PokerGameApp
//
//  Created by Cui Jing on 12/25/15.
//  Copyright © 2015 Jingplusplus. All rights reserved.
//

#ifndef GAMEINFO_H
#define GAMEINFO_H
#include "Constants.hpp"
#include "Card.hpp"
#include <list>

class GameInfo {
public:
    static Suits keySuit;
    static Ranks keyRank;
    static Suits currentSuit;
    static std::list<Card> format;
};


#endif /* GameInfo_hpp */
