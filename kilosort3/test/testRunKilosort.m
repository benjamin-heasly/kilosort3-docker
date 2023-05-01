% Exercise the runKilosort() code and make correctness assertions.
function testRunKilosort()

testOps = struct('foo', 'bar', 'baz', 42);
testOutDir = 'test';

%% Basic Ops Struct.
[rezFile, phyDir, rez] = runKilosort(testOps, testOutDir, 'dryRun', true);
assert(isequal(rezFile, fullfile(testOutDir, 'rez.mat')));
assert(isequal(phyDir, fullfile(testOutDir, 'phy')));
expectedOps = testOps;
expectedOps.useStableMode = true;
expectedOps.LTseed = 1;
assert(isequal(rez.ops, expectedOps));


%% Ops Struct from JSON.
opsJson = '{"foo": "bar", "baz": 42}';
[rezFile, phyDir, rez] = runKilosort(opsJson, testOutDir, 'dryRun', true);
assert(isequal(rezFile, fullfile(testOutDir, 'rez.mat')));
assert(isequal(phyDir, fullfile(testOutDir, 'phy')));
expectedOps = testOps;
expectedOps.useStableMode = true;
expectedOps.LTseed = 1;
assert(isequal(rez.ops, expectedOps));


%% Ops with Overrides.
customOps = struct('baz', 1000, 'quux', false);
[rezFile, phyDir, rez] = runKilosort(testOps, testOutDir, 'ops', customOps, 'dryRun', true);
assert(isequal(rezFile, fullfile(testOutDir, 'rez.mat')));
assert(isequal(phyDir, fullfile(testOutDir, 'phy')));

expectedOps = struct('foo', 'bar', 'baz', 1000, 'quux', false, 'useStableMode', true, 'LTseed', 1);
assert(isequal(rez.ops, expectedOps));


%% Ops with Overrides from JSON.
customOpsJson = '{"baz": 1000, "quux": false}';
[rezFile, phyDir, rez] = runKilosort(testOps, testOutDir, 'ops', customOpsJson, 'dryRun', true);
assert(isequal(rezFile, fullfile(testOutDir, 'rez.mat')));
assert(isequal(phyDir, fullfile(testOutDir, 'phy')));

expectedOps = struct('foo', 'bar', 'baz', 1000, 'quux', false, 'useStableMode', true, 'LTseed', 1);
assert(isequal(rez.ops, expectedOps));


%% Ops with override tStart into trange(1).
trangeOps = struct('foo', 'bar', 'baz', 42, 'trange', [1 100]);
customOps = struct('tStart', 2);
[~, ~, rez] = runKilosort(trangeOps, testOutDir, 'ops', customOps, 'dryRun', true);
expectedOps = struct('foo', 'bar', 'baz', 42, 'trange', [2 100], 'tStart', 2, 'useStableMode', true, 'LTseed', 1);
assert(isequal(rez.ops, expectedOps));


%% Ops with override tStart creating trange.
customOps = struct('tStart', 2);
[~, ~, rez] = runKilosort(testOps, testOutDir, 'ops', customOps, 'dryRun', true);
expectedOps = struct('foo', 'bar', 'baz', 42, 'trange', [2 inf], 'tStart', 2, 'useStableMode', true, 'LTseed', 1);
assert(isequal(rez.ops, expectedOps));


%% Ops with override tEnd creating tRange(2).
trangeOps = struct('foo', 'bar', 'baz', 42, 'trange', [1 100]);
customOps = struct('tEnd', 99);
[~, ~, rez] = runKilosort(trangeOps, testOutDir, 'ops', customOps, 'dryRun', true);
expectedOps = struct('foo', 'bar', 'baz', 42, 'trange', [1 99], 'tEnd', 99, 'useStableMode', true, 'LTseed', 1);
assert(isequal(rez.ops, expectedOps));


%% Ops with override tEnd creating trange.
customOps = struct('tEnd', 99);
[~, ~, rez] = runKilosort(testOps, testOutDir, 'ops', customOps, 'dryRun', true);
expectedOps = struct('foo', 'bar', 'baz', 42, 'trange', [0 99], 'tEnd', 99, 'useStableMode', true, 'LTseed', 1);
assert(isequal(rez.ops, expectedOps));


%% Ops with nested struct.
customOps = struct('nestedStruct', struct('quux', 9000));
[~, ~, rez] = runKilosort(testOps, testOutDir, 'ops', customOps, 'dryRun', true);
expectedOps = struct('foo', 'bar', 'baz', 42, 'nestedStruct', struct('quux', 9000), 'useStableMode', true, 'LTseed', 1);
assert(isequal(rez.ops, expectedOps));


%% Override useStableMode and LTseed.
[~, ~, rez] = runKilosort(testOps, testOutDir, 'useStableMode', false, 'LTseed', 42000, 'dryRun', true);
expectedOps = testOps;
expectedOps.useStableMode = false;
expectedOps.LTseed = 42000;
assert(isequal(rez.ops, expectedOps));
