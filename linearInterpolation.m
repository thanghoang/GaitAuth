function [interpolated_data] = linearInterpolation(data)
    %
    % 0. CONFIGURATION SETTING
    %
    interpolation_frequency = 32; %32 Hz
    
    nTotalTime = data(end,1) - data(1,1); 
    nTotalSample = round(nTotalTime/1000*interpolation_frequency);
    % Create a new reference axis
    refX_axis = linspace(data(end,1)-(nTotalSample*1000/32),data(end,1),nTotalSample);
    
    % Do interpolation according to the reference axis
    interpolated_data = zeros(nTotalSample,4);
    interpolated_data(:,1) = refX_axis;
    [C,ia,ic] = unique(data(:,1));
    for i = 2:4
        vq = interp1(data(ia,1),data(ia,i),refX_axis);
        interpolated_data(:,i) = vq;
    end
    %remove NaN values in the interpolated acceleration matrix
    y = isnan(interpolated_data(:,2));
    interpolated_data(y,:) = [];
end
