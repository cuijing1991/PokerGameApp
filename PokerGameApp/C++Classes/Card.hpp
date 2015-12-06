//
//  Card.hpp
//  CircularCollectionView
//
//  Created by Cui Jing on 11/10/15.
//  Copyright © 2015 Jingplusplus. All rights reserved.
//

/* Card */
#ifndef CARD_H
#define CARD_H

#include <string>

using std::string;

enum Ranks { Low = 0, High = 1, Two = 2, Three = 3, Four = 4, Five = 5, Six = 6, Seven = 7, Eight = 8, Nine = 9, Ten = 10, Jack = 11, Queen = 12, King = 13, Ace = 14 };
enum Suits { Spade = 0, Heart = 1, Diamond = 2, Club = 3, Joker = 4 };
extern const string suitNames[];
extern const string rankNames[];

extern const int doubleDeckSize;
extern const int suitSize;
extern const int rankMin;
extern const int rankMax;


class Card {
public:
  Card(int suit, int rank);
  Card(Suits suit, Ranks rank);
  const string toString();
  bool operator==(const Card& rhs);
  int getSuit() {return m_suit_int;};
  int getRank() {return m_rank_int;};
  
private:
  Ranks m_rank;
  Suits m_suit;
  int m_rank_int;
  int m_suit_int;
  
};

#endif