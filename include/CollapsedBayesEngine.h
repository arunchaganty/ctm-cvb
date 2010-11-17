/* 
 * ctm-cvb
 * 
 * CollapsedBayesEngine
 */

#ifndef COLLAPSED_BAYES_ENGINE_H
  #define COLLAPSED_BAYES_ENGINE_H

#include "InferenceEngine.h"

#include <gsl/gsl_vector.h>
#include <gsl/gsl_matrix.h>

namespace ctm 
{
    class CollapsedBayesEngine : public InferenceEngine
    {
        /***
         * Model hyperparameters learnt by maximisation
         */
        struct Model
        {
            gsl_vector* mu;
            gsl_matrix* cov;
            gsl_matrix* inv_cov;

            gsl_matrix* log_beta;

            double gamma;
            double log_det_inv_cov;

            Model( int D, int K, int V );
            ~Model();
        };

        /***
         * Data collected in the 'expectation' step, to be used in the
         * maximisation step.
         */
        struct CollectedData
        {
            // Expected counts
            gsl_matrix* n_ij;
            gsl_matrix* n_jk;
            double ndata;

            CollectedData( int D, int K, int V );
            ~CollectedData();
        };
            
        /***
         * Variational parameters to be optimised in the expectation step
         */
        struct Parameters
        {
            // Stores \phi_{*kj}
            gsl_matrix* phi;
            gsl_matrix* log_phi;
            
            // Likelihood saved for optimisation purposes
            double lhood;

            Parameters( int K, int V );
            ~Parameters();
        };

    public:
        CollapsedBayesEngine(InferenceOptions& options);

        // Load/Store in a file
        virtual void init( string filename );
        virtual void save( string filename );

        // Parse a single file
        virtual double infer( Corpus& data );
        virtual double infer( Corpus& data, CollectedData* cd );
        virtual void estimate( Corpus& data );

    protected:
        Model* model;
    };
};

#endif // COLLAPSED_BAYES_ENGINE_H
