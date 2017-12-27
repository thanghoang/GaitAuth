function [timeFeature] = extractFeature_timedomain(dataBySession)
    %
    % CONFIGURATION SETTING
    %
    % IMPORTANT NOTE:
    % the extracted freqFeature will have 5 column, with each is the
    % extracted feature on separate axis as follwing
    % [feature(X) feature(Y) feature(Z) feature(MXY) feature(MXYZ)]
    %
    nBin_histogram = 10;
    
    timeFeature = {};
    for i = 1:length(dataBySession)
        %get the data of the current segment
        curData = dataBySession{i,1};
        % create MXY & MXYZ signal to extract features on these axes
        MXY = sqrt(curData(:,2).^2+curData(:,3).^2);
        MXYZ = sqrt(curData(:,2).^2 + curData(:,3).^2 + curData(:,4).^2);
        curData = [curData MXY MXYZ];

        curPeakPos = dataBySession{i,2};
        n_components = size(curData,2);
        curFeature = [];
        for j =2:n_components %1 is the timestamp
            curComData = curData(:,j);
            % 1. Average maximum acceleration values of each gait cycle in a
            % segment
            avg_max = 0 ;
            for jj = 1: length(curPeakPos)-1
                avg_max = avg_max + max(curComData(curPeakPos(jj):curPeakPos(jj+1)));                
            end
            avg_max = avg_max/(length(curPeakPos)-1);

            % 2. Average minimum acceleration values of each gait cycle in a
            %segment
            avg_min = 0 ;
            for jj = 1: length(curPeakPos)-1
                avg_min = avg_min + min(curComData(curPeakPos(jj):curPeakPos(jj+1)));
            end
            avg_min = avg_min/(length(curPeakPos)-1);

            % 3. average absolute difference
            mu = mean(curComData);
            avg_abs_dif = sum(abs(curComData - mu));

            % 4. rms feature
            rms = sqrt(mean(curComData.^2));

            % 5. n bins histogram distribution
            histogram = hist(curComData,nBin_histogram)/length(curComData);

            % 6. standard deviation
            sd = std(curComData);

            % 7. waveform length
            Comp_2 = curComData; Comp_2(1) = [];
            Comp_1 = curComData; Comp_1(end) = [];
            waveform_len = sum(abs(Comp_2-Comp_1));

            % 8. gait cycle's average length (Cadence as in SEC)
            curPos1 = curPeakPos; curPos1(end) = [];
            curPos2 = curPeakPos; curPos2(1) = [];
            gc_avg_len = mean(curPos2-curPos1);

            curComp_feature = [avg_max avg_min avg_abs_dif rms histogram sd waveform_len gc_avg_len]';
            curFeature=[curFeature curComp_feature];
        end
        timeFeature{i,1} = curFeature;
    end
end