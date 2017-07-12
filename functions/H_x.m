function [H] = H_x(x,p_table)
%
% expected entropy for test x
%

% % vectorised
% unconditioned prob. of outcomes
pr1 = p_r1_uncond(x,p_table);
pr0 = 1 - pr1;

% reshaped prior array
pm_prior = reshape(p_table.p, numel(p_table.p),1);

% likelihood
pr_m = p_r1_cond(x, p_table.mu_v, p_table.sigma_v, p_table.lambda_v);

% posterior probabilities
pm_1 = (pm_prior .* pr_m )/ pr1;
pm_0 = (pm_prior .* (1-pr_m) )/ pr0;
pm_1(pm_1==0) = realmin;
pm_0(pm_0==0) = realmin;

% expected entropies
H = sum(pr1 * (-pm_1 .* log(pm_1)) + pr0 * (-pm_0 .* log(pm_0)));