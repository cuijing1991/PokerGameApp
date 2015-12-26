//
//  CardManager.cpp
//  PokerGameApp
//
//  Created by Cui Jing on 12/25/15.
//  Copyright © 2015 Jingplusplus. All rights reserved.
//

#include "CardManager.hpp"
#include <list>
#include <iostream>
#include "Constants.hpp"
#include "Card.hpp"
#include "GameInfo.hpp"

using std::list;
using std::cout;
using std::endl;

CardManager::CardManager(const list<Card> &cards) {
    for (Card card: cards) {
        
        if (card.isKey()) {
            keys.push_back(card);
        }
        
        else {
            switch(static_cast<Suits>(card.getSuit())) {
                case Spade:
                    spades.push_back(card);
                    break;
                case Heart:
                    hearts.push_back(card);
                    break;
                case Club:
                    clubs.push_back(card);
                    break;
                case Diamond:
                    diamonds.push_back(card);
                    break;
                default:
                    cout << "Error -- CardManager: CardManager()" << endl;
                    break;
            }
        }
    }
    cout << "Spade = " << spades.size() << endl;
    cout << "Diamond = " << diamonds.size() << endl;

}


list<CardUnit> CardManager::getStructure(const list<Card> &cards) {
    list<CardUnit> cu_list;
    vector<int> card_array;
    int mark = 0;
    int bound;
    int gap;
    
    if (GameInfo::keySuit != Joker) {
        if ((cards.begin())->isKey()) card_array.assign(rankMax - rankMin + 6, 0);
        else card_array.assign(rankMax - rankMin, 0);
    }
    else {
        if ((cards.begin())->isKey()) card_array.assign(6, 0);
        else card_array.assign(rankMax - rankMin, 0);
    }
    
    for (Card card: cards) {
        card_array[card.computeValue()]++;
    }
    
    if ((cards.begin())->isKey()) {
        if (GameInfo::keySuit != Joker) {
            bound = 11;
            gap = 3;
        }
        else {
            bound = -1;
            gap = 4;
        }
        mark = 0;
        for (int i = 0; i < card_array.size(); i++) {
            if ( i <= bound || i >= bound + 4 ) {
                if(card_array[i] == 2) {
                    if (mark != i) {
                        card_array[mark] += 2;
                        card_array[i] = 0;
                    }
                }
                else mark = i+1;
            }
            else {
                if (i >= bound + 1 && i < bound + gap) {
                    if (card_array[i] == 2) {
                        if (mark != i) {
                            card_array[mark] += 2;
                            card_array[i] = 0;
                        }
                        i = bound + gap;
                    }
                    else {
                        if (mark != i) {}
                        else mark = mark+1;
                    }
                }
                else if (i == bound + gap) {
                    if (card_array[i] == 2) {
                        if (mark != i) {
                            card_array[mark] += 2;
                            card_array[i] = 0;
                        }
                    }
                    else mark = bound + gap + 1;
                }
            }
        }
    }
    
    else {
        mark = 0;
        for (int i = 0; i < card_array.size(); i++) {
            if (card_array[i] == 2) {
                if(i != mark) {
                    card_array[mark] += 2;
                    card_array[i] = 0;
                }
            }
            else {
                mark = i + 1;
            }
        }
    }
    
    std::vector<int>::const_iterator iterator;
    int order = 0;
    for (iterator = card_array.begin(); iterator != card_array.end(); ++iterator) {
        if (*iterator != 0) {
            if ((cards.begin())->isKey()) {
                if (GameInfo::keySuit != Joker && (order==13 || order==14))
                    cu_list.push_back(CardUnit(*iterator, 12));
                else if (GameInfo::keySuit == Joker && (order==1 || order==2))
                    cu_list.push_back(CardUnit(*iterator, 0));
                else
                    cu_list.push_back(CardUnit(*iterator, order));
            }
            else {
                cu_list.push_back(CardUnit(*iterator, order));
            }
        }
        order ++;
    }
    cu_list.sort([](const CardUnit &cu1, const CardUnit &cu2) { return CardUnit::compare(cu1, cu2);});
    return cu_list;
}

/* Assume cards in format have the same suit */
bool CardManager::testCards(const Suits suit, const list<Card> &format, const list<Card> &cards) {
    int size_format = (int)format.size();
    int size_all = (int)getList(suit).size();
    int size = (int)cards.size();
    int size_test = 0;
    
    if (size != size_format) return false;
    
    if (suit == GameInfo::keySuit) {
        for (Card card: cards) {
            if (card.isKey())
                size_test ++;
        }
    }
    else {
        for (Card card: cards) {
            if (card.getSuit() == static_cast<int>(suit) && !card.isKey())
                size_test ++;
        }
    }
    
    if(size_test > size_all) return false;
    if(size_test > size_format) return false;
    if(size_test < size_format && size_test != size_all) return false;
    if(size_test < size_format && size_test == size_all) return true;
    
    list<CardUnit> cu_format1 = getStructure(format);
    list<CardUnit> cu_format2 = getStructure(format);
    list<CardUnit> cu_all = getStructure(getList(suit));
    list<CardUnit> cu_test = getStructure(cards);
    
    vector<bool> b_vector1 = anaylsisStructure(cu_format1, cu_all);
    vector<bool> b_vector2 = anaylsisStructure(cu_format2, cu_test);
    
    
    if(b_vector1.size() != b_vector2.size()) return false;
    for ( int i = 0; i < b_vector1.size(); i++) {
        if (b_vector1.at(i) != b_vector2.at(i) ) return false;
    }
    return true;
}


list<Card> CardManager::getList(const Suits suit) {
    if ( suit == GameInfo::keySuit ) return keys;
    switch (suit) {
        case Spade:
            return spades;
        case Heart:
            return hearts;
        case Club:
            return clubs;
        case Diamond:
            return diamonds;
        default:
            cout << "Error -- CardManager: getList()" << endl;
            return keys;
    }
}

vector<bool> CardManager::anaylsisStructure( list<CardUnit> cu1, list<CardUnit> cu2) {
    
    int type1, type2, head1, head2;
    vector<bool> b_vector;
    
    while(cu1.size() > 0) {
        type1 = cu1.begin()->m_type;
        type2 = cu2.begin()->m_type;
        if(type1 > type2) {
            b_vector.push_back(false);
            head1 = cu1.begin()->m_head;
            cu1.begin()->m_type = type2;
            cu1.begin()->m_head = head1 + (type1 - type2) / 2;
            cu1.erase(cu1.begin());
            cu2.erase(cu2.begin());
            cu1.push_back(CardUnit(type1 - type2, head1));
            cu1.sort([](const CardUnit &cuA, const CardUnit &cuB) { return CardUnit::compare(cuA, cuB);});
        }
        else if(type1 == type2) {
            b_vector.push_back(true);
            cu1.erase(cu1.begin());
            cu2.erase(cu2.begin());
            
        }
        else {
            b_vector.push_back(true);
            head2 = cu2.begin()->m_head;
            cu2.begin()->m_type = type1;
            cu2.begin()->m_head = head2 + (type2 - type1) / 2;
            cu1.erase(cu1.begin());
            cu2.erase(cu2.begin());
            cu2.push_back(CardUnit(type2 - type1, head2));
            cu2.sort([](const CardUnit &cuA, const CardUnit &cuB) { return CardUnit::compare(cuA, cuB);});
        }
    }
    return b_vector;
}

int CardManager::isUniform(const list<Card> &cards) {
    if (cards.size() == 0) {
        cout << "Error -- CardManager: isUniform(), empty list" << endl;
        return -1;
    }
    if (cards.begin()->isKey()) {
        for (Card card : cards) {
            if (!card.isKey()) return -1;
        }
        return static_cast<int>(GameInfo::keySuit);
    }
    else {
        int suit = cards.begin()->getSuit();
        for (Card card : cards) {
            if (card.getSuit() != suit) return -1;
        }
        return suit;
    }
}

bool CardManager::remove(const Card card) {
    if (card.isKey()) return remove(card, keys);
    switch (static_cast<Suits>(card.getSuit())) {
        case Spade: return remove(card, spades);
        case Heart: return remove(card, hearts);
        case Club: return remove(card, clubs);
        case Diamond: return remove(card, diamonds);
        default:
            cout << "Error -- CardManager: remove()" << endl;
            return remove(card, keys);
    }
}

bool CardManager::remove(const Card card, list<Card>& l) {
    list<Card>::const_iterator iterator;
    for (iterator = l.begin(); iterator != l.end(); ++iterator) {
        if (iterator->getSuit() == card.getSuit() && iterator->getRank() == card.getRank()) {
            cout << "Size = " << l.size() << endl;
            cout << "Suit = " << iterator->getSuit() << " Rank = " << iterator->getRank() << endl;
            l.erase(iterator);
            cout << "Size = " << l.size() << endl;
            return true;
        }
    }
    return false;
}

list<Card> CardManager::getCards(const CardUnit& cu, const Suits suit) {
    list<Card> r_list;
    for (int i = 0; i < cu.m_type; i++) {
        if ( cu.m_head + i/2 + 2 < static_cast<int>(GameInfo::keyRank))
            r_list.push_back(Card(static_cast<int>(suit), cu.m_head + i/2 + 2));
        else
            r_list.push_back(Card(static_cast<int>(suit), cu.m_head + i/2 + 3));
    }
    return r_list;
}



