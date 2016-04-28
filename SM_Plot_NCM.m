function SM_Plot_NCM(roi_ave);


ROI_dat{1} = roi_ave; 

figure();  
cell = 1; 
day = 1; 
close all

figure(); 
c = jet(6);



plot(roi_ave.analogIO_time{1},(roi_ave.analogIO_dat{1}));
hold on;
for i = 1:56
    if min(min((ROI_dat{day}.interp_raw{cell,i}))) <70;
        continue
    end
  plot(ROI_dat{day}.interp_time{1,i}(10:end),(ROI_dat{day}.interp_raw{cell,i}(10:end)-mean(ROI_dat{day}.interp_raw{cell,i}(10:end)))); 
  hold on; 
end;


for i = 1:56

ROI_dat{day}.raw_dat2{1,i} = interp1(ROI_dat{day}.raw_time{1,i},ROI_dat{day}.raw_dat{1,i},0:1/30:max(roi_ave.interp_time{1}));
end

    



for i = 1:56
for ii= 1:((size(ROI_dat{day}.raw_time{1,i},2))-6);
smoothedA = ROI_dat{day}.raw_dat{1,i}(ii);
smoothedB = ROI_dat{day}.raw_dat{1,i}(ii+1);
smoothedC = ROI_dat{day}.raw_dat{1,i}(ii+2);
smoothedD = ROI_dat{day}.raw_dat{1,i}(ii+3);
smoothedE = ROI_dat{day}.raw_dat{1,i}(ii+4);
smoothedF = ROI_dat{day}.raw_dat{1,i}(ii+5);
SMdat{1,i}(ii)= (smoothedA + smoothedB + smoothedC + smoothedD+ smoothedE+ smoothedF)/6;
end
end;




figure(); 

plot(roi_ave.analogIO_time{1},(roi_ave.analogIO_dat{1}));
hold on;
for i = 1:56
    if min(min((ROI_dat{day}.interp_raw{cell,i}))) <70;
        continue
    end
     gg = str2num(roi_ave.filename{i}(end-4:end-4));
  plot(((1:size(SMdat{1,i}(1:end),2))/30),zscore(SMdat{1,i}(1:end)),'color',c(gg,:)); 
  hold on; 
end;




figure();


counter = 1;
per = 0;
for i = 1:56
    if min(min((ROI_dat{day}.interp_raw{cell,i})))<70;
        continue
    end

% if roi_ave.filename{i}(end-7:end-4) == '0006';
      
%     subplot(2,1,1);
%     plot(roi_ave.analogIO_time{i},(roi_ave.analogIO_dat{i})+counter);
%     hold on;
%     subplot(2,1,2);
%     
    baseline=repmat(prctile(SMdat{1,i},per,2),[1 size(SMdat{1,i},2)]);
    gg = str2num(roi_ave.filename{i}(end-4:end-4));
  plot(((1:size(SMdat{1,i}(1:end),2))/30),((SMdat{1,i}(1:end)-baseline)./baseline)*100,'color',c(gg,:)); 
  legend_disp{counter} = roi_ave.filename{i}(end-7:end-4);
  hold on; 
  axis tight
  counter = counter+1;
%      end
try
AV_trace{gg} = vertcat(AV_trace{gg},((SMdat{1,i}((1:50))-baseline(1:50))./baseline(1:50))*100);
catch
AV_trace{gg} = ((SMdat{1,i}((1:50))-baseline(1:50))./baseline(1:50))*100;
end

end

grid on;
legend(legend_disp)
xlabel('time(s)');

CC = {'r','g','b','c','m','y'}
figure()
for i = 1:size(AV_trace,2);
    G = (AV_trace{i});
    x=1:size(G,2);
   h(i) =  shadedErrorBar(x/30,G,{@mean,@std},{CC{i},'LineWidth',3,'markerfacecolor',CC{i}},1);  
    %plot((1:length(G))/30,G,'color',c(i,:),'LineWidth',3)
    hold on;
    grid on;
    axis tight;
    legendInfo{i} = ['Motif# = ' num2str(i)]; % or whatever is appropriate
end


title('Average of single cell response to different motif conditions')
ylabel('df/f')
xlabel('time(s)')
legend([h(1).mainLine,h(2).mainLine,h(3).mainLine,h(4).mainLine,h(5).mainLine,h(6).mainLine],legendInfo)
clear Legend_disp;
