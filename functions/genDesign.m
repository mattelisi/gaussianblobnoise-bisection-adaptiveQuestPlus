function [design, qp] = genDesign(visual,scr)
%
% location uncertainty v1.1 - gaussian blobs
%
% Matteo Lisi, 2017
% 

%% display parameters
design.eccentricity = [10];

%% target parameters
design.min_sigma = 0.3;
% design.sigma_range_deg = [design.min_sigma, 1.5];

% fixed set of sigmas
design.sigmas_deg = design.min_sigma;
for s = 1:4
    design.sigmas_deg = [design.sigmas_deg, design.sigmas_deg(s)*1.5];
end
design.sigmas = visual.ppd * design.sigmas_deg;

% uniform within range
% design.sigma_range = visual.ppd * design.sigma_range_deg;

%design.side = [-1 1]; % side of the more distant target (+1 = right; -1 = left)
%design.deltaE = linspace(4/visual.ppd, 1.6, 6);
design.r_dE = [-4 4];

% conditions %% warning - works only for FE only %%
design.condition_FE = [1]; % whether it is a fixed energy or constant peak condition

peak_contrast = 1;

% this is actually a multiplier, ensure that peak luminance is at correct
% level
design.contrast_FE = 2 * pi * (visual.ppd * design.min_sigma)^2;
design.contrast_FE = design.contrast_FE * peak_contrast;

% this if you want to keep the peak constant
design.contrast_CP = ((design.min_sigma^2) / (max(design.sigmas_deg)^2) +1)/2;
design.contrast_CP = 0.4; % design.contrast_CP * peak_contrast;

% set the level of background noise
design.bg_RMScontrast = 10; % percentage
design.bgsigma = design.bg_RMScontrast/100 * 256; 

% size of displayed pixel in screen pixels
design.pixSixe = 4;

%% timing
design.dur = 0.25;
design.soa = [300, 200]; % [min, jitter]
design.iti = 0.3;
design.preRelease = scr.fd/2;

%% exp structure
design.nBlocks = 12;
design.totSession = 1;

%% other
design.fixJtStd = 0.2;

%% limit sigma conditions
% design.sigmas_deg = design.sigmas_deg(2:end);
% design.sigmas = design.sigmas(2:end);
design.sigmas_deg = linspace(design.sigmas_deg(1),design.sigmas_deg(end),3);
design.sigmas = linspace(design.sigmas(1),design.sigmas(end),3);
% design.sigmas_deg = design.sigmas_deg(1);
% design.sigmas = design.sigmas(1);

%% prepare staircases
design.rep = 100;
design.range_mu = [-2, 2];
design.range_sigma = [0.1, 4];
design.gridsize = 30;
design.lambdas_val = [0, 0.01, 0.02, 0.05, 0.1];
design.stim_n = 100;
for cond = design.condition_FE 
for c = 1:length(design.sigmas)
    
    eval(['qp.s',num2str(c),'.sigma = design.sigmas(c);']);
    eval(['qp.s',num2str(c),'.FE = cond;']);
    eval(['qp.s',num2str(c),'.count = 0;']);
    eval(['qp.s',num2str(c),'.x = [];']);
    eval(['qp.s',num2str(c),'.rr = [];']);
    eval(['qp.s',num2str(c),'.tab = set_unif_lambda(design.range_mu, design.range_sigma, design.gridsize,design.lambdas_val);']);
    eval(['qp.s',num2str(c),'.x_range = design.r_dE;']);
    eval(['qp.s',num2str(c),'.x_n = design.stim_n;']);
    eval(['qp.s',num2str(c),'.x_values = linspace(design.r_dE(1),design.r_dE(2),design.stim_n);']);
    eval(['qp.s',num2str(c),'.x_EH = NaN(1,design.stim_n);']);
end
end

%% trials list
t = 0;
for cond = design.condition_FE
for i = 1:design.rep
for s = 1:length(design.sigmas)
for bg = design.bgsigma
for e = design.eccentricity

    t = t+1;
    
    % trial settings 
    trial(t).ecc = e;
    trial(t).FE = cond;
    if cond
        trial(t).contrast = design.contrast_FE;
    else
        trial(t).contrast = design.contrast_CP;
    end
    
    trial(t).acode = (['s',num2str(s)]);
    
    trial(t).bg_sigma = bg;
    trial(t).sigma = design.sigmas(s);
    % trial(t).sigma = design.sigma_range(1) + rand(1) * (design.sigma_range(2) - design.sigma_range(1));
    
    trial(t).dE = NaN;
    trial(t).side = NaN;
    
    trial(t).fixLoc = [scr.centerX scr.centerY] + round(randn(1,2)*design.fixJtStd*visual.ppd);
    trial(t).soa = (design.soa(1) + rand*design.soa(2))/1000;
    
end
end
end
end
end
    
design.totTrials = t;

% random order
r = randperm(design.totTrials);
trial = trial(r);

% generate blocks
design.blockOrder = 1:design.nBlocks;
design.nTrialsInBlock = design.totTrials/design.nBlocks;
beginB=1; endB=design.nTrialsInBlock;
for i = 1:design.nBlocks
    design.b(i).trial = trial(beginB:endB);
    beginB  = beginB + design.nTrialsInBlock;
    endB    = endB   + design.nTrialsInBlock;
end



