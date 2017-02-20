function test(package)
    if nargin < 1
        package = 'sa_labs.analysis';
    end
    
    rootPath = fileparts(mfilename('fullpath'));
    addpath(genpath(fullfile(rootPath, 'lib')));
    tbUse('mmockito');
    addpath(genpath(fullfile(rootPath, 'src')));
    addpath(genpath(fullfile(rootPath, 'apps')));
        
    initializeLogger();
    suite = matlab.unittest.TestSuite.fromPackage(package, 'IncludingSubpackages', true);
    results = run(suite);
    
    failed = sum([results.Failed]);
    if failed > 0
        error([num2str(failed) ' test(s) failed!']);
    end
    
    
    function initializeLogger()
        [log, ~] = logging.getLogger(sa_labs.analysis.app.Constants.ANALYSIS_LOGGER, 'path', 'test.log');
        log.setLogLevel(logging.logging.ALL);
        log.setCommandWindowLevel(logging.logging.DEBUG);
    end
end
