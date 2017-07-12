 function [data, rr] = runSingleTrial(td, scr, visual, const, design)
%
% run individual trials
% location uncertainty v1.1 - gaussian blobs - noise
%
% Matteo Lisi, 2017
%

% clear keyboard buffer
FlushEvents('KeyDown');

% define response keys
leftkey = KbName('LeftArrow');
rightkey = KbName('RightArrow');

if const.TEST == 1
    ShowCursor;
    SetMouse(scr.centerX, scr.centerY, scr.main); % set mouse 
else
    HideCursor;
end

% % predefine boundary information
% cxm = round(td.fixLoc(1));
% cym = round(td.fixLoc(2));
% chk = visual.fixCkRad;
% 
% % draw trial information on EyeLink operator screen
% Eyelink('command','draw_cross %d %d', cxm, cym);
% 
% % coord
% far_loc = [cxm + td.side * visual.ppd * (td.ecc + td.dE/2), cym]; 
% near_loc = [cxm - td.side * visual.ppd * (td.ecc  - td.dE/2), cym];
% 
% % generate noise background for this trial
% bgmat = visual.bgColor + td.bg_sigma*randn(scr.yres, scr.xres);
% bgtexture = Screen('MakeTexture', scr.main, uint8(bgmat)); 
% 
% % target texture
% [x, y] = meshgrid(1:scr.xres, 1:scr.yres);
% absoluteDifference = abs(visual.white - visual.bgColor);
% 
% % with this you can have the constant energy one
% if td.FE
%     imageMat_far =  1/(2*pi*td.sigma^2) *  exp(-(((x-far_loc(1)) .^ 2) + ((y-far_loc(2)) .^ 2)) / (2*td.sigma ^ 2));
%     imageMat_near =  1/(2*pi*td.sigma^2) *  exp(-(((x-near_loc(1)) .^ 2) + ((y-near_loc(2)) .^ 2)) / (2*td.sigma ^ 2));
% 
% else
%     % this keep the peak constant and vary only the sigma
%     imageMat_far =  exp(-(((x-far_loc(1)) .^ 2) + ((y-far_loc(2)) .^ 2)) / (2*td.sigma ^ 2));
%     imageMat_near = exp(-(((x-near_loc(1)) .^ 2) + ((y-near_loc(2)) .^ 2)) / (2*td.sigma ^ 2));
% end
%     
% targetImageMatrix = bgmat + td.contrast*absoluteDifference*(imageMat_far + imageMat_near);
% targettexture = Screen('MakeTexture', scr.main, uint8(targetImageMatrix));


%% varying pix size
% predefine boundary information
cxm = round(td.fixLoc(1));
cym = round(td.fixLoc(2));
chk = visual.fixCkRad;

% draw trial information on EyeLink operator screen
Eyelink('command','draw_cross %d %d', cxm, cym);

% coord
%far_loc = [cxm + td.side * visual.ppd * (td.ecc + td.dE/2), cym] / design.pixSixe; 
%near_loc = [cxm - td.side * visual.ppd * (td.ecc  - td.dE/2), cym] / design.pixSixe;

far_loc = [cxm + sign(td.dE) * visual.ppd * (td.ecc + abs(td.dE)/2), cym] / design.pixSixe; 
near_loc = [cxm - sign(td.dE) * visual.ppd * (td.ecc  - abs(td.dE)/2), cym] / design.pixSixe;


% generate noise background for this trial
bgmat = visual.bgColor + td.bg_sigma*randn(scr.yres/design.pixSixe, scr.xres/design.pixSixe);
bgtexture = Screen('MakeTexture', scr.main, uint8(repelem(bgmat,design.pixSixe,design.pixSixe))); 

% target texture
[x, y] = meshgrid(1:scr.xres/design.pixSixe, 1:scr.yres/design.pixSixe);
absoluteDifference = abs(visual.white - visual.bgColor);
scaled_sigma = td.sigma/design.pixSixe;

% with this you can have the constant energy one
if td.FE
    imageMat_far =  1/(2*pi*td.sigma^2) *  exp(-(((x-far_loc(1)) .^ 2) + ((y-far_loc(2)) .^ 2)) / (2*scaled_sigma ^ 2));
    imageMat_near =  1/(2*pi*td.sigma^2) *  exp(-(((x-near_loc(1)) .^ 2) + ((y-near_loc(2)) .^ 2)) / (2*scaled_sigma ^ 2));
    PeakLum = (td.contrast * 1/(2*pi*td.sigma^2) * absoluteDifference);
    

else
    % this keep the peak constant and vary only the sigma
    imageMat_far =  exp(-(((x-far_loc(1)) .^ 2) + ((y-far_loc(2)) .^ 2)) / (2*scaled_sigma ^ 2));
    imageMat_near = exp(-(((x-near_loc(1)) .^ 2) + ((y-near_loc(2)) .^ 2)) / (2*scaled_sigma ^ 2));
    PeakLum = (td.contrast * absoluteDifference);
    
end
    
targetImageMatrix = bgmat + td.contrast*absoluteDifference*(imageMat_far + imageMat_near);
targettexture = Screen('MakeTexture', scr.main, uint8(repelem(targetImageMatrix,design.pixSixe,design.pixSixe)));


%%

% predefine time stamps
tOn    = NaN;
tOff    = NaN;
tResp   = NaN; 

% other flags
ex_fg = 0;      % 0 = ok; 1 = fix break
eventStr = 'EVENT_TargetOnset';

% draw fixation 
Screen('DrawTexture', scr.main, bgtexture,[],[]);
drawFixation(visual.fixCol,[cxm cym],scr,visual);
tFix = Screen('Flip', scr.main,0);
Eyelink('message', 'EVENT_FixationDot');
if const.TEST>0; fprintf(1,strcat('\n','EVENT_FixationDot')); end
if const.saveMovie
    Screen('AddFrameToMovie', scr.main, visual.imageRect, 'frontBuffer', const.moviePtr, round(td.soa/scr.fd)); 
end

% random SoA before stimulus
tFlip = tFix + td.soa;
%WaitSecs(td.soa - design.preRelease);

% fixation check
if const.TEST < 2
    while GetSecs < (tFix +td.soa - scr.fd)
        [x,y] = getCoord(scr, const); % get eye position data
        chkres = checkGazeAtPoint([x,y],[cxm,cym],chk);
        if ~chkres
            ex_fg = 1;
        end
    end
end
    
% draw stimuli 
Screen('DrawTexture', scr.main, targettexture,[],[]);
drawFixation(visual.fixCol,[cxm cym],scr,visual);
tFlip = Screen('Flip', scr.main, tFlip);

Eyelink('message', eventStr);
eventStr = 'EVENT_TargetOffset';
if const.saveMovie
    Screen('AddFrameToMovie', scr.main, visual.imageRect, 'frontBuffer', const.moviePtr, round(design.dur/scr.fd)); 
end

%
tOn = tFlip;
tFlip = tFlip + design.dur;

% fixation check
if const.TEST < 2
    while GetSecs < (tOn + design.dur - scr.fd)
        [x,y] = getCoord(scr, const); % get eye position data
        chkres = checkGazeAtPoint([x,y],[cxm,cym],chk);
        if ~chkres
            ex_fg = 1;
        end
    end
end

%
Screen('DrawTexture', scr.main, bgtexture,[],[]);
%drawFixation(visual.fixCol,[cxm cym],scr,visual);
tFlip = Screen('Flip', scr.main, tFlip);
Eyelink('message', eventStr);
tOff = tFlip;

%
if const.saveMovie
    Screen('AddFrameToMovie', scr.main, visual.imageRect, 'frontBuffer', const.moviePtr, round(0.5/scr.fd)); 
end


%% trial end

switch ex_fg
    
    case 1
        data = 'fixBreak';
        Eyelink('command','draw_text 100 100 15 Fixation break');
                
    case 0
        
        % trial OK; collect response
        while 1
            [keyisdown, secs, keycode] = KbCheck(-1);
            
            if keyisdown && (keycode(leftkey) || keycode(rightkey))
                tResp = secs - tOff;
                
                if keycode(leftkey)
                    resp = -1;
                    rr = 0;
                    if td.side == resp
                        acc = 1;
                    else
                        acc = 0;
                    end
                else
                    resp = 1;
                    rr = 1;
                    if td.side == resp
                        acc = 1;
                    else
                        acc = 0;
                    end
                end
                break;
            end
        end
        
        % collect trial information
        trialData = sprintf('%i\t%.2f\t%.2f\t%i\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f',[td.side td.ecc td.dE td.contrast td.sigma td.FE PeakLum NaN NaN td.soa]); 
        
        % timing
        timeData = sprintf('%.2f\t%.2f\t%.2f\t%.2f',[tFix tOn tOff tResp]);
        
        % determine response data
        respData = sprintf('%i\t%i',[resp acc]);
        
        % collect data for tab [14 x trialData, 6 x timeData, 1 x respData]
        data = sprintf('%s\t%s\t%s',trialData, timeData, respData);
        
end


% close active textures
Screen('Close', bgtexture);
Screen('Close', targettexture);

