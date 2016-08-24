classdef DaoTest < matlab.unittest.TestCase
    
    properties
        beanFactory
        testCellDatas
        cellNames
    end
    
    properties(Constant)
        FILE_PREFIX = 'c_test';
        NO_OF_FILES = 10;
    end
    
    methods (TestClassSetup)
        
        function initContext(obj)
            import sa_labs.analysis.*;
            
            obj.beanFactory = mdepin.getBeanFactory(which('TestContext.m'));
            repository = obj.beanFactory.getBean('fileRepository');
            
            fixture = [fileparts(which('test.m')) filesep 'fixtures'];
            repository.preferenceFolder = [fixture filesep 'PreferenceFiles'];
            repository.analysisFolder = [fixture filesep 'analysis'];
            repository.rawDataFolder = [fixture filesep 'rawDataFolder'];
       
            util.file.overWrite(repository.analysisFolder);
            util.file.overWrite(repository.rawDataFolder);
            util.file.overWrite([repository.analysisFolder filesep 'cellData']);

            obj.testCellDatas = entity.CellData.empty(10, 0);
            obj.cellNames = cell(obj.NO_OF_FILES, 1);

            for i = 1 : obj.NO_OF_FILES
                name = [datestr(now, 'mmddyy') obj.FILE_PREFIX num2str(i)];
                path = [repository.rawDataFolder filesep  name '.h5'];
                h5create(path ,'/ds' , [10 20]);
                h5writeatt(path, '/','version', 1);
                cellData = sa_labs.analysis.entity.CellData();
                cellData.savedFileName = name;
                
                obj.testCellDatas(i) = cellData;
                obj.cellNames{i} = name;
            end
        end
    end
    
    methods(Test)
      
        % Test for Analysis Dao
        
        function testFindRawDataFiles(obj)
            dao = obj.beanFactory.getBean('analysisDao');
            files = dao.findRawDataFiles(date);
            obj.verifyEqual(numel(files), obj.NO_OF_FILES);
            
            for i = 1 : numel(files)
                obj.verifyEqual(exist(files{i}, 'file'), 2);
            end
            files = dao.findRawDataFiles(datestr(busdate(date, 1)));
            obj.verifyEmpty(files);
        end
        
        function testSaveCellData(obj)
            dao = obj.beanFactory.getBean('analysisDao');
            path = [dao.repository.analysisFolder filesep 'cellData' filesep];
            arrayfun(@(d) dao.saveCellData(d), obj.testCellDatas);
            
            for i = 1 : obj.NO_OF_FILES
                name = obj.cellNames{i};
                obj.verifyEqual(exist([path name '.mat'], 'file'), 2);
            end
        end
        
        function testCreateProject(obj)
             dao = obj.beanFactory.getBean('analysisDao');
             folder = dao.createProject(obj.cellNames);
             text = importdata([folder filesep 'cellNames.txt'],'\n');
             obj.verifyEqual(obj.cellNames, text);
        end
        
        function testFindCellDataNames(obj)
            dao = obj.beanFactory.getBean('analysisDao');
            names = dao.findCellDataNames(date);
            obj.verifyEmpty(setdiff(obj.cellNames, names));
            names = dao.findCellDataNames(datestr(busdate(date, 1)));
            obj.verifyEmpty(names);
        end
        
        function testLoadCellData(obj)
            dao = obj.beanFactory.getBean('analysisDao');
            fname = [datestr(now, 'mmddyy') obj.FILE_PREFIX '1'];
            data = dao.loadCellData(fname);
            obj.verifyEqual(data.savedFileName, fname);
            
            dataHandle = @()dao.loadCellData('unknown');
            obj.verifyError(dataHandle, 'MATLAB:load:couldNotReadFile');
        end
    end
    
    methods(Test)
        
         % Test for fileRepository and preferenceDao
         
        function testFileRepositorySettings(obj)
            % TODO verify folder exisits
            rep = obj.beanFactory.getBean('fileRepository');
            obj.verifyGreaterThan(regexp(rep.analysisFolder, '\w*analysis'), 1);
            obj.verifyGreaterThan(regexp(rep.rawDataFolder, '\w*rawDataFolder'), 1);
            obj.verifyGreaterThan(regexp(rep.preferenceFolder, '\w*PreferenceFiles'), 1);
        end
        
        function testLoadPreference(obj)
            dao = obj.beanFactory.getBean('preferenceDao');
            dao.loadPreference();
            obj.verifyEqual(dao.cellTags.keys, sort({'QualityRating' , 'RecordedBy'}))
            obj.verifyEqual(dao.cellTags('QualityRating'), {'4', '3', '2', '1'});
            obj.verifyEqual(dao.cellTags('RecordedBy'), {'Petri', 'Jussi', 'Daisuke', 'Sanna', 'Lina'});
            obj.verifyEmpty(setdiff(dao.cellTypeNames, {'rod bipolar', 'a2 amacrine'}));
        end
    end
end

