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
    int testStarter (const list<CardUnit> cu, const list<Card> cards);
    /* Return list of cards to play */
    list<Card> testStarter (const list<Card> cards, Suits suit, int n);
    
    
    /*  Remove Cards from manager */
    bool remove(const list<Card> removeList, int n);
    
    /* Record Game Scores */
    int scores;
    
    /* Append table cards to one player in lists */
    void appendTableCards(list<Card> &cards, int ID);

    /* Remove table cards to one player in lists */
    void removeTableCards(list<Card> &cards, int ID);

    /* Construct CardManager of each player */
    void constructManager();
    
    /* Decide next lord based on scores */
    static void nextLordandRank(int scores);
    
private:
    list<Card> lists[4];
    CardManager manager[4];
    
};

#endif


