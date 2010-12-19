#
# Correlated Topic Model
# Using CVB
#

source "expectation.m"
source "mlmaximisation.m"

# Initialise the model parameters with a uniform prior
function [M, S, B] = init_model_params( C, K )
    [D, V] = size( C );

    # Uniform distribution for topics
    M = zeros( 1, K ); #ones( 1, K ) ./ ( K );

    # No correlation 
    # S_{jj'} = 1 [ Satisifies positive-semidefiniteness ]
    S = eye( K, K );

    # Random Initialise - 
    B = 1 + (V/K) * rand( K, V ) + 0.01; # (let's not have zeros...)
end;

# @args C - Corpus
# @args K - No. of topics
# @args bounds - [ lhood_bound, var_bound, cov_bound ]
# @args max_iter - [ lhood_max_iter, var_max_iter, cov_max_iter ]
function [M,S,B] = ctm( C, K, bounds, max_iter )
    # Initialise model parameters \mu, \Sigma, \Beta, \gamma
    [M, S, B] = init_model_params( C, K );
    Si = inv( S );

    lhood_bound = bounds(1);
    var_bound = bounds(2);

    lhood_max_iter = max_iter(1);
    var_max_iter = max_iter(2);

    lhood = 0;
    iter = 0;
    [lhood, Lambda, Nu, EN_jk, VN_jk] = expectation( C, K, M, Si, B, var_bound, var_max_iter );
    do
#        Lambda, Nu, EN_jk, VN_jk
#        input "Continue";

        lhood_ = lhood;
        [M, S, B] = mlmaximisation( C, K, M, Si, B, Lambda, Nu, EN_jk, VN_jk );
        Si = inv( S );
#        M, S, B
#        input "Continue";

        [lhood, Lambda, Nu, EN_jk, VN_jk] = expectation( C, K, M, Si, B, var_bound, var_max_iter );

        fflush(1);
        iter++;
    until ( abs(1 - lhood_/lhood) < lhood_bound || iter > lhood_max_iter );
    M, S, B
end;
