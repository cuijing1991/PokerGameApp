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
    static int lordID;
    static bool noSkip2;
    static bool noSkip51013;
    static bool changeTableCards;
    static int even_odd_Rank[];
    static bool done2[];
    static bool done5[];
    static bool done10[];
    static bool done13[];
};


#endif /* GameInfo_hpp */
