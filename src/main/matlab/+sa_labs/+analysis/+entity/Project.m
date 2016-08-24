classdef Project < handle
    
    properties
        name = ''
        purpose = ''
        notes = ''
        experimentFiles
        startDate = datestr(now)
    end
    
    properties (Hidden)
        experimentFilesType
        nameType =  sa_labs.analysis.core.PropertyType('char', 'row');
        purposeType = sa_labs.analysis.core.PropertyType('char', 'row');
        notesType = sa_labs.analysis.core.PropertyType('char', 'row');
        startDateType = sa_labs.analysis.core.PropertyType('char', 'row', 'datestr')
    end
    
    methods
        
        function createExperimentFilesType(obj, files)
            obj.experimentFilesType =  sa_labs.analysis.core.PropertyType('cellstr', 'row', files);
            obj.experimentFiles = files(1);
        end
        
        function p = createPreset(obj, name)
            descriptors = obj.getPropertyDescriptors();
            i = arrayfun(@(d)d.isReadOnly, descriptors);
            descriptors(i) = [];
            p = sa_labs.analysis.core.ProjectPreset(name, class(obj), descriptors.toMap());
        end
        
        function applyPreset(obj, preset)
            if ~isempty(preset.projectId) && ~strcmp(preset.projectId, class(obj))
                error('Project ID mismatch');
            end
            obj.setPropertyMap(preset.propertyMap);
        end
        
        function m = getPropertyMap(obj)
            m = obj.getPropertyDescriptors().toMap();
        end
        
        function setPropertyMap(obj, map)
            exception = [];
            names = map.keys;
            for i = 1:numel(names)
                try
                    obj.setProperty(names{i}, map(names{i}));
                catch x
                    if isempty(exception)
                        exception = MException('sa_labs.analysis:entity:Project', 'Failed to set one or more property values');
                    end
                    exception.addCause(x);
                end
            end
            if ~isempty(exception)
                throw(exception);
            end
        end
        
        function v = getProperty(obj, name)
            descriptor = obj.getPropertyDescriptor(name);
            v = descriptor.value;
        end
        
        function setProperty(obj, name, value)
            mpo = findprop(obj, name);
            if isempty(mpo) || ~strcmp(mpo.SetAccess, 'public')
                error([name ' is not a property with public set access']);
            end
            descriptor = obj.getPropertyDescriptor(name);
            if ~descriptor.type.canAccept(value)
                error([value ' does not conform to property type restrictions for ' name]);
            end
            obj.(name) = value;
        end
        
        function d = getPropertyDescriptors(obj)
            names = properties(obj);
            d = sa_labs.analysis.core.PropertyDescriptor.empty(0, numel(names));
            for i = 1:numel(names)
                d(i) = obj.getPropertyDescriptor(names{i});
            end
        end
        
        function d = getPropertyDescriptor(obj, name)
            d = sa_labs.analysis.core.PropertyDescriptor.fromProperty(obj, name);
        end
    end
end

