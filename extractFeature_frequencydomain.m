function [freqFeature] = extractFeature_frequencydomain(dataBySession)
    %
    % CONFIGURATION SETTING
    %
    % IMPORTANT NOTE:
    % the extracted freqFeature will have 5 column, with each is the
    % extracted feature on separate axis as follwing
    % [feature(X) feature(Y) feature(Z) feature(MXY) feature(MXYZ)]
    %
    
    f= 32;  %frequency
    %%FFT & DCT
    fft_dim = 40;
    dct_dim = 40;
    
    freqFeature = {};
    for i = 1:length(dataBySession)
        %normalize the segment to a fixed length of gait cycle
        %curData = normalizeGCLength(dataBySession(i,:));
        %curData = curData{1,1};
        %get the data of the current segment
        curData = dataBySession{i,1};
        
        
        % create MXY & MXYZ signal to extract features on these axes
        MXY = sqrt(curData(:,2).^2+curData(:,3).^2);
        MXYZ = sqrt(curData(:,2).^2 + curData(:,3).^2 + curData(:,4).^2);
        curData = [curData MXY MXYZ];
        
        n = size(curData,2);
        %extract FFT coefficient for each data
        fFeature = [];
        for j = 2:n % 1 is the timestamp
            %extract FFT
            %FFT = fft(curData(:,j),2^nextpow2(size(curData,1)))/size(curData,1);
            FFT = fft(curData(:,j),2^nextpow2(size(curData,1)))/size(curData,1);
            %get the magnitude...
            fft_coef_mag = abs(FFT(2:fft_dim+1));
            %... and phase.
            fft_phase_coef = angle((FFT(2:fft_dim+1)));
            
            %..and DCT
            DCT = dct(curData(:,j))/length(size(curData,1));
            dct_coef = DCT(1:dct_dim,:);

            fFeature = [fFeature [fft_coef_mag;  dct_coef]];
            %fFeature = [fFeature [fft_coef_mag; dct_coef]];
        end
        freqFeature{i,1} = fFeature;
    end
end