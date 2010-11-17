/* 
 * ctm-cvb
 * 
 * Inference Engine
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

#include "InferenceEngine.h"

#define BUF_SIZE 1024

namespace ctm
{
    InferenceOptions InferenceOptions::parse( string filename )
    {
        InferenceOptions options;

        fstream file( filename.c_str(), fstream::in );
        char buf_[ BUF_SIZE ];

        // Read key-value pairs from the file
        while( !file.eof() )
        {
            file.getline( buf_, BUF_SIZE );
            string buf( buf_ );

            int idx = buf.find(' ');
            string key = buf.substr( 0, idx );
            string value = buf.substr( idx+1 );

            // Try to insert the key
            if( key == "em_max_iter" )
            {
                options.em_max_iter = strtof( value.c_str(), NULL );
            }
            else if( key == "var_max_iter" )
            {
                options.var_max_iter = strtof( value.c_str(), NULL );
            }
            else if( key == "cg_max_iter" )
            {
                options.cg_max_iter = strtof( value.c_str(), NULL );
            }
            else if( key == "em_convergence" )
            {
                options.em_convergence = strtof( value.c_str(), NULL );
            }
            else if( key == "var_convergence" )
            {
                options.var_convergence = strtof( value.c_str(), NULL );
            }
            else if( key == "cg_convergence" )
            {
                options.cg_convergence = strtof( value.c_str(), NULL );
            }
            else if( key == "lag" )
            {
                options.lag = strtof( value.c_str(), NULL );
            }
        }
        return options;
    }
    
    InferenceEngine::InferenceEngine( InferenceOptions& options )
        : options( options)
    {
    }

    void InferenceEngine::train( Corpus& data )
    {
        int i;
        double log_likelihood;

        i = 0;
        do
        {
            g_Log->info( "EM Iteration %d", i );

            // Estimate parameters 
            log_likelihood = infer( data );

            // Estimate model
            estimate( data );
        } while( ( options.em_max_iter < ++i ) && 
                ( log_likelihood < options.em_convergence ) );
    }
};

