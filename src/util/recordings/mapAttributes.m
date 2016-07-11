function map = mapAttributes(h5group, fname, map)
    
    if nargin < 3
        map = containers.Map();
    end
    
    if ischar(h5group)
       h5group = h5info(fname, h5group);
    end
    
    attributes = h5group.Attributes;

    for i = 1 : length(attributes)
        name = attributes(i).Name;
        root = strfind(name, '/');

        if ~ isempty(root)
            name = attributes(i).Name(root(end) + 1 : end);
        end
        map(name) = attributes(i).Value;
    end
end

