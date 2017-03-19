function map  = addToMap(map, key, value)

    if isKey(map, key)
        old = map(key);
        
        if ischar(value)
            value = cellstr(value);
            old = cellstr(old);
        end
        map(key) = [old, value];
    else
        map(key) = value;
    end
end