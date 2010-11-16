/* 
 * ctm-cvb
 * 
 * Test: Reading corpora
 *
 */

#include <cstdio>
#include <cstdlib>
#include <cassert>
#include <cstring>
#include <sys/stat.h>

#include <string>
using namespace std;

#include "ctm-data.h"
#include "util.h"
using namespace ctm;

#define TEST_DATA "data/corpus.dat"
#define TMP_DATA "tmp.dat"

int main()
{
    Corpus corpus = Corpus::construct( TEST_DATA );

    corpus.write( TMP_DATA );

    // Assert files are equal
    assert( file_equal( TEST_DATA, TMP_DATA ) );

    return 0;
}

