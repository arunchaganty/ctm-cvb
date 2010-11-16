/* 
 * ctm-cvb
 * 
 * Collapsed Variational Bayes Inference Engine
 */

#include <iostream>
#include <cstdlib>
#include <cstring>
#include <cstdio>
using namespace std;

#include "ctm.h"
#include "util.h"
#include "ctm-data.h"

#include "CollapsedBayesEngine.h"

namespace ctm
{
    CollapsedBayesEngine::CollapsedBayesEngine( InferenceOptions options )
        : InferenceEngine( options )
    {
    }

    void CollapsedBayesEngine::init( string filename ) {}
    void CollapsedBayesEngine::save( string filename ) {}

    double CollapsedBayesEngine::infer( Corpus data ) { return 0.0; }
    void CollapsedBayesEngine::estimate( Corpus data ) { }
};

