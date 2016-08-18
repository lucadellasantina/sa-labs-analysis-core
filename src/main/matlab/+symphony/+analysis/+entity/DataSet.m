classdef DataSet < handle & matlab.mixin.CustomDisplay
    
    properties
        name
        epochIndices
        filter
        quality
    end
    
    methods
        
        function obj = DataSet(epochIndices, filter)
            obj.epochIndices = epochIndices;
            obj.filter = filter;
        end
    end
end
