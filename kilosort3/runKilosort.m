% A "main" entrypoint for running Kilosort in noninteractive / batch mode.
%
% This is driven by a Kilosort ops struct which can be passed in as a
% struct or as the string name of a .mat file to load into a struct.
%
% Running this will invoke a standard set of Kilosort utils as found in
% Kilosort's main_kilosort3.m.  Results will be written to the given
% outDir, including:
%  - the Kilosort "rez" struct
%  - a subdir of files for the Python phy tool.
%
% Inputs:
%
% ops -- Kilosort ops, supporting several input formats via loadStruct()
% outDir -- directory where outputs should be saved
%
% In addition to these positional arguments, optional name-value pairs are
% allowed.
%
% ops -- A value passed with the 'ops' name will be read in as a struct,
%        supporting several input formats via loadStruct().  Fields of this
%        new struct will supplement and/or override fields of the original
%        ops struct pass in as the first positional argument.  In addition
%        to standard Kilosort ops, keys tStart and/or tEnd can be included,
%        with their values set to ops.trange(1) and/or ops.trange(2),
%        respectively.
% dryRun -- If true, skips actual Kilosort run.  Default is false.
% driftCorrection -- If true, applies Kilosort3 drift correction to the
%                    incoming data on disk.  Setting to false might make
%                    sense for widely-spaced probe contacts.  Default is
%                    true.
% autoMerge -- If true, Kilosort3 will automatically merge clusters based
%              on template correlation, spike cross-correlograms, and spike
%              refractoriness.  If false, just computes cross-correlogram
%              and spike refractoriness scores.  Default is true.
%
% Outputs:
%
% rezFile -- path where Kilosort's own "rez" struct is saved to file
% phyDir -- path to generated files for the Python phy tool
% rez -- Kilosort's own "rez" struct as a Matlab variabe in memory
function [rezFile, phyDir, rez] = runKilosort(ops, outDir, varargin)

arguments
    ops { mustBeNonempty }
    outDir = pwd()
end

arguments (Repeating)
    varargin
end

% Parse out optional 'ops' name-value pair.
% Only one option for now, but inputParser is nice, and extensible.
parser = inputParser();
parser.CaseSensitive = true;
parser.KeepUnmatched = false;
parser.PartialMatching = false;
parser.StructExpand = true;

parser.addParameter('ops', struct());
parser.addParameter('dryRun', false);
parser.addParameter('driftCorrection', true);
parser.addParameter('autoMerge', true);

parser.parse(varargin{:});

start = datetime('now', 'Format', 'uuuuMMdd''T''HHmmss');
fprintf('runKilosort Start at: %s\n', char(start));

if ~isstruct(ops)
    fprintf('runKilosort Loading ops.\n');
    ops = loadStruct(ops);
end

fprintf('runKilosort Merging ops positional arg with any ''ops'' overrides.\n');
customOps = loadStruct(parser.Results.ops);
customFields = fieldnames(customOps);
for ii = 1:numel(customFields)
    fieldName = customFields{ii};
    fprintf('runKilosort Overriding ops %s with value: %s\n', fieldName, mat2str(customOps.(fieldName)));
    ops.(fieldName) = customOps.(fieldName);
end

if isfield(ops, 'tStart')
    fprintf('runKilosort setting ops.trange(1) from ops.tStart: %f\n', ops.tStart);
    if ~isfield(ops, 'trange')
        ops.trange = [ops.tStart, inf];
    else
        ops.trange(1) = ops.tStart;
    end
end

if isfield(ops, 'tEnd')
    fprintf('runKilosort setting ops.trange(2) from ops.tEnd: %f\n', ops.tEnd);
    ops.trange(2) = ops.tEnd;
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

if ~isfolder(outDir)
    mkdir(outDir);
end


%% Run Kilosort utils to create the "rez" struct.
if parser.Results.dryRun
    fprintf('runKilosort Dry run: skipping actual kilosort run.\n');
    rez.ops = ops;
else
    fprintf('runKilosort Initializing GPU.\n');
    gpuDevice(1);

    fprintf('runKilosort Beginning kilosort run...\n');
    fprintf('\n')
    rez = preprocessDataSub(ops);
    rez = datashift2(rez, parser.Results.driftCorrection);
    [rez, st3, tF] = extract_spikes(rez);
    rez = template_learning(rez, tF, st3);
    [rez, st3, tF] = trackAndSort(rez);
    rez = final_clustering(rez, tF, st3);
    rez = find_merges(rez, parser.Results.autoMerge);
    fprintf('\n')
    fprintf('runKilosort Finished kilosort run.\n');
end


%% Export results to Numpy / Phy.
phyDir = fullfile(outDir, 'phy');
if parser.Results.dryRun
    fprintf('runKilosort Dry run: skipping phy file writing.\n');
else
    fprintf('runKilosort Writing phy files to %s.\n', phyDir);
    if ~isfolder(phyDir)
        mkdir(phyDir);
    end
    rezToPhy2(rez, phyDir);
end


%% Save Kilosort's own results.
rezFile = fullfile(outDir, 'rez.mat');
if parser.Results.dryRun
    fprintf('runKilosort Dry run: skipping Kilosort "rez" file writing.\n');
else
    fprintf('runKilosort Writing "rez" struct to %s.\n', rezFile);
    save(rezFile, 'rez', '-v7.3');
end

tFFile = fullfile(outDir, 'tF.mat');
if parser.Results.dryRun
    fprintf('runKilosort Dry run: skipping Kilosort "tF" file writing.\n');
else
    fprintf('runKilosort Writing "tF" spike template features to %s.\n', tFFile);
    save(tFFile, 'tF', '-v7.3');
end


%% Save any figures produced by Kilosort, so we can view the images.
figures = findobj('Type', 'figure');
for ii = 1:numel(figures)
    fig = figures(ii);
    name = sprintf('runKilosort-%d.png', ii);
    file = fullfile(outDir, name);
    saveas(fig, file);
end


finish = datetime('now', 'Format', 'uuuuMMdd''T''HHmmss');
duration = finish - start;
fprintf('runKilosort Finish at: %s (%s elapsed)\n\n', char(finish), char(duration));
