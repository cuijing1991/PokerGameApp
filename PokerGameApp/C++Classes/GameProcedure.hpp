//
//  GameProcedure.hpp
//  CircularCollectionView
//
//  Created by Cui Jing on 11/14/15.
//  Copyright © 2015 Jingplusplus. All rights reserved.
//

/**
 * GameProcedure: Controls Game Process.
 * Constructor Parameter List:
 */

#ifndef GAMEPROCEDURE_H
#define GAMEPROCEDURE_H

#include <list>
#include "Card.hpp"
#include "CardUnit.hpp"
#include "CardManager.hpp"
using std::list;


class GameProcedure {
public:
    GameProcedure () {};
    
    /* ShuffleCards takes in four empty list and shuffle a doubledeck. */
    void ShuffleCards (list<Card> &pc1, list<Card> &pc2, list<Card> &pc3, list<Card> &pc4, list<Card> &tb);
    
    /* Find the winner from 4 players */
    int Winner (int ID, const list<Card> &pc1, const list<Card> &pc2, const list<Card> &pc3, const list<Card> &pc4);
    
    /* Test whether the starter's cards (cu) are legal
     * If legal return the -1
     * Otherwise return index of CardUnit (cu) to play
     */
    list<Card> testStarter (const list<Card> cards, Suits suit, int n);
    int testStarter (const list<CardUnit> cu, const list<Card> cards);
    
    /*  Remove Cards from manager */
    bool remove(const list<Card> removeList, int n);
    
    /* Record Game Scores */
    int scores;
    
    void appendTableCards(list<Card> &cards, int ID);
    
private:
    CardManager manager[4];
    
};

#endif


