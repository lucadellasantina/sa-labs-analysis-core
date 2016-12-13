classdef FeatureIdentifier < dynamicprops
    
    properties
        fname
        % Look up from feature-table csv first column
    end
    
    properties(Constant)
    end
    
    methods(Static)
        
        function value = getDescription(id, file)
            
            import sa_labs.analysis.*;
            persistent instance;
            
            if nargin < 2
                file = app.App.getResource(app.Constants.FEATURE_DESC_FILE_NAME);
            end
            
            if isempty(instance) || ~ strcmp(file, instance.fname)
                
                formatSpec = '%s%s%s%s%s%s%s%[^\n\r]';
                obj = core.FeatureIdentifier();
                fid = fopen(file, 'r');
                text = textscan(fid, formatSpec, 'Delimiter', ',');
                text =  [text{1, :}];
                vars = text(:, 1);
                for i = 2 : numel(vars)
                    var = strtrim(vars{i});
                    addprop(obj, var);
                    obj.(vars{i}) = entity.FeatureDescription(containers.Map(text(1, :), text(i, :)));
                end
                obj.fname = file;
                instance = obj;
            end
            
            if ~ isprop(instance, id)
                error([id ' property not found ! ' app.App.getResource('feature-table.csv')])
            end
            value = instance.(id);
        end
    end
    
end

