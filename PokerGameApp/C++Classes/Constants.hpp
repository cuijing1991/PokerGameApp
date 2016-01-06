//
//  Constants.hpp
//  PokerGameApp
//
//  Created by Cui Jing on 12/6/15.
//  Copyright © 2015 Jingplusplus. All rights reserved.
//

#ifndef Constants_hpp
#define Constants_hpp

#include <string>

using std::string;

enum Ranks { Low = 0, High = 1, Two = 2, Three = 3, Four = 4, Five = 5, Six = 6, Seven = 7, Eight = 8, Nine = 9, Ten = 10, Jack = 11, Queen = 12, King = 13, Ace = 14 };
enum Suits { Spade = 0, Heart = 1, Club = 2, Diamond = 3, Joker = 4 };
extern const string suitNames[];
extern const string rankNames[];

extern const int doubleDeckSize;
extern const int tableCardSize;
extern const int suitSize;
extern const int rankMin;
extern const int rankMax;

#endif /* Constants_hpp */
