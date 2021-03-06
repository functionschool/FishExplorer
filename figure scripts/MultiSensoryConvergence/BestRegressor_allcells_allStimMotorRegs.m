% fig2C: best clusters/cells? for an array of stim/motor regressors, GUI function
clear all;close all;clc;

hfig = figure;
InitializeAppData(hfig);
ResetDisplayParams(hfig);

%%
range_fish = 8:18;
M_congr = zeros(length(range_fish),1);
M_incongr = zeros(length(range_fish),1);
% M_anat_count = zeros(length(range_fish),3);%6);

%%
for i_fishcount = 1:length(range_fish)
    i_fish = range_fish(i_fishcount);
    
    setappdata(hfig,'isMotorseed',1);
    % i_fish = 8;
    LoadSingleFishDefault(i_fish,hfig);
    
    %% regression with all regs
    % ResetDisplayParams(hfig,i_fish);
    setappdata(hfig,'stimrange',1:2);
    setappdata(hfig,'isStimAvr',0);
    UpdateTimeIndex(hfig);
    
    isRegIndividualCells = 1;
    isRegCurrentCells = 0;
    setappdata(hfig,'thres_reg',0.4);
    [cIX_reg,gIX_reg,numK,IX_regtype,corr_max,names] = AllRegsRegression(hfig,isRegIndividualCells,isRegCurrentCells);
    
    % regtypes_plot = [2,3,8,9,16,17]%[2,3,4,7,8,9,16,17]; % manual input % PT, OMR, joint
%     regtypes_plot = [2,3,8,9,16,17,18,19];%[2,3,4,7,8,9,16,17]; % manual input % PT, OMR, joint, incongruent ('P_l,O_r','P_r,O_l')
    regtypes_plot = [2,3,8,9,16,17,18,19,20,21];%[2,3,4,7,8,9,16,17]; % manual input % PT, OMR, joint, incongruent ('P_l,O_r','P_r,O_l')
    [cIX,gIX] = SelectClusterRange(cIX_reg,gIX_reg,regtypes_plot);
    [gIX, numU] = SqueezeGroupIX(gIX);
    % manually switch order for the last two groups (motor)!
    m1 = regtypes_plot(end-1);
    m2 = regtypes_plot(end);
    gIX_old = gIX;
    gIX(gIX_old==m1) = m2;
    gIX(gIX_old==m2) = m1;
    
    UpdateIndices_Manual(hfig,cIX,gIX,numU);
    
    %% pool congruent / incongruent cells
    % PT/OMR joint cells only
    cIX_cong = union(find(gIX==5),find(gIX==6));
    M_congr(i_fishcount) = length(cIX_cong);
    
    % PT/OMR incongruent cells only
    cIX_incong = union(find(gIX==7),find(gIX==8));
    M_incongr(i_fishcount) = length(cIX_incong);
    

    %% divide by anat
% 
%     % count cells: hindbrain vs not
%     MASKs = getappdata(hfig,'MASKs');
%     CellXYZ_norm = getappdata(hfig,'CellXYZ_norm');
%     absIX = getappdata(hfig,'absIX');
%     
%     % congruent
%     cIX = cIX_cong;
%     gIX = ones(size(cIX));
%     %     Msk_IDs = [94,219,220];% midbrain 94; Rh1 219; Rh2 220; hindbrain 114;
%     cIX_mb = ScreenCellsWithMasks(94,cIX,gIX,MASKs,CellXYZ_norm,absIX);
%     cIX_ahb = ScreenCellsWithMasks([219,220],cIX,gIX,MASKs,CellXYZ_norm,absIX);
%     cIX_phb = ScreenCellsWithMasks([221:225],cIX,gIX,MASKs,CellXYZ_norm,absIX);
%     
%     M_anat_count(i_fishcount,1) = length(cIX_mb)/length(absIX);
%     M_anat_count(i_fishcount,2) = length(cIX_ahb)/length(absIX);
%     M_anat_count(i_fishcount,3) = length(cIX_phb)/length(absIX);
    
%     % incongruent
%     cIX = cIX_incong;
%     gIX = ones(size(cIX));
%      %     Msk_IDs = [94,219,220];% midbrain 94; Rh1 219; Rh2 220; hindbrain 114;
%     cIX_mb = ScreenCellsWithMasks(94,cIX,gIX,MASKs,CellXYZ_norm,absIX);
%     cIX_ahb = ScreenCellsWithMasks([219,220],cIX,gIX,MASKs,CellXYZ_norm,absIX);
%     cIX_phb = ScreenCellsWithMasks([221:225],cIX,gIX,MASKs,CellXYZ_norm,absIX);
%     
%     M_anat_count(i_fishcount,4) = length(cIX_mb)/length(absIX);
%     M_anat_count(i_fishcount,5) = length(cIX_ahb)/length(absIX);
%     M_anat_count(i_fishcount,6) = length(cIX_phb)/length(absIX);
    
end

%% multi-fish summary "bar plot" of congruent vs incongruent convergent cells
figure('Position',[100,400,150,160]);hold on;

inc1 = 0.2;
inc = 0.15;

% connect the x columns with grey lines for each fish
for i_fishcount = 1:length(range_fish)
    Y = [M_congr(i_fishcount),M_incongr(i_fishcount)]; %M_anat_count(i_fishcount,:)*100;
    plot([1,2],Y,'color',[0.7,0.7,0.7],'linewidth',0.5)
end

% plot the data points as dots, with avr and SEM
for x = 1:2
    switch x
        case 1
            Y = M_congr;
        case 2
            Y = M_incongr;
    end
    scatter(x*ones(length(Y),1),Y,20,'MarkerEdgeColor',[0,0,0],'MarkerEdgeAlpha',...
        0.5,'MarkerFaceColor',[0.8,0.8,0.8],'MarkerFaceAlpha',0.5);
    plot([x-inc1,x+inc1],[mean(Y),mean(Y)],'k');
    err = std(Y)/sqrt(length(Y));
    plot([x-inc,x+inc],[mean(Y)+err,mean(Y)+err],'color',[1,0.5,0.5]);
    plot([x-inc,x+inc],[mean(Y)-err,mean(Y)-err],'color',[1,0.5,0.5]);
    plot([x,x],[mean(Y)-err,mean(Y)+err],'color',[1,0.5,0.5]);
end

xlim([0.5,2.5])
set(gca,'XTickLabels',{'congruent','incongruent'},'XTickLabelRotation',45);

[~,p] = ttest2(M_congr,M_incongr);

%% plots for example fish (i_fish=8)

%% left plot
figure('Position',[50,100,400,500]);
% isCentroid,isPlotLines,isPlotBehavior,isPlotRegWithTS
setappdata(hfig,'isPlotBehavior',0);
setappdata(hfig,'isStimAvr',1);
UpdateTimeIndex(hfig);
DrawTimeSeries(hfig,cIX,gIX);

%% right plot
% figure('Position',[50,100,800,1000]);
I = LoadCurrentFishForAnatPlot(hfig,cIX,gIX);
DrawCellsOnAnat(I);

%% right plot of PT/OMR joint cells only
cIX_cong = union(find(gIX==5),find(gIX==6));
cIX2 = cIX(cIX_cong);
gIX2 = gIX(cIX_cong);
% UpdateIndices_Manual(hfig,cIX2,gIX2,numU);
I = LoadCurrentFishForAnatPlot(hfig,cIX2,gIX2);
DrawCellsOnAnat(I);

%% right plot of PT/OMR incongruent cells only
cIX_incong = union(find(gIX==7),find(gIX==8));
cIX2 = cIX(cIX_incong);
gIX2 = gIX(cIX_incong);
% UpdateIndices_Manual(hfig,cIX2,gIX2,numU);
I = LoadCurrentFishForAnatPlot(hfig,cIX2,gIX2);
DrawCellsOnAnat(I);

%% right plot of motor cells only
cIX_cong = union(find(gIX==9),find(gIX==10));
cIX2 = cIX(cIX_cong);
gIX2 = gIX(cIX_cong);
% UpdateIndices_Manual(hfig,cIX2,gIX2,numU);
I = LoadCurrentFishForAnatPlot(hfig,cIX2,gIX2);
DrawCellsOnAnat(I);

%% left plot for the motor traces, not plotted in anat

[cIX,gIX] = SelectClusterRange(cIX_reg,gIX_reg,[7,8]);
UpdateIndices_Manual(hfig,cIX,gIX,numU);
clrmap = [1,0.5,0.5;0.5,0.5,0.5];
opts = [];
opts.clrmap = clrmap;

figure('Position',[50,100,400,500]);
% isCentroid,isPlotLines,isPlotBehavior,isPlotRegWithTS
setappdata(hfig,'isPlotBehavior',0);
setappdata(hfig,'isStimAvr',1);
UpdateTimeIndex(hfig);
DrawTimeSeries(hfig,cIX,gIX,opts);


% %% left-right combined plot
% figure('Position',[50,100,1400,800]);
% % isCentroid,isPlotLines,isPlotBehavior,isPlotRegWithTS
% subplot(121)
% setappdata(hfig,'isPlotBehavior',0);
% setappdata(hfig,'isStimAvr',1);
% UpdateTimeIndex(hfig);
% DrawTimeSeries(hfig,cIX,gIX);
%
% % right plot
% subplot(122)
% I = LoadCurrentFishForAnatPlot(hfig,cIX,gIX);
% DrawCellsOnAnat(I);


%% left plot for the incong traces
% cIX_incong = union(find(gIX==7),find(gIX==8));
% cIX2 = cIX(cIX_incong);
% gIX2 = gIX(cIX_incong);
UpdateIndices_Manual(hfig,cIX2,gIX2,numU);
clrmap = [0.5,0.5,0.5;0.5,0.5,0.5];
opts = [];
opts.clrmap = clrmap;

figure('Position',[50,100,400,500]);
% isCentroid,isPlotLines,isPlotBehavior,isPlotRegWithTS
setappdata(hfig,'isPlotBehavior',0);
setappdata(hfig,'isStimAvr',1);
UpdateTimeIndex(hfig);
DrawTimeSeries(hfig,cIX2,gIX2,opts);


%% left plot for all groups in grey
% cIX_incong = union(find(gIX==7),find(gIX==8));
% cIX2 = cIX(cIX_incong);
% gIX2 = gIX(cIX_incong);
UpdateIndices_Manual(hfig,cIX,gIX,numU);
clrmap = repmat([0.5,0.5,0.5],numU,1);
opts = [];
opts.clrmap = clrmap;

figure('Position',[50,100,400,500]);
% isCentroid,isPlotLines,isPlotBehavior,isPlotRegWithTS
setappdata(hfig,'isPlotBehavior',0);
setappdata(hfig,'isStimAvr',1);
UpdateTimeIndex(hfig);
DrawTimeSeries(hfig,cIX,gIX,opts);

%%
% dataDir = GetCurrentDataDir;
% saveDir = fullfile(dataDir,'motorsourceplot');
% if ~exist(saveDir, 'dir'), mkdir(saveDir), end;
% filename = fullfile(saveDir, num2str(i_fish));
% saveas(gcf, filename, 'png');
% close(gcf)