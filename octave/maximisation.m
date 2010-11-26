#
# Correlated Topic Model
# Using CVB
# The maximisation step
#

global EN;
global VN;
global dS_wts;
global M_opt;
global G_opt;

function [dS] = gradient(S) 
    global dS_wts;
    dS = dS_wts ./ S;
end;

function [ddS] = hessian(S) 
    global dS_wts;
    ddS = - dS_wts ./ (S.^2);
    ddS = diag( ddS );
end;

function [L] = phi(S)
    K = sqrt( length( S ) );
    S = reshape( S, K, K );

    L = sum( sum( (EN' * EN) .* log( S ) ) ) + sum( VN .* diag( 2 * log( S ) ) );
end;

function [r] = CEF( S )
    K = sqrt( length( S ) );
    S = reshape( S, K, K );

    r = sum( M_opt .* diag( S ) ) - G_opt;
    r = diag( repmat( r, K, 1 ) );
    r = r(:);
end;

function [dr] = dCEF( S )
    K = sqrt( length( S ) );
    S = reshape( S, K, K );

    dr = M_opt;
end;

function [r] = CIF( S )
    K = sqrt( length( S ) );
    S = reshape( S, K, K );

    d = diag( S );
    r = sqrt( d * d' ) - S;
    r = r(:);
end;

function [dr] = dCIF( S )
    dr = - ones( K, K ) + diag( ones(K,1) );
end;

# Compute "better" expected topic assignments
function [lhood, M, S, B, G] = maximisation( C, K, M, S, B, G, EN_ij, EN_jk, bound, max_iter );
    global dS_wts;
    lhood = 0;
    iter = 0;

    [D,V] = size( C );
    N = sum( sum( C ) );

    # Update M
    # M_j = log(G) - log(N) + log( sum_i EN_ij ) + S_jj
    M = log( G ) - log( N ) + log( sum( EN_ij ) ) + diag( S );

    # Update B
    # B_jk = EN_jk
    B = EN_jk;

    # Update S 
    # Gradient weights
    dS_wts = 2 * (diag( EN_ij' * EN_ij ) + diag( sum( VN_ij, 1 ) )) ;
    dS_wts = dS_wts(:); 
    EN = EN_ij;
    VN = VN_ij;
    exp_S = exp(S./2);
    M_opt = exp(M);
    G_opt = G; 
    LB = G / sum(M_opt) .* ones(K*K,1);
    UB = REALMAX .* ones(K*K,1);

    [S, obj, info, iter, nf, lambda] = sqp( exp_S, {@phi, @gradient, @hessian}, 
                {CEF, dCEF}, {CIF, dCIF}, LB(:), UB(:), max_iter );
    S = 2 * log(exp_S);

    # Update G 
    G = sum( M + 0.5 * diag(S) );
end;

