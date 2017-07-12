function L = L_r(x, r, mu, sigma, lambda)
%
% log-likelihood of the psychometric function defined in p_r1_cond.m
%

L = sum(log(p_r1_cond(x(r==1), mu, sigma, lambda))) + sum(log(1 - p_r1_cond(x(r==0), mu, sigma, lambda