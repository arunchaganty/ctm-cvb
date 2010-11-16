/* 
 * ctm-cvb
 * 
 * General Utilities
 */

#ifndef UTIL_H
  #define UTIL_H

#include <string>
#include <fstream>

using namespace std;

bool file_exists( string filename );
bool file_equal( string filename1, string filename2 );

class Log
{
    enum Level
    {
        INFO = 0,
        DEBUG = 1,
        ERROR = 2
    };

    public:
        Log( fstream& stream, Level level );
        ~Log();

        static Log create( string filename, Level level );

        void info( const string& msg );
        void debug( const string& msg );
        void error( const string& msg );

    private:
        fstream& stream;
        Level level;
};

extern Log g_Log;

#endif // UTIL_H
