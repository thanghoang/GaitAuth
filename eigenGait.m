function [PCAedData,eigenVec,meanVec] = eigenGait(data)
    %
    %CONFIGURATION SETTING
    %
    n = 42; % n is the number of selected eigen coefficients; n is 
    % selected based on the cummulative sum of latent which achieves higher than 99.5%
    
    [eigenVec,score,latent] = princomp(data);
    eigenVec = eigenVec(:,1:n);
    meanVec = mean(data);
    meanMat = repmat(meanVec,size(data,1),1);
    PCAedData = (data - meanMat)*eigenVec;
    
end