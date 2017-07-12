function[texture, mu_x, sd_x] = makePixelPatch(win,visual,n,sigma,width, smooth)
% make a texture of a Gaussian "pixels' cloud"
% width should be even number or bad things will happen
%
% Matteo Lisi 2017

if nargin < 6
    smooth = 1;
end

halfWidthOfGrid = floor(width / 2);

% color codes
white = visual.white;
gray = visual.bgColor;

% samples
z = round(repmat([halfWidthOfGrid halfWidthOfGrid]+0.5,n,1) + randn(n,2)*sigma);

% if you want specific variance-covariance matrix
% z = round(repmat([0 0],n,1) + randn(n,2)*chol([sigma 0; 0 sigma])); 

z2 = unique(z,'rows');
while size(z2,1) < n 
    nd = n - size(z2,1);
    z2 = unique([z2; round(repmat([halfWidthOfGrid halfWidthOfGrid]+0.5,nd,1) + randn(nd,2)*sigma)],'rows');
end

% correct points outside texture area
z2(z2>width) =  width - floor((z2(z2>width) - width)/2);
z2(z2<=0) = 1;

imagematrix = repmat(gray,width,width);
for i = 1:n
    imagematrix(z2(i,1),z2(i,2)) = white;
end

if smooth > 0
    imagematrix = imgaussfilt(imagematrix, smooth);
end

mu_x = mean(z2(:,1));
sd_x = std(z2(:,1));
    
texture = Screen('MakeTexture', win, uint8(imagematrix)); 
end