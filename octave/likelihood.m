#
# Correlated Topic Model
# Using CVB
# Computing likelihood
#

# Compute the log-likelihood of the model
function lhood = likelihood( C, K, M, S, B, G, EN_ij, VN_ij, EN_jk, VN_jk )
    lhood = 0;

    N = sum( sum( C ) );

    # \sum_i N_i log(G) + EN_ij S_jj' EN_ij' + S_jj VN_ij + EN_ij M_j 
    lhood +=  N * log( G ) + sum(sum(EN_ij' .* (S * EN_ij'))) + sum(VN_ij * diag(S)) + sum( EN_ij * M' );
    # \sum_j 1/2( log( \sum_k B_jk + EN_jk ) - log( \sum_k B_jk ) - \sum_j \sum_k 1/2( log( B_jk + EN_jk ) - log( B_jk )  
    B_ = sum( B, 2 );
    B_jk = B + EN_jk;
    B_j = sum( B_jk, 2 );
    lhood += 0.5 * sum( log( B_j ) - log( B_ ) - sum( log( B_jk ) - log( B ), 2 ) );
    # - \sum_j 1/2( \sum_k VN_jk ) ( 1 / ( sum_k B_jk + EN_jk ) + 1 / 2( sum_k  B_jk + EN_jk )^2
    lhood -= 0.5 * sum( sum( VN_jk, 2 )' .* ( B_j.^(-1) + (B_j.^(-2))./2 )' );
    # + \sum_j 1/2( VN_jk ) ( 1 / ( B_jk + EN_jk ) + 1 / 2( B_jk + EN_jk )^2
    lhood += 0.5 * sum(  sum( VN_jk' .* ( B_jk.^(-1) + (B_jk.^(-2))./2 )' ) );
end;

