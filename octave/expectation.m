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
        phi{ j } =  C ./ K;
    end;
end;

# Compute "better" expected topic assignments
function [lhood, EN_ij, EN_jk, VN_ij, VN_jk] = expectation( C, K, M, S, B, G, bound, max_iter )
    lhood = 0;
    iter = 0;

    [D,V] = size( C );
    C2 = C.^2;

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
            EN = phi{ j } .* C;
            VN = C2 .* (1 - phi{ j }) .* phi{ j };

            # Fill up the counts
            EN_ij( :, j ) = sum( EN, 2 );
            EN_jk( j, : ) = sum( EN, 1 );

            VN_ij( :, j ) = sum( VN, 2 );
            VN_jk( j, : ) = sum( VN, 1 );
        end;

        # Update (log_phi)
        for j = [1:K];
            EN = phi{ j } .* C;
            VN = C2 .* (1 - phi{ j }) .* phi{ j };

            C_ = C;
            C_(C_>0) -= 1;

            # log(phi_ijk) = \sum_j' S_jj' EN_ij' - S_jj n_ik ( 1 - 2\phi_ijk ) + M_j
            phi_ = 0.5 .* ( repmat( EN_ij * S( :, j ), 1, V ) + S( j, j ) .* ( C - 2 .* EN ) ) + repmat( M(j), D, V );
            #              - log( \sum_k' B_jk' + EN_jk' - n_ik \phi_ijk + (n_ik - 1)/2 ) 
            #              + log( B_jk + EN_jk - n_ik \phi_ijk _ (n_ik - 1)/2 )
            B_j_tmp = repmat( sum( B(j,:) + EN_jk(j,:) ), D, V ) - EN + (C_)/2;
            B_jk_tmp = repmat( B(j,:) + EN_jk(j,:), D, 1 ) - EN + (C_)/2;
            assert( B_j_tmp > 0 )
            assert( B_jk_tmp > 0 )
            phi_ += -log( B_j_tmp );
            phi_ += log( B_jk_tmp );
            #              + (\sum_k' VN_jk' - n_ik^2 (1-\phi_ijk) \phi_ijk )/2(\sum_k' B_jk' + EN_jk' - n_ik\phi_ijk + n_ik - 1 /2 )^2 
            V_j_tmp = repmat( sum( VN_jk(j,:) ), D, V ) - VN;
            V_jk_tmp = repmat( VN_jk(j,:), D, 1 ) - VN;
            phi_ +=  V_j_tmp ./ (2.*( B_j_tmp.^2 ));
            phi_ -=  V_jk_tmp ./ (2.*( B_jk_tmp.^2 ));

            # Update
            phi{j} = phi_;
        end;

        # Flatten phi
        phinorm = phi{1}(:)';
        for j = [2:length(phi)];
            phinorm = logsum( [phinorm;phi{j}(:)'], 1);
        end;
        # Normalise across topics
        phinorm = reshape( phinorm, D, V );

        # Subtract the norm from all the topics, and exponentiate
        phi = cellfun( @(phi_j) (C>0) .* exp( phi_j - phinorm ), phi, "UniformOutput", false );

#        phinorm = 0;
#        for j = [1:length(phi)];
#            phinorm += phi{j};
#        end;
#
#        phinorm

        lhood = likelihood( C, K, M, S, B, G, EN_ij, VN_ij, EN_jk, VN_jk, phi );
        P = perplexity( C, K, phi );
        printf( "E(%d) = %f, %f\n", iter, P, lhood );
        fflush(1);

        iter++;
    until( abs(1 - lhood_/lhood) < bound || iter > max_iter );
end;

