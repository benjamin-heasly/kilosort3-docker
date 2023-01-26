% Exercise the runKilosort() code and make correctness assertions.
function testRunKilosort()

testOps = struct('foo', 'bar', 'baz', 42);
testOutDir = 'test';

%% Basic Ops Struct.
[rezFile, phyDir, rez] = runKilosort(testOps, testOutDir, 'dryRun', true);
assert(isequal(rezFile, fullfile(testOutDir, 'rez.mat')));
assert(isequal(phyDir, fullfile(testOutDir, 'phy')));
assert(isequal(rez.ops, testOps));


%% Ops Struct from JSON.
opsJson = '{"foo": "bar", "baz": 42}';
[rezFile, phyDir, rez] = runKilosort(opsJson, testOutDir, 'dryRun', true);
assert(isequal(rezFile, fullfile(testOutDir, 'rez.mat')));
assert(isequal(phyDir, fullfile(testOutDir, 'phy')));
assert(isequal(rez.ops, testOps));


%% Ops with Overrides.
customOps = struct('baz', 1000, 'quux', false);
[rezFile, phyDir, rez] = runKilosort(testOps, testOutDir, 'ops', customOps, 'dryRun', true);
assert(isequal(rezFile, fullfile(testOutDir, 'rez.mat')));
assert(isequal(phyDir, fullfile(testOutDir, 'phy')));

expectedOps = struct('foo', 'bar', 'baz', 1000, 'quux', false);
assert(isequal(rez.ops, expectedOps));


%% Ops with Overrides from JSON.
customOpsJson = '{"baz": 1000, "quux": false}';
[rezFile, phyDir, rez] = runKilosort(testOps, testOutDir, 'ops', customOpsJson, 'dryRun', true);
assert(isequal(rezFile, fullfile(testOutDir, 'rez.mat')));
assert(isequal(phyDir, fullfile(testOutDir, 'phy')));

expectedOps = struct('foo', 'bar', 'baz', 1000, 'quux', false);
assert(isequal(rez.ops, expectedOps));
