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

void GameProcedure::ShuffleCards(list<Card> &pc1, list<Card> &pc2, list<Card> &pc3, list<Card> &pc4, list<Card> &tb) {

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

    for ( int i = 0; i < (doubleDeckSize - tableCardSize); i = i + 4 ) {
        pc1.push_back(doubleDeck[i]);
        pc2.push_back(doubleDeck[i+1]);
        pc3.push_back(doubleDeck[i+2]);
        pc4.push_back(doubleDeck[i+3]);
    }

    for ( int i = doubleDeckSize - tableCardSize; i < doubleDeckSize; i = i + 1 ) {
        tb.push_back(doubleDeck[i]);
    }

    lists[0] = pc1;
    lists[1] = pc2;
    lists[2] = pc3;
    lists[3] = pc4;

    scores = 0;
}

void GameProcedure::appendTableCards(list<Card> &cards, int ID) {
    std::cout << "Original Cards, count = " << cards.size() << std::endl;
    lists[ID].insert(lists[ID].end(), cards.begin(), cards.end());
    std::cout << "Append Table Cards, count = " << cards.size() << std::endl;
}

void GameProcedure::removeTableCards(list<Card> &cards, int ID) {
    int count = 0;
    std::list<Card>::const_iterator iterator;
    for (Card card : cards) {
        for (iterator = lists[ID].begin(); iterator != lists[ID].end(); ++iterator) {
            if((*iterator) == card) {
                lists[ID].erase(iterator);
                count++;
                break;
            }
        }
    }
    std::cout << "Remove Table Cards, count = " << count << std::endl;
}

void GameProcedure::constructManager() {

    for (int i = 0; i < 4; i ++) {
        manager[i] = CardManager(lists[i]);
        std::cout << "****************************" << std::endl;
        for (Card c : lists[i]) {
            std::cout << c.toString() << std::endl;
        }
    }
}


/*
 * Find the winner from 4 players && add scores appropritely
 * pc1, pc2, pc3, pc4 are cards of four players in order
 * pc1 is the one who started in this round
 * ID is pc1 player's ID
 * this ID here is to determine to add score or not
 * (winnerIndex + ID) % 2 != GameInfo::lordID % 2)
 */

int GameProcedure::Winner (int ID, const list<Card> &pc1, const list<Card> &pc2, const list<Card> &pc3, const list<Card> &pc4) {

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
  list<CardUnit> cu1 = CardManager::getStructure(pc1);
  order1 = cu1.begin()->m_head;

  if (suit2 != -1) {
    vector<bool> test_result2 = CardManager::anaylsisStructure(CardManager::getStructure(pc1), CardManager::getStructure(pc2));
    for (bool b : test_result2) {
      if (!b) {suit2 = -1; break;}
    }

    if (suit2 != -1) {
      list<CardUnit> cu2 = CardManager::getStructure(pc2);
      std::list<CardUnit>::const_iterator iterator;
      for (iterator = cu2.begin(); iterator != cu2.end(); ++iterator) {
        if (iterator->m_type >= cu1.begin()->m_type && iterator->m_head > order2)
          order2 = iterator->m_head;
      }
    }

  }
  if (suit3 != -1) {
    vector<bool> test_result3 = CardManager::anaylsisStructure(CardManager::getStructure(pc1), CardManager::getStructure(pc3));
    for (bool b : test_result3) {
      if (!b) {suit3 = -1; break;}
    }

    if (suit3 != -1) {
      list<CardUnit> cu3 = CardManager::getStructure(pc3);
      std::list<CardUnit>::const_iterator iterator;
      for (iterator = cu3.begin(); iterator != cu3.end(); ++iterator) {
        if (iterator->m_type >= cu1.begin()->m_type && iterator->m_head > order3)
          order3 = iterator->m_head;
      }
    }
  }
  if (suit4 != -1) {
    vector<bool> test_result4 = CardManager::anaylsisStructure(CardManager::getStructure(pc1), CardManager::getStructure(pc4));
    for (bool b : test_result4) {
      if (!b) {suit4 = -1; break;}
    }
    if (suit4 != -1) {
      list<CardUnit> cu4 = CardManager::getStructure(pc4);
      std::list<CardUnit>::const_iterator iterator;
      for (iterator = cu4.begin(); iterator != cu4.end(); ++iterator) {
        if (iterator->m_type >= cu1.begin()->m_type && iterator->m_head > order4)
          order4 = iterator->m_head;
      }
    }
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
  int winnerIndex = index_max - 1;

  if((winnerIndex + ID) % 2 != GameInfo::lordID % 2) {
    for (Card c : pc1) { scores += c.value; }
    for (Card c : pc2) { scores += c.value; }
    for (Card c : pc3) { scores += c.value; }
    for (Card c : pc4) { scores += c.value; }
  }
  return winnerIndex;
}

list<Card> GameProcedure::testStarter (const list<Card> cards, Suits suit, int n) {
  if (suit == GameInfo::keySuit || suit == Joker) {
    cout << "Error -- GameProcedure: testStarter()" << endl;
    return cards;
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
    for (CardUnit c2 : cu_all) {
        cout << "(" << c2.m_type << ", " << c2.m_head << ")" << endl;
    }
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
    std::cout << "run gameprocedure remove" << endl;
    for (Card c: removeList) {
        if(!manager[n].remove(c)) return false;
    }
    return true;
}

void GameProcedure::nextLordandRank(int scores) {
    if (scores >= 80 ) {
        GameInfo::even_odd_Rank[GameInfo::lordID % 2] = static_cast<int>(GameInfo::keyRank);
        switch(GameInfo::keyRank) {
            case 2: GameInfo::done2[GameInfo::lordID % 2] = true; break;
            case 5: GameInfo::done5[GameInfo::lordID % 2] = true; break;
            case 10: GameInfo::done10[GameInfo::lordID % 2] = true; break;
            case 13: GameInfo::done13[GameInfo::lordID % 2] = true; break;
            default: break;
        }

        GameInfo::lordID = (GameInfo::lordID + 3) % 4;
        int level = GameInfo::even_odd_Rank[GameInfo::lordID % 2];
        while(scores >= 120) {
            if(   (level == 2 && GameInfo::noSkip2 && !GameInfo::done2[GameInfo::lordID % 2])
               || (level == 5 && GameInfo::noSkip51013 && !GameInfo::done5[GameInfo::lordID % 2])
               || (level == 10 && GameInfo::noSkip51013 && !GameInfo::done10[GameInfo::lordID % 2])
               || (level == 13 && GameInfo::noSkip51013 && !GameInfo::done13[GameInfo::lordID % 2])) { break; }

            level = ((level - 2 + 1) % 13 + 2);
            if(level == 2) {
                GameInfo::done2[GameInfo::lordID % 2] = false;
                GameInfo::done5[GameInfo::lordID % 2] = false;
                GameInfo::done10[GameInfo::lordID % 2] = false;
                GameInfo::done13[GameInfo::lordID % 2] = false;
            }
            scores -= 40;
        }
        GameInfo::keyRank = static_cast<Ranks>(level);
    }
    else {
        GameInfo::lordID = (GameInfo::lordID + 2) % 4;
        int level = (static_cast<int>(GameInfo::keyRank) - 2 + 1) % 13 + 2;
        while(scores < 40) {
            if(   (level == 2 && GameInfo::noSkip2 && !GameInfo::done2[GameInfo::lordID % 2])
               || (level == 5 && GameInfo::noSkip51013 && !GameInfo::done5[GameInfo::lordID % 2])
               || (level == 10 && GameInfo::noSkip51013 && !GameInfo::done10[GameInfo::lordID % 2])
               || (level == 13 && GameInfo::noSkip51013 && !GameInfo::done13[GameInfo::lordID % 2])) { break; }

            level = ((level - 2 + 1) % 13 + 2);
            if(level == 2) {
                GameInfo::done2[GameInfo::lordID % 2] = false;
                GameInfo::done5[GameInfo::lordID % 2] = false;
                GameInfo::done10[GameInfo::lordID % 2] = false;
                GameInfo::done13[GameInfo::lordID % 2] = false;
            }
            scores += 40;
        }
        GameInfo::keyRank = static_cast<Ranks>(level);
        std::cout << "Next Game: keyrank = " << GameInfo::keyRank << " lord = " << GameInfo::lordID << std::endl;
    }
}

