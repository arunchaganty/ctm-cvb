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
        struct Model
        {
            struct SufficientStatistic
            {
                gsl_matrix* cov_ss;
                gsl_matrix* mu_ss;
                gsl_matrix* beta_ss;
                double ndata;
            };

            gsl_matrix* log_beta;
            gsl_matrix* mu;
            gsl_matrix* inv_cov;
            gsl_matrix* cov;
            double log_det_inv_cov;
        };
            
        struct Parameters
        {
            gsl_matrix* phi;
            gsl_matrix* log_phi;
            double gamma;
            double lhood;
        };

    public:
        CollapsedBayesEngine(InferenceOptions options);

        // Load/Store in a file
        virtual void init( string filename );
        virtual void save( string filename );

        // Parse a single file
        virtual double infer( Corpus data );
        virtual void estimate( Corpus data );

    protected:
        Model model;
        Model::SufficientStatistic ss;
        InferenceOptions options;
    };
};

#endif // COLLAPSED_BAYES_ENGINE_H
