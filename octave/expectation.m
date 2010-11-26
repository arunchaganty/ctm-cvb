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
function [lhood, N_ij, N_jk] = expectation( C, K, M, S, B, G, bound, max_iter )
    lhood = 0;
    iter = 0;

    [D,V] = size( C );
    C2 = C.^2;

    phi = init_phi_unif( C, K, M, S, B, G )
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

            # Update (log_phi)
            # log(phi_ijk) = \sum_j' S_jj' EN_ij' - S_jj n_ik ( 1 - 2\phi_ijk ) + M_j
            phi_ = EN_ij * S( j, : ) - S( j, j ) .* ( C - 2 .* EN ) + M(j);
            #              - log( \sum_k' B_jk' EN_jk' - B_jk n_ik \phi_ijk + (n_ik - 1)/2 ) 
            #              + log( B_jk EN_jk - B_jk n_ik \phi_ijk _ (n_ik - 1)/2 )
            B_jk_tmp = ( B(j,:) .* EN_jk(j,:) - repmat( B(j,:), D ) .* EN + (C - 1)/2 );
            phi_ += -log( sum( B_jk_tmp ) );
            phi_ += log( B_jk_tmp );
            #              + (\sum_k' VN_jk' - n_ik^2 (1-\phi_ijk) \phi_ijk )/2(\sum_k' B_jk' + EN_jk' - n_ik\phi_ijk + n_ik - 1 /2 )^2 
            phi_ += sum( VN_jk(j,:) - VN ) ./ (2.*( sum( B_jk_tmp ) ).^2 );
            phi_ -= ( VN_jk(j,:) - VN ) ./ (2.*( B_jk_tmp ).^2 );

            # Update
            phi{j} = phi_;
        end;

        # Flatten phi
        phinorm = sparse( D * V, 1 );
        for j = [1:length(phi)];
            phinorm(j) = phi{j}(:);
        end;
        # Normalise across topics
        phinorm = logsum( phinorm, 1 );
        phinorm = (C>0) .* reshape( phinorm, D, V );

        # Subtract the norm from all the topics, and exponentiate
        phi = cellfun( @(phi_j) exp( phi_j - phinorm ), phi, "UniformOutput", false );

        lhood = likelihood( C, K, M, S, B, G, EN_ij, VN_ij, EN_jk, VN_jk );
        iter++;
    while( lhood - lhood_ < bound && iter < max_iter );
end;

