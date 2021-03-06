function [M,behavior,stim] = GetTimeIndexedData(hfig,isAllCells) %#ok<INUSD>
%{
% naming convention used:
M = GetTimeIndexedData(hfig);
M_0 = GetTimeIndexedData(hfig,'isAllCells');
%}

isZscore = getappdata(hfig,'isZscore');
% main data input
if ~isZscore,
    cellResp = getappdata(hfig,'CellResp');
    cellRespAvr = getappdata(hfig,'CellRespAvr');
else
    cellResp = getappdata(hfig,'CellRespZ');
    cellRespAvr = getappdata(hfig,'CellRespAvrZ');
end
Behavior_full = getappdata(hfig,'Behavior_full');
BehaviorAvr = getappdata(hfig,'BehaviorAvr');
stim_full = getappdata(hfig,'stim_full');
stimAvr = getappdata(hfig,'stimAvr');
% other params
isAvr = getappdata(hfig,'isAvr');
cIX = getappdata(hfig,'cIX');
tIX = getappdata(hfig,'tIX');

%% set data
if isAvr,
    if exist('isAllCells','var'),
        M = cellRespAvr(:,tIX);
    else
        M = cellRespAvr(cIX,tIX);
    end
    behavior = BehaviorAvr(:,tIX);
    stim = stimAvr(:,tIX);
else
    if exist('isAllCells','var'),
        M = cellResp(:,tIX);
    else
        M = cellResp(cIX,tIX);
    end
    behavior = Behavior_full(:,tIX);
    stim = stim_full(:,tIX);
end

setappdata(hfig,'behavior',behavior);
setappdata(hfig,'stim',stim);
end