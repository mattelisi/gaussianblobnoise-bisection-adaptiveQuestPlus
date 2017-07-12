function v = Evar_sigma(x,mu, sigma, lambda)
% this function compute the expected variance
% of the psychometric slope (sigma)

v = (pi* (sigma^4) * exp(((x - mu)/sigma)^2) * (1 - (1 - 2*lambda)^2 * erf((x - mu)/(sqrt(2)*sigma))^2)) / (2*(1 - 2*lambda)^2 *(x -mu)^2);