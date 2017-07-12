
clear all

% prove

mu = 0;
lambda = 0.01;
sigma = 1;

for t = 1:20
    
    x(t) = -3 + (6).*rand;
    
    % generate response
    r(t) = x(t)+sigma*randn >= mu;
    
    % add lapses
    if binornd(1,lambda)
        r(t) = abs(r(t)-1);
    end
     
end

[mu_hat, sigma_hat, lambda_hat, L] = fit_p_r(x,r)


% find sweetpoints
s_1 = compute_sweetpoint(mu_hat, sigma_hat, lambda_hat, 1)
s_0 = compute_sweetpoint(mu_hat, sigma_hat, lambda_hat, 0)

