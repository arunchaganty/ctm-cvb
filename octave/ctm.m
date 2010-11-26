#
# Correlated Topic Model
# Using CVB
#

# Initialise the model parameters with a uniform prior
function [M, S, B, G] = init_model_params( C, K )
    [D, V] = size( C );

    # Uniform distribution for topics
    M = ones( 1, K ) ./ ( K );

    # Uniform correlation 
    # S_{jj'} = 1 [ Satisifies positive-semidefiniteness ]
    S = ones( K, K );

    B = ones( K, V ); # A pseudo-count of 1 each

    # G = \sum_j exp( M_j + 1/2 S_jj )
    G = K * exp( 1/K + 1/2 );
end;

# @args C - Corpus
# @args K - No. of topics
# @args bounds - [ lhood_bound, var_bound, cov_bound ]
# @args max_iter - [ lhood_max_iter, var_max_iter, cov_max_iter ]
function ctm( C, K, bounds, max_iter )
    # Initialise model parameters \mu, \Sigma, \Beta, \gamma
    [M, S, B, G] = init_model_params( C, K )

    lhood_bound, var_bound, cov_bound = bounds
    lhood_max_iter, var_max_iter, cov_max_iter = max_iter

    lhood = 0;
    iter = 0;
    do
        [N_ij, N_jk] = expectation( C, K, M, S, B, G, var_bound, var_max_iter );
        [lhood, M, S, B, G] = maximisation( C, K, M, S, B, G, N_ij, N_jk, cov_bound, cov_max_iter );
        iter++;
    while (lhood > lhood_bound && iter > lhood_max_iter );
end;

