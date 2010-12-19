#
# LG-LDA
# Using CVB
# Computing likelihood
#

# Compute the log-likelihood of the model per document
function lhood = doc_likelihood( N_k, K, M, Si, B, lambda, nu, phi, EN_j, VN_j, EN_jk, VN_jk )
    V = length( N_k );
    # Mean \alpha parameters
    A = exp( lambda + 0.5*nu )';
    # Variance \alpha parameters 2l + 2s - 2l + s
    VA = (exp( 2*lambda + nu ) .* ( exp( nu ) - 1 ))';

    lhood = 0;

    Si;

    # - 0.5 log(|2 \pi S|) - 0.5 \sum_j nu_j inv(S)_jj - 0.5 \sum_j,j' (l-M) inv(S)_jj (l - M) 
    lhood += - 0.5 * log( det( Si ./ (2*pi) ) ) - 0.5 * nu * diag(Si) - 0.5 * (lambda - M) * Si * (lambda - M)';

    # From alpha
    # logGamma( \sum A) - logGamma( \sum A + EN ) + \sum logGamma( A + EN ) - logGamma( A )  
    lhood += lgamma( sum( A ) ) - lgamma( sum( A + EN_j ) ) + sum( lgamma( A + EN_j ) - lgamma( A ) );
    # 2nd-order Corrections
    lhood += - 0.5 * sum( VN_j ) * psi_n(1, sum(  A + EN_j ) ) + 0.5 * sum( VN_j .* psi_n(1, A + EN_j ) );

    # Bound corrections : TODO
#    lhood += - 0.5 * ( sum(VA) * ( 1 / (2 * sum(A)^2) + 1 / sum( A + EN_j ) ) ) - 0.5 * sum( VA .* ( 1 ./ (2 * ( A + EN_j ).^2 ) + 1 ./ A ) );
#    # 2nd-order
#    lhood += - 0.5 * ( sum(VA) * ( sum(VN_j) ./ ( sum( A + EN_j ).^3 ) ) ) - 0.5 * sum( VA .* VN_j .* 3 ./ (2 * ( A + EN_j ) .^4 ) );
     
    # From Beta
    # \sum_j logGamma( \sum B) - logGamma( \sum B + EN ) + \sum logGamma( B + EN ) - logGamma( B )  
    lhood += sum( lgamma( sum( B, 2 ) ) - lgamma( sum( B + EN_jk, 2 ) ) + sum( lgamma( B + EN_jk ) - lgamma( B ), 2 ), 1 );
    # 2nd-order Corrections
    lhood += - 0.5 * sum( sum( VN_jk, 2 ) .* psi_n(1, sum( B + EN_jk, 2 ) ), 1 ) + 0.5 * sum( sum( VN_jk .* psi_n(1, B + EN_jk ) ) );

    # From lambda, nu
    lhood += 0.5 * sum( log( 2 * pi * nu ) ) + 0.5 * K;

    # From phi
    lhood += -sum( sum ( N_k .* phi .* log( phi ), 1 ), 2 );
end;

# Compute the log-likelihood of the model
function lhood = likelihood( C, K, M, Si, B, EN_ij, VN_ij, EN_jk, VN_jk, Lambda, Nu, phi )
    [D,V] = size(C);
    # TODO: Worry about phi 

    # Compute likelihood scores for each document
    lhood = 0;
    for i = [1:D];
        lhood += doc_likelihood( C(i,:), K, M, Si, B, EN_ij(i,:), VN_ij(i,:), EN_jk, VN_jk, Lambda(i), Nu(i), phi{i} );
    end;
end;

