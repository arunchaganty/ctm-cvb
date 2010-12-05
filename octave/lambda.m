# Optimising Lambda

global nu_opt;
global Si_opt;
global EN_j_opt;
global VN_j_opt;

# Optimisation functions for lambda
function lhood = f_lambda( lambda )
    global nu_opt;
    global Si_opt;
    global EN_j_opt;
    global VN_j_opt;

    # Mean \alpha parameters
    A = exp( lambda + 0.5*nu );
    # Variance \alpha parameters 2l + 2s - 2l + s
    VA = exp( 2*lambda + nu ) * ( exp( nu ) - 1 );

    lhood = 0;
    lhood += - 0.5 * (lambda - M) * Si * (lambda - M);
    
    # From alpha
    # logGamma( \sum A) - logGamma( \sum A + EN ) + \sum logGamma( A + EN ) - logGamma( A )  
    lhood += lgamma( sum( A ) ) - lgamma( sum( A + EN_j ) ) + sum( lgamma( A + EN_j ) - lgamma( A ) );
    # 2nd-order Corrections
    lhood += - 0.5 * sum( VN_j ) * psi_n(1, sum(  A + EN_j ) ) + 0.5 * sum( VN_j .* psi_n(1, A + EN_j ) );

    # Negated because sqp only handles _minimisation_
    lhood = -lhood;
end;

function G = df_lambda( lambda )
    global nu_opt;
    global Si_opt;
    global EN_j_opt;
    global VN_j_opt;

    # Mean \alpha parameters
    A = exp( lambda + 0.5*nu );
    # Variance \alpha parameters 2l + 2s - 2l + s
    VA = exp( 2*lambda + nu ) * ( exp( nu ) - 1 );

    lhood = 0;
    lhood += - 0.5 * ( (lambda - M) * Si + diag( Si ) .* (lambda - M) );
    
    # From alpha
    # logGamma( \sum A) - logGamma( \sum A + EN ) + \sum logGamma( A + EN ) - logGamma( A )  
    lhood += A .* ( psi_n( 0, sum( A ) ) - psi_n( 0, sum( A + EN_j ) ) + psi_n( 0, A + EN_j ) - psi_n(0, A ) );
    # 2nd-order Corrections
    lhood += A .* ( - 0.5 * sum( VN_j ) * psi_n(2, sum(  A + EN_j ) ) + 0.5 * VN_j .* psi_n(2, A + EN_j ) );

    # Negated because sqp only handles _minimisation_
    G = -lhood;
end;

function H = d2f_lambda( lambda )
    global nu_opt;
    global Si_opt;
    global EN_j_opt;
    global VN_j_opt;

    # Mean \alpha parameters
    A = exp( lambda + 0.5*nu );
    # Variance \alpha parameters 2l + 2s - 2l + s
    VA = exp( 2*lambda + nu ) * ( exp( nu ) - 1 );

    H = zeros( length( lambda ) );
    H += - 0.5 * ( Si + diag( Si ) );

    # From alpha
    # logGamma( \sum A) - logGamma( \sum A + EN ) + \sum logGamma( A + EN ) - logGamma( A )  
    X = psi_n( 1, sum( A ) ) - psi_n( 1, sum( A + EN_j ) );
    XX = psi_n( 1, A + EN_j ) - psi_n(1, A );
    # 2nd-order Corrections
    X += - 0.5 * sum( VN_j ) * psi_n(3, sum(  A + EN_j ) );
    XX += 0.5 * VN_j .* psi_n(3, A + EN_j );

    H += (A' * A) .* X + A.^2 .* diag( XX );

    # logGamma( \sum A) - logGamma( \sum A + EN ) + \sum logGamma( A + EN ) - logGamma( A )  
    Y = A .* ( psi_n( 0, sum( A ) ) - psi_n( 0, sum( A + EN_j ) ) + psi_n( 0, A + EN_j ) - psi_n(0, A ) );
    # 2nd-order Corrections
    Y += A .* ( - 0.5 * sum( VN_j ) * psi_n(2, sum(  A + EN_j ) ) + 0.5 * VN_j .* psi_n(2, A + EN_j ) );

    H += diag( Y );

    # Negated because sqp only handles _minimisation_
    H = -H;
end;

function lambda = opt_lambda_doc( N_k, K, M, S, B, EN_jk, VN_jk, lambda, nu, EN_j, VN_j, bound, max_iter )
    global nu_opt;
    global Si_opt;
    global EN_j_opt;
    global VN_j_opt;

    nu_opt = nu;
    Si_opt = inv( S ) ;
    EN_j_opt = EN_j;
    VN_j_opt = VN_j;

    # TODO : ?
    lambda0 = 10.0 * ones(1, K); # Used in Blei's code
    lb = zeros( 1, K );

    [lambda, lhood, info, iter, nf, L] = sqp( lambda0, {f_lambda, df_lambda, d2f_lambda}, [], [], lb );
end;

