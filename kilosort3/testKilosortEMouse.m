% Sanity check for Kilosort installation based on eMouse simulation.
%
% This function is intended for automated / unattended testing of a
% Kilosort installation.  It uses the eMouse simulator to generate data to
% be sorted, then invokes kilosort sourting routines that will try to do
% spike sorting with Kilosort's GPU-accelerated mex-functions.
%
% If the installation is good:
%  - This function should complete without error.
%  - This function should print a summary to the Command Window / sdtout.
%  - Sanity check assertions at the end of this function should pass.
%
% This was writting with Docker containers and Linux in mind.  It should
% run on Windows, too (or we should update it to make that be so).
%
function success = testKilosortEMouse(eMouseDataDir, kilosortCodeDir, kilosortScratchDir)

arguments
    eMouseDataDir = fullfile('/', 'home', 'matlab', 'eMouse')
    kilosortCodeDir = fileparts(which('kilosort.m'));
    kilosortScratchDir = fullfile('/', 'home', 'matlab', 'kilosortScratch');
end

success = false;

if ~isfolder(eMouseDataDir)
    mkdir(eMouseDataDir)
end

if ~isfolder(kilosortScratchDir)
    mkdir(kilosortScratchDir)
end

% Create the simulated probe channel map: 64 sites with imec 3A geometry.
NchanTOT = 64;
chanMapName = make_eMouseChannelMap_3B_short(eMouseDataDir, NchanTOT);

% Generate simulated neural data.
useGPU = 1;
useParPool = 0;
make_eMouseData_drift(eMouseDataDir, kilosortCodeDir, chanMapName, useGPU, useParPool)

% Choose kilosort options suitable for the simulated probe and neural data.
% See Kilosort/configFiles/StandardConfig_MOVEME.m for some explanation.
ops.chanMap = fullfile(eMouseDataDir, chanMapName);
ops.NchanTOT = NchanTOT;

ops.rootZ = eMouseDataDir;
ops.fbinary = fullfile(eMouseDataDir,  'sim_binary.imec.ap.bin');
ops.trange = [0 Inf];

ops.fproc = fullfile(kilosortScratchDir, 'temp_wh.dat');

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

% Reinitialize the GPU.
gpuDevice(1);   %re-initialize GPU

%% Run Kilosort utils on the simulated probe and neural data.
rez = preprocessDataSub(ops);
rez = datashift2(rez, 1);
[rez, st3, tF] = extract_spikes(rez);
rez = template_learning(rez, tF, st3);
[rez, st3, tF] = trackAndSort(rez);
rez = final_clustering(rez, tF, st3);
rez = find_merges(rez, 1);
rez.good = get_good_units(rez);

% Export results to Numpy / Phy.
rezToPhy(rez, eMouseDataDir);

% Discard features in final rez file (too slow to save) (what??)
rez.cProj = [];
rez.cProjPC = [];

rezFileName = fullfile(eMouseDataDir, 'rezFinal.mat');
save(rezFileName, 'rez', '-v7.3');

clusterGroupFile = fullfile(eMouseDataDir, 'cluster_group.tsv');
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

% Report sanity checks.
sumOfGood = sum(rez.good>0);
assert(any(sumOfGood), 'We didn''t find any good clusters');

disp('We found some good clusters:')
disp(sumOfGood)

success = true;
