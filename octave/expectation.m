#
# Correlated Topic Model
# Using CVB
# The expectation step
#

# Initialise phi uniformly for document 'i'
function phi = init_phi_unif( C, K, M, S, B, G, i )
    [D, V] = size( C );
    phi = cell( K, 1 );
    
    for j = [1:K];
        phi{ j } =  safe_log(C ./ K);
    end;
end;

# Compute "better" expected topic assignments
function [lhood, EN_ij, EN_jk, VN_ij, VN_jk] = expectation( C, K, M, S, B, G, bound, max_iter )
    lhood = 0;
    iter = 0;

    [D,V] = size( C );

    # Topic ratios (precomputed)
    lR = M + 0.5 * diag( S )';
    R = exp( lR - logsum( lR ) );
    # N
    N_i = sum( C, 2 );

    # Stored in logspace
    phi = init_phi_unif( C, K, M, S, B, G );
    do
        lhood_ = lhood;

        # N_ij = \sum_{k} \phi_ijk
        # N_jk = \sum_{i} \phi_ijk

        EN_ij = zeros( D, K );
        EN_jk = zeros( K, V );
        VN_ij = zeros( D, K );
        VN_jk = zeros( K, V );

        # Get updated counts
        for j = [1:K];
            EN = phi{ j } + safe_log(C);
            VN = C.*(1 - exp(phi{ j })).*exp(phi{j});

            # Fill up the counts
            EN_ij( :, j ) = exp(logsum( EN, 2 ));
            EN_jk( j, : ) = exp(logsum( EN, 1 ));

            VN_ij( :, j ) = sum( VN, 2 );
            VN_jk( j, : ) = sum( VN, 1 );
        end;

        lhood = likelihood( C, K, M, S, B, G, EN_ij, VN_ij, EN_jk, VN_jk, phi );

#        EN_ij
#        EN_jk
#        input "Continue";

        # Adjust counts
        #  Every element is a KxV matrix
        EN_ij_ik = cell( 1, D );
        #  Every element is a KxD matrix
        # EN_jk_ik = cell( 1, V );
        for j = [1:K];
            EN = C .* exp(phi{ j });
            for i = [1:D];
                EN_ij_ik{i}( j, : ) = repmat( EN_ij( i, j ), 1, V );
                EN_ij_ik{i}( j, : ) -= EN( i, : );
            end;
        end;

        # Update (log_phi)
        for j = [1:K];
            EN = exp(phi{ j }) .* C;
            VN = C .* (1 - exp(phi{ j })) .* exp(phi{ j });

            C_ = C;
            C_(C_>0) -= 1;

            # log(phi_ijk) = \M_j + 0.5 * S_jj - 0.5*(exp(S_jj) - 1)
            phi_ = repmat( lR(j) , D, V ); 
#            phi_( 1,1:10 )
            for i = [1:D];
                #                + 0.5 * \sum_j' (exp(S_jj') -  1)( EN_ij'_ik - N_i R_j' )
                err = EN_ij_ik{i} - repmat( N_i(i) * R', 1, V);
                err(j,:) -= 1;
                proj_err = 0.5 * (exp(S(j,:)) - 1) * err;
                phi_(i,:) += proj_err;
            end;
#            phi_( 1,1:10 )
            #              - log( \sum_k' B_jk' + EN_jk' - n_ik phi_ijk + (n_ik - 1)/2 ) 
            B_j_tmp = repmat( sum( B(j,:) + EN_jk(j,:) ), D, V ) - EN;# + (C_)/2;
            #              + log( B_jk + EN_jk + (n_ik - 1)/2 )
            B_jk_tmp = repmat( B(j,:) + EN_jk(j,:), D, 1 ) - EN;# + (C_)/2;
            assert( B_j_tmp > 0 );
            assert( B_jk_tmp > 0 );
            phi_ += -safe_log( B_j_tmp ) + safe_log( B_jk_tmp );
#            phi_( 1,1:10 )
            #              + (\sum_k' VN_jk' - n_ik^2 (1-\phi_ijk) \phi_ijk )/2(\sum_k' B_jk' + EN_jk' - n_ik\phi_ijk + n_ik - 1 /2 )^2 
            V_j_tmp = repmat( sum( VN_jk(j,:) ), D, V ) - VN;
            V_jk_tmp = repmat( VN_jk(j,:), D, 1 ) - VN;
            phi_ +=  V_j_tmp ./ (2.*( B_j_tmp.^2 )) - V_jk_tmp ./ (2.*( B_jk_tmp.^2 ));
#            phi_( 1,1:10 )

            # Update
            phi{j} = (C>0) .* phi_;
        end;

        # Flatten phi
        flat_phi = zeros( K, D*V );
        for j = [1:length(phi)];
            flat_phi(j,:) = phi{j}(:)';
        end;
        sum_phi = sum( flat_phi, 1 );
        phinorm = logsum( flat_phi, 1 );
        # Normalise across topics
        sum_phi = reshape( sum_phi, D, V );
        phinorm = reshape( phinorm, D, V );
#        phi{1}(1:12, 1:12)
#        sum_phi(1:12, 1:12)
#        ((C>0).*phinorm)(1:12, 1:12)
#        ((C>0).*(phi{1} - phinorm))(1:12, 1:12)
#        input "Continue";

        # Subtract the norm from all the topics, and exponentiate
        phi = cellfun( @(phi_j) (C>0) .* (phi_j - phinorm), phi, "UniformOutput", false );
#        phi{1}(phi{1} > 0.3)
#        phi{1}(1:10,1:10)
#        input "Continue";

        phinorm = zeros(D,V);
        for j = [1:length(phi)];
            phinorm += phi{j};
#            phi{j}(10:12,10:12)
        end;
#        phinorm
        assert( phinorm( C > 0 ) - 1 < 0.001 );
#        input "Continue";

        #lhood = likelihood( C, K, M, S, B, G, EN_ij, VN_ij, EN_jk, VN_jk, phi );
        #N = sum(sum(C));
        #P = exp( - lhood / N );
        printf( "E(%d) = %e\n", iter, lhood );
        fflush(1);

        iter++;
    until( abs(1 - lhood_/lhood) < bound || iter > max_iter );
end;

