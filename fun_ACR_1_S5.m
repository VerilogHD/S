function [distance_real_hori,distance_real_vert,...
    distance_real_ng,distance_real_pg,pf_hdl]=fun_ACR_1_S5...
    (dir_name,file_name,visual,imag_check,img_type,save_path)
% This function is used for geometric distortion check on S5. Two pairs
% of cross lines are measured, the 1st cross is measured as normal. Before
% measuring the 2nd cross, the image is rotated by 45 degrees and then
% performs the normal mearsurement. 1st cross measurement gives the
% horizontal and vertical diameter of phantom, 2nd cross measurement gives
% the negative and positive gradient diameter of phantom
%
% NOTE: This function uses two methods for the rest of the 1st and 2nd 
% pairs of crosses coordinant finding. For 1st cross, it uses the normal 
% function defined as fun_ACR_FindWaterBndryBinary_RestCoord. For 2nd pair
% cross, it simply sum rotated binary image horizontally and vertically and 
% search for peak. Because this process is only for display purpose, the 
% 2nd method is acceptable.
%
% Input:
%   dir_name: directory path string where image is stored
%   file_name: file name of S5
%   visual: visualisation option, 1=on & 0=off. Showing all graphs and
%           plots for visualisation purpose
%   imag_check: if check the current image is the correct image
%   img_type: image type (string: T1 or T2)
%   save_path: the path to save image
% Output:
%   distance_real_hori: horizontal measurement of phantom
%   distance_real_vert: vertical measurement of phantom
%   distance_real_pg: positive gradient measurement of phantom
%   distance_real_ng: negative gradient measurement of phantom
%   pf_hdl: pass/fail handle
% Usage: 
%   [dist_hori,dist_vert,dist_ng,dist_pg]=fun_ACR_1_S5()
%   [dist_hori,dist_vert,dist_ng,dist_pg]=fun_ACR_1_S5('dir_str','file_str',1or0)
% HW: (search for HW)
%   mask threshold=mu-2*std to cover most water (necessary to cover 95%)
%   sum up row & col band using 30%-60% of central image to avoid missing
%       circle centre because of positioning error
%   result display location on image
%   sometime pg length is off by ~10 pixels when showing on image

% Author: Jidi Sun
% Email: jidi.sun@uon.edu.au
% Version: v.1 (28/03/13)
%          v.2 (15/05/13)(search for v2)
%          v.3 (21/08/13)(search for v3)
%          v.4 (27/08/13)(search for v4)
%          v.5 (09/01/14)(search for v5)
%          v.6 (11/01/14)(search for v6)
%          v.7 (30/04/14)(search for v7)
% History: v.1
%          v.2 allow user to change the directory and file names depends
%              on where the image is stored. This can be changed at the
%              beginning of this file;
%              also directory and file name strings are 2 new inputs of
%              this function;
%              add visualisation option;
%          v.3 add option if to allow user to check the current image;
%              output pass/fail handle;
%          v.4 replace FINDPEAKS function with MAX function to find the
%              coordinates to display length
%          v.5 simplify the method to find coord for displaying diameter
%              for hori & vert phantom diameter;
%              replace v4 with midpoint of phantom boundaries, because 
%              sometime phantom edge is spiky after rotation and the peak 
%              may not be the central line
%          v.6 replace manual setup of intensity range for water peak
%              intensity calculation with automatic peak estimation
%          v.7 add save_path variable to save measurement image to a
%              designated path
% Copyright: please see license.txt
% Acknowledgement: My study is funded by the Cancer Council NSW, Australia,
%                  project grant RG11-05. PhD under the University of 
%                  Newcastle and the Calvary Mater Newcastle Hospital 
%                  provides me the office and the MR scanner to work with.
%1.check if user has specified dir and file name and visualisation option
if ~exist('dir_name','var')||isempty(dir_name)%v2
    dir_name='test_images\';
end
if ~exist('file_name','var')||isempty(file_name)%v2
    file_name='S5.dcm';
end
if ~exist('visual','var')||isempty(visual)%v2
    visual=0;
end
if ~exist('imag_check','var')||isempty(imag_check)%v5
    imag_check=0;
end
%2.load and display image to let user check if it is S5
I=dicomread([dir_name file_name]);%v2
if imag_check==1%v3
    h=imtool(I,[]);
    choice = questdlg('Is this image the S5 image?', ...
        'Choose Red or Blue Pill', ...
        'Yes','No','Yes');%Construct a questdlg with two options
    switch choice%Handle response
        case 'Yes'
            path_name=[dir_name file_name];%v2
            %v6 comment out
%             imcontrast(h);%open contrast window
%             prompt = {'Lower Intensity:','Higher Intensity:'};
%             dlg_title = 'Water Intensity Range';
%             num_lines = 1;
%             def = {'1500','3500'};
%             answer = inputdlg(prompt,dlg_title,num_lines,def);
            close(h);%shut window
        case 'No'
            close(h);%shut window
            disp('Manually select localiser image.');%manual selection
            [f_n,p_n]=uigetfile([dir_name '*.dcm']);%v2
            path_name=fullfile(p_n,f_n);
            I=dicomread(path_name);
            h=imtool(I,[]);
            %v6 comment out
%             imcontrast(h);%open contrast window
%             prompt = {'Lower Intensity:','Higher Intensity:'};
%             dlg_title = 'Water Intensity Range';
%             num_lines = 1;
%             def = {'1500','3500'};
%             answer = inputdlg(prompt,dlg_title,num_lines,def);
            close(h);%shut window
    end
elseif imag_check==0
    path_name=[dir_name file_name];
    %v6 comment out
%     h=imtool(I,[]);
%     imcontrast(h);
%     prompt = {'Lower Intensity:','Higher Intensity:'};
%     dlg_title = 'Water Intensity Range';
%     num_lines = 1;
%     def = {'1500','3500'};
%     answer = inputdlg(prompt,dlg_title,num_lines,def);
%     close(h);%shut window
end
%3.use mean and std of water to mask image
%v6 comment out
% I_low=str2double(answer{1,1});%get the input
% I_high=str2double(answer{2,1});
% [mu,~]=fun_ACR_FindWaterMean...
%     (I,I_low,I_high,'rician',visual);%find water mean
mu=fun_ACR_FindWaterIntPeak(I,0.1,visual);
% I_bin=add_threshold(I,mu-2*sigma);%HW:threshold mu-2*std to ensure most
% imtool(I_bin,[]);                 %water masked in new binary image
I_bin=add_threshold(I,mu/2);%half water mean as threshold
if visual==1%v2
    figure;
    imshow(I_bin,[]);
    title('Thresholded S5 Image');
else
    disp(['You have turned off graph visualisation '...
        'to show the thresholded S5 image']);
end
%4.sum up a band of row (30%-60% of image size) to get row bndry
[ind_l,ind_r]=fun_ACR_FindBndryFromBand(I_bin,'row',[0.3 0.6]);
%5.sum up a band of col (30%-60% of image size) to get col bndry
[ind_t,ind_b]=fun_ACR_FindBndryFromBand(I_bin,'col',[0.3 0.6]);
%6.find pixel distance and convert to mm
distance_col=ind_r-ind_l;
distance_row=ind_b-ind_t;
pxl_sz=fun_DICOMInfoAccess(path_name,'PixelSpacing');
distance_real_c=distance_col*pxl_sz(1,1);
distance_real_hori=round(distance_real_c*10)/10;
distance_real_r=distance_row*pxl_sz(1,1);
distance_real_vert=round(distance_real_r*10)/10;
%7.find rest coord of bndry
% [ind_l_y,ind_r_y]=fun_ACR_FindWaterBndryBinary_RestCoord(I_bin,'row');
% [ind_t_x,ind_b_x]=fun_ACR_FindWaterBndryBinary_RestCoord(I_bin,'col');
ind_l_y=(ind_b-ind_t)/2+ind_t;%v5
ind_t_x=(ind_r-ind_l)/2+ind_l;%v5
figure;
imshow(I,[]);
hold on
% plot([ind_t_x,ind_b_x],[ind_t,ind_b],'Color','r','LineWidth',2);
% plot([ind_l,ind_r],[ind_l_y,ind_r_y],'Color','r','LineWidth',2);
plot([ind_t_x,ind_t_x],[ind_t,ind_b],'Color','r','LineWidth',2);%v5
plot([ind_l,ind_r],[ind_l_y,ind_l_y],'Color','r','LineWidth',2);%v5
text(ind_t_x-50,ind_t+20,...%HW:50 pxls to left
    [num2str(distance_real_vert) '\rightarrow'],...%use 'normalized' to
    'Color','r','FontUnits','normalized');         %scale letter to image
text(ind_t_x+20,ind_l_y-10,...%HW:20 pxls up
    ['\downarrow' num2str(distance_real_hori)],...%use 'normalized' to
    'Color','r','FontUnits','normalized');        %scale letter to image
if exist('save_path','var')
    if strcmp(img_type,'T1')
        saveas(gcf,[save_path 'Test1_S5_T1(1).png']);
    elseif strcmp(img_type,'T2')
        saveas(gcf,[save_path 'Test1_S5_T2(1).png']);
    end
    disp('The result image has been saved to the following path:');
    disp(save_path);
end
%8.rotate binary image by 45 degrees
I_bin_r=imrotate(I_bin,45);
%9.sum up a band of row (30%-60% of image size) to get row bndry for
%  negative gradient length
[ind_l_r,ind_r_r]=fun_ACR_FindBndryFromBand(I_bin_r,'row',[0.3 0.6]);
%10.sum up a band of col (30%-60% of image size) to get col bndry for
%  positive gradient length
[ind_t_r,ind_b_r]=fun_ACR_FindBndryFromBand(I_bin_r,'col',[0.3 0.6]);
%10.find pixel distance and convert to mm
distance_col_r=ind_r_r-ind_l_r;
distance_row_r=ind_b_r-ind_t_r;
distance_real_ng=distance_col_r*pxl_sz(2,1);
distance_real_ng=round(distance_real_ng*10)/10;
distance_real_pg=distance_row_r*pxl_sz(2,1);
distance_real_pg=round(distance_real_pg*10)/10;
%11.fast way to get other coord of bndry for display purpose only
% sum_h=sum(I_bin_r,1);%sum image horizontally
% [~,ind_tb_r]=findpeaks(sum_h,'SORTSTR','ascend');
% ind_tb_r=ind_tb_r(end);%peak is the last element
% sum_v=sum(I_bin_r,2);%sum image vertically
% [~,ind_lr_r]=findpeaks(sum_v,'SORTSTR','ascend');
% ind_lr_r=ind_lr_r(end);%peak is the last element
% [~,ind_tb_r]=max(sum_h);%v4
% ind_tb_r=ind_tb_r+10;%HW:sometimes off by 10 pixels,need improve%v4
% [~,ind_lr_r]=max(sum_v);%v4
% ind_tb_r=(find(sum_h,1,'last')-find(sum_h,1,'first'))/2+...
%     find(sum_h,1,'first');%v5
% ind_lr_r=(find(sum_v,1,'last')-find(sum_v,1,'first'))/2+...
%     find(sum_v,1,'first');%v5
ind_lr_r=(ind_b_r-ind_t_r)/2+ind_t_r;%v5
ind_tb_r=(ind_r_r-ind_l_r)/2+ind_l_r;%v5
figure;
imshow(imrotate(I,45),[]);
hold on
plot([ind_tb_r,ind_tb_r],[ind_t_r,ind_b_r],'Color','r','LineWidth',2);
plot([ind_l_r,ind_r_r],[ind_lr_r,ind_lr_r],'Color','r','LineWidth',2);
text(ind_lr_r-50,ind_t_r+20,...%HW:50 pxls to left
    [num2str(distance_real_ng) '\rightarrow'],...%use 'normalized' to
    'Color','r','FontUnits','normalized');       %scale letter to image
text(ind_lr_r+20,ind_tb_r-10,...%HW:20 pxls up
    ['\downarrow' num2str(distance_real_pg)],...%use 'normalized' to scale
    'Color','r','FontUnits','normalized');      %letter to image
disp('The displayed line only extends to the pixel centre.');
if exist('save_path','var')
    if strcmp(img_type,'T1')
        saveas(gcf,[save_path 'Test1_S5_T1(2).png']);
    elseif strcmp(img_type,'T2')
        saveas(gcf,[save_path 'Test1_S5_T2(2).png']);
    end
    disp('The result image has been saved to the following path:');
    disp(save_path);
end
%12.pass/fail handle
if distance_real_vert>=188 && distance_real_vert<=192%v3
    pf_hdl(1,1)=1;
else
    pf_hdl(1,1)=0;
end
if distance_real_hori>=188 && distance_real_hori<=192%v3
    pf_hdl(1,2)=1;
else
    pf_hdl(1,2)=0;
end
if distance_real_ng>=188 && distance_real_ng<=192%v3
    pf_hdl(1,3)=1;
else
    pf_hdl(1,3)=0;
end
if distance_real_pg>=188 && distance_real_pg<=192%v3
    pf_hdl(1,4)=1;
else
    pf_hdl(1,4)=0;
end
end