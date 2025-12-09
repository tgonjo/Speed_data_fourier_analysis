clear all
close all

%replace the file name. Each swimmer's speed data should be contained in a
%column. The top row should contain each swimmer's ID/name
File = readtable('sample_data.xlsx');

[a,b] = size(File);


%Dialog to input the data information: sampling frequency and the number of
%stroke cycles
prompt    = {'Enter the sampling frequency:', 'Enter the number of cycles contained in each data column:'};
dlgtitle  = 'Input';
fieldsize = [1 60; 1 60];
definput  = {'250','1'};
answer    = inputdlg(prompt, dlgtitle, fieldsize, definput);

if isempty(answer); return; end  % user cancelled

sf = str2double(answer{1});
nC = str2double(answer{2});
assert(isfinite(sf) && sf>0, 'Invalid sampling frequency');
assert(isfinite(nC) && nC>=1 && abs(nC-round(nC))<1e-9, 'Invalid number of cycles');

%Dialog to input the data detrend method. This process is necessary to
%avoid the impact of 0Hz frequency in the analysis
method_list = ["Subtract the mean","Subtract the linear trend (recommended when some swimmers show clear linear acceleration/deceleration)","Subtract the 2nd order exponential trend(recommended when some swimmers show clear exponential acceleration/deceleration)"];
method_id = listdlg("PromptString","Select the data detrend method", ...
                    "ListString",method_list,"ListSize",[700 100],"SelectionMode","single");
if isempty(method_id); return; end


Int = 1/sf;



Export = zeros(30,b*4);
NExport = zeros(30,b*4);

for i = 1:b

    A = table2array(File(:,i));
    A(isnan(A)) = [];

    %% Absolute frequency analysis
    
    data{i} = A;

    Data{i} = detrend_method(data{i},method_id);
        
    Fdata{i} = FourierAnalysis(Data{i},sf);
    
    Sort{i} = sort(Fdata{i}(:,3),'descend');
    
    B = 0;
    N(i,1) = 1;
    
    % Loop until the total power reaches 95% of the original cycle. This
    % assumes that the lowest 5% is the noise. Edit the number if you
    % want to adjust the threshold. 

    abs_power_threshold = 95;

    while B < abs_power_threshold 
        
        B = B + Sort{i}(N(i,1),1);
        
        N(i,1) = N(i,1)+1;
        
    end
    
    Freq_major{i} = Sort{i}(1:N(i,1)-1,1);
    
    for k=1:length(Freq_major{i})
    
    elm{i}(k,1) = find(Fdata{i}(:,3) == Freq_major{i}(k,1));
    
    Export(k,(i-1)*4+1:(i-1)*4+3) = Fdata{i}(elm{i}(k,1),:);
    
    end
    
    Swimmer(1,(i-1)*4+1:(i-1)*4+2) = ["Swimmer",num2str(i)];
    
    title(1,(i-1)*4+1:(i-1)*4+3) = ["frequency (Hz)","power","contribution(%)"];

    
    
    %% Relative frequency analysis
    
    Sample{i} = 0:1:length(A)-1;
    Atime{i} = Sample{i}'*Int;
    InterA{i} = max(Atime{i})/(nC*100);
    Btime{i} = (0:InterA{i}:max(Atime{i}));
    Ndata{i} = spline(Atime{i},A,Btime{i})';

    NData{i} = detrend_method(Ndata{i},method_id);       
    NFdata{i} = FourierAnalysis(NData{i},(nC*100+1));
    
    NSort{i} = sort(NFdata{i}(:,3),'descend');
    
    NB = 0;
    NN(i,1) = 1;

    % Loop until the total power reaches 95% of the original cycle. This
    % assumes that the lowest 5% is the noise. Edit the number if you
    % want to adjust the threshold. 

    rel_power_threshold = 95;
    
    while NB < rel_power_threshold
        
        NB = NB + NSort{i}(NN(i,1),1);
        
        NN(i,1) = NN(i,1)+1;
        
    end
    
    NFreq_major{i} = NSort{i}(1:NN(i,1)-1,1);
    
    for k=1:length(NFreq_major{i})
    
    Nelm{i}(k,1) = find(NFdata{i}(:,3) == NFreq_major{i}(k,1));
    
    NExport(k,(i-1)*4+1:(i-1)*4+3) = NFdata{i}(Nelm{i}(k,1),:);
    
    end
    
    NExport(:,(i-1)*4+1) = NExport(:,(i-1)*4+1)./nC;
    
    Ntitle(1,(i-1)*4+1:(i-1)*4+3) = ["Relative frequency","power","contribution(%)"];
    
   
   clear A 

end


%% Data export
Export(Export==0) = nan;
NExport(NExport==0) = nan;

x = inputdlg('Enter the export file name (without .xlsx):', ...
             'Output file (.xlsx)', [1 50]);
filename_output = [x{1} '.xlsx']; 


writematrix(Export,filename_output,'Sheet','Absolute','Range','A3');
writematrix(Swimmer,filename_output,'Sheet','Absolute','Range','A1');
writematrix(title,filename_output,'Sheet','Absolute','Range','A2');

writematrix(NExport,filename_output,'Sheet','Relative','Range','A3');
writematrix(Swimmer,filename_output,'Sheet','Relative','Range','A1');
writematrix(Ntitle,filename_output,'Sheet','Relative','Range','A2');

