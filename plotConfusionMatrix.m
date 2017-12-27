function plotConfusionMatrix( figno, true_label, predicted_label )
%PLOTCONFUSIONMATRIX Summary of this function goes here
%   Detailed explanation goes here
    %create a confusion matrix
    uniLabel = unique(true_label);
    confusionMat = zeros(length(uniLabel));
    
    for i = 1:length(true_label)
        confusionMat(predicted_label(i),true_label(i))=confusionMat(predicted_label(i),true_label(i))+1;
    end
    %normalize the confusion matrix to 0 ...1 for each row
    for i = 1 : size(confusionMat,1)
       confusionMat(i,:) =  confusionMat(i,:)./sum(confusionMat(i,:));
    end
    figure(figno);
    hold on
        grid on
    axis on
    %iptsetpref('ImshowAxesVisible','on');
    
    iptsetpref('ImshowBorder','tight');

%      imshow(confusionMat,'InitialMagnification',10000);
 h  = pcolor(confusionMat);
%      colormap(flipud(gray))
 %colormap(jet);
%colormap(jet);
 %set(h, 'EdgeColor', [ 0 0 .6]);
 set(h, 'EdgeColor', [ 0 0 0.6]);
 set(h,'LineStyle','-');
 set(h,'LineWidth',0.1);
set(gca,'xlim',[1 38]);
 set(gca,'ylim',[1 38]);
%     %change to color
  colormap(jet);
%  colormap(flipud(colormap));
 set(gcf, 'color', [1 1 1]);
 tick = linspace(1,38,38);
 set(gca,'XTick',[0:5:38]);  %
 set(gca,'YTick',[0:5:38]);
 %set(gca,'XTickLabel','');
% %label tick
% 
% %labelPos = linspace(1,37,19);
% tick = linspace(1,38,38);
% set(gca,'XTick',tick)  %
% XTick = get(gca,'XTick');
% set(gca,'XTickLabel','');
% %xticklabel_rotate90(XTick);
%  
% set(gca,'YTick',tick)  %
% set(gca,'YTickLabel','');
%set(gca,'YTickLabel',labelPos); 
% Set the XTickLabel so that abbreviations for the
% months are used.

    
   c=colorbar;
x1=get(gca,'position');
x=get(c,'Position');
x(3)=0.02;
set(c,'Position',x)
set(gca,'position',x1)

    hold off
end

