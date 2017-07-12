function [x_next, qp] = QuestNext(qp, limitbehav)
%
% choose next stimulus, Quest+
%

if nargin < 2
    limitbehav = 0;
end

% compute expected entropies
for x_i = 1:qp.x_n
    qp.x_EH(x_i) = H_x(qp.x_values(x_i),qp.tab);
end

% select stimulus with minimum entropy
x_next = qp.x_values(qp.x_EH==min(qp.x_EH));

% due to quantizations sometimes more than one have the same entropy
% pick a random one
if length(x_next)>1
    x_next = x_next(randperm(length(x_next),1));
end

% this adjust limiting behavior of the Quest+
% can be useful if you don't want to present stimuli at the boundaries
% the alternative here compute the sweetpoints for the slope, and present
% the stimulus there
if x_next==qp.x_range(1) || x_next==qp.x_range(2)
    if ~limitbehav
        x_next = sign(randn) * abs(x_next);
    else
        [mu_hat, sigma_hat, lambda_hat] = fit_p_r(qp.x, qp.rr);
        x_next = compute_sweetpoint(mu_hat, sigma_hat, lambda_hat);
    end
end

