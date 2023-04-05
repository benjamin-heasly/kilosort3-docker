% Exercise the summarizeRez() code and make correctness assertions.
function testSummarizeRez()

% Load some expected Kilosort "rez" data.
% This came from Kilosort, then I truncated big fields to save space.
thisDir = fileparts(mfilename('fullpath'));
fixtureFile = fullfile(thisDir, 'rez.mat');
fixtureData = load(fixtureFile);

% Here's what the summary should look like.
goodClusters = [4, 14, 18, 22, 24, 25, 28, 29, 31, 34, 35, 41, 49, 54]';
clusterSpikeCount = [223, 929, 483, 86, 932, 669, 61, 37, 66, 155, 107, ...
    876, 1, 1, 43, 39, 13, 0, 0, 622, 67, 1, 155, 3, 1, 0, 0, 1, 0, 1, ...
    0, 0, 4, 0, 2, 3, 124, 20, 749, 3, 3, 180, 125, 336, 1, 214, 213, ...
    2, 34, 412, 350, 49, 168, 14, 3, 76, 1343]';
expectedSummary = struct( ...
    'clusterCount', 57, ...
    'goodCount', 14, ...
    'goodClusters', goodClusters, ...
    'spikeCount', 10000, ...
    'clusterSpikeCount', clusterSpikeCount);

% Work in a temp dir during the tests.
testDir = fullfile(tempdir(), 'testSummarizeRez');
if ~isfolder(testDir)
    mkdir(testDir);
end
originalDir = pwd();
cleanup = onCleanup(@() cd(originalDir));
cd(testDir);


%% Expected Summary in Matlab.
summary = summarizeRez(fixtureData.rez);
assert(isequal(summary, expectedSummary))


%% Expected Summary in JSON.
[summary, outFile] = summarizeRez(fixtureData.rez);
summaryFromJson = loadStruct(outFile);
assert(isequal(summaryFromJson, summary))
assert(isequal(summaryFromJson, expectedSummary))


%% Alternative file.
alternativeOutFile = fullfile(testDir, 'alternative', 'summary.json');
[summary, outFile] = summarizeRez(fixtureData.rez, alternativeOutFile);
assert(isequal(outFile, alternativeOutFile));
summaryFromJson = loadStruct(alternativeOutFile);
assert(isequal(summaryFromJson, summary))
assert(isequal(summaryFromJson, expectedSummary))
