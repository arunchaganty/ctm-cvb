#
# Correlated Topic Model
# Using CVB
# The maximisation step (using ML estimates)
#

# Compute "better" model parameters
function [M, S, B, G] = mlmaximisation( C, K, M, S, B, G, EN_ij, EN_jk, VN_ij, VN_jk, bound, max_iter );
    iter = 0;

    [D,V] = size( C );
    N = sum( sum( C ) );

    # Update B
    # B_jk = EN_jk
    B = EN_jk + 1;

    lhood = 0;
    iter = 0;
    do
        lhood_ = lhood;
        # Update M
        # M_j = log(G) - log(N_i) + log( sum_i EN_ij ) 
        M_ij = log( EN_ij ) - repmat( log( sum( C, 2 ) ), 1, K );
        G = sum( sum( M_ij, 2 ) ) ./ D;
        M_ij = M_ij - repmat( sum( M_ij, 2 ), 1, K );
        M = sum( M_ij ) ./ D;

        # Update S 
        S_ij = (M_ij - repmat(M, D, 1));
        S = zeros( K, K );
        for i = [1:D]
            S += diag(VN_ij(i,:)) + S_ij(i,:) * S_ij(i,:)';
        end;
        S = S ./ D;

        # Update G 
        # G = sum( exp(M + 0.5 * diag(S)') );
        lhood = likelihood( C, K, M, S, B, G, EN_ij, VN_ij, EN_jk, VN_jk );
        M, S, G
        iter
        lhood
        input "[Max] Continue";
    until ( abs(1 - lhood_/lhood) > bound && iter > max_iter );
end;

