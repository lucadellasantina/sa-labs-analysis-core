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
            files = dao.findRawDataFiles(datestr(date, 'mmddyy'));
            obj.verifyEqual(numel(files), obj.NO_OF_FILES);
            
            for i = 1 : numel(files)
                obj.verifyEqual(exist(files{i}, 'file'), 2);
            end
            files = dao.findRawDataFiles(datestr(busdate(date, 1), 'mmddyy'));
            obj.verifyEmpty(files);
        end
        
        function testSaveCell(obj)
            dao = obj.beanFactory.getBean('analysisDao');
            path = [dao.repository.analysisFolder filesep 'cellData' filesep];
            arrayfun(@(d) dao.saveCell(d), obj.testCellDatas);
            
            for i = 1 : obj.NO_OF_FILES
                name = obj.cellNames{i};
                obj.verifyEqual(exist([path name '.mat'], 'file'), 2);
            end
        end
        
        function testSaveProject(obj)
            import sa_labs.analysis.*;
            expected = struct('identifier', 'test-project-1',...
                'description', 'matlab-unit-test',...
                'experimentDate',  datestr(now, 'dd.mm.yyyy'),...
                'analysisDate', datestr(now, 'dd.mm.yyyy'),...
                'performedBy', 'Sathish');
            expected.cellDataNames = obj.cellNames(1 : end -1)';
            project = entity.AnalysisProject(expected);
            dao = obj.beanFactory.getBean('analysisDao');
            project = dao.saveProject(project);
            obj.verifyNotEmpty(project.file);
            
            expected.cellDataNames = obj.cellNames';
            project = entity.AnalysisProject(expected);
            project = dao.saveProject(project);
            obj.verifyNotEmpty(project.file);
        end
        
        function testFindProject(obj)
            import sa_labs.analysis.*;
            expected = struct('identifier', 'test-project-1',...
                'description', 'matlab-unit-test',...
                'experimentDate',  datestr(now, 'dd.mm.yyyy'),...
                'analysisDate', datestr(now, 'dd.mm.yyyy'),...
                'performedBy', 'Sathish');
            expected.cellDataNames = obj.cellNames';
            
            dao = obj.beanFactory.getBean('analysisDao');
            project = dao.findProjects('test-project-1');
            expected = rmfield(expected, 'cellDataNames');
            attributes = fields(expected);
            validate(project, attributes);
            obj.verifyEqual(project.getCellDataNames(),  obj.cellNames');
            
            expected.identifier = 'test-project-2';
            expected.cellDataNames = obj.cellNames';
            project = entity.AnalysisProject(expected);
            dao.saveProject(project);
            projects = dao.findProjects({'test-project-1', 'test-project-2'});
            obj.verifyEqual({projects.identifier}, {'test-project-1', 'test-project-2'});
            
            handle = @()dao.findProjects('unknow');
            obj.verifyError(handle, app.Exceptions.NO_PROJECT.msgId);
            
            function validate(project, attributes)
                for j = 1 : numel(attributes)
                    attr = attributes{j};
                    obj.verifyEqual(project.(attr), expected.(attr));
                end
            end
        end
        
        function testFindCellNames(obj)
            dao = obj.beanFactory.getBean('analysisDao');
            names = dao.findCellNames(date);
            obj.verifyEmpty(setdiff(obj.cellNames, names));
            names = dao.findCellNames(datestr(busdate(date, 1)));
            obj.verifyEmpty(names);
            expected = {[datestr(now, 'mmddyy') obj.FILE_PREFIX '2']; [datestr(now, 'mmddyy') obj.FILE_PREFIX '3']};
            actual = dao.findCellNames(expected);
            obj.verifyEmpty(setdiff(expected, actual));
        end
        
        function testFindCell(obj)
            dao = obj.beanFactory.getBean('analysisDao');
            fname = [datestr(now, 'mmddyy') obj.FILE_PREFIX '1'];
            data = dao.findCell(fname);
            obj.verifyEqual(data.savedFileName, fname);
            
            dataHandle = @()dao.findCell('unknown');
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

