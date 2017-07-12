function [mu, sigma, lambda, L] = fit_p_r(x,r, mu0, sigma0, lambda0)
%
% fit cumulative Gaussian with symmetric asymptotes (lambda and 1-lambda)
%

% initial parameters
if nargin < 5; lambda0 = 0; end
if nargin < 4; sigma0 = mean(abs(x)); end
if nargin < 3; mu0 = 0; end
par0 = [mu0, sigma0, lambda0];

% options
options = optimset('Display', 'off') ;

% set boundaries
lb = [-3*sigma0,    sigma0/4, 0];
ub = [ 3*sigma0, 4*sigma0, 0.2];

% do optimization
fun = @(par) -L_r(x, r, par(1), par(2), par(3));
[par, L] = fmincon(fun, par0, [],[],[],[], lb, ub,[],options);

% output parameters & loglikelihood
mu = par(1); 
sigma = par(2);
lambda = par(3);
L = -L;
