classdef Presets < appbox.Settings
    
    properties (SetAccess = private)
        projectPresets
    end
    
    methods
        
        function addProjectPresets(obj, preset)
            presets = obj.projectPresets;
            if presets.isKey(preset.name)
                error([preset.name ' is already a protocol preset']);
            end
            presets(preset.name) = preset;
            obj.projectPresets = presets;
        end
        
        function removeProjectPresets(obj, name)
            presets = obj.projectPresets;
            if ~presets.isKey(name)
                error([name ' is not an available protocol preset']);
            end
            presets.remove(name);
            obj.projectPresets = presets;
        end
        
        function p = getProjectPresets(obj, name)
            presets = obj.projectPresets;
            if ~presets.isKey(name)
                error([name ' is not an available protocol preset']);
            end
            p = presets(name);
        end
        
        function n = getAvailableProjectPresetNames(obj)
            presets = obj.projectPresets;
            n = presets.keys;
        end
        
        function p = get.projectPresets(obj)
            p = containers.Map();
            structs = obj.get('projectPresets', containers.Map);
            keys = structs.keys;
            for i = 1:numel(keys)
                p(keys{i}) = sa_labs.analysis.core.ProjectPreset.fromStruct(structs(keys{i}));
            end
        end
        
        function set.projectPresets(obj, p)
            validateattributes(p, {'containers.Map'}, {'2d'});
            structs = containers.Map();
            keys = p.keys;
            for i = 1:numel(keys)
                preset = p(keys{i});
                structs(keys{i}) = preset.toStruct();
            end
            obj.put('projectPresets', structs);
        end
        
        
    end
    
    methods (Static)
        
        function o = getDefault()
            persistent default;
            if isempty(default) || ~isvalid(default)
                default = sa_labs.analysis.app.Presets();
            end
            o = default;
        end
        
    end
    
end

