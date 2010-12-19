# Optimising Nu

global lambda_opt;
global M_opt;
global Si_opt;
global EN_j_opt;
global VN_j_opt;

# Optimisation functions for nu
function lhood = f_nu( nu )
    global lambda_opt;
    global M_opt;
    global Si_opt;
    global EN_j_opt;
    global VN_j_opt;

    lambda = lambda_opt;
    M = M_opt;
    Si = Si_opt;
    EN_j = EN_j_opt;
    VN_j = VN_j_opt;

    nu = nu';

    # Mean \alpha parameters
    A = exp( lambda + 0.5*nu )' + 1;

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
    global M_opt;
    global Si_opt;
    global EN_j_opt;
    global VN_j_opt;

    lambda = lambda_opt;
    M = M_opt;
    Si = Si_opt;
    EN_j = EN_j_opt;
    VN_j = VN_j_opt;

    nu = nu';

    # Mean \alpha parameters
    A = exp( lambda + 0.5*nu )' + 1;

    G = - 0.5 * diag(Si); 
    
    # From alpha
    # logGamma( \sum A) - logGamma( \sum A + EN ) + \sum logGamma( A + EN ) - logGamma( A )  
    G += 0.5 * A .* ( psi_n( 0, sum( A ) ) - psi_n( 0, sum( A + EN_j ) ) + psi_n( 0, A + EN_j ) - psi_n( 0, A ) );
    # 2nd-order Corrections
    G += 0.5 * A .* ( - 0.5 * sum( VN_j ) * psi_n(2, sum(  A + EN_j ) ) + 0.5 * VN_j .* psi_n(2, A + EN_j ) );

    G += 0.5 ./ nu'; 

    # Negated because sqp only handles _minimisation_
    G = -G;
end;

function H = d2f_nu( nu )
    global lambda_opt;
    global M_opt;
    global Si_opt;
    global EN_j_opt;
    global VN_j_opt;

    lambda = lambda_opt;
    M = M_opt;
    Si = Si_opt;
    EN_j = EN_j_opt;
    VN_j = VN_j_opt;

    nu = nu';

    # Mean \alpha parameters
    A = exp( lambda + 0.5*nu )' + 1;

    H = zeros( length( nu ) );

    # From alpha
    # logGamma( \sum A) - logGamma( \sum A + EN ) + \sum logGamma( A + EN ) - logGamma( A )  
    X = psi_n( 1, sum( A ) ) - psi_n( 1, sum( A + EN_j ) );
    XX = psi_n( 1, A + EN_j ) - psi_n(1, A );
    # 2nd-order Corrections
    X += - 0.5 * sum( VN_j ) * psi_n(3, sum(  A + EN_j ) );
    XX += 0.5 * VN_j .* psi_n(3, A + EN_j );

    H += 0.25 * ((A * A') * X + diag( (A.^2) .* XX ));

    # logGamma( \sum A) - logGamma( \sum A + EN ) + \sum logGamma( A + EN ) - logGamma( A )  
    Y = A .* ( psi_n( 0, sum( A ) ) - psi_n( 0, sum( A + EN_j ) ) + psi_n( 0, A + EN_j ) - psi_n(0, A ) );
    # 2nd-order Corrections
    Y += A .* ( - 0.5 * sum( VN_j ) * psi_n(2, sum(  A + EN_j ) ) + 0.5 * VN_j .* psi_n(2, A + EN_j ) );

    H += 0.25 * diag( Y );

    H += diag(-0.5 ./ nu.^2); 

    # Negated because sqp only handles _minimisation_
    H = -H;
end;

function nu  = opt_nu_doc( N_k, K, M, Si, B, EN_jk, VN_jk, lambda, nu, EN_j, VN_j, bound, max_iter )
    global lambda_opt;
    global M_opt;
    global Si_opt;
    global EN_j_opt;
    global VN_j_opt;

    lambda_opt = lambda;
    M_opt = M;
    Si_opt = Si;
    EN_j_opt = EN_j;
    VN_j_opt = VN_j;

    # TODO : ?
    nu0 = ones(K, 1); # Used in Blei's code

    [nu, lhood, info, iter, nf, L] = sqp( nu0, {@f_nu, @df_nu, @d2f_nu}, [], [] );

    nu = nu';
end;

