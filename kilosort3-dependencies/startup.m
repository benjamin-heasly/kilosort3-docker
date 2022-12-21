% Log what we have here for official Matlab stuff.
ver

% Get kilosort on the path.
kilosortPath = '/home/matlab/kilosort';
addpath(genpath(kilosortPath));

fprintf('Found kilosort at %s\n', which('kilosort'));

[~, gitStatus] = system(sprintf('git -C %s status', kilosortPath));
fprintf('Kilosort git status:\n%s\n', gitStatus);
