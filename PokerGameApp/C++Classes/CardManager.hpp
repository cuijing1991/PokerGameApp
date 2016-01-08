//
//  CardManager.hpp
//  PokerGameApp
//
//  Created by Cui Jing on 12/25/15.
//  Copyright © 2015 Jingplusplus. All rights reserved.
//

#ifndef CARDMANAGER_H
#define CARDMANAGER_H

#include <list>
#include <vector>
#include "Card.hpp"
#include "CardUnit.hpp"
#include "Constants.hpp"

using std::list;
using std::vector;

class CardManager {
public:
    /* Default Constructor */
    CardManager() {};
    
    /* Constructor takes in a list of <Card> and sort them into five lists according to their suits. */
    CardManager(const list<Card> &cards);
    
    /* testCards takes in two lists, &format is the first player's cards, and &cards is the thing to test */
    bool testCards(const Suits suit, const list<Card> &format, const list<Card> &cards);
    
    /* Return the correct list */
    list<Card> getList(const Suits suit);
    
    /* Remove a certain card form list */
    bool remove(const Card card);
    bool remove(const Card card, list<Card>& l);
   
    /* Append new cards */
    void append(list<Card>& l);
    /**
     * Return a vector of bool.
     * Each bool indicates whether there could be a same cardUnit.
     */
    static vector<bool> anaylsisStructure( list<CardUnit> cu1, list<CardUnit> cu2);
    
    /*
     * Return the card structure which is a list of integers that represent ..."Tractor"(4), "Double"(2), "Single"(1)
     * If there's more, add to front
     * that means the lenght of the vector determins the first type, and the last type is always "Single"
     * All the cards in list should be of the same suit or keysuit
     */
    static list<CardUnit> getStructure(const list<Card> &cards);
    
    /*
     * If all the cards have the same suit (or key suit) return the suit number
     */
    static int isUniform(const list<Card> &cards);
    
    /* CardUnit -> Card, not applicable to key suit */
    static list<Card> getCards(const CardUnit& cu, const Suits suit);
    
private:
    list<Card> spades;
    list<Card> hearts;
    list<Card> clubs;
    list<Card> diamonds;
    list<Card> keys;
    
    
    
};
#endif /* CardManager_hpp */

