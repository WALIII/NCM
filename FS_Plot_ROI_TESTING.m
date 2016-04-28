function roi_ave= FS_Plot_ROI_TESTING(ROIS,varargin)
% FS_Plot_ROI.m

% Selects an arbitrary number of roi's for plotting. Run in .mat directory.
%   Created: 2015/08/02
%   By: WALIII
%   Updated: 2016/02/15
%   By: WALIII

%% Starting Variables
colors=eval(['winter(' num2str(length(ROIS.coordinates)) ')']);
sono_colormap='hot';
baseline=3;
ave_fs=30*3; % multiply by a variable 'n' if you want to interpolate
save_dir='roi';
template=[];
fs=48000;
per=2;
max_row=5;
min_f=0;
max_f=9e3;
lims=1;
dff_scale=20;
t_scale=.5;
resize=1;
detrend_traces=0;
crop_correct=0;
counteri = 1;

nparams=length(varargin);

if mod(nparams,2)>0
	error('Parameters must be specified as parameter/value pairs');
end

for i=1:2:nparams
	switch lower(varargin{i})
		case 'colors'
			colors=varargin{i+1};
		case 'sono_colormap'
			sono_colormap=varargin{i+1};
		case 'baseline'
			baseline=varargin{i+1};
		case 'ave_fs'
			ave_fs=varargin{i+1};
		case 'save_dir'
			save_dir=varargin{i+1};
		case 'template'
			template=varargin{i+1};
		case 'fs'
			fs=varargin{i+1};
		case 'per'
			per=vargin{i+1};
		case 'max_row'
			max_row=varargin{i+1};
		case 'dff_scale'
			dff_scale=varargin{i+1};
		case 't_scale'
			t_scale=varargin{i+1};
		case 'resize'
			resize=varargin{i+1};
		case 'detrend_traces'
			detrend_traces=varargin{i+1};
		case 'crop_correct'
			crop_correct=varargin{i+1};
	end
end



mkdir(save_dir);
% ROIS is a cell array of image indices returned by fb_select_roi

mov_listing=dir(fullfile(pwd,'*.mat'));
mov_listing={mov_listing(:).name};


for i=1:length(mov_listing)
clear tmp; clear mov_data; clear frames;

	disp(['Processing file ' num2str(i) ' of ' num2str(length(mov_listing))]);
	load(fullfile(pwd,mov_listing{i}),'mov_data','mic_data','fs','vid_times','video','audio');

% Get Audio/Video template matched offsets
try
	for ii = 1:length(mov_data)
		mov_data2(:,:,ii) = rgb2gray(mov_data(ii).cdata(:,:,:,:));
	end
	disp(' Template match detected- Compensating for A/V mis-alignment...')
		 offset2 = (vid_times(:,1)-mic_data(1,2)/fs);
		 timevec=(offset2'); %movie_fs
		 G = diff(vid_times(:,1), 1);
catch
	disp(' Non-template matched video- proceed to align to A/V timestamps...')
	mov_data = video.frames;
	vid_times = video.times;
	mic_data = audio.data;
	fs = 48000;
	G = diff(vid_times(:,1), 1);
	timevec = (vid_times');
	for ii = 1:length(mov_data)
	     mov_data2(:,:,ii) = rgb2gray(mov_data(ii).cdata(:,:,:,:));
	end
end

% Check For Dropped Frames:
if any(G >.07) %0.05 for 30fps
    disp('   **    Dropped Frame detected    **  ')
else
    disp('No Dropped Frames Detected')
clear offset2

mov_data = double(mov_data2);
roi_n=length(ROIS.coordinates);
ave_time=0:1/ave_fs:length(mic_data)/fs;
% roi_ave.raw={};
% roi_ave.interp_dff={};
% roi_ave.interp_raw={};

% roi_ave.interp_dff{i} = zeros(roi_n,length(ave_time),length(mov_listing));
% roi_ave.interp_raw{i} = zeros(roi_n,length(ave_time),length(mov_listing));

[rows,columns,frames]=size(mov_data);
	% resize if we want



	[path,file,ext]=fileparts(mov_listing{i});
	save_file=[ file '_roi' ];


	% roi_traces

	roi_t=zeros(roi_n,frames);







	disp('Computing ROI averages...');

	[nblanks,formatstring]=fb_progressbar(100);
	fprintf(1,['Progress:  ' blanks(nblanks)]);

	% unfortunately we need to for loop by frames, otherwise
	% we'll eat up too much RAM for large movies

	for j=1:roi_n
		fprintf(1,formatstring,round((j/roi_n)*100));

		for k=1:frames

			tmp=mov_data(ROIS.coordinates{j}(:,2),ROIS.coordinates{j}(:,1),k);
			roi_t(j,k)=mean(tmp(:));
		end
	end

	fprintf(1,'\n');

	dff=zeros(size(roi_t));


	% interpolate ROIs to a common timeframe
roi_ave.AnalogIn{i} = mic_data;
	for j=1:roi_n
clear tmp
clear dff

		tmp=roi_t(j,:);
        tmp = tmp(:,(1:size(timevec,2)));


		if baseline==0
			norm_fact=mean(tmp,3);
		elseif baseline==1
			norm_fact=median(tmp,3);
		elseif baseline==2
			norm_fact=trimmean(tmp,trim_per,'round',3);
		else
			norm_fact=prctile(tmp,per);
		end

dff(j,:)=((tmp-norm_fact)./norm_fact).*100;
yy=interp1(timevec,dff(j,:),ave_time,'spline');
yy2=interp1(timevec,tmp,ave_time,'spline');


roi_ave.interp_dff{j,counteri}=yy;
roi_ave.interp_raw{j, counteri}=yy2;
roi_ave.RawTime{j,counteri} = timevec;
roi_ave.RAWdat{j,counteri} = tmp;
clear yy2; clear yy;

%         roi_ave.interp_corr(j,:,i)=yy3;
%         roi_ave.interp_corr2(j,:,i)=yy4;
%         roi_ave.interp_Timeing(j,:,i) = (1:length(yy2));

    end
        counteri = counteri+1;


				roi_ave.raw{i}=roi_t; % store for average
				roi_ave.filename{i}=mov_listing{i};



end
end

roi_ave.t=ave_time;
save(fullfile(save_dir,['ave_roi.mat']),'roi_ave');
disp('Generating average ROI figure...');
