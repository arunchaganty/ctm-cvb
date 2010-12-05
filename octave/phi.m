# LG-LDA

function phi = init_phi_unif( K, V )
    phi = (1/K) * ones( K, V ); # 1/K
end;

function [EN_ij, VN_ij] = init_N_ij( N_k, K )
    EN_ij = repmat( N_k, 1, K ) .* (1/K);
    VN_ij = repmat( N_k, K, 1 ) .* ((1/K) * (1 - 1/K));
end;

function [phi, EN_j, VN_j, lhood] = opt_phi_doc(N_k, K, M, S, B, EN_jk, VN_jk, lambda, nu, bound, max_iter )
    V = length( N_k );
    # Adjusted for use
    N_k = repmat( N_k, K, 1 );
    A = exp( lambda + 0.5*nu )';
    A = repmat( A, 1, V );

    # Initialise
    phi = init_phi_unif( K, V );
    [EN_ij, VN_ij] = init_N_ij( N_k, K );

    lhood = 1; # Set to 1 to prevent 1/0 condition
    lhood_ = 1;
    iter = 0;
    do 
        phi_E = N_k .* phi;
        phi_V = N_k .* phi .* ( 1 - phi );
        EN_j = sum( phi_E, 2 );
        VN_j = sum( phi_V, 2 );
        EN_j_ = repmat( EN_j, 1, V ); # Repeated for later convenience
        VN_j_ = repmat( VN_j, 1, V );

        # Update phi
        log_phi = zeros( K, V );

        X = repmat( sum( A + EN_j_ ), K, 1 ) - phi_E + (N_k - 1)/2;
        Y = A + EN_j_ - phi_E + (N_k - 1)/2;
        log_phi += -log( X ) + ( repmat( sum( VN_j_ ), K, 1 ) - phi_V ) ./ ( 2 * X.^2 );
        log_phi += log( Y ) - ( VN_j_ - phi_V ) ./ ( 2 * Y.^2 );

        X = repmat( sum( B + EN_jk ), K, 1 ) - phi_E + (N_k - 1)/2;
        Y = B + EN_jk - phi_E + (N_k - 1)/2;
        log_phi += -log( X ) + ( repmat( sum( VN_jk ), K, 1 ) - phi_V ) ./ ( 2 * X.^2 );
        log_phi += log( Y ) - ( VN_jk - phi_V ) ./ ( 2 * Y.^2 );

        # Normalise
        log_norm = repmat( logsum( log_phi, 1 ), K, 1 );
        phi  = exp( log_phi - log_norm );
        
        lhood = doc_likelihood( N_k, K, M, S, B, lambda, nu, phi, EN_j, VN_j, EN_jk, VN_jk );

        iter++;
    until( abs(1 - lhood_/lhood) < bound || iter > max_iter );

end;

