/* test_driver.cpp
 *
 * Test driver for C++ Code
 */
#include <iostream>
#include "test_driver.h"

using std::cout;
using std::endl;

int main() {
  compare_function_test();
  cout << "=== === === compare_function_test passed === === ===" << endl;

  isUniform_function_test();
  cout << "=== === === isUniform_function_test passed === === ===" << endl;

  return 0;
}
