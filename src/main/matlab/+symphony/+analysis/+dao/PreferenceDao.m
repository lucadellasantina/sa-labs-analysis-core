classdef PreferenceDao < handle
    
    properties(Access = private)
        folder
    end
    
    properties(SetAccess = private)
        cellTags
        cellTypeNames
        epochTags
    end
    
    properties(Constant)
        FILE_CELL_TAGS = 'CellTags.txt'
        FILE_CELL_TYPE_NAMES = 'cellTypeNames.txt'
        FILE_EPOCH_TAGS = 'EpochTags.txt'
        FILE_MERGED_CELLS = 'MergedCells.txt'
    end
        
    methods
        
        function obj = PreferenceDao(repository)
            obj.folder = repository.preferenceFolder;
            obj.cellTags = containers.Map();
            obj.epochTags = containers.Map();
            obj.loadPreference();
        end
        
        function loadPreference(obj)
            import symphony.analysis.util.*;
            
            obj.cellTypeNames = importdata([obj.folder filesep obj.FILE_CELL_TYPE_NAMES], '\n');
            obj.cellTags = file.readTextToMap([obj.folder filesep obj.FILE_CELL_TAGS]);
            obj.epochTags = file.readTextToMap([obj.folder filesep obj.FILE_MERGED_CELLS]);
        end
        
        function names = mergeCellNames(obj, names)
            %TODO merge cell name implementation
        end
    end
end

