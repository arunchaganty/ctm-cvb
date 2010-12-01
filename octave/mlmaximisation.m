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
    B = EN_jk + 1 + 1/K; # Small smoothing
    #B = B ./ repmat( sum( B, 2 ), 1, V ) + 1;

    # Update M
    # M_j = log(G) + log( sum_i EN_ij ) - log(N_i)
    M_ij = log(G) + safe_log( EN_ij ) - repmat( log( sum( C, 2 ) ), 1, K );
    M = sum( M_ij ) ./ D;

    # Update S 
    S_ij = (M_ij - repmat(M, D, 1));
    S = zeros( K, K );
    for i = [1:D]
        S += S_ij(i,:)' * S_ij(i,:);
#S += diag(VN_ij(i,:)) + S_ij(i,:)' * S_ij(i,:);
    end;
    S = S ./ D;
    assert( abs(triu(S) - tril(S)') < 0.01 );
    S = (S + S')/2;

    # Update G 
    G = sum( exp(M + 0.5 * diag(S)') );
end;

