dataPath = 'DATASET/';
%
% 0. Load data of accelerometer and rotation matrix. Note that the files of rotation
%    matrix and accelerometer have a structure of ID,SessionID,Order
%
dataUsage = 'Linear Acceleration Sensor';
fData = dir(fullfile(dataPath,strcat('*',dataUsage,'*.txt')));
RawData = cell(length(fData),12);
for i=1:length(fData)
    curAccelerationData = load(strcat(dataPath,fData(i).name));
    curRotationData = load(strcat(dataPath,strrep(fData(i).name,dataUsage,'Rotation Matrix')));
    
    % read some information such as User ID, Gender, SessionID, Order
    idxID = strfind(fData(i).name,'ID');
    curID = str2double(fData(i).name(idxID+2:idxID+3));
    curGender = fData(i).name(idxID+5);
    idxSessionID = strfind(fData(i).name,'_');
    curSessionID = str2double([fData(i).name(idxID+2:idxID+3) fData(i).name(idxSessionID(2)+1:idxSessionID(3)-1)]);curOrder = str2double(fData(i).name(idxSessionID(end)+1:strfind(fData(i).name,'.txt')-1));
    
    curOrder = str2double(fData(i).name(idxSessionID(end)+1:strfind(fData(i).name,'.txt')-1));
 
    % store data as well as description to a cell following the structure:
    % [RawAccelerationData  RawRotationMatrixData ID Sex Session Order]
    RawData{i,1} = curAccelerationData;
    RawData{i,2} = curRotationData;
    RawData{i,3} = curID;
    RawData{i,4} = curGender;
    RawData{i,5} = curSessionID;
    RawData{i,6} = curOrder;    
end
%
%   1.  PREPROCESSING:
%       Do acclerometer calibration, linear interpolation, and noise
%       elimination
% 
%   1.1. ACCELEROMETER DATA CALIBRATION
%   Input: [Raw_Acceleration_Data Rotation_Matrix]
%   Output: [Calibrated_Data] % replace the 2nd column of the rotation matrix 
%   in the Raw Data by the new column of the calibrated_data

for i = 1: length(RawData)
   RawData{i,2} =  calibrateAccelerometerData(RawData{i,1},RawData{i,2});
end
%
%   1.2. LINEAR INTERPOLATION
%   Input: [accelerometer data]
%   Ouput: [Interpolated_accelerometer_data]

for i =1: length(RawData)
   RawData{i,2} = linearInterpolation(RawData{i,2});  
end
%
%   1.3. NOISE ELIMINATION
%   Input:   [accelerometer_data]
%   Output:  [noise_reduced_accelerometer_data]
%
for i = 1: length(RawData)
   RawData{i,2} = eliminateNoise('db6',2,RawData{i,2}); 
end

%
%   2. SEGMENTATION
%
%   2.1. GAIT CYCLE DETECTION
%        Detect peaks representing beginning points of gait cycles.
%   Input:  [accelerometer_data ]
%   Output: [peak_position]
for i = 1: length(RawData)
    peak_pos = detectGaitCycle(RawData{i,2});
    %   Save these positions to 7th column of the data for further use to extract gait patterns
    RawData{i,7} = peak_pos;
end
%
%  2.2. GAIT CYCLE BASED SEGMENTATION
%       Divide data into separate 1-gait cycle segments according to the
%       detected gait cycle peaks obtained before
%  Input:  [accelerometer_data peak_position]
%  Output: [1-gait cycle based segments]

for i = 1:length(RawData)
   segments = segment2GaitCycle(RawData{i,2},RawData{i,7});
   % Save these segments to 8th column of the data for further use 
   RawData{i,8} = segments;

end
%
%  2.3. GAIT PATTERN EXTRACTION
%       Extract gait patterns based on gait cycle segments. A gait pattern
%       may consist of n gait cycle. Gait patterns can be overlapped of p with 
%       the previous one
%  Input: [1-gait cycle based segments n p]
%  Output:[gait_patterns]
n = 4; p = 0.5;
for i=1:length(RawData)
    gait_patterns = extractGaitPattern(RawData{i,8},n,p);
    % Save these segments to 9th column of the data for further use
    RawData{i,9} = gait_patterns;
end


%%   3. FEATURE EXTRACTION
%       Extract features on time & frequency domain
%   Input:  [Gait Pattern]
%   Output: [feature vectors]

for i =1:length(RawData)
   time_features = extractFeature_timedomain(RawData{i,9});
   frequency_features = extractFeature_frequencydomain(RawData{i,9});
   RawData{i,10} = time_features;
   RawData{i,11} = frequency_features;
end
%
%   3.1. FEATURE VECTOR CONCATENATION
%       (1) Concatenate time domain & frequency domain of each segment to 
%       obtain a unique feature vector, (2) and create a feature matrix 
%       from these vectors, (3) and store it in the 12th column
% 
selectedAxis = [3 4 5]; % use features of Z, MXY, MXYZ axes
for i =1:length(RawData)
    curTimeFeature = RawData{i,10};
    curFrequencyFeature = RawData{i,11};
    concatFeature = {};
    for ii = 1:length(curTimeFeature)
    % get the last time feature since this feature is same for n axes
    lastTimeFeature = curTimeFeature{ii,1}(end);
    concatTimeFeature = [lastTimeFeature ];
    for iii = 1:length(selectedAxis)
        concatTimeFeature = [concatTimeFeature curTimeFeature{ii,1}(1:end-1,selectedAxis(iii))'];
    end
    %BASED ON FEATURE SELECTION
    %concatTimeFeature = [concatTimeFeature(2) concatTimeFeature(3) concatTimeFeature(1) concatTimeFeature(6:15) concatTimeFeature(4) concatTimeFeature(4+16) concatTimeFeature(4+32) concatTimeFeature(17+32)];
    %
    concatFrequencyFeature = [];
    for iii = 1:length(selectedAxis)
        concatFrequencyFeature = [concatFrequencyFeature curFrequencyFeature{ii,1}(:,selectedAxis(iii))'];
    end
    %BASED ON FEATURE SELECTION
    %concatFrequencyFeature = [ concatFrequencyFeature(41:end)];
    %
    concatFeature{ii,1} = [ concatFrequencyFeature concatTimeFeature];    
    end
    RawData{i,12} = concatFeature;
end
%
%   3.2. DATA DIVISION
%   Split all data into two parts of training and testing data
% 
%   Based on the order number of collected data
%   if (order%2==0) -> training; else -> testing
dataTrain = RawData(mod(cell2mat(RawData(:,6)),2)==1,:);
dataTest = RawData(mod(cell2mat(RawData(:,6)),2)==0,:);
%
%   3.3. FEATURE MATRIX AND LABEL VECTOR GENERATION
%   Create the matrices of features and vector of labels for both 
%   training and testing data
%
% TRAINING part
featureMatTrain = [];
labelVecTrain = [];
sessionVecTrain = [];
for i = 1: length(dataTrain)
    featureMatTrain = [featureMatTrain;cell2mat(dataTrain{i,12})];
    tempVec = zeros(length(dataTrain{i,12}),1);
    tempVec(:) = dataTrain{i,3};
    labelVecTrain = [labelVecTrain; tempVec];
    tempVec = zeros(length(dataTrain{i,9}),1);
    tempVec(:) = dataTrain{i,5};
    sessionVecTrain = [sessionVecTrain;tempVec];
end

%TESTING part
featureMatTest = [];
labelVecTest = [];
sessionVecTest = [];
for i = 1: length(dataTest)
    featureMatTest = [featureMatTest;cell2mat(dataTest{i,12})];
    tempVec = zeros(length(dataTest{i,12}),1);
    tempVec(:) = dataTest{i,3};
    labelVecTest = [labelVecTest; tempVec];
    tempVec = zeros(length(dataTest{i,9}),1);
    tempVec(:) = dataTest{i,5};
    sessionVecTest = [sessionVecTest;tempVec];
    
end

%%  3.4 AUTHENTICATION
%   Use libsvm to train/predict data.
%   3.4.1 TRAINING
%   3.4.1a Apply PCA to training data
[featureMatTrain,eigenVec,meanVec] = eigenGait(featureMatTrain);
%   3.4.1b Normalize the training data to -1...1 scale
max_val = max(featureMatTrain);
min_val = min(featureMatTrain);
max_valTrain = repmat(max_val,size(featureMatTrain,1),1);
min_valTrain = repmat(min_val,size(featureMatTrain,1),1);
featureMatTrain = ((featureMatTrain-min_valTrain)./(max_valTrain-min_valTrain) - 0.5 ) *2;
% 
% 3.4.2 TESTING
%
% 3.4.2.1a Apply PCA to testing data using eigen vector and mean value obtained in training phase
meanMat = repmat(meanVec,size(featureMatTest,1),1);
featureMatTest = (featureMatTest - meanMat)*eigenVec;
% 3.4.2.1b normalize feature matrix based on max min values extracted from the training phase
max_valTest = repmat(max_val,size(featureMatTest,1),1);
min_valTest = repmat(min_val,size(featureMatTest,1),1);
featureMatTest = ((featureMatTest-min_valTest)./(max_valTest-min_valTest) - 0.5 ) *2;

%% 3.4.3a AUTHENITCATION USING SVM 
% Uncomment this block, comment the next block if using SVM classification

% DO MANUALLY to plot ROC curve for showing authentication performance
uniLabel =unique(labelVecTrain); 
stack_x_1 = {};
stack_x_2 = {};
stack_y_1  = {};
stack_y_2  = {};
for i = 1 :length(uniLabel)
    labelVecBinTrain = labelVecTrain;
    labelVecBinTrain(labelVecBinTrain(:)~=(uniLabel(i)))=-1;
    labelVecBinTrain(labelVecBinTrain(:)==(uniLabel(i)))=1;
    unbalanced_weight = round((length(labelVecBinTrain)-sum(labelVecBinTrain(:)==1))/sum(labelVecBinTrain(:)==1));    
    % train the model...
    model = svmtrain(labelVecBinTrain,featureMatTrain,['-t 0 -b 1 -w1 1 ' '-w-1 ' num2str(unbalanced_weight) ]);  
    %... and test
    labelVecBinTest = labelVecTest;
    labelVecBinTest(labelVecBinTest(:)~=uniLabel(i))=-1;
    labelVecBinTest(labelVecBinTest(:)==uniLabel(i))=1;
    [l,a,deci]=svmpredict(labelVecBinTest,featureMatTest,model);
    
%%    3.4.3a.i. Consider EACH SEGMENT as a testing sample....
%     Uncomment this sub-block, comment the 2.3.3a.ii. sub-block if considering each segment as a testing sample 
    [val,ind] = sort(deci,'descend');
    roc_y = labelVecBinTest(ind);
	  stack_x_1tmp = cumsum(roc_y == -1);
    stack_x_2tmp = sum(roc_y == -1);
    stack_y_1tmp = (sum(roc_y == 1)-cumsum(roc_y == 1));
    stack_y_2tmp = sum(roc_y == 1);
    stack_x_1{1,i} = stack_x_1tmp;
    stack_x_2{1,i} = stack_x_2tmp;
    stack_y_1{1,i} = stack_y_1tmp;
    stack_y_2{1,i} = stack_y_2tmp;
end
%     -- END 3.4.3a.i. HERE -- 

% %%  3.4.3a.ii. Consider EACH SESSIONG as a testing sample: Grouping
% %   Uncomment this sub-block, comment the 2.3.3a.i. sub-block if considering each session as a testing sample  
%     % Normalize decision value to 0..1;
%     max_deci = max(deci);
%     min_deci = min(deci);
%     deci = (deci-min_deci)/(max_deci-min_deci); 
%     % Start Grouping
%     uniSessionTest = unique(sessionVecTest);
%     newPredictedLabel = zeros(length(uniSessionTest),1);
%     newTrueLabel = zeros(length(uniSessionTest),1);
%     newDeci = zeros(length(uniSessionTest),1);
%     for ii=1:length(uniSessionTest)
%         curIdxTest = find(sessionVecTest==uniSessionTest(ii));
%         newTrueLabel(ii) = unique(labelVecBinTest(curIdxTest)); 
%         curPredictedLabel = l(curIdxTest);
%         curDecisionVal = deci(curIdxTest);
%         count_1 = sum(curPredictedLabel==1);
%         count_minus1 = sum(curPredictedLabel==-1);
%         sumDeci_1 = sum(curDecisionVal(curPredictedLabel==1));
%         sumDeci_minus1 = sum(curDecisionVal(curPredictedLabel==-1));
%         if(count_1 > count_minus1)
%             newPredictedLabel(ii) = 1;
%             newDeci(ii) = sumDeci_1/count_1;
%         elseif (count_1 < count_minus1)
%             newPredictedLabel(ii) = -1;
%             newDeci(ii) = sumDeci_minus1/count_minus1;
%         else
%             if(sumDeci_1>sumDeci_minus1)
%                 newPredictedLabel(ii) = 1;
%                 newDeci(ii) = sumDeci_1/count_1;
%             else
%                 newPredictedLabel(ii) = -1;
%                 newDeci(ii) = csumDeci_minus1/count_minus1;
%             end
%         end
%     end
%     [val,ind] = sort(newDeci,'descend');
%     roc_y = newTrueLabel(ind);
% 	  stack_x_1tmp = cumsum(roc_y == -1);
%     stack_x_2tmp = sum(roc_y == -1); 
%     stack_y_1tmp = (sum(roc_y == 1)-cumsum(roc_y == 1));
%     stack_y_2tmp = sum(roc_y == 1);
%     stack_x_1{1,i} = stack_x_1tmp;
%     stack_x_2{1,i} = stack_x_2tmp;
%     stack_y_1{1,i} = stack_y_1tmp;
%     stack_y_2{1,i} = stack_y_2tmp;
%   end
% %    --- END 3.4.3a.ii. HERE   ---


% PLOT ROC 
s = cell2mat(stack_x_1);
s2 = sum(s,2);
s3 = cell2mat(stack_x_2);
s4 = sum(s3);
stack_x = s2./s4;
s = cell2mat(stack_y_1);
s2 = sum(s,2);
s3 = cell2mat(stack_y_2);
s4 = sum(s3);
stack_y = s2./s4;
figure(1);
hold on
axis xy
axis([-0.01 1 -0.01 1])
axis equal
plot(stack_x,stack_y,'color','b');
plot([0 1], [0 1]);
xlabel('False Acceptance Rate');
ylabel('False Rejection Rate');
title(['ROC curve ']);
hold off

% %% 3.4.3b AUTHENTICATION BASED ON THRESHOLD 
% %  Uncomment this block, and comment the previous block if using
% %  threshold-based authentication
% 
% %   Calculate the matrix distance between two data of training & testing
% matDistance = pdist2(featureMatTest,featureMatTrain,'euclidean');
% 
% %% 3.4.3b.i. Consider EACH SEGMENT as a testing sample....
% %  Uncomment this sub-block, comment the 2.3.3b.ii. sub-block if considering each segment as a testing sample 
% 
% referLabelVecTest = labelVecTest;
% matDistanceSegmentTestVSIDTrain = zeros(size(matDistance,1),length(unique(labelVecTrain)));
% uniLabelTrain = unique(labelVecTrain);
% for i = 1 : size(matDistance,1)
%     for ii = 1: length(uniLabelTrain)
%         matDistanceSegmentTestVSIDTrain(i,ii) = min(matDistance(i,labelVecTrain(:)== uniLabelTrain(ii)));
%     end  
% end
% 
% % PLOT ROC CURVE
% stack_x_1 = {};
% stack_x_2 = {};
% stack_y_1  = {};
% stack_y_2  = {};
% 
% for i = 1: size(matDistanceSegmentTestVSIDTrain,2)
%     curDistance = matDistanceSegmentTestVSIDTrain(:,i);
%     [val,ind] = sort(curDistance);
%     roc_y = referLabelVecTest(ind);
%     stack_x_1{1,i} = cumsum(roc_y ~= uniLabelTrain(i));
%     stack_x_2{1,i} = sum(roc_y ~= uniLabelTrain(i));
%     stack_y_1{1,i} = (sum(roc_y == uniLabelTrain(i))-cumsum(roc_y == uniLabelTrain(i))); 
%     stack_y_2{1,i} = sum(roc_y == uniLabelTrain(i));
%     
%  
% end
% s = cell2mat(stack_x_1);
% s2 = sum(s,2);
% s3 = cell2mat(stack_x_2);
% s4 = sum(s3);
% stack_x = s2./s4;
% s = cell2mat(stack_y_1);
% s2 = sum(s,2);
% s3 = cell2mat(stack_y_2);
% s4 = sum(s3);
% stack_y = s2./s4;
% figure(1);
% hold on
% axis xy
% axis([-0.01 1 -0.01 1])
% axis equal
% plot(stack_x,stack_y,'color','r');
% xlabel('False Acceptance Rate');
% ylabel('False Rejection Rate');
% title(['ROC curve ']);
% hold off
% % --- END 3.4.3b.i. HERE   ---
% 
% 
% % %%   3.4.3b.ii. Consider EACH SESSIONG as a testing sample: Grouping
% % %    Uncomment this sub-block, comment the 2.3.4b.i. sub-block if considering each session as a testing sample
% % uniLabelTrain= unique(labelVecTrain);
% % uniSessionTest= unique(sessionVecTest);
% % matDistanceSessionTestVSIDTrain = zeros(length(uniSessionTest),length(uniLabelTrain));
% % referLabelVecTest = zeros(length(uniSessionTest),1);
% % for i = 1:length(uniSessionTest)
% %     idxTest = find(sessionVecTest==uniSessionTest(i));
% %     referLabelVecTest(i)=unique(labelVecTest(idxTest));
% %     if(isnan(idxTest))
% %         continue;
% %     end
% %     for j =1:length(uniLabelTrain)
% %         idxTrain = find(labelVecTrain == uniLabelTrain(j));
% %         subMatDist = matDistance(idxTest,idxTrain);
% %         minVal = min(min(subMatDist));
% %         matDistanceSessionTestVSIDTrain(i,j) = minVal;
% %     end
% % end
% % % PLOT ROC CURVE
% % stack_x_1 = {};
% % stack_x_2 = {};
% % stack_y_1  = {};
% % stack_y_2  = {};
% % for i = 1: size(matDistanceSessionTestVSIDTrain,2)
% %     curDistance = matDistanceSessionTestVSIDTrain(:,i);
% %     [val,ind] = sort(curDistance);
% %     roc_y = referLabelVecTest(ind);
% %     stack_x_1{1,i} = cumsum(roc_y ~= uniLabelTrain(i));
% %     stack_x_2{1,i} = sum(roc_y ~= uniLabelTrain(i));
% %     stack_y_1{1,i} = (sum(roc_y == uniLabelTrain(i))-cumsum(roc_y == uniLabelTrain(i))); 
% %     stack_y_2{1,i} = sum(roc_y == uniLabelTrain(i));
% % end
% % s = cell2mat(stack_x_1);
% % s2 = sum(s,2);
% % s3 = cell2mat(stack_x_2);
% % s4 = sum(s3);
% % stack_x = s2./s4;
% % s = cell2mat(stack_y_1);
% % s2 = sum(s,2);
% % s3 = cell2mat(stack_y_2);
% % s4 = sum(s3);
% % stack_y = s2./s4;
% % figure(1);
% % hold on
% % axis xy
% % axis([-0.01 1 -0.01 1])
% % axis equal
% % plot(stack_x,stack_y,'color','r');
% % xlabel('False Acceptance Rate');
% % ylabel('False Rejection Rate');
% % title(['ROC curve ']);
% % hold off
% % % --- END 3.4.3b.ii. HERE   ---
