classdef AnalysisMode

    enumeration
        ONLINE_ANALYSIS
        OFFLINE_ANALYSIS
    end
    
    methods
        
        function tf = isOnline(obj)
            tf = obj == sa_labs.analysis.core.AnalysisMode.ONLINE_ANALYSIS;
        end
    end

    methods (Static)
    	
    	function obj = getInstace(desc)
    		[objects, descriptions] = enumeration('sa_labs.analysis.core.AnalysisMode');
    		[present, idx] = ismember(desc, descriptions);
    		% TODO replace with exception
    		if ~ present
    			error('mode not configured')	
    		end
			obj = objects(idx);
    	end
	end
end

