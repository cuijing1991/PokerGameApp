//
//  Card.cpp
//  CircularCollectionView
//
//  Created by Cui Jing on 11/10/15.
//  Copyright © 2015 Jingplusplus. All rights reserved.
//

#include "Card.hpp"


using std::string;

const string suitNames[] = { "spades", "hearts", "diamonds", "clubs", "joker"};
const string rankNames[] = { "black", "red", "2", "3", "4", "5", "6", "7", "8", "9", "10", "jack", "queen", "king", "ace" };

const int doubleDeckSize = 108;
const int suitSize = 4;
const int rankMin = 2;
const int rankMax = 14;

Card::Card(int suit, int rank) {
  m_suit = static_cast<Suits>(suit);
  m_rank = static_cast<Ranks>(rank);
  m_rank_int = rank;
  m_suit_int = suit;
}

Card::Card(Suits suit, Ranks rank) {
  m_suit = suit;
  m_rank = rank;
  m_rank_int = static_cast<int>(rank);
  m_suit_int = static_cast<int>(suit);
}

const string Card::toString() {
  return rankNames[m_rank] + "_of_" + suitNames[m_suit];
}

bool Card::operator==(const Card& rhs) {
  return (m_suit == rhs.m_suit) && (m_rank == rhs.m_rank);
}

