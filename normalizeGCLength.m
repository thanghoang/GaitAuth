function [normalizedData] = normalizeGCLength(Segment,n)
% This function nomarlizes the length of each gait cycle in a segment to
% a fixed value.
%
%   CONFIGURATION SETTING
%
SegmentTmp =[];
newGCLen = [];
curPos = 1;
for i = 1 : length(Segment{:,2})
    curGC = Segment{1,1}(curPos:curPos-1+Segment{:,2}(i),:);
    if n == length(curGC)
        newGCLen = [newGCLen length(curGC)];
        SegmentTmp = [SegmentTmp; curGC];     
        continue;
    elseif n > length(curGC)
        for ii = 1 : n-length(curGC)
           posTmp = 1;
           d = abs(sqrt(curGC(1,2)^2+curGC(1,3)^2+curGC(1,4)^2)-sqrt(curGC(1+1,2)^2+curGC(1+1,3)^2+curGC(1+1,4)^2));
           for iii = 2: length(curGC)-1
               dTmp = abs(sqrt(curGC(iii,2)^2+curGC(iii,3)^2+curGC(iii,4)^2)-sqrt(curGC(iii+1,2)^2+curGC(iii+1,3)^2+curGC(iii+1,4)^2));
               if dTmp > d
                   d = dTmp;
                   posTmp = iii;
               end
           end
           newVal = (curGC(posTmp,:)+ curGC(posTmp+1,:))/2;
           curGC = [curGC(1:posTmp,:); newVal; curGC(posTmp:end,:)];
        end
        newGCLen = [newGCLen length(curGC)];
        SegmentTmp = [SegmentTmp; curGC];
    elseif n < length(curGC)
        for ii = 1 : length(curGC)-n
            posTmp = 1;
            d = abs(sqrt(curGC(1,2)^2+curGC(1,3)^2+curGC(1,4)^2)-sqrt(curGC(1+1,2)^2+curGC(1+1,3)^2+curGC(1+1,4)^2));
                for iii = 2: length(curGC)-1
                       dTmp = abs(sqrt(curGC(iii,2)^2+curGC(iii,3)^2+curGC(iii,4)^2)-sqrt(curGC(iii+1,2)^2+curGC(iii+1,3)^2+curGC(iii+1,4)^2));
                       if dTmp < d
                           d = dTmp;
                           posTmp = iii;
                       end
                end
                curGC = [curGC(1:posTmp-1,:); curGC(posTmp+1:end,:)];
        end
        newGCLen = [newGCLen length(curGC)];
        SegmentTmp = [SegmentTmp; curGC];        
    end
    curPos = curPos +Segment{:,2}(i)-1;
end
    normalizedData = {};
    normalizedData{1,1} = SegmentTmp;
    %normalizedData{1,2} = newGCLen;
end