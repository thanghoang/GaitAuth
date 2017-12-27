function [gait_pattern] = extractGaitPattern (segments,n,overlap)
    step = n*(1-overlap); 
    if rem(step,1) ~=0
        gait_pattern  = []; 
        return;
    end
    ii=1;
    t = 1;
    mergedSegment = {};
    
    while ii+n-1 <= length(segments)
        %1.1 merge n gait cycles to 1 segment
        if(n>1)
            matTmp = segments{ii}(1:end-1,:);
        else
            matTmp = segments{ii}(1:end,:);
        end
        for j = ii+1: ii+n-1
            if j == ii+n-1
                matTmp = [matTmp;segments{j}(1:end,:)]; 
            else
                matTmp = [matTmp;segments{j}(1:end-1,:)]; 
            end
        end
        mergedSegment{t,1} = matTmp;
        
        %1.2 save the peak positions of each gait cycle
        peakPos = zeros(n,1);
        peakPos(1) = 1;
        for iii = 1 : n
            peakPos(iii+1) = peakPos(iii) + length(segments{ii+iii-1})-1;
        end
        mergedSegment{t,2} = peakPos';
        ii = ii + step;
        t = t +1;
     end  
     %1.3 save mergedSegment to output data
     gait_pattern = mergedSegment;
end