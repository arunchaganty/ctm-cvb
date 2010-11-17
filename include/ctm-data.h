/* 
 * ctm-cvb
 * 
 * Structures pertaining to manipulation of data
 */

#ifndef CTM_DATA_H
  #define CTM_DATA_H

#include <string>
#include <vector>
using namespace std;

namespace ctm 
{
  struct Corpus;
  struct Document;

  struct Corpus 
  {
    vector<Document> docs;
    int D;
    int K;
    int V;

    static Corpus construct( string filename );

    void write( string filename );
  };

  struct Document
  {
    vector<int> terms;
    vector<int> counts;
    int length;
  };

};

#endif // CTM_DATA_H
