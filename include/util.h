/* 
 * ctm-cvb
 * 
 * General Utilities
 */

#ifndef UTIL_H
  #define UTIL_H

#include <string>
#include <iostream>
#include <fstream>
#include <cmath>

#define EPSILON 1e-6;

using namespace std;

bool file_exists( string filename );
bool file_equal( string filename1, string filename2 );

bool double_equal( double v1, double v2 );
bool float_equal( float v1, float v2 );

class Log
{
    public:
        enum Level
        {
            DEBUG = 0,
            INFO = 1,
            ERROR = 2
        };

        static Log& create( string filename, Level level );
        static Log& create( ostream& stream, Level level );

        void setLevel( Level level ); 
        Level getLevel(); 

        void info( const char* msg, ...);
        void debug( const char* msg, ...);
        void error( const char* msg, ...);

    protected:
        Log( ostream& stream, Level level );
        ostream* stream;
        Level level;
};

#endif // UTIL_H

