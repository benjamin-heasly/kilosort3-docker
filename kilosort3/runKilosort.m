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
% ops -- a value passed with the 'ops' name will be read as a struct,
%        supporting several input formats via loadStruct().  Fields of this
%        new struct will supplement and/or override fields of the original
%        ops struct from the first positional argument.
% dryRun -- if true, skips actual Kilosort run
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
if parser.Results.dryRun
    fprintf('runKilosort Dry run: skipping actual kilosort run.\n');
    rez.ops = ops;
else
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

% Discard features in final rez file (too slow to save)
% Why is this / what does this mean?
rez.cProj = [];
rez.cProjPC = [];

if parser.Results.dryRun
    fprintf('runKilosort Dry run: skipping Kilosort "rez" file writing.\n');
else
    fprintf('runKilosort Writing "rez" struct to %s.\n', phyDir);
    save(rezFile, 'rez', '-v7.3');
end


finish = datetime('now', 'Format', 'uuuuMMdd''T''HHmmss');
duration = finish - start;
fprintf('runKilosort Finish at: %s (%s elapsed)\n\n', char(finish), char(duration));
