//
//  Card.cpp
//  CircularCollectionView
//
//  Created by Cui Jing on 11/10/15.
//  Copyright © 2015 Jingplusplus. All rights reserved.
//

#include "Constants.hpp"
#include "Card.hpp"

Card::Card(int suit, int rank) {
    m_suit = static_cast<Suits>(suit);
    m_rank = static_cast<Ranks>(rank);
    m_rank_int = rank;
    m_suit_int = suit;
    m_value = m_suit_int * rankMax + m_rank_int;
}

Card::Card(Suits suit, Ranks rank) {
    m_suit = suit;
    m_rank = rank;
    m_rank_int = static_cast<int>(rank);
    m_suit_int = static_cast<int>(suit);
    m_value = m_suit_int * rankMax + m_rank_int;
}

const string Card::toString() const {
    return rankNames[m_rank] + "_of_" + suitNames[m_suit];
}

bool Card::operator==(const Card& rhs) {
    return (m_suit == rhs.m_suit) && (m_rank == rhs.m_rank);
}


/* This compare function is only used to sort cards for displaying */
bool Card::compare(const Card& card1, const Card& card2, const Suits& suit, const Ranks& rank) {
    
    return
    (card1.getValue()
     + ( card1.getSuit() == static_cast<int>(Joker) ? 1000 : 0 )
     + ( card1.getRank() == static_cast<int>(rank) ? 500 : 0 )
     + ( card1.getSuit() == static_cast<int>(suit) ? 200 : 0 )
     )
    >
    (card2.getValue()
     + ( card2.getSuit() == static_cast<int>(Joker) ? 1000 : 0 )
     + ( card2.getRank() == static_cast<int>(rank) ? 500 : 0 )
     + ( card2.getSuit() == static_cast<int>(suit) ? 200 : 0 )
     ) ;
}


