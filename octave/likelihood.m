#
# Correlated Topic Model
# Using CVB
# Computing likelihood
#

# Compute the log-likelihood of the model
function lhood = likelihood( C, K, M, S, B, G, EN_ij, VN_ij, EN_jk, VN_jk, phi )
    [D,V] = size(C);

    # Topic ratios (precomputed)
    lR = M + 0.5 * diag( S )';
    R = exp( lR - logsum( lR ) );
    # N
    N_i = sum( C, 2 );

    lhood = 0;
    # \sum_i \sum_j EN_ij * (M_j + 0.5 * S_jj) - N_i log( sum_j M_j + 0.5 * S_jj )
    lhood += sum(sum(EN_ij) .* lR) - sum(N_i) * logsum(lR);

    #\sum_jj' 0.5 * (exp(S_jj') - 1) (\sum_i Var(n_j,n_j') + E[n_j]E[n_j'] + d_jj' E[n_j] - N_i( E[n_j] r_j' + E[n_j'] r_j )
    Var = zeros(K,K);
    EN = zeros(K,K);
    I = eye( K, K );
    for j=[1:K];
        for j_ = [1:K];
            Var(j,j_) += sum( sum( C .* ( phi{j} .* I(j,j_) - phi{j} .* phi{j_}  ) ) );
            EN(j,j_) += sum( EN_ij(:,j) .* EN_ij(:,j_) - EN_ij(:,j) .* I(j,j_) - N_i .* ( EN_ij(:, j) * R(j_) + EN_ij(:, j_) * R(j) ) );
        end;
    end;
    lhood += 0.5 * sum( sum( (exp( S ) - 1) .* (Var + EN) ) );

    #\sum_i (N_i + N_i^2)/2 \sum_jj' 0.5 * (exp(S_jj') - 1) r_j r_j'
    lhood += sum(N_i + N_i.^2) * 0.5 * sum( sum( (exp(S) - 1).* (R' * R) ) );

    # \sum_j 1/2( log( \sum_k B_jk + EN_jk ) - log( \sum_k B_jk ) - \sum_j \sum_k 1/2( log( B_jk + EN_jk ) - log( B_jk )  
    B_ = sum( B, 2 );
    B_jk = B + EN_jk;
    B_j = sum( B_jk, 2 );
    lhood += 0.5 * sum( log( B_j ) - log( B_ ) - sum( log( B_jk ) - log( B ), 2 ) );
    # - \sum_j 1/2( \sum_k VN_jk ) ( 1 / ( sum_k B_jk + EN_jk ) + 1 / 2( sum_k  B_jk + EN_jk )^2
    lhood += -0.5 * sum( sum( VN_jk, 2 )' .* ( B_j.^(-1) + (B_j.^(-2))./2 )' );
    # + \sum_j 1/2( VN_jk ) ( 1 / ( B_jk + EN_jk ) + 1 / 2( B_jk + EN_jk )^2
    lhood += 0.5 * sum(  sum( VN_jk' .* ( B_jk.^(-1) + (B_jk.^(-2))./2 )' ) );

    # - n_ik * E_q( log( \phi_ijk ) )
    for j = [1:K]
        lhood += -sum( sum( C .* phi{j} .* safe_log(phi{j}) ) );
    end;
end;

