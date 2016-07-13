function [tf, key] = hasMatchingKey(map, name)

% hasMatchingKey - Look for match, if not found search for inexact match  
% by omitting  ('-')
% parameter
%   map - Matlab container map
%   name - key to be searched for in the map
    
    key = '';
    tf = false;
    
    if isempty(map)
        return
    end
    
    keys = map.keys;
    ind = find(strcmp(name, keys));

    if isempty(ind) 
        name = strtok(name, '_');
        ind = find(strcmp(name, keys));
    end

    tf = ~isempty(ind);
    if tf
        key = keys{ind};
    end
end