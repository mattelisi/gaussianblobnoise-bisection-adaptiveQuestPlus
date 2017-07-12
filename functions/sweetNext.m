function x_next = sweetNext(sweet, side)
%
% suggest next stimulus, acording to minimum-variance criterion
% for the psychometric slope
%

if nargin < 2
    side = randn >= 0;
end

if sweet.count <= sweet.init_n
    x_next = sweet.range(1) + (sweet.range(2)-sweet.range(1)).*rand;
else
    [mu, sigma, lambda] = fit_p_r(sweet.x, sweet.rr);
    x_next = compute_sweetpoint(mu, sigma, lambda, side);
end