classdef DaoTest < matlab.unittest.TestCase
    
    properties
        daoContext
    end
    
    properties(Constant)
        file_prefix = 'c_test';
    end
    
    methods (TestClassSetup)
        
        function initContext(obj)
            ctx = struct();
            ctx.analysisDao.class = 'symphony.analysis.dao.AnalysisDao';
            ctx.analysisDao.repository = 'fileRepository';
            ctx.fileRepository.class = 'symphony.analysis.app.FileRepository';
            obj.daoContext = mdepin.createApplication(ctx, 'analysisDao');
            rep = obj.daoContext.repository;
            for i = 1 : 10
                path = [rep.rawDataFolder filesep datestr(now, 'mmddyy') obj.file_prefix num2str(i) '.h5'];
                h5create(path ,'/ds' , [10 20]);
                h5writeatt(path, '/','version', 1);
            end
        end
    end
    
    methods(Test)
        
        function testFileRepositorySettings(obj)
            rep = obj.daoContext.repository;
            obj.verifyGreaterThan(regexp(rep.analysisFolder, '\w*analysis'), 1);
            obj.verifyGreaterThan(regexp(rep.rawDataFolder, '\w*rawDataFolder'), 1);
            obj.verifyGreaterThan(regexp(rep.preferenceFolder, '\w*PreferenceFiles'), 1);
        end
        
        function testFindRawDataFiles(obj)
            dao = obj.daoContext;
            dao.testFindRawDataFiles()
        end
    end
end

