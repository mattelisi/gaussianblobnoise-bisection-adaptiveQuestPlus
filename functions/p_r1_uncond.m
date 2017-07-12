function p = p_r1_uncond(x,p_table)
% unconditioned probability of observing r_1 given x
% (summed over all psy functions)

% vectorized version
p_par = reshape(p_table.p, numel(p_table.p),1);
p = sum(p_r1_cond(x, p_table.mu_v, p_table.sigma_v, p_table.lambda_v) .* p_par);