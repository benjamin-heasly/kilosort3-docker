% Sanity check for Kilosort installation based on eMouse simulation.
%
% This function is intended for automated / unattended testing of a
% Kilosort installation.  It uses the eMouse simulator to generate data to
% be sorted, then tries to do spike sorting with Kilosort's utilities and
% GPU-accelerated mex-functions.
%
% If the installation is good:
%  - This function should complete without error.
%  - This function should print a summary to the Command Window / sdtout.
%  - Sanity check assertions at the end of this function should pass.
%
% This was written with Docker containers and Linux in mind.  It should
% run on Windows, too (or we should update it to make that be so).
%
function [success, rezFile, phyDir] = testKilosortEMouse(eMouseDataDir, outDir, varargin)

arguments
    eMouseDataDir = fullfile('/', 'home', 'matlab', 'eMouse')
    outDir = fullfile(eMouseDataDir, 'results')
end

arguments (Repeating)
    varargin
end

if ~isfolder(eMouseDataDir)
    mkdir(eMouseDataDir)
end

if ~isfolder(outDir)
    mkdir(outDir)
end

%% Generate eMouse simulated data.

% Create the simulated probe channel map: 64 sites with imec 3A geometry.
NchanTOT = 64;
chanMapName = make_eMouseChannelMap_3B_short(eMouseDataDir, NchanTOT);

% Generate simulated neural data.
useGPU = 1;
useParPool = 0;
make_eMouseData_drift(eMouseDataDir, kilosortCodeDir, chanMapName, useGPU, useParPool);

% Choose kilosort ops suitable for the simulated probe and neural data.
% See Kilosort/configFiles/StandardConfig_MOVEME.m for some explanation.
ops.chanMap = fullfile(eMouseDataDir, chanMapName);
ops.NchanTOT = NchanTOT;

ops.rootZ = eMouseDataDir;
ops.fbinary = fullfile(eMouseDataDir,  'sim_binary.imec.ap.bin');
ops.trange = [0 Inf];

ops.fproc = fullfile(eMouseDataDir, 'temp_wh.dat');

ops.fs = 30000;
ops.fshigh = 300;
ops.minfr_goodchannels = 0.1;
ops.Th = [9 9];
ops.lam = 10;
ops.AUCsplit = 0.9;
ops.minFR = 1 / 50;
ops.momentum = [20 400];
ops.sigmaMask = 30;
ops.sig = 20;
ops.ThPre = 8;
ops.reorder = 1;
ops.nskip = 25;
ops.spkTh = -6;
ops.GPU = 1;
ops.nfilt_factor = 4;
ops.ntbuff = 64;
ops.NT = 64 * 1024 + ops.ntbuff;
ops.whiteningRange = 32;
ops.nSkipCov = 25;
ops.scaleproc = 200;
ops.nPCs = 3;
ops.useRAM = 0;
ops.nblocks = 5;


%% Run Kilosort and report sanity checks.
[rezFile, phyDir, rez] = runKilosort(ops, outDir, varargin);

clusterCount = numel(rez.good);
goodCount = sum(rez.good > 0);
success = any(rez.good);
if success
    fprintf('Success: found %d clusters with %d considered "good".\n', clusterCount, goodCount);
else
    fprintf('Failure: found %d clusters but none considered "good".\n', clusterCount);
end


%% Record a table of raw cluster info.
clusterGroupFile = fullfile(outDir, 'cluster_group.tsv');
fileID = fopen(clusterGroupFile, 'w');
fprintf(fileID, 'cluster_id%sgroup', char(9));
fprintf(fileID, char([13 10]));
for k = 1:length(rez.good)
    if rez.good(k)
        fprintf(fileID, '%d%sgood', k-1, char(9));
        fprintf(fileID, char([13 10]));
    end
end
fclose(fileID);


%% Compare sorting results to eMouse ground truth.
sortType = 2;
bAutoMerge = 0;
benchmark_drift_simulation(rez, ...
    fullfile(outDir, 'eMouseGroundTruth.mat'), ...
    fullfile(outDir, 'eMouseSimRecord.mat'), ...
    sortType, ...
    bAutoMerge, ...
    fullfile(outDir, 'output_cluster_metrics.txt'));


%% Save any figures produced above so we can view the images.
figures = findobj('Type', 'figure');
for ii = 1:numel(figures)
    fig = figures(ii);
    name = sprintf('testKilosortEMouse-%d.png', ii);
    file = fullfile(outDir, name);
    saveas(fig, file);
end
