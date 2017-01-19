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
end

