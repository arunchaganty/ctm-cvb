#
# Correlated Topic Model
# Using CVB
#

# Initialise the model parameters with a uniform prior
function [M, S, B, G] = init_model_params( C, K )
    [D, V] = size( C );

    # Uniform distribution for topics
    M = zeros( 1, K ); #ones( 1, K ) ./ ( K );

    # No correlation 
    # S_{jj'} = 1 [ Satisifies positive-semidefiniteness ]
    S = eye( K, K );

    # Random Initialise
    B = 1 + rand( K, V ) + 0.01; # (let's not have zeros...)

    # G = \sum_j exp( M_j + 1/2 S_jj )
    G = K * exp( 1/2 );
end;

# @args C - Corpus
# @args K - No. of topics
# @args bounds - [ lhood_bound, var_bound, cov_bound ]
# @args max_iter - [ lhood_max_iter, var_max_iter, cov_max_iter ]
function [M,S,B,G] = ctm( C, K, bounds, max_iter )
    # Initialise model parameters \mu, \Sigma, \Beta, \gamma
    [M, S, B, G] = init_model_params( C, K );

    lhood_bound = bounds(1);
    var_bound = bounds(2);
    cov_bound = bounds(3);

    lhood_max_iter = max_iter(1);
    var_max_iter = max_iter(2);
    cov_max_iter = max_iter(3);

    lhood = 0;
    iter = 0;
    [lhood, EN_ij, EN_jk, VN_ij, VN_jk] = expectation( C, K, M, S, B, G, var_bound, var_max_iter );
    do
#        EN_ij, EN_jk, VN_ij, VN_jk
#        input "Continue";

        lhood_ = lhood;
        [M, S, B, G] = mlmaximisation( C, K, M, S, B, G, EN_ij, EN_jk, VN_ij, VN_jk, cov_bound, cov_max_iter );

#        M, S, B, G
#        input "Continue";

        [lhood, EN_ij, EN_jk, VN_ij, VN_jk] = expectation( C, K, M, S, B, G, var_bound, var_max_iter );

        fflush(1);
        iter++;
    until ( abs(1 - lhood_/lhood) < lhood_bound || iter > lhood_max_iter );
    M, S, B, G
end;

