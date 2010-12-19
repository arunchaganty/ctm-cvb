#
# Correlated Topic Model
# Using CVB
# The maximisation step (using ML estimates)
#

# Compute "better" model parameters
function [M, S, B] = mlmaximisation( C, K, M, Si, B, Lambda, Nu, EN_jk, VN_jk )
    [D,V] = size(C);

    M = mean( Lambda, 1 );

    for i = [1:D];
        S = diag(Nu(i,:)) + (Lambda(i,:) - M)' * (Lambda(i,:) - M);
    end;
    S ./ D;

    B = EN_jk + 1; # Actually proportional
end;

