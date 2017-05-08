classdef ParserFactory < handle & mdepin.Bean
    
    methods
      
      function obj = ParserFactory(config)
            obj = obj@mdepin.Bean(config);
        end
    end 

    methods (Static)
        
        function obj = getInstance(fname)
            
            import sa_labs.analysis.parser.*
            version = SymphonyParser.getVersion(fname);
            if version == 2
                obj = Symphony2Parser();
            else
                obj = DefaultSymphonyParser();
            end
            obj.fname = fname;
        end
    end
end

