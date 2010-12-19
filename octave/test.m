function r = g (x)
  r = [ sumsq(x)-10;
        x(2)*x(3)-5*x(4)*x(5);
        x(1)^3+x(2)^3+1 ];
endfunction

function G = dphi (x)
  G = exp(prod(x)) * prod(x) ./ x;
 - 0.5*(x(1)^3+x(2)^3+1)^2;
  G(1) += -(x(1)^3+x(2)^3+1) * (3*x(1)^2);
  G(2) += -(x(1)^3+x(2)^3+1) * (3*x(2)^2);
endfunction

function obj = phi (x)
  obj = exp(prod(x)) - 0.5*(x(1)^3+x(2)^3+1)^2;
endfunction

x0 = [-1.8; 1.7; 1.9; -0.8; -0.8];

[x, obj, info, iter, nf, lambda] = sqp (x0, {@phi, @dphi}, @g, [])
