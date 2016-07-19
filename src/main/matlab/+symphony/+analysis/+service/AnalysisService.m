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
            fnames = obj.analysisDao.findRawDataFiles(date);
            
            for i = 1 : numel(fnames)
                parser = symphony.analysis.parser.getInstance(fnames{i});
                data = parser.parse().getResult();
                obj.analysisDao.saveCellData(data);
            end
        end
        
        function folder = createProject(obj, date)
            import symphony.analysis.constants.*;
            
            dao = obj.analysisDao;
            names = dao.findCellDataNames(date);
            
            if isempty(names)
                throw(Exceptions.NO_CELL_DATA.create());
            end
            names = obj.preferenceDao.mergeCellNames(names);
            folder = dao.createProject(names);
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

