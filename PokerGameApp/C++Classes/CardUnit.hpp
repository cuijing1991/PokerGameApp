//
//  CardUnit.hpp
//  PokerGameApp
//
//  Created by Cui Jing on 12/25/15.
//  Copyright © 2015 Jingplusplus. All rights reserved.
//

#ifndef CARDUNIT_H
#define CARDUNIT_H

#include "Constants.hpp"

class CardUnit {
public:
  CardUnit(int type, int head): m_type(type), m_head(head){};
    CardUnit(const CardUnit& cu);
    ~CardUnit() {};
    int m_type;
    int m_head;
    static bool compare(const CardUnit& cu1, const CardUnit& cu2);
};

#endif /* CardUnit_hpp */
