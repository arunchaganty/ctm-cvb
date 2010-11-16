/* 
 * ctm-cvb
 * 
 * General Utilities
 */

#include <cstdio>
#include <cstdlib>
#include <cassert>
#include <cstring>
#include <sys/stat.h>

#include "util.h"

#define BUF_SIZE 1024

bool file_exists( string filename )
{
    struct stat st;

    if ( stat( filename.c_str(), &st ) == 0 && S_ISREG( st.st_mode ) ) 
    {
      return true;
    }
    else
    {
      return false;
    }
}

bool file_equal( string filename1, string filename2 )
{
    assert( file_exists( filename1 ) );
    assert( file_exists( filename2 ) );

    // Compare file lengths
    struct stat st1;
    struct stat st2;
    stat( filename1.c_str(), &st1 );
    stat( filename2.c_str(), &st2 );

    if( st1.st_size != st2.st_size ) return false;

    // Open file
    FILE* file1 = fopen( filename1.c_str(), "r" ); 
    FILE* file2 = fopen( filename2.c_str(), "r" ); 

    // Blockwise comparison
    char buf1[ BUF_SIZE ];
    char buf2[ BUF_SIZE ];
    int len;

    while( !feof( file1 ) )
    {
        fread( buf1, sizeof( char ), BUF_SIZE, file1 );
        len = fread( buf2, sizeof( char ), BUF_SIZE, file2 );

        if( memcmp( buf1, buf2, len ) != 0 ) return false;
    }

    return true;
}

