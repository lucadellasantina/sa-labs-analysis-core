classdef ProjectPreset < handle
    % A ProjectPreset stores a set of property values for a project.
    
    properties (SetAccess = private)
        name
        projectId
        propertyMap
    end
    
    methods
        
        function obj = ProjectPreset(name, projectId, propertyMap)
            obj.name = name;
            obj.projectId = projectId;
            obj.propertyMap = propertyMap;
        end
        
        function s = toStruct(obj)
            s.name = obj.name;
            s.projectId = obj.projectId;
            s.propertyMap = obj.propertyMap;
        end
        
    end
    
    methods (Static)
        
        function obj = fromStruct(s)
            obj = sa_labs.analysis.core.ProjectPreset(s.name, s.projectId, s.propertyMap);
        end
        
    end
    
end

