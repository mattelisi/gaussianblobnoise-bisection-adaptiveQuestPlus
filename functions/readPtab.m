function tab = readPtab(vpcode, c)
%
% load posterio probability table from previous Quest+ session
%

subDir=substr(vpcode, 0, 4);
sessionDir=num2str(str2double(substr(vpcode, 5, 2))-1);
if length(sessionDir)==1
    sessionDir = strcat('0',sessionDir);
end
presFile=sprintf('data/%s/%s/%s%s.mat',subDir,sessionDir,subDir,sessionDir);

load(presFile, 'qp');

% sprintf('qp.s%s.tab.p',num2str(c))
eval(['tab = qp.s',num2str(c),'.tab.p;']);

