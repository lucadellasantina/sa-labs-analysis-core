classdef AnalysisService < handle & mdepin.Bean
    
    properties
        analysisDao
        preferenceDao
    end
    
    methods
        
        function obj = AnalysisService(config)
            obj = obj@mdepin.Bean(config);
        end
        
        function data = parseSymphonyFiles(obj, date)
            files = obj.analysisDao.findRawDataFiles(date);
            
            for i = 1 : numel(files)
                parser = symphony.analysis.parser.getInstance(files{i});
                data = parser.parse().getResult();
                obj.analysisDao.saveCellData(data);
            end
        end
        
        function createProject(obj, date)
            import symphony.analysis.constants.*;
            
            dao = obj.analysisDao;
            names = dao.findCellDataNames(date);
            
            if isempty(names)
                obj.parseSymphonyFiles(date);
            end
            names = obj.preferenceDao.mergeCellNames(names);
            dao.createProject(names);
        end
        
        function data = preProcess(obj, data, functions)
            for i = 1 : numel(functions)
                fun = functions{i};
                data = fun(data);
            end
            obj.analysisDao.saveCellData(data);
        end
    end
    
end

