function s = compute_sweetpoint(mu, sigma, lambda, side)
%
% compute sweetpoint for slope estimation of a given function
%
% 'side' is a parameter that indicates which sweepoint is requested,
%   i.e. upper or lower. There are two sweetpoints for the slope, and 
%   in the case of a Gaussian they are symmetrical around mu.
%   If side is not provided the function will randomly choose one.
%

if nargin < 4
    side = randn >= 0;
end

% options
options = optimset('Display', 'off') ;

% set boundaries & initial parameters
if sigma*4 < 1
    bdwidth = 1; % avoid numerical issues when range is too small
else
    bdwidth = sigma*4;
end

% adjust boundaries depending on which sweetpoint is estimated
if side
    lb = mu;
    ub = mu + bdwidth;
    x0 = mu + bdwidth/4;
else
    lb = mu - bdwidth;
    ub = mu;
    x0 = mu - bdwidth/4;
end

% do optimization
fun = @(x) Evar_sigma(x, mu, sigma, lambda);
s = fmincon(fun, x0, [],[],[],[], lb, ub,[],options);



