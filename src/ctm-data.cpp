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

#include <iostream>
#include <fstream>
using namespace std;

#include "ctm-data.h"
#include "util.h"

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
      fscanf( file, "\n" );

      corpus.docs.push_back( doc );
    }
    corpus.D = corpus.docs.size();
    corpus.V = maxTerm + 1;

    return corpus;
  }

  void Corpus::write( string filename )
  {
    // Open file
    fstream file ( filename.c_str(), fstream::out );

    // For every document, a line
    for( vector<Document>::iterator doc = docs.begin(); doc != docs.end(); doc++ )
    {
        file << doc->terms.size();
        for( unsigned int i = 0; i < doc->terms.size(); i++ )
        {
            // M term1:count1 ... termM:countM
            file << " " << doc->terms[ i ] << ":" << doc->counts[ i ];
        }
        file << endl;
    }

    file.close();

  }

};

