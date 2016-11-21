classdef Session < handle
    
    properties (SetAccess = private)
        project
        presets
    end

    methods
        
        function obj = Session(presets, project)
            obj.presets = presets;
            obj.project = project;
        end
        
    end
end

