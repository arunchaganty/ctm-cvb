#
# Correlated Topic Model
# Using CVB
# Computing likelihood
#

# Compute document norm
function lhood = doc_norm( N, K, M, S )
    # \sum_n nCk( N - n + K - 2, K - 2 ) (n)(n+1)^2/6 \sum( \mS ) +\sum_n nCk( N - n + K - 1, K - 1 ) (n)(n+1)/2 \sum( \mU ) 
    n = [1:N];
    Sk = sum( arrayfun( @(x) nchoosek( N - x + K - 2, K - 2) * (x) * (x+1) * (x+1), n ) ) / 6 ;
    Mk = sum( arrayfun( @(x) nchoosek( N - x + K - 1, K - 1) * (x) * (x+1) , n ) ) / 2;

    lhood = ( sum( sum( S ) ) * Sk + sum( M ) * Mk );
    lhood
end;

# Compute the log-likelihood of the model
function lhood = likelihood( C, K, M, S, B, G, EN_ij, VN_ij, EN_jk, VN_jk, phi )
    lhood = 0;

    [D,V] = size(C);

    # \sum_i - (N_i+K) log(G) + EN_ij S_jj' EN_ij' + S_jj VN_ij + EN_ij M_j 
    sum(sum(0.5 .* EN_ij' .* (S * EN_ij')) + 0.5 .* (VN_ij * diag(S))') + sum( EN_ij * M' );
    lhood += sum(sum(0.5 .* EN_ij' .* (S * EN_ij')) + 0.5 .* (VN_ij * diag(S))') + sum( EN_ij * M' );
    # \sum_j 1/2( log( \sum_k B_jk + EN_jk ) - log( \sum_k B_jk ) - \sum_j \sum_k 1/2( log( B_jk + EN_jk ) - log( B_jk )  
    B_ = sum( B, 2 );
    B_jk = B + EN_jk;
    B_j = sum( B_jk, 2 );
    lhood += 0.5 * sum( log( B_j ) - log( B_ ) - sum( log( B_jk ) - log( B ), 2 ) );
    # - \sum_j 1/2( \sum_k VN_jk ) ( 1 / ( sum_k B_jk + EN_jk ) + 1 / 2( sum_k  B_jk + EN_jk )^2
    lhood += -0.5 * sum( sum( VN_jk, 2 )' .* ( B_j.^(-1) + (B_j.^(-2))./2 )' );
    # + \sum_j 1/2( VN_jk ) ( 1 / ( B_jk + EN_jk ) + 1 / 2( B_jk + EN_jk )^2
    lhood += 0.5 * sum(  sum( VN_jk' .* ( B_jk.^(-1) + (B_jk.^(-2))./2 )' ) );

    # Denominator
    # \sum_n nCk( N - n + K - 2, K - 2 ) (n)(n+1)^2/6 \sum( \mS ) +\sum_n nCk( N - n + K - 1, K - 1 ) (n)(n+1)/2 \sum( \mU ) 
    N = sum( C, 2 );
    norm = - sum( arrayfun( @(n) doc_norm( n, K, M, S ), N ) )
    lhood += norm;

    # - n_ik * E_q( log( \phi_ijk ) )
    for j = [1:K]
        lhood += -sum( sum( C .* phi{j} .* safe_log(phi{j}) ) );
    end;
end;

