#include <vector>
#include <list>
#include <iostream>     // std::shuffle
#include <algorithm>    // std::default_random_engine
#include <random>
#include <chrono>       // std::chrono::system_clock
#include <iostream>

#include "Constants.hpp"
#include "GameProcedure.hpp"
#include "Card.hpp"
#include "GameInfo.hpp"
#include "CardManager.hpp"

using std::vector;
using std::list;
using std::cout;
using std::endl;

void GameProcedure::ShuffleCards(list<Card> &pc1, list<Card> &pc2, list<Card> &pc3, list<Card> &pc4) {
    
    vector<Card> doubleDeck;
    
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
    
    
    unsigned seed = (unsigned)std::chrono::system_clock::now().time_since_epoch().count();
    //seed = 149;  // 149 has some really nice feature
    shuffle (doubleDeck.begin(), doubleDeck.end(), std::default_random_engine(seed));
    
    for ( int i = 0; i < doubleDeckSize; i = i + 4 ) {
        
        pc1.push_back(doubleDeck[i]);
        pc2.push_back(doubleDeck[i+1]);
        pc3.push_back(doubleDeck[i+2]);
        pc4.push_back(doubleDeck[i+3]);
    }
    manager[0] = CardManager(pc1);
    manager[1] = CardManager(pc2);
    manager[2] = CardManager(pc3);
    manager[3] = CardManager(pc4);
}





int GameProcedure::Winner (const list<Card> &pc1, const list<Card> &pc2, const list<Card> &pc3, const list<Card> &pc4) {
    int suit1, suit2, suit3, suit4;
    int order1 = -1, order2 = -1, order3 = -1, order4 = -1;
    int suit_max;
    int order_max;
    int index_max;
    
    suit1 = CardManager::isUniform(pc1);
    suit2 = CardManager::isUniform(pc2);
    suit3 = CardManager::isUniform(pc3);
    suit4 = CardManager::isUniform(pc4);
    if (suit1 == -1) cout << "Error -- GameProceduce: Winner()" << endl;
    
    vector<bool> test_result2 = CardManager::anaylsisStructure(CardManager::getStructure(pc1), CardManager::getStructure(pc2));
    vector<bool> test_result3 = CardManager::anaylsisStructure(CardManager::getStructure(pc1), CardManager::getStructure(pc3));
    vector<bool> test_result4 = CardManager::anaylsisStructure(CardManager::getStructure(pc1), CardManager::getStructure(pc4));
    for (bool b : test_result2) {
        if (!b) {suit2 = -1; break;}
    }
    for (bool b : test_result3) {
        if (!b) {suit3 = -1; break;}
    }
    for (bool b : test_result4) {
        if (!b) {suit4 = -1; break;}
    }
    list<CardUnit> cu1 = CardManager::getStructure(pc1);
    list<CardUnit> cu2 = CardManager::getStructure(pc2);
    list<CardUnit> cu3 = CardManager::getStructure(pc3);
    list<CardUnit> cu4 = CardManager::getStructure(pc4);
    
    order1 = cu1.begin()->m_head;
    
    std::list<CardUnit>::const_iterator iterator;
    for (iterator = cu2.begin(); iterator != cu2.end(); ++iterator) {
        if (iterator->m_type >= cu1.begin()->m_type && iterator->m_head > order2)
            order2 = iterator->m_head;
    }
    
    for (iterator = cu3.begin(); iterator != cu3.end(); ++iterator) {
        if (iterator->m_type >= cu1.begin()->m_type && iterator->m_head > order3)
            order3 = iterator->m_head;
    }
    
    for (iterator = cu4.begin(); iterator != cu4.end(); ++iterator) {
        if (iterator->m_type >= cu1.begin()->m_type && iterator->m_head > order4)
            order4 = iterator->m_head;
    }
    
    suit_max = suit1;
    order_max = order1;
    index_max = 1;
    
    if (suit_max != static_cast<int>(GameInfo::keySuit)) {
        if ( (suit2 == suit_max && order2 > order_max) || suit2 == static_cast<int>(GameInfo::keySuit) ) {
            suit_max = suit2;
            order_max = order2;
            index_max = 2;
        }
    }
    else {
        if ( suit2 == static_cast<int>(GameInfo::keySuit) && order2 > order_max) {
            suit_max = suit2;
            order_max = order2;
            index_max = 2;
        }
    }
    
    if (suit_max != static_cast<int>(GameInfo::keySuit)) {
        if ( (suit3 == suit_max && order3 > order_max) || suit3 == static_cast<int>(GameInfo::keySuit) ) {
            suit_max = suit3;
            order_max = order3;
            index_max = 3;
        }
    }
    else {
        if ( suit3 == static_cast<int>(GameInfo::keySuit) && order3 > order_max) {
            suit_max = suit3;
            order_max = order3;
            index_max = 3;
        }
    }
    
    if (suit_max != static_cast<int>(GameInfo::keySuit)) {
        if ( (suit4 == suit_max && order4 > order_max) || suit4 == static_cast<int>(GameInfo::keySuit) ) {
            suit_max = suit4;
            order_max = order4;
            index_max = 4;
        }
    }
    else {
        if ( suit4 == static_cast<int>(GameInfo::keySuit) && order4 > order_max) {
            suit_max = suit4;
            order_max = order4;
            index_max = 4;
        }
    }
    return index_max;
}

list<Card> GameProcedure::testStarter (const list<Card> cards, Suits suit, int n) {
    
    if (suit == GameInfo::keySuit || suit == Joker) {
        cout << "Error -- GameProcedure: testStarter()" << endl;
    }
    
    list<CardUnit> cu = CardManager::getStructure(cards);
    int r1 = testStarter (cu, manager[(n+1) % 4].getList(suit));
    if (r1 != -1) {
        std::list<CardUnit>::const_iterator it = cu.begin();
        std::advance(it, r1);
        return CardManager::getCards(*it, suit);
    }
    int r2 = testStarter (cu, manager[(n+2) % 4].getList(suit));
    if (r2 != -1) {
        std::list<CardUnit>::const_iterator it = cu.begin();
        std::advance(it, r2);
        return CardManager::getCards(*it, suit);
    }
    
    int r3 = testStarter (cu, manager[(n+3) % 4].getList(suit));
    if (r3 != -1) {
        std::list<CardUnit>::const_iterator it = cu.begin();
        std::advance(it, r3);
        return CardManager::getCards(*it, suit);
    }
    
    return cards;
}

int GameProcedure::testStarter (const list<CardUnit> cu, const list<Card> cards) {
    list<CardUnit> cu_all = CardManager::getStructure(cards);
    int i = 0;
    for (CardUnit c1 : cu) {
        for (CardUnit c2 : cu_all) {
            if ( c2.m_type >= c1.m_type && c2.m_head > c1.m_head)
                return i;
        }
        i++;
    }
    return -1;
}

bool GameProcedure::remove(const list<Card> removeList, int n) {
    
    for (Card c: removeList) {
        if(!manager[n].remove(c)) return false;
    }
    return true;
}

