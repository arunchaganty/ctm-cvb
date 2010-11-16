/* 
 * ctm-cvb
 * 
 * General Utilities
 */

#include <cstdio>
#include <cstdlib>
#include <cassert>
#include <cstring>
#include <cstdarg>
#include <sys/stat.h>

#include <iostream>
using namespace std;

#include "util.h"

#define BUF_SIZE 1024
#define STR_BUF_SIZE 1024

Log* g_Log = NULL;

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

// FP Comparison
bool double_equal( double v1, double v2 )
{
    return fabs( v2 - v1 ) <= fabs( v1 ) * EPSILON;
}

bool float_equal( float v1, float v2 )
{
    return fabs( v2 - v1 ) <= fabs( v1 ) * EPSILON;
}


// Log Implementation

Log::Log( ostream& stream, Level level )
    : stream( &stream ), level( level )
{
}

Log& Log::create( string filename, Level level )
{
    ostream* stream = new fstream( filename.c_str(), fstream::out );
    Log* log = new Log( *stream, level );

    return *log;
}

Log& Log::create( ostream& stream, Level level )
{
    ostream* stream_ = &stream;
    Log* log = new Log( *stream_, level );

    return *log;
}

Log::Level Log::getLevel() 
{
    return level;
}

void Log::setLevel( Log::Level level ) 
{
    this->level = level;
}

char str_buf[STR_BUF_SIZE];
void Log::info( const char* msg, ... )
{
    if( level <= INFO )
    {
        va_list vl;
        va_start( vl, msg );
        vsnprintf( str_buf, STR_BUF_SIZE * sizeof( char ), msg, vl );
        (*stream) << "[INFO]: " << string( str_buf ) << endl;
    }
}

void Log::debug( const char* msg, ... )
{
    if( level <= DEBUG )
    {
        va_list vl;
        va_start( vl, msg );
        vsnprintf( str_buf, STR_BUF_SIZE * sizeof( char ), msg, vl );
        (*stream) << "[DEBUG]: " << str_buf << endl;
    }
}

void Log::error( const char* msg, ... )
{
    if( level <= ERROR )
    {
        va_list vl;
        va_start( vl, msg );
        vsnprintf( str_buf, STR_BUF_SIZE * sizeof( char ), msg, vl );
        (*stream) << "[ERROR]: " << str_buf << endl;
    }
}

