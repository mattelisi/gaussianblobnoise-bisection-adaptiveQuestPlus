function np = p_m_uncond(x,p_table, r1)

% reshaped prior array
pm_prior = reshape(p_table.p, numel(p_table.p),1);

% likelihood
pr_m = p_r1_cond(x, p_table.mu_v, p_table.sigma_v, p_table.lambda_v);

if r1
    pr1 = p_r1_uncond(x,p_table);
    np = (pm_prior .* pr_m )/ pr1;
else
    pr1 = 1 - p_r1_uncond(x,p_table);
    np = (pm_prior .* (1-pr_m) )/ pr1;
end
np(np==0) = realmin;
np = reshape(np,size(p_table.p));