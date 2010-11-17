/* 
 * ctm-cvb
 * 
 * InferenceEngine
 */

#ifndef INFERENCE_ENGINE_H
  #define INFERENCE_ENGINE_H

#include "ctm.h"
#include "ctm-data.h"

namespace ctm 
{
    struct InferenceOptions
    {
        int em_max_iter;
        int var_max_iter;
        int cg_max_iter;

        double em_convergence;
        double var_convergence;
        double cg_convergence;

        int cov_estimate;
        int lag;

        static InferenceOptions parse( string filename );
    };

    class InferenceEngine
    {
        public:
            InferenceEngine( InferenceOptions& options );

            // Load/Store in a file
            virtual void init( string filename ) = 0;
            virtual void save( string filename ) = 0;

            // Parse a single file
            
            // Returns likelihood
            virtual double infer( Corpus& data ) = 0;
            virtual void estimate( Corpus& data ) = 0;

            // EM until change < eps
            virtual void train( Corpus& data );

        protected:
            InferenceOptions options;
    };
};

#endif // INFERENCE_ENGINE_H
