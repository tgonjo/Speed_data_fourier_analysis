function Data = detrend_method(data,method_id)

if method_id ==1
        Data = data - mean(data);
    else
        t = (1:length(data))';  
        Y = data;
        if method_id ==2
            p = polyfit(t, Y, 1);
            a2 = p(1); b2 = p(2);
            trend = a2.*t + b2;
            Data = data - trend;
        elseif method_id ==3
            p = polyfit(t, Y, 2);
            a2 = p(1); b2 = p(2); c2 = p(3);
            trend = a2.*t.^2 + b2.*t+c2;
            Data = data - trend;
        end
end

end