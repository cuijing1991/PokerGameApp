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

#include "Constants.hpp"
#include <string>

using std::string;

class Card {
public:
    Card(int suit, int rank);
    Card(Suits suit, Ranks rank);
    const string toString() const;
    bool operator==(const Card& rhs) const;
    int getSuit() const {return m_suit_int;};
    int getRank() const {return m_rank_int;};
    bool isKey() const;
    int computeValue() const;
    static bool compare(const Card& card1, const Card& card2, const Suits& suit, const Ranks& rank);
    int value;
private:
    Ranks m_rank;
    Suits m_suit;
    int m_rank_int;          /* Rank as an integer */
    int m_suit_int;          /* Suit as an integer */
};


#endif

