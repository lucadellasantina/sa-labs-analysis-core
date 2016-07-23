classdef AnalysisTree < tree
    
    properties
        name        % Descriptive name of analysis
    end
    
    methods
        
        function cellName = getCellName(obj, nodeInd)
            import symphony.analysis.constants.*;
            cellName = obj.getParameterValue(AnalysisConstant.CELL_NAME, nodeInd, 0);
        end
        
        function mode = getMode(obj, nodeInd)
            import symphony.analysis.constants.*;
            mode = obj.getParameterValue(AnalysisConstant.AMP_MODE_PARAM, nodeInd, 1);
        end
        
        function device = getDevice(obj, nodeInd)
            import symphony.analysis.constants.*;
            device = obj.getParameterValue(AnalysisConstant.DEVICE_NAME, nodeInd, 1);
        end
        
        function className = getClassName(obj, nodeInd)
            import symphony.analysis.constants.*;
            className = obj.getParameterValue(AnalysisConstant.CLAZZ, nodeInd, 1);
        end
        
        function value = getParameterValue(obj, parameter, nodeInd, leastExpectedInd)
            nodeData = obj.get(nodeInd);
            value = [];
            while ~ isfield(nodeData, parameter);
                if nodeInd == leastExpectedInd
                    return;
                end
                
                nodeInd = obj.getparent(nodeInd);
                nodeData = obj.get(nodeInd);
            end
            value = nodeData.(parameter);
        end
        
        function nodeData = updateNodeDataInStructure(obj, nodeId, in, out)
            nodeData = obj.get(parent);
            ref = obj.get(nodeId);
            nodeData.(out) = [];
            inStructure = ref.(in);
            fnames = fieldnames(inStructure);
            
            for i = 1 : length(fnames)
                field = fnames{i};
                inValue = inStructure.(field);
                
                if strcmp(field, 'units') || stcmp(field, 'type')
                    nodeData.(out) = inValue;
                elseif length(inValue) < 2 && isfield(nodeData.(out), field)
                    % append to end of existing value vector
                    nodeData.(out).(field)(end + 1) = inValue;
                end
            end
        end
        
    end
end
