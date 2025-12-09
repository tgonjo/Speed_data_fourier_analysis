function Fdata = FourierAnalysis(data,sf)

Y = fft(data);
    
    n = length(data);
    F = (0:n-1)*(sf/n);
    f = F';
    power = abs(Y).^2/n; 
    
    if rem(length(power), 2) == 0
    
    Fdata = horzcat(f(1:length(power)/2),power(1:length(power)/2));
    
    else
        
        Fdata = horzcat(f(1:round(length(power)/2)),power(1:round(length(power)/2)));
    
    end
    
    for j = 1:length(Fdata)
        
        Fdata(j,3) = Fdata(j,2)./sum(Fdata(1:end,2))*100;
        
    end
    


end