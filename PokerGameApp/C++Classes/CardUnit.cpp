//
//  CardUnit.cpp
//  PokerGameApp
//
//  Created by Cui Jing on 12/25/15.
//  Copyright © 2015 Jingplusplus. All rights reserved.
//

#include "CardUnit.hpp"
#include "Constants.hpp"

CardUnit::CardUnit(const CardUnit& cu) {
    m_type = cu.m_type;
    m_head = cu.m_head;
}

bool CardUnit::compare(const CardUnit& cu1, const CardUnit& cu2) {
    if (cu1.m_type > cu2.m_type) return true;
    if (cu1.m_type < cu2.m_type) return false;
    
    if (cu1.m_head > cu2.m_head) return true;
    
    return false;
}