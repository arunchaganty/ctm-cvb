#
# LG-LDA
# Using CVB
# The expectation step
#
source "likelihood.m"
source "phi.m"
source "lambda.m"
source "nu.m"

function [lambda, nu] = init_var_unif( K )
    lambda = 10.0 * ones(1, K); # Used in Blei's code
    nu = 1 * ones(1, K);        # Making it up here
end;

function [EN_jk, VN_jk] = init_N_jk( C, K )
    N_k = sum(C, 1);
    EN_jk = repmat( N_k, K, 1 ) .* (1/K);
    VN_jk = repmat( N_k, K, 1 ) .* (1/K) * (1 - 1/K);
end;

function [phi, lambda, nu, lhood] = opt_doc(N_k, K, M, S, B, EN_jk, VN_jk, bound, max_iter )
    V = length( N_k );

    [lambda, nu] = init_var_unif( K );

    lhood = 1; # Set to 1 to prevent 1/0 condition
    lhood_ = 1;
    iter = 0;

    [phi, EN_j, VN_j, lhood] = opt_phi_doc(N_k, K, M, S, B, EN_jk, VN_jk, lambda, nu, bound, max_iter );
    do 
        lhood_ = lhood;

        lambda = opt_lambda_doc( N_k, K, M, S, B, EN_jk, VN_jk, lambda, nu, EN_j, VN_j, bound, max_iter );
        nu  = opt_nu_doc( N_k, K, M, S, B, EN_jk, VN_jk, lambda, nu, EN_j, VN_j, bound, max_iter );
        [phi, EN_j, VN_j, lhood] = opt_phi_doc(N_k, K, M, S, B, EN_jk, VN_jk, lambda, nu, bound, max_iter );

        printf( "E_doc(%d) = %e\n", iter, lhood );
        fflush(1);

        iter++;
    until( abs(1 - lhood_/lhood) < bound || iter > max_iter );

end;

function [lhood, Lambda, Nu, EN_jk, VN_jk] = expectation( C, K, M, S, B, bound, max_iter )
    [D,V] = size( C );

    [EN_jk_, VN_jk_] = init_N_jk( C, K ); 
    # Store sufficient stats for the maximisation step
    Lambda = zeros( D, K );
    Nu = zeros( D, K );

    lhood = 1;
    lhood_ = 1;
    iter = 0;
    do
        lhood_ = lhood;
        lhood = 0;

        # Update EN_jk
        EN_jk = EN_jk_; VN_jk = VN_jk_;
        EN_jk_(:) = 0; VN_jk_(:) = 0;

        # Inference for every document
        for i = [1:D]
            N_k = C(i,:);
            [phi, lambda, nu, doc_lhood] = opt_doc( N_k, K, M, S, B, EN_jk, VN_jk, bound, max_iter );

            lhood += doc_lhood;
            EN_jk_ += repmat( N_k, K, 1 ) .* phi;
            VN_jk_ += repmat( N_k, K, 1 ) .* phi .* ( 1 - phi );
            Lambda(i,:) = lambda;
            Nu(i,:) = nu;
        end;

        printf( "E(%d) = %e\n", iter, lhood );
        fflush(1);

        iter++;
    until( abs(1 - lhood_/lhood) < bound || iter > max_iter );
end;

