/*
 * This test contains different cases to test GameProcedure::Winner function
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


int compare_function_test() {

  GameProcedure game;

  // Setup GameInfo
  GameInfo::keyRank = Two;
  GameInfo::keySuit = Spade;
  GameInfo::lordID = 0;

  list<Card> player1;
  list<Card> player2;
  list<Card> player3;
  list<Card> player4;

  // Test 1
  player1.push_back(Card(Heart, Three));
  player1.push_back(Card(Heart, Three));
  GameInfo::format = player1;
  GameInfo::currentSuit = Heart;
  player2.push_back(Card(Spade, Ten));
  player2.push_back(Card(Club, Ten));
  player3.push_back(Card(Diamond, Four));
  player3.push_back(Card(Diamond, Jack));
  player4.push_back(Card(Spade, Jack));
  player4.push_back(Card(Spade, Two));

  assert(game.Winner(1, player1, player2, player3, player4) == 0);
  cout << "------ Compare Test 1 Passed ------" << endl;

  // Test 2
  player1.clear();
  player2.clear();
  player3.clear();
  player4.clear();
  player1.push_back(Card(Heart, Three));
  player1.push_back(Card(Heart, Three));
  GameInfo::format = player1;
  GameInfo::currentSuit = Heart;
  player2.push_back(Card(Spade, Ten));
  player2.push_back(Card(Club, Ten));
  player3.push_back(Card(Diamond, Four));
  player3.push_back(Card(Diamond, Jack));
  player4.push_back(Card(Spade, Jack));
  player4.push_back(Card(Spade, Jack));

  assert(game.Winner(1, player1, player2, player3, player4) == 3);
  cout << "------ Compare Test 2 Passed ------" << endl;

  // Test 3
  player1.clear();
  player2.clear();
  player3.clear();
  player4.clear();
  player1.push_back(Card(Heart, Three));
  player1.push_back(Card(Heart, Three));
  GameInfo::format = player1;
  GameInfo::currentSuit = Heart;
  player2.push_back(Card(Spade, Ten));
  player2.push_back(Card(Club, Ten));
  player3.push_back(Card(Diamond, Two));
  player3.push_back(Card(Diamond, Two));
  player4.push_back(Card(Spade, Jack));
  player4.push_back(Card(Spade, Jack));

  assert(game.Winner(1, player1, player2, player3, player4) == 2);
  cout << "------ Compare Test 3 Passed ------" << endl;

  // Test 4
  player1.clear();
  player2.clear();
  player3.clear();
  player4.clear();
  player1.push_back(Card(Heart, Three));
  player1.push_back(Card(Heart, Three));
  GameInfo::format = player1;
  GameInfo::currentSuit = Heart;
  player2.push_back(Card(Spade, Ten));
  player2.push_back(Card(Club, Ten));
  player3.push_back(Card(Diamond, Two));
  player3.push_back(Card(Diamond, Two));
  player4.push_back(Card(Joker, Low));
  player4.push_back(Card(Joker, Low));

  assert(game.Winner(1, player1, player2, player3, player4) == 3);
  cout << "------ Compare Test 4 Passed ------" << endl;


  // Test 5
  player1.clear();
  player2.clear();
  player3.clear();
  player4.clear();
  player1.push_back(Card(Heart, Three));
  player1.push_back(Card(Heart, Three));
  player1.push_back(Card(Heart, Four));
  player1.push_back(Card(Heart, Four));
  GameInfo::format = player1;
  GameInfo::currentSuit = Heart;
  player2.push_back(Card(Spade, Ten));
  player2.push_back(Card(Club, Ten));
  player2.push_back(Card(Heart, Ten));
  player2.push_back(Card(Heart, Ten));
  player3.push_back(Card(Diamond, Two));
  player3.push_back(Card(Diamond, Two));
  player3.push_back(Card(Heart, Jack));
  player3.push_back(Card(Heart, Queen));
  player4.push_back(Card(Heart, Six));
  player4.push_back(Card(Heart, Six));
  player4.push_back(Card(Heart, Eight));
  player4.push_back(Card(Heart, Eight));
  assert(game.Winner(1, player1, player2, player3, player4) == 0);
  cout << "------ Compare Test 5 Passed ------" << endl;


  // Setup GameInfo
  GameInfo::keyRank = Two;
  GameInfo::keySuit = Joker;
  GameInfo::lordID = 0;

  // Test 6
  player1.clear();
  player2.clear();
  player3.clear();
  player4.clear();
  player1.push_back(Card(Heart, Two));
  player1.push_back(Card(Heart, Two));
  GameInfo::format = player1;
  GameInfo::currentSuit = Heart;
  player2.push_back(Card(Spade, Two));
  player2.push_back(Card(Spade, Two));
  player3.push_back(Card(Diamond, Four));
  player3.push_back(Card(Diamond, Jack));
  player4.push_back(Card(Spade, Jack));
  player4.push_back(Card(Spade, Two));

  assert(game.Winner(1, player1, player2, player3, player4) == 0);
  cout << "------ Compare Test 6 Passed ------" << endl;

  // Test 7
  player1.clear();
  player2.clear();
  player3.clear();
  player4.clear();
  player1.push_back(Card(Heart, Two));
  player1.push_back(Card(Heart, Two));
  player1.push_back(Card(Joker, High));
  GameInfo::format = player1;
  GameInfo::currentSuit = Heart;
  player2.push_back(Card(Joker, Low));
  player2.push_back(Card(Joker, Low));
  player2.push_back(Card(Spade, Two));
  player3.push_back(Card(Diamond, Four));
  player3.push_back(Card(Diamond, Jack));
  player3.push_back(Card(Diamond, Three));
  player4.push_back(Card(Spade, Two));
  player4.push_back(Card(Spade, Two));
  player4.push_back(Card(Spade, Jack));

  assert(game.Winner(1, player1, player2, player3, player4) == 1);
  assert(game.Winner(1, player1, player3, player2, player4) == 2);
  assert(game.Winner(1, player1, player4, player3, player2) == 3);
  cout << "------ Compare Test 7 Passed ------" << endl;

  return 0;
}
