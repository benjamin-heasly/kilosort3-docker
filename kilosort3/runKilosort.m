% A "main" entrypoint for running Kilosort in noninteractive / batch mode.
%
% This is driven by a Kilosort ops struct which can be passed in as a
% struct or as the string name of a .mat file to load into a struct.
%
% Running this will invoke a standard set of Kilosort utils as found in
% Kilosort's main_kilosort3.m.  Results will be written to the given
% outDir, including the Kilosort "rez" struct, and a subdir of files for
% the Python phy tool.
%
% Inputs:
%
% ops -- struct or name of .mat file with Kilosort ops
% outDir -- directory where outputs should be saved
%
% Following these two positional arguments, additional name-value pairs may
% be passed in.  These will override fields of ops.  This should
% allow the same basic ops to be reused on different data files, for
% example.
%
% Outputs:
%
% rezFile -- path where Kilosort's own "rez" struct is saved
% phyDir -- path to generated files for the Python phy tool
% rez -- Kilosort's own "rez" struct
function [rezFile, phyDir, rez] = runKilosort(ops, outDir, varargin)

arguments
    ops { mustBeNonempty }
    outDir = pwd()
end

arguments (Repeating)
    varargin
end

start = datetime('now', 'Format', 'uuuuMMdd''T''HHmmss');
fprintf('runKilosort Start at: %s\n', char(start));

if isfile(ops)
    fprintf('runKilosort Loading ops from file: %s\n', ops);
    ops = load(ops);
end

for ii = 1:2:numel(varargin)
    opsName = varargin{ii};
    opsValue = varargin{ii + 1};
    fprintf('runKilosort Overriding ops %s with value: %s\n', opsName, mat2str(opsValue));
    ops.(opsName) = opsValue;
end

fprintf('runKilosort Here are the final Kilosort ops:\n');
disp(ops)

% For quality of life, create the Kilosort scratch dir.
if isfield(ops, 'fproc')
    scratchDir = fileparts(ops.fproc);
    if ~isempty(scratchDir) && ~isfolder(scratchDir)
        fprintf('runKilosort Creating parent folder for ops.fproc: %s\n', ops.fproc);
        mkdir(scratchDir)
    end
end


%% Run Kilosort utils to create the "rez" struct.
fprintf('runKilosort Initializing GPU.\n');
gpuDevice(1);

fprintf('runKilosort Beginning kilosort run...\n');
fprintf('\n')
rez = preprocessDataSub(ops);
rez = datashift2(rez, 1);
[rez, st3, tF] = extract_spikes(rez);
rez = template_learning(rez, tF, st3);
[rez, st3, tF] = trackAndSort(rez);
rez = final_clustering(rez, tF, st3);
rez = find_merges(rez, 1);
fprintf('\n')
fprintf('runKilosort Finished kilosort run.\n');


%% Export results to Numpy / Phy.
phyDir = fullfile(outDir, 'phy');
fprintf('runKilosort Writing phy files to %s:\n', phyDir);
if ~isfolder(phyDir)
    mkdir(phyDir);
end
rezToPhy2(rez, phyDir);


%% Save Kilosort's own results.

% Discard features in final rez file (too slow to save)
% Why is this / what does this mean?
rez.cProj = [];
rez.cProjPC = [];

rezFile = fullfile(outDir, 'rez.mat');
save(rezFile, 'rez', '-v7.3');


finish = datetime('now', 'Format', 'uuuuMMdd''T''HHmmss');
duration = finish - start;
fprintf('runKilosort Finish at: %s (%s elapsed)\n', char(finish), char(duration));
