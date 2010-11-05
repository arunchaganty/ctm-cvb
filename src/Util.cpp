/* 
 * ctm-cvb
 * 
 * General Utilities
 */

#include "Util.h"
#include <sys/stat.h>

namespace ctm 
{
  bool fileExists( string filename )
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
      
};

