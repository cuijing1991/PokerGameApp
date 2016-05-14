/*
 * This test contains different cases to test CardManager::isUniform function
 * Casses cover differnt GameInfo settings
 */


#include <iostream>
#include <list>
#include <cassert>
#include "Constants.hpp"
#include "Card.hpp"
#include "GameProcedure.hpp"
#include "GameInfo.hpp"
#include "CardManager.hpp"

using std::list;
using std::cout;
using std::endl;

int isUniform_function_test() {

  GameProcedure game;

  // Setup GameInfo
  GameInfo::keyRank = Two;
  GameInfo::keySuit = Spade;


  list<Card> player;
  CardManager manager(player);


  list<Card> cards;

  cards.clear();
  cards.push_back(Card(Heart, Three));
  cards.push_back(Card(Heart, Three));
  assert(manager.isUniform(cards) == Heart);
  cout << "------- isUniform Test1 passed -------" << endl;

  cards.clear();
  cards.push_back(Card(Heart, Two));
  cards.push_back(Card(Spade, Two));
  assert(manager.isUniform(cards) == Spade);
  cout << "------- isUniform Test2 passed -------" << endl;

  cards.clear();
  cards.push_back(Card(Heart, Two));
  cards.push_back(Card(Joker, Low));
  assert(manager.isUniform(cards) == Spade);
  cout << "------- isUniform Test3 passed -------" << endl;

  cards.clear();
  cards.push_back(Card(Heart, Two));
  cards.push_back(Card(Club, Three));
  assert(manager.isUniform(cards) == -1);
  cout << "------- isUniform Test4 passed -------" << endl;

  cards.clear();
  cards.push_back(Card(Club, Two));
  cards.push_back(Card(Club, Three));
  assert(manager.isUniform(cards) == -1);
  cout << "------- isUniform Test5 passed -------" << endl;


  GameInfo::keyRank = Two;
  GameInfo::keySuit = Joker;

  cards.clear();
  cards.push_back(Card(Heart, Two));
  cards.push_back(Card(Spade, Two));
  assert(manager.isUniform(cards) == Joker);
  cout << "------- isUniform Test6 passed -------" << endl;


  cards.clear();
  cards.push_back(Card(Heart, Two));
  cards.push_back(Card(Joker, Low));
  assert(manager.isUniform(cards) == Joker);
  cout << "------- isUniform Test7 passed -------" << endl;

  cards.clear();
  cards.push_back(Card(Heart, Two));
  cards.push_back(Card(Club, Three));
  assert(manager.isUniform(cards) == -1);
  cout << "------- isUniform Test8 passed -------" << endl;

  return 0;
}
