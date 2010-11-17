/* 
 * ctm-cvb
 * 
 * Collapsed Variational Bayes Inference Engine
 */

#include <iostream>
#include <limits>
#include <cstdlib>
#include <cstring>
#include <cstdio>
using namespace std;

#include "ctm.h"
#include "util.h"
#include "ctm-data.h"

#include "CollapsedBayesEngine.h"

#include <gsl/gsl_vector.h>
#include <gsl/gsl_matrix.h>

namespace ctm
{
    // Model
    CollapsedBayesEngine::Model::Model( int D, int K, int V )
    {
        mu = gsl_vector_alloc( K );
        cov = gsl_matrix_alloc( K, K );
        inv_cov = gsl_matrix_alloc( K, K );

        log_beta = gsl_matrix_alloc( K, V );

        // TODO
        gamma = 1;
        log_det_inv_cov = 0;
    }
    CollapsedBayesEngine::Model::~Model()
    {
        gsl_vector_free( mu );
        gsl_matrix_free( cov );
        gsl_matrix_free( inv_cov );
        gsl_matrix_free( log_beta );
    }
    
    // CollectedData
    CollapsedBayesEngine::CollectedData::CollectedData( int D, int K, int V )
    {
        n_ij = gsl_matrix_alloc( D, K );
        n_jk = gsl_matrix_alloc( K, V );

        ndata = 0;
    }
    CollapsedBayesEngine::CollectedData::~CollectedData()
    {
        gsl_matrix_free( n_ij );
        gsl_matrix_free( n_jk );
    }

    // Parameters
    CollapsedBayesEngine::Parameters::Parameters( int K, int V )
    {
        // Re-used semi-sparse
        phi = gsl_matrix_alloc( K, V );
        log_phi = gsl_matrix_alloc( K, V );

        lhood = 0;
    }

    CollapsedBayesEngine::Parameters::~Parameters()
    {
        gsl_matrix_free( phi );
        gsl_matrix_free( log_phi );
    }

    CollapsedBayesEngine::CollapsedBayesEngine( InferenceOptions& options )
        : InferenceEngine( options ), model( NULL )
    {
    }

    void CollapsedBayesEngine::init( string filename ) {}
    void CollapsedBayesEngine::save( string filename ) {}

    double CollapsedBayesEngine::infer( Corpus& data )
    {
        return infer( data, NULL );
    }

    double CollapsedBayesEngine::infer( Corpus& data, CollectedData* cd ) 
    {
        // With CVB, only the \phi_{inj} have to be updated.
        double lhood = 0;
        double convergence = numeric_limits<double>::infinity();

        do
        {

        } while( convergence > options.var_convergence  );
       

        return lhood;
    }

    void CollapsedBayesEngine::estimate( Corpus& data ) { }
};

