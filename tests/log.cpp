/* 
 * ctm-cvb
 * 
 * Test: Log utility
 *
 */

#include <cassert>
#include <iostream>
using namespace std;

#include "util.h"
#include "global.h"

#define VERIFY_DATA "data/log.dat"
#define TMP_DATA "tmp.dat"

int main()
{
    Log& log = Log::create( TMP_DATA, Log::DEBUG );
    g_Log = &log;
    int i = 0;

    g_Log->debug( "%d", i++ );
    g_Log->info( "%d", i++ );
    g_Log->error( "%d", i++ );

    g_Log->setLevel( Log::INFO );
    g_Log->debug( "%d", i++ );
    g_Log->info( "%d", i++ );
    g_Log->error( "%d", i++ );

    g_Log->setLevel( Log::ERROR );
    g_Log->debug( "%d", i++ );
    g_Log->info( "%d", i++ );
    g_Log->error( "%d", i++ );

    assert( file_equal( TMP_DATA, VERIFY_DATA ) );

    return 0;
}

