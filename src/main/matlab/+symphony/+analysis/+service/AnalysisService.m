classdef AnalysisService < handle
    
    properties
        symphonyParser
        analysisDao
        preferenceDao
    end
    
    methods
                
        function data = parseSymphonyFiles(obj, date)
            data = obj.symphonyParser.parse(date);
            obj.analysisDao.saveCellData(data);
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

