% Summarize a Kilosort "rez" struct in JSON, to integrate with other tools.
%
% Inputs:
%
% rez -- Kilosort rez struct with sorting results
% outFile -- path to file where JSON summary should be saved
%            (default is ./rez-summary.json)
%
% Outputs:
%
% summary-- a struct version of the rez summary
% outFile -- the outFile path as given, or default
function [summary, outFile] = summarizeRez(rez, outFile)

arguments
    rez struct
    outFile = fullfile(pwd(), 'rezSummary.json')
end


%% Summarize some rez info to a plain old struct.
clusterCount = numel(rez.good);
summary.clusterCount = clusterCount;
summary.goodCount = sum(rez.good);
summary.goodClusters = find(rez.good);
summary.spikeCount = size(rez.st3, 1);

clusterSpikeCount = zeros([clusterCount, 1]);
for ii = 1:clusterCount
    clusterSpikeCount(ii) = sum(rez.st3(:,2) == ii);
end
summary.clusterSpikeCount = clusterSpikeCount;


%% Write the summary struct to JSON.
outDir = fileparts(outFile);
if ~isempty(outDir) && ~isfolder(outDir)
    mkdir(outDir);
end

fprintf('summarizeRez Writing rez summary to %s.\n', outFile);
summaryJson = jsonencode(summary);
writelines(summaryJson, outFile);
