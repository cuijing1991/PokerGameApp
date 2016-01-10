//
//  Card.cpp
//  CircularCollectionView
//
//  Created by Cui Jing on 11/10/15.
//  Copyright © 2015 Jingplusplus. All rights reserved.
//

#include "Constants.hpp"
#include "Card.hpp"
#include "GameInfo.hpp"

Card::Card(int suit, int rank) {
    m_suit = static_cast<Suits>(suit);
    m_rank = static_cast<Ranks>(rank);
    m_rank_int = rank;
    m_suit_int = suit;
    if (m_rank_int == 10 || m_rank_int == 13) {
        value = 10;
    }
    else if (m_rank_int == 5) {
        value = 5;
    }
    else {
        value = 0;
    }
}

Card::Card(Suits suit, Ranks rank) {
    m_suit = suit;
    m_rank = rank;
    m_rank_int = static_cast<int>(rank);
    m_suit_int = static_cast<int>(suit);
    if (m_rank_int == 10 || m_rank_int == 13) {
        value = 10;
    }
    else if (m_rank_int == 5) {
        value = 5;
    }
    else {
        value = 0;
    }
}

const string Card::toString() const {
    return rankNames[m_rank] + "_of_" + suitNames[m_suit];
}

bool Card::operator==(const Card& rhs) const {
    return (m_suit == rhs.m_suit) && (m_rank == rhs.m_rank);
}


/* This compare function is only used to sort cards for displaying */
bool Card::compare(const Card& card1, const Card& card2, const Suits& suit, const Ranks& rank) {
    
    return
    (card1.getSuit() * rankMax + card1.getRank()
     + ( card1.getSuit() == static_cast<int>(Joker) ? 1000 : 0 )
     + ( card1.getRank() == static_cast<int>(rank) ? 500 : 0 )
     + ( card1.getSuit() == static_cast<int>(suit) ? 200 : 0 )
     )
    >
    (card2.getSuit() * rankMax + card2.getRank()
     + ( card2.getSuit() == static_cast<int>(Joker) ? 1000 : 0 )
     + ( card2.getRank() == static_cast<int>(rank) ? 500 : 0 )
     + ( card2.getSuit() == static_cast<int>(suit) ? 200 : 0 )
     ) ;
}

bool Card::isKey() const {
    return (m_suit == GameInfo::keySuit) || (m_rank == GameInfo::keyRank) || (m_suit == Joker);
}

int Card::computeValue() const {
    int val;
    if (GameInfo::keySuit != Joker) {
        if (this->isKey()) {
            if (m_suit == Joker && m_rank == Low) val = 16;
            else if (m_suit == Joker && m_rank == High) val = 17;
            else if (m_rank == GameInfo::keyRank && m_suit == GameInfo::keySuit) val = 15;
            else if (m_rank == GameInfo::keyRank) val = 11 + (m_suit_int - static_cast<int>(GameInfo::keySuit) + 4) % 4;
            else if (m_rank_int > static_cast<int>(GameInfo::keyRank)) val = m_rank_int - 3;
            else if (m_rank_int < static_cast<int>(GameInfo::keyRank)) val = m_rank_int - 2;
        }
        else {
            if (m_rank_int > static_cast<int>(GameInfo::keyRank)) val = m_rank_int - 3;
            else val = m_rank_int - 2;
            
        }
    }
    else {
        if (this->isKey()) {
            if (m_suit == Joker && m_rank == Low) val = 4;
            else if (m_suit == Joker && m_rank == High) val = 5;
            else val = m_suit_int;
            
        }
        else {
            if (m_rank_int > static_cast<int>(GameInfo::keyRank)) val = m_rank_int - 3;
            else val = m_rank_int-2;
        }
    }
    return val;  
}