classdef AnalysisNodeType
	
	enumeration
		FEATURE_GROUPS
		FEATURE
	end

	function c = char(obj)
	    import sa_labs.analysis.ui.AnalysisNodeType;
	    
	    switch obj
	        case AnalysisNodeType.FEATURE_GROUPS
	            c = 'Feature Groups';
	        case AnalysisNodeType.FEATURE
	            c = 'Feature';
	        otherwise
	            c = 'Unknown';
	    end
	end
	
	function tf = isFeaturesFolder(obj)
	    tf = obj == sa_labs.analysis.ui.AnalysisNodeType.FEATURE_GROUPS;
	end
end