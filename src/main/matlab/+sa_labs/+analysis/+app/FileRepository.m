classdef FileRepository < appbox.Settings & mdepin.Bean
    
    properties
        startupFile
        searchPath
        analysisFolder
        rawDataFolder
        preferenceFolder
        dateFormat
        logFile
    end
    
    methods
        
        function obj = FileRepository(config)
            obj = obj@mdepin.Bean(config);
            
            if ~ exist(obj.analysisFolder, 'dir')
                mkdir(obj.analysisFolder)
            end
            if ~ exist(obj.rawDataFolder, 'dir')
                mkdir(obj.rawDataFolder)
            end
            if ~ exist(obj.preferenceFolder, 'dir')
                mkdir(obj.preferenceFolder)
            end
        end
        
        function f = get.startupFile(obj)
            f = obj.get('startupFile', '');
        end
        
        function set.startupFile(obj, f)
            validateattributes(f, {'char', 'function_handle'}, {'2d'});
            obj.put('startupFile', f);
        end
        
        function set.searchPath(obj, p)
            validateattributes(p, {'char', 'function_handle'}, {'2d'});
            obj.put('searchPath', p);
        end
        
        function p = get.searchPath(obj)
            p = obj.get('searchPath', sa_labs.analysis.app.App.getResource('examples'));
        end
        
        function f = get.analysisFolder(obj)
            f = obj.get('analysisFolder', fullfile(char(java.lang.System.getProperty('user.home')), 'data', 'analysis'));
        end
        
        function set.analysisFolder(obj, f)
            validateattributes(f, {'char', 'function_handle'}, {'2d'});
            obj.put('analysisFolder', f);
        end
        
        function f = get.rawDataFolder(obj)
            f = obj.get('rawDataFolder', fullfile(char(java.lang.System.getProperty('user.home')), 'data', 'rawDataFolder'));
        end
        
        function set.rawDataFolder(obj, f)
            validateattributes(f, {'char', 'function_handle'}, {'2d'});
            obj.put('rawDataFolder', f);
        end
        
        function f = get.preferenceFolder(obj)
            f = obj.get('preferenceFolder', fullfile(char(java.lang.System.getProperty('user.home')), 'data', 'PreferenceFiles'));
        end
        
        function set.preferenceFolder(obj, f)
            validateattributes(f, {'char', 'function_handle'}, {'2d'});
            obj.put('preferenceFolder', f);
        end
        
        function f = get.dateFormat(obj)
            f = obj.get('dateFormat', @(date)datestr(date, 'mmddyy'));
        end
        
        function set.dateFormat(obj, f)
            validateattributes(f, { 'function_handle'}, {'2d'});
            obj.put('dateFormat', f);
        end

        function f = get.logFile(obj, f)
             f = obj.get('logFile', fullfile(char(java.lang.System.getProperty('user.home')), 'data', 'analysis', 'analysis.log'));
        end

        function set.logFile(obj, f)
            validateattributes(p, {'char', 'function_handle'}, {'2d'});
            obj.put('logFile', f);
        end
    end
    
end

