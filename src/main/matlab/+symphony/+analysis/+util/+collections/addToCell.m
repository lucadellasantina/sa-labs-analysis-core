function new = addToCell(old, new)
    
    if iscell(old) && ~iscell(new)
        old{end + 1} = new;
        new = old;
    elseif iscell(old) && iscell(new)
        new = {old{:}, new{:}};
    else
        new = {old, new};
    end
end

