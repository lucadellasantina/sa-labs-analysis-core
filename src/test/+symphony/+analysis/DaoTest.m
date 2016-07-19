classdef DaoTest < matlab.unittest.TestCase
    
    properties
        analysisDao
        preferenceDao
        testCellDatas
        cellNames
    end
    
    properties(Constant)
        FILE_PREFIX = 'c_test';
        NO_OF_FILES = 10;
    end
    
    methods (TestClassSetup)
        
        function initContext(obj)
            import symphony.analysis.*;
            
            ctx = struct();
            
            ctx.analysisDao.class = 'symphony.analysis.dao.AnalysisDao';
            ctx.analysisDao.repository = 'fileRepository';
            ctx.preferenceDao.class = 'symphony.analysis.dao.PreferenceDao';
            ctx.preferenceDao.repository = 'fileRepository';
            ctx.fileRepository.class = 'symphony.analysis.app.FileRepository';
            
            obj.analysisDao = mdepin.createApplication(ctx, 'analysisDao');
            obj.preferenceDao = mdepin.createApplication(ctx, 'preferenceDao');
            
            rep = obj.analysisDao.repository;
            fixture = strrep(fileparts(rep.searchPath), 'main', 'test');
            rep.preferenceFolder = [fixture filesep 'PreferenceFiles'];
            rep.analysisFolder = [fixture filesep 'analysis'];
            rep.rawDataFolder = [fixture filesep 'rawDataFolder'];
            
            util.file.overWrite(rep.analysisFolder);
            util.file.overWrite(rep.rawDataFolder);
            util.file.overWrite([rep.analysisFolder filesep 'cellData']);
            
            obj.preferenceDao.repository = rep;
            
            obj.testCellDatas = core.CellData.empty(10, 0);
            obj.cellNames = cell(obj.NO_OF_FILES, 1);

            for i = 1 : obj.NO_OF_FILES
                name = [datestr(now, 'mmddyy') obj.FILE_PREFIX num2str(i)];
                path = [rep.rawDataFolder filesep  name '.h5'];
                h5create(path ,'/ds' , [10 20]);
                h5writeatt(path, '/','version', 1);
                cellData = symphony.analysis.core.CellData();
                cellData.savedFileName = name;
                
                obj.testCellDatas(i) = cellData;
                obj.cellNames{i} = name;
            end
        end
    end
    
    methods(Test)
        
        function testFileRepositorySettings(obj)
            rep = obj.analysisDao.repository;
            obj.verifyGreaterThan(regexp(rep.analysisFolder, '\w*analysis'), 1);
            obj.verifyGreaterThan(regexp(rep.rawDataFolder, '\w*rawDataFolder'), 1);
            obj.verifyGreaterThan(regexp(rep.preferenceFolder, '\w*PreferenceFiles'), 1);
        end
        
        function testFindRawDataFiles(obj)
            dao = obj.analysisDao;
            files = dao.findRawDataFiles(date);
            obj.verifyEqual(numel(files), obj.NO_OF_FILES);
            
            for i = 1 : numel(files)
                obj.verifyEqual(exist(files{i}, 'file'), 2);
            end
            files = dao.findRawDataFiles(datestr(busdate(date, 1)));
            obj.verifyEmpty(files);
        end
        
        function testSaveCellData(obj)
            dao = obj.analysisDao;
            path = [dao.repository.analysisFolder filesep 'cellData' filesep];
            arrayfun(@(d) dao.saveCellData(d), obj.testCellDatas);
            
            for i = 1 : obj.NO_OF_FILES
                name = obj.cellNames{i};
                obj.verifyEqual(exist([path name '.mat'], 'file'), 2);
            end
        end
        
        function testCreateProject(obj)
             folder = obj.analysisDao.createProject(obj.cellNames);
             text = importdata([folder filesep 'cellNames.txt'],'\n');
             obj.verifyEqual(obj.cellNames, text);
        end
        
        function testFindCellDataNames(obj)
            dao = obj.analysisDao;
            names = dao.findCellDataNames(date);
            obj.verifyEmpty(setdiff(obj.cellNames, names));
            names = dao.findCellDataNames(datestr(busdate(date, 1)));
            obj.verifyEmpty(names);
        end
        
        function testLoadPreference(obj)
            dao = obj.preferenceDao;
            dao.loadPreference();
            obj.verifyEqual(dao.cellTags.keys, sort({'QualityRating' , 'RecordedBy'}))
            obj.verifyEqual(dao.cellTags('QualityRating'), {'4', '3', '2', '1'});
            obj.verifyEqual(dao.cellTags('RecordedBy'), {'Petri', 'Jussi', 'Daisuke', 'Sanna', 'Lina'});
            obj.verifyEmpty(setdiff(dao.cellTypeNames, {'rod bipolar', 'a2 amacrine'}));
        end
    end
end

