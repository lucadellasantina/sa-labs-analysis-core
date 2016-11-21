classdef PreferenceDao < handle & mdepin.Bean
    
    properties
        repository
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
        
        function obj = PreferenceDao(config)
            obj = obj@mdepin.Bean(config);
            obj.cellTags = containers.Map();
            obj.epochTags = containers.Map();
        end
        
        function loadPreference(obj)
            import sa_labs.analysis.util.*;
            
            folder = obj.repository.preferenceFolder;
            obj.cellTypeNames = importdata([folder filesep obj.FILE_CELL_TYPE_NAMES], '\n');
            obj.cellTags = file.readTextToMap([folder filesep obj.FILE_CELL_TAGS]);
            obj.epochTags = file.readTextToMap([folder filesep obj.FILE_MERGED_CELLS]);
        end
        
        function names = mergeCellNames(obj, names)
            %TODO merge cell name implementation
        end
    end
end
