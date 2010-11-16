/* 
 * ctm-cvb
 * 
 * Test: Parsing settings
 *
 */

#include <cassert>
#include <iostream>
using namespace std;

#include "util.h"
#include "global.h"

#include "InferenceEngine.h"
using namespace ctm;

#define TEST_DATA "data/settings.txt"

int main()
{
    InferenceOptions options = InferenceOptions::parse( TEST_DATA );

    assert( double_equal( options.em_max_iter, 1000 ) );
    assert( double_equal( options.var_max_iter, 20 ) );
    assert( double_equal( options.cg_max_iter, -1 ) );
    assert( double_equal( options.em_convergence, 0.01 ) );
    assert( double_equal( options.var_convergence, 0.001 ) );
    assert( double_equal( options.cg_convergence, 0.001 ) );
    assert( double_equal( options.lag, 10 ) );

    return 0;
}

