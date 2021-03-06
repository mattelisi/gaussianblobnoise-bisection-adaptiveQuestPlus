function[texture] = makeNoisyGaussianDist1Patch(win,visual,sigma,width,contrast,bgsigma)
%
% white gaussian patch texture
%

% if is clipped on the sides, increase width.
halfWidthOfGrid = width / 2;
widthArray = (-halfWidthOfGrid) : halfWidthOfGrid;  

absoluteDifference = abs(visual.white - visual.bgColor);
[x, y] = meshgrid(widthArray, widthArray);
imageMatrix =  1/(2*pi*sigma^2) *  exp(-((x .^ 2) + (y .^ 2)) / (2*sigma ^ 2));

% textvisual.bgColor + bgsigma*randn(scr.xres, scr.yres)

grayscaleImageMatrix = visual.bgColor + contrast * absoluteDifference * imageMatrix;
texture = Screen('MakeTexture', win, uint8(grayscaleImageMatrix)); 