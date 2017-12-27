function [calibrated_accelerometer_data] = calibrateAccelerometerData(data_accelerometer,data_rotation_matrix) 
    
    interpolatedData_rotation = zeros(size(data_accelerometer,1),9);
    interpolatedData_rotation(:,1) = data_accelerometer(:,1);
    % 1. Applying linear interpolation to Rotation Matrix file to fix the time 
    %    axis of both files
    [C,ia,ic] = unique(data_rotation_matrix(:,1));
    for i = 2 : size(data_rotation_matrix,2)
        vq = interp1(data_rotation_matrix(ia,1),data_rotation_matrix(ia,i),data_accelerometer(:,1),'linear');
        interpolatedData_rotation(:,i) =  vq;
    end
    data_rotation_matrix = interpolatedData_rotation;
    %1.2 Remove NaN values in the interpolated rotation matrix
    y = isnan(data_rotation_matrix(:,2));
    data_rotation_matrix(y,:) = [];
    data_accelerometer(y,:) = [];

    %2. Get the last 3 columns of acceleration values and last 9 columns of rotation matrix
    accelerationMat = data_accelerometer(:,[2:4]);
    rotationMat = data_rotation_matrix(:,[2:10]);
    
    %3. Transform acceleration vectors to the ones in the fixed coordinate system
    calibrated_accelerometer_data = zeros(size(data_accelerometer));
    calibrated_accelerometer_data(:,1) = data_accelerometer(:,1);
    for i = 1 : length(accelerationMat)
       curAccVal =  accelerationMat(i,:)';
       curRotationMat = reshape(rotationMat(i,:),[3,3])';
       newAccVal = curRotationMat*curAccVal;
       calibrated_accelerometer_data(i,2:4) = newAccVal';
    end
end