function pos = findPos(num)
    pos = 0;
    for i = length(num):-1:1
        if num(i) == 1
            pos = i;
            break;
        end
    end
end