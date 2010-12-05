# Optimising Nu

global lambda_opt;
global Si_opt;
global EN_j_opt;
global VN_j_opt;

# Optimisation functions for nu
function lhood = f_nu( nu )
    global lambda_opt;
    global Si_opt;
    global EN_j_opt;
    global VN_j_opt;

    # Mean \alpha parameters
    A = exp( lambda + 0.5*nu );
    # Variance \alpha parameters 2l + 2s - 2l + s
    VA = exp( 2*lambda + nu ) * ( exp( nu ) - 1 );

    lhood = 0;
    lhood += - 0.5 * nu * diag(Si); 
    
    # From alpha
    # logGamma( \sum A) - logGamma( \sum A + EN ) + \sum logGamma( A + EN ) - logGamma( A )  
    lhood += lgamma( sum( A ) ) - lgamma( sum( A + EN_j ) ) + sum( lgamma( A + EN_j ) - lgamma( A ) );
    # 2nd-order Corrections
    lhood += - 0.5 * sum( VN_j ) * psi_n(1, sum(  A + EN_j ) ) + 0.5 * sum( VN_j .* psi_n(1, A + EN_j ) );

    lhood += 0.5 * sum( log( nu ) );

    # Negated because sqp only handles _minimisation_
    lhood = -lhood;
end;

function G = df_nu( nu )
    global lambda_opt;
    global Si_opt;
    global EN_j_opt;
    global VN_j_opt;

    # Mean \alpha parameters
    A = exp( lambda + 0.5*nu );
    # Variance \alpha parameters 2l + 2s - 2l + s
    VA = exp( 2*lambda + nu ) * ( exp( nu ) - 1 );

    G = - 0.5 * diag(Si); 
    
    # From alpha
    # logGamma( \sum A) - logGamma( \sum A + EN ) + \sum logGamma( A + EN ) - logGamma( A )  
    G += 0.5 * A .* ( psi_n( 0, sum( A ) ) - psi_n( 0, sum( A + EN_j ) ) + psi_n( 0, A + EN_j ) - psi_n(0, A ) );
    # 2nd-order Corrections
    G += 0.5 * A .* ( - 0.5 * sum( VN_j ) * psi_n(2, sum(  A + EN_j ) ) + 0.5 * VN_j .* psi_n(2, A + EN_j ) );

    G += 0.5 ./ nu; 

    # Negated because sqp only handles _minimisation_
    G = -G;
end;

function H = d2f_nu( nu )
    global lambda_opt;
    global Si_opt;
    global EN_j_opt;
    global VN_j_opt;

    # Mean \alpha parameters
    A = exp( lambda + 0.5*nu );
    # Variance \alpha parameters 2l + 2s - 2l + s
    VA = exp( 2*lambda + nu ) * ( exp( nu ) - 1 );

    H = zeros( length( lambda ) );

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

    H += -0.5 ./ nu.^2; 

    # Negated because sqp only handles _minimisation_
    H = -H;
end;

function nu  = opt_nu_doc( N_k, K, M, S, B, EN_jk, VN_jk, lambda, nu, EN_j, VN_j, bound, max_iter )
    global lambda_opt;
    global Si_opt;
    global EN_j_opt;
    global VN_j_opt;

    lambda_opt = lambda;
    Si_opt = inv( S ) ;
    EN_j_opt = EN_j;
    VN_j_opt = VN_j;

    # TODO : ?
    nu0 = ones(1, K); # Used in Blei's code
    #lb = zeros( 0, K );

    [nu, lhood, info, iter, nf, L] = sqp( nu0, {f_nu, df_nu, d2f_nu}, [], [] );
end;

