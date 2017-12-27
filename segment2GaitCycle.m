function [ segment ] = segment2GaitCycle( accelerometer_data, gait_cycle_position)
%   segment2gait_cycle split/divide data into separate segments according to 
%   detected starting points of gait cycles 

    segment = {};  
    %segment data into gait cycles
    %The array of peak detected manually starts from 
    
    for ii=1:length(gait_cycle_position)-1
        if (gait_cycle_position(ii+1) >length(accelerometer_data))
            return;
        end
        curSegment = accelerometer_data(gait_cycle_position(ii):gait_cycle_position(ii+1),:);
        segment{ii,1} = curSegment;
    end 
    
end

