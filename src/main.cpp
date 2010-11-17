/* 
 * ctm-cvb
 * 
 * Program Entry Point
 */

#include <iostream>
#include <cstdlib>
#include <cstring>
#include <cstdio>
using namespace std;

#include "ctm.h"
#include "util.h"
#include "ctm-data.h"
#include "global.h"

#include "CollapsedBayesEngine.h"

using namespace ctm;

extern int optind, opterr;

void print_help( ostream& stream, int argc, char* argv[] )
{
  stream << "Correlated Topic Model - Collapsed Variational Bayes" << endl;
  stream << "----------------------------------------------------" << endl;
  stream << "ctm est <settings-file> <corpus-file> <output-dir>" << endl;
  stream << "ctm inf <settings-file> <corpus-file> <model-dir> " << endl;
  stream << "ctm [-h]" << endl;
  stream << "----------------------------------------------------" << endl;
}

/**
* ctm is invoked:
* ctm est <settings-file> <corpus-file> <output-dir>  
* ctm inf <settings-file> <corpus-file> <model-dir> 
* ctm [-h]
*
*/
int main( int argc, char* argv[] )
{
  // Parse command line arguments
  g_Log = &Log::create( "log.txt", Log::INFO );
  
  if( argc == 1 || ( argc == 2 && strcmp( argv[1], "-h" ) == 0 ) )
  {
    print_help( cout, argc, argv );
  }
  else if( argc == 5 && strcmp( argv[1], "est" ) == 0 )
  {
    string settings_path = argv[2];
    string corpus_path = argv[3];
    string output_dir = argv[4];

    if( !file_exists( corpus_path ) )
    {
      cerr << "Path does not exist at: " << corpus_path << endl;
    }
    if( !file_exists( settings_path ) )
    {
      cerr << "Path does not exist at: " << settings_path << endl;
    }

    // Load corpus
    Corpus corpus = Corpus::construct( corpus_path );
    InferenceOptions options = InferenceOptions::parse( settings_path );
    CollapsedBayesEngine engine( options );

    engine.train( corpus );
  }
  else if( argc == 5 && strcmp( argv[1], "inf" ) == 0 )
  {
    string settings_path = argv[2];
    string corpus_path = argv[3];
    string model_dir = argv[4];

    if( !file_exists( corpus_path ) )
    {
      cerr << "Path does not exist at: " << corpus_path << endl;
    }
    if( !file_exists( settings_path ) )
    {
      cerr << "Path does not exist at: " << settings_path << endl;
    }

    Corpus corpus = Corpus::construct( corpus_path );
    InferenceOptions options = InferenceOptions::parse( settings_path );
    CollapsedBayesEngine engine( options );

    engine.infer( corpus, NULL );
  }
  else
  {
    print_help( cerr, argc, argv );
    cerr << "Error parsing arguments" << endl;
    exit( EXIT_FAILURE );
  }

  exit( EXIT_SUCCESS );
}


