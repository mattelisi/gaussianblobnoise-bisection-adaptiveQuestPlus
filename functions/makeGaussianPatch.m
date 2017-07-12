function[texture] = makeGaussianPatch(win,visual,sigma,width,contrast)
%
% make a simple white gaussian patch (texture, allows fast presentation)
%

if nargin < 5
    contrast = 1;
end

% if is clipped on the sides, increase width.
halfWidthOfGrid = width / 2;
widthArray = (-halfWidthOfGrid) : halfWidthOfGrid;  

% color codes
white = visual.white;
gray = visual.bgColor; 
  
absoluteDifference = abs(white - gray);
[x, y] = meshgrid(widthArray, widthArray);
imageMatrix = exp(-((x .^ 2) + (y .^ 2)) / (sigma ^ 2));
grayscaleImageMatrix = gray + contrast * absoluteDifference * imageMatrix;
texture = Screen('MakeTexture', win, uint8(grayscaleImageMatrix)); 