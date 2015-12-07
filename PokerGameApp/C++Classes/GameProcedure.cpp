//
//  GameProcedure.cpp
//  CircularCollectionView
//
//  Created by Cui Jing on 11/14/15.
//  Copyright © 2015 Jingplusplus. All rights reserved.
//

#include <vector>
#include <list>
#include <iostream>     // std::shuffle
#include <algorithm>    // std::default_random_engine
#include <random>
#include <chrono>       // std::chrono::system_clock

#include "Constants.hpp"
#include "GameProcedure.hpp"
#include "Card.hpp"


using std::vector;
using std::list;

void GameProcedure::ShuffleCards(list<Card> *pc1, list<Card> *pc2, list<Card> *pc3, list<Card> *pc4) {
  
  vector<Card> doubleDeck;
  std::default_random_engine generator;
  std::uniform_int_distribution<int> distribution(0,9);
  
  
  for ( int i = 0; i < suitSize; i++) {
    for (int j = rankMin; j <= rankMax; j++) {
      doubleDeck.push_back(Card(i,j));
      doubleDeck.push_back(Card(i,j));
    }
  }
  doubleDeck.push_back(Card(4,0));
  doubleDeck.push_back(Card(4,0));
  doubleDeck.push_back(Card(4,1));
  doubleDeck.push_back(Card(4,1));
  
  unsigned seed = (unsigned) std::chrono::system_clock::now().time_since_epoch().count();
  shuffle (doubleDeck.begin(), doubleDeck.end(), std::default_random_engine(seed));
  
  for ( Card c : doubleDeck) {
    std::cout << c.toString() << std::endl;
  }
  
  for ( int i = 0; i < doubleDeckSize; i = i + 4 ) {
    pc1->push_back(doubleDeck[i]);
    pc2->push_back(doubleDeck[i+1]);
    pc3->push_back(doubleDeck[i+2]);
    pc4->push_back(doubleDeck[i+3]);
  }
}


