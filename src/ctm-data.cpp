/* 
 * ctm-cvb
 * 
 * Structures pertaining to manipulation of data
 */

#include <cstdio>
#include <vector>
#include <string>
#include <cassert>
#include <cstring>
using namespace std;

#include "ctm-data.h"
#include "Util.h"

#define BUF_SIZE 50
#define MAX(x,y) ( ((x) >= (y)) ? (x) : (y) )

namespace ctm
{

  Corpus Corpus::construct( string filename )
  {
    Corpus corpus;

    assert( file_exists( filename ) );

    // Open file
    FILE* file = fopen( filename.c_str(), "r" ); 

    int maxTerm = 0;

    // For every line, in format:
    // M term1:count1 ... termM:countM
    while( !feof( file ) )
    {
      Document doc;

      int M = 0;
      int length = 0;

      // Get M
      fscanf( file, "%d", &M );
      for( int i = 0; i < M; i++ )
      {
        int vocab, count;
        // term_i, count_i
        fscanf( file, "%d:%d", &vocab, &count );
        doc.terms.push_back( vocab );
        doc.counts.push_back( count );

        maxTerm = MAX( maxTerm, vocab );
        length += count;
      }
      doc.length = length;

      corpus.docs.push_back( doc );
    }
    corpus.termCount = maxTerm + 1;

    return corpus;
  }



};

