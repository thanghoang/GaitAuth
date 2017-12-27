function noise_removed_data = eliminateNoise (wavelet_name,level,data)
    %
    % CONFIGURATION SETTING
    %
    %level = 2;
    %wavelet_name = 'db6';
    
    noise_removed_data = zeros(size(data));
    % 1st col is the timestamp, so just leave it as is
    noise_removed_data(:,1) = data(:,1); 
    for i = 2:size(data,2)
        % decompose signal to multi-level wavelet with high and low
        % frequency components
        [C,L] = wavedec(data(:,i),level,wavelet_name);
        % eliminate noise by assigning low components of each level to 0
        C(L(1)+1:end,:) = 0 ;
        noise_removed_data(:,i) = waverec(C,L,'db6');
    end    
end