% This RUN script runs all the functions to test ACR phantom
%
% A log file summarises the QA result and a spreadsheet of result will be
% created and saved to the directory of the QA images. The path is
% displayed in cmd window.
% 
% Author: Jidi Sun
% Email: jidi.sun@uon.edu.au
% Version: v.1 (17/05/13)
%          v.2 (13/10/13)(search for v2)
%          v.3 (30/04/14)
% History: v.1
%          v.2 changed the output Excel format to single row
%              changed PIU to % before saving, to be consistent to Michael
%              save the Excel sheet in localiser folder
%              add instruction to high contrast test message box
%          v.3 major change: -create a log file store results info
%                            -check if an output exists, so don't repeat
%                             the same measurement if 1st time went wrong
% Copyright: please see license.txt
% Acknowledgement: My study is funded by the Cancer Council NSW, Australia,
%                  project grant RG11-05. PhD under the University of 
%                  Newcastle and the Calvary Mater Newcastle Hospital 
%                  provides me the office and the MR scanner to work with.

%1.pre-define dir&file name
if ~exist('test_choice','var')||isempty(test_choice)%v5
    test_choice=questdlg('What do you want to do?', ...
    'Red or Blue Pill', ...
    'Test Demo','My Own Site','Test Demo');
end
switch test_choice%Handle response
    case 'Test Demo'
        if ~exist('dir_name_loc','var')
            dir_name_loc=pwd;%for testing only
            dir_name_loc=[dir_name_loc '\test_images\loc\'];
        else
            disp('You have specified Localiser directory.');
        end
        if ~exist('dir_name_T1','var')
            dir_name_T1=pwd;
            dir_name_T1=[dir_name_T1 '\test_images\T1\'];
        else
            disp('You have specified T1 directory.');
        end
        if ~exist('dir_name_T2','var')
            dir_name_T2=pwd;
            dir_name_T2=[dir_name_T2 '\test_images\T2\'];
        else
            disp('You have specified T2 directory.');
        end
    case 'My Own Site'
        if ~exist('dir_name_loc','var')||isequal(dir_name_loc,0)
            dir_name_loc=uigetdir('C:\','Select Localiser Directory');
            dir_name_loc=[dir_name_loc '\'];
        else
            disp('You have specified Localiser directory.');
        end
        if ~exist('dir_name_T1','var')||isequal(dir_name_T1,0)
            dir_name_T1=uigetdir('C:\','Select T1 Image Directory');
            dir_name_T1=[dir_name_T1 '\'];
        else
            disp('You have specified T1 directory.');
        end
        if ~exist('dir_name_T2','var')||isequal(dir_name_T2,0)
            dir_name_T2=uigetdir('C:\','Select T2 Image Directory');
            dir_name_T2=[dir_name_T2 '\'];
        else
            disp('You have specified T2 directory.');
        end
end
[file_name_loc]=fun_ACR_FindSlice('loc',dir_name_loc);
[file_name_S1_T1,file_name_S5_T1,file_name_S7_T1,file_name_S8_T1,...
    file_name_S9_T1,file_name_S10_T1,file_name_S11_T1]=...
    fun_ACR_FindSlice('T1',dir_name_T1);
[file_name_S1_T2,file_name_S5_T2,file_name_S7_T2,file_name_S8_T2,...
    file_name_S9_T2,file_name_S10_T2,file_name_S11_T2]=...
    fun_ACR_FindSlice('T2',dir_name_T2);
%2.ask user for visual option
% if ~exist('visual_choice','var')||isempty(visual_choice)
%     visual_choice=questdlg('Do you want to see analysis images?', ...
%         'Choose Red or Blue Pill', ...
%         'Yes','No','No');
%     switch visual_choice
%         case 'Yes'
%             visual=1;
%         case 'No'
%             visual=0;
%     end
% end
visual=0;
%3.initial image check or not
imag_check=0;
%4.user's personal contrast
if ~exist('contrast_choice','var')||isempty(contrast_choice)||...
        ~exist('myContrast','var')||isempty(myContrast)
    contrast_choice=questdlg('Do you know your visual contrast?', ...
        'Choose Red or Blue Pill', ...
        'Yes','No','Yes');
    switch contrast_choice
        case 'Yes'
            prompt={'Your visual contrast (%):'};
            dlg_title='Input';
            num_lines=1;
            def={'0.3'};
            answer=inputdlg(prompt,dlg_title,num_lines,def);
            myContrast=str2double(answer{1,1})/100;%convert percentage to demical
        case 'No'
            myContrast=fun_TestContrast(300,0.001,0.05,0.001);
    end
end
%5.other pre-required variables for functions to run properly
choice_S1='S1';
choice_S11='S11';
slice_num_S8=8;
slice_num_S9=9;
slice_num_S10=10;
slice_num_S11=11;
%6.define pass/fail handle
if ~exist('pf_hdl','var')||isempty(pf_hdl)
    pf_hdl=zeros(1,19);
end
%7.define result saving path
dummy=0;
for i=size(dir_name_loc,2)-1:-1:1
    if strcmp(dir_name_loc(1,i),'\')==1
        dummy=i;
        break;
    end
end
save_path=dir_name_loc(1,1:dummy);
%8.TEST 1-GEOMETRIC DISTORTION
%81.localiser
tic;
s=whos;
imhere=zeros(size(s,1),1);
for i=1:size(s,1)
    imhere(i,1)=strcmp(s(i,1).name,'TEST_1_loc');
end
if sum(imhere)>0
    disp('You have done the Test 1 on localiser.');
else
    disp('It''s the 1st time you run Test 1 on localiser.');
    [TEST_1_loc,pf_hdl(1,1)]=fun_ACR_1_loc...
        (dir_name_loc,file_name_loc,visual,imag_check,save_path);
end
close all;
t_loc=toc;
%82.S1
tic;
dummy=0;
s=whos;
imhere=zeros(size(s,1),1);
for i=1:size(s,1)
    imhere(i,1)=strcmp(s(i,1).name,'TEST_1_S1_hori');
end
if sum(imhere)>0
    disp('You have done the Test 1 on S1 T1 image.');
else
    disp('It''s the 1st time you run Test 1 on S1 T1 image.');
    [TEST_1_S1_hori,TEST_1_S1_vert,mu_S1,dummy(1,1:2)]=fun_ACR_1_S1...
        (dir_name_T1,file_name_S1_T1,visual,imag_check,'T1',save_path);
end
close all;
%83.S5
s=whos;
imhere=zeros(size(s,1),1);
for i=1:size(s,1)
    imhere(i,1)=strcmp(s(i,1).name,'TEST_1_S5_hori');
end
if sum(imhere)>0
    disp('You have done the Test 1 on S5 T1 image.');
else
    disp('It''s the 1st time you run Test 1 on S5 T1 image.');
    [TEST_1_S5_hori,TEST_1_S5_vert,TEST_1_S5_ng,TEST_1_S5_pg,dummy(1,3:6)]...
        =fun_ACR_1_S5(dir_name_T1,file_name_S5_T1,visual,imag_check,'T1',save_path);
    if sum(dummy)==6
        pf_hdl(1,2)=1;
    else
        pf_hdl(1,2)=0;
    end
end
close all;
%9.TEST 2-HIGH CONTRAST SPATIAL RESOLUTION
s=whos;
imhere=zeros(size(s,1),1);
for i=1:size(s,1)
    imhere(i,1)=strcmp(s(i,1).name,'TEST_2_S1');
end
if sum(imhere)>0
    disp('You have done the Test 2 on S1 T1 image.');
else
    disp('It''s the 1st time you run Test 2 on S1 T1 image.');
    test2_choice=questdlg('How do you want to do the HCSR test?', ...
        'Choose Red or Blue Pill', ...
        'Automatic','Manual','Automatic');
    switch test2_choice
        case 'Automatic'
            manual_test2=0;
        case 'Manual'
            manual_test2=1;
            h=msgbox(['You are doing high contrast spatial resolution test. ' ...
                '(Zoom in the High Contrast test region, adjust image window, ' ...
                'see if you can identify 4 point-objects, close image and enter ' ...
                'contrast index 1.1=left/1.0=middle/0.9=right)']);%v2
            uiwait(h);
    end
    [TEST_2_S1,pf_hdl(1,4:5)]=fun_ACR_2_S1...
        (dir_name_T1,file_name_S1_T1,visual,manual_test2,imag_check,myContrast);
end
%10.TEST 3-SLICE THICKNESS ACCURACY
s=whos;
imhere=zeros(size(s,1),1);
for i=1:size(s,1)
    imhere(i,1)=strcmp(s(i,1).name,'TEST_3_S1');
end
if sum(imhere)>0
    disp('You have done the Test 3 on S1 T1 image.');
else
    disp('It''s the 1st time you run Test 3 on S1 T1 image.');
    [TEST_3_S1,pf_hdl(1,8)]=fun_ACR_3_S1...
        (dir_name_T1,file_name_S1_T1,mu_S1,imag_check);
end
%11.TEST 4-SLICE POSITION ACCURACY
%111.S1
s=whos;
imhere=zeros(size(s,1),1);
for i=1:size(s,1)
    imhere(i,1)=strcmp(s(i,1).name,'TEST_4_S1');
end
if sum(imhere)>0
    disp('You have done the Test 4 on S1 T1 image.');
else
    disp('It''s the 1st time you run Test 4 on S1 T1 image.');
    [TEST_4_S1,pf_hdl(1,10)]=fun_ACR_4_S1S11...
        (choice_S1,dir_name_T1,file_name_S1_T1,visual,mu_S1,imag_check);
end
%112.S11
s=whos;
imhere=zeros(size(s,1),1);
for i=1:size(s,1)
    imhere(i,1)=strcmp(s(i,1).name,'TEST_4_S11');
end
if sum(imhere)>0
    disp('You have done the Test 4 on S11 T1 image.');
else
    disp('It''s the 1st time you run Test 4 on S11 T1 image.');
    mu_S11=fun_ACR_FindWaterIntPeak(dicomread([dir_name_T1 file_name_S11_T1]),...
        0.1,visual);
    [TEST_4_S11,pf_hdl(1,11)]=fun_ACR_4_S1S11...
        (choice_S11,dir_name_T1,file_name_S11_T1,visual,mu_S11,imag_check);
end
%12.TEST 5-IMAGE INTENSITY UNIFORMITY
s=whos;
imhere=zeros(size(s,1),1);
for i=1:size(s,1)
    imhere(i,1)=strcmp(s(i,1).name,'TEST_5_S7');
end
if sum(imhere)>0
    disp('You have done the Test 5 on S7 T1 image.');
else
    disp('It''s the 1st time you run Test 5 on S7 T1 image.');
    test5_choice=questdlg('How do you want to do the PIU test?', ...
        'Choose Red or Blue Pill', ...
        'Automatic','Manual','Automatic');
    switch test5_choice
        case 'Automatic'
            manual_test5=0;
        case 'Manual'
            manual_test5=1;
    end
    [TEST_5_S7,mu_S7,pf_hdl(1,14)]=fun_ACR_5_S7...
        (dir_name_T1,file_name_S7_T1,visual,imag_check,manual_test5);
end
%13.TEST 6-PERCENTAGE SIGNAL GHOSTING
s=whos;
imhere=zeros(size(s,1),1);
for i=1:size(s,1)
    imhere(i,1)=strcmp(s(i,1).name,'TEST_6_S7');
end
if sum(imhere)>0
    disp('You have done the Test 6 on S7 T1 image.');
else
    disp('It''s the 1st time you run Test 6 on S7 T1 image.');
    [TEST_6_S7,pf_hdl(1,16)]=fun_ACR_6_S7...
        (dir_name_T1,file_name_S7_T1,visual,mu_S7,imag_check,'T1',save_path);
end
close all;
%14.TEST 7-LOW CONTRAST OBJECT DETECTABILITY
% if ~exist('test7_choice','var')
%     test7_choice=questdlg('How do you want to do the LCOD test?', ...
%         'Choose Red or Blue Pill', ...
%         'Automatic','Manual','Manual');
%     switch test7_choice
%         case 'Automatic'
%             manual_test7=0;
%         case 'Manual'
%             manual_test7=1;
%     end
% else
%     disp(['You have chosen ' test7_choice ' for Test 7.']);
% end
manual_test7=1;
%141.S11
s=whos;
imhere=zeros(size(s,1),1);
for i=1:size(s,1)
    imhere(i,1)=strcmp(s(i,1).name,'TEST_7_S11');
end
if sum(imhere)>0
    disp('You have done the Test 7 on S11 T1 image.');
else
    disp('It''s the 1st time you run Test 7 on S11 T1 image.');
    [TEST_7_S11,I_spk_S11]=fun_ACR_7_S8S9S10S11...
        (dir_name_T1,file_name_S11_T1,slice_num_S11,visual,manual_test7,imag_check);
end
%142.S10
s=whos;
imhere=zeros(size(s,1),1);
for i=1:size(s,1)
    imhere(i,1)=strcmp(s(i,1).name,'TEST_7_S10');
end
if sum(imhere)>0
    disp('You have done the Test 7 on S10 T1 image.');
else
    disp('It''s the 1st time you run Test 7 on S10 T1 image.');
    [TEST_7_S10,I_spk_S10]=fun_ACR_7_S8S9S10S11...
        (dir_name_T1,file_name_S10_T1,slice_num_S10,visual,manual_test7,imag_check);
end
%143.S9
s=whos;
imhere=zeros(size(s,1),1);
for i=1:size(s,1)
    imhere(i,1)=strcmp(s(i,1).name,'TEST_7_S9');
end
if sum(imhere)>0
    disp('You have done the Test 7 on S9 T1 image.');
else
    disp('It''s the 1st time you run Test 7 on S9 T1 image.');
    [TEST_7_S9,I_spk_S9]=fun_ACR_7_S8S9S10S11...
        (dir_name_T1,file_name_S9_T1,slice_num_S9,visual,manual_test7,imag_check);
end
%144.S8
s=whos;
imhere=zeros(size(s,1),1);
for i=1:size(s,1)
    imhere(i,1)=strcmp(s(i,1).name,'TEST_7_S8');
end
if sum(imhere)>0
    disp('You have done the Test 7 on S8 T1 image.');
else
    disp('It''s the 1st time you run Test 7 on S8 T1 image.');
    [TEST_7_S8,I_spk_S8]=fun_ACR_7_S8S9S10S11...
        (dir_name_T1,file_name_S8_T1,slice_num_S8,visual,manual_test7,imag_check);
end
if sum([TEST_7_S11,TEST_7_S10,TEST_7_S9,TEST_7_S8])>=37
    pf_hdl(1,18)=1;
else
    pf_hdl(1,18)=0;
end
t_T1=toc;
%15.TEST 1-GEOMETRIC DISTORTION
%151.S1
tic;
dummy=0;
s=whos;
imhere=zeros(size(s,1),1);
for i=1:size(s,1)
    imhere(i,1)=strcmp(s(i,1).name,'TEST_1_S1_hori_T2');
end
if sum(imhere)>0
    disp('You have done the Test 1 on S1 T2 image.');
else
    disp('It''s the 1st time you run Test 1 on S1 T2 image.');
    [TEST_1_S1_hori_T2,TEST_1_S1_vert_T2,mu_S1_T2,dummy(1,1:2)]=...
        fun_ACR_1_S1(dir_name_T2,file_name_S1_T2,visual,imag_check,'T2',save_path);
end
close all;
%152.S5
s=whos;
imhere=zeros(size(s,1),1);
for i=1:size(s,1)
    imhere(i,1)=strcmp(s(i,1).name,'TEST_1_S5_hori_T2');
end
if sum(imhere)>0
    disp('You have done the Test 1 on S5 T2 image.');
else
    disp('It''s the 1st time you run Test 1 on S5 T2 image.');
    [TEST_1_S5_hori_T2,TEST_1_S5_vert_T2,TEST_1_S5_ng_T2,TEST_1_S5_pg_T2,dummy(3:6)]...
        =fun_ACR_1_S5(dir_name_T2,file_name_S5_T2,visual,imag_check,'T2',save_path);
    if sum(dummy)==6
        pf_hdl(1,3)=1;
    else
        pf_hdl(1,3)=0;
    end
end
close all;
%16.TEST 2-HIGH CONTRAST SPATIAL RESOLUTION
s=whos;
imhere=zeros(size(s,1),1);
for i=1:size(s,1)
    imhere(i,1)=strcmp(s(i,1).name,'TEST_2_S1_T2');
end
if sum(imhere)>0
    disp('You have done the Test 2 on S1 T2 image.');
else
    disp('It''s the 1st time you run Test 2 on S1 T2 image.');
    [TEST_2_S1_T2,pf_hdl(1,6:7)]=fun_ACR_2_S1...
        (dir_name_T2,file_name_S1_T2,visual,manual_test2,imag_check,myContrast);
end
%17.TEST 3-SLICE THICKNESS ACCURACY
s=whos;
imhere=zeros(size(s,1),1);
for i=1:size(s,1)
    imhere(i,1)=strcmp(s(i,1).name,'TEST_3_S1_T2');
end
if sum(imhere)>0
    disp('You have done the Test 3 on S1 T2 image.');
else
    disp('It''s the 1st time you run Test 3 on S1 T2 image.');
    [TEST_3_S1_T2,pf_hdl(1,9)]=fun_ACR_3_S1...
        (dir_name_T2,file_name_S1_T2,mu_S1_T2,imag_check);
end
%18.TEST 4-SLICE POSITION ACCURACY
%181.S1
s=whos;
imhere=zeros(size(s,1),1);
for i=1:size(s,1)
    imhere(i,1)=strcmp(s(i,1).name,'TEST_4_S1_T2');
end
if sum(imhere)>0
    disp('You have done the Test 4 on S1 T2 image.');
else
    disp('It''s the 1st time you run Test 4 on S1 T2 image.');
    [TEST_4_S1_T2,pf_hdl(1,12)]=fun_ACR_4_S1S11...
        (choice_S1,dir_name_T2,file_name_S1_T2,visual,mu_S1_T2,imag_check);
end
%182.S11
s=whos;
imhere=zeros(size(s,1),1);
for i=1:size(s,1)
    imhere(i,1)=strcmp(s(i,1).name,'TEST_4_S11_T2');
end
if sum(imhere)>0
    disp('You have done the Test 4 on S11 T2 image.');
else
    disp('It''s the 1st time you run Test 4 on S11 T2 image.');
    mu_S11_T2=fun_ACR_FindWaterIntPeak(dicomread([dir_name_T2 file_name_S11_T2]),...
        0.1,visual);
    [TEST_4_S11_T2,pf_hdl(1,13)]=fun_ACR_4_S1S11...
        (choice_S11,dir_name_T2,file_name_S11_T2,visual,mu_S11_T2,imag_check);
end
%19.TEST 5-IMAGE INTENSITY UNIFORMITY
s=whos;
imhere=zeros(size(s,1),1);
for i=1:size(s,1)
    imhere(i,1)=strcmp(s(i,1).name,'TEST_5_S7_T2');
end
if sum(imhere)>0
    disp('You have done the Test 5 on S7 T2 image.');
else
    disp('It''s the 1st time you run Test 5 on S7 T2 image.');
    [TEST_5_S7_T2,mu_S7_T2,pf_hdl(1,15)]=fun_ACR_5_S7...
        (dir_name_T2,file_name_S7_T2,visual,imag_check,manual_test5);
end
%20.TEST 6-PERCENTAGE SIGNAL GHOSTING
s=whos;
imhere=zeros(size(s,1),1);
for i=1:size(s,1)
    imhere(i,1)=strcmp(s(i,1).name,'TEST_6_S7_T2');
end
if sum(imhere)>0
    disp('You have done the Test 6 on S7 T2 image.');
else
    disp('It''s the 1st time you run Test 6 on S7 T2 image.');
    [TEST_6_S7_T2,pf_hdl(1,17)]=fun_ACR_6_S7...
        (dir_name_T2,file_name_S7_T2,visual,mu_S7_T2,imag_check,'T2',save_path);
end
close all;
%21.TEST 7-LOW CONTRAST OBJECT DETECTABILITY
%211.S11
s=whos;
imhere=zeros(size(s,1),1);
for i=1:size(s,1)
    imhere(i,1)=strcmp(s(i,1).name,'TEST_7_S11_T2');
end
if sum(imhere)>0
    disp('You have done the Test 7 on S11 T2 image.');
else
    disp('It''s the 1st time you run Test 7 on S11 T2 image.');
    [TEST_7_S11_T2,I_spk_S11_T2]=fun_ACR_7_S8S9S10S11...
        (dir_name_T2,file_name_S11_T2,slice_num_S11,visual,manual_test7,imag_check);
end
%212.S10
s=whos;
imhere=zeros(size(s,1),1);
for i=1:size(s,1)
    imhere(i,1)=strcmp(s(i,1).name,'TEST_7_S10_T2');
end
if sum(imhere)>0
    disp('You have done the Test 7 on S10 T2 image.');
else
    disp('It''s the 1st time you run Test 7 on S10 T2 image.');
    [TEST_7_S10_T2,I_spk_S10_T2]=fun_ACR_7_S8S9S10S11...
        (dir_name_T2,file_name_S10_T2,slice_num_S10,visual,manual_test7,imag_check);
end
%213.S9
s=whos;
imhere=zeros(size(s,1),1);
for i=1:size(s,1)
    imhere(i,1)=strcmp(s(i,1).name,'TEST_7_S9_T2');
end
if sum(imhere)>0
    disp('You have done the Test 7 on S9 T2 image.');
else
    disp('It''s the 1st time you run Test 7 on S9 T2 image.');
    [TEST_7_S9_T2,I_spk_S9_T2]=fun_ACR_7_S8S9S10S11...
        (dir_name_T2,file_name_S9_T2,slice_num_S9,visual,manual_test7,imag_check);
end
%214.S8
s=whos;
imhere=zeros(size(s,1),1);
for i=1:size(s,1)
    imhere(i,1)=strcmp(s(i,1).name,'TEST_7_S8_T2');
end
if sum(imhere)>0
    disp('You have done the Test 7 on S8 T2 image.');
else
    disp('It''s the 1st time you run Test 7 on S8 T2 image.');
    [TEST_7_S8_T2,I_spk_S8_T2]=fun_ACR_7_S8S9S10S11...
        (dir_name_T2,file_name_S8_T2,slice_num_S8,visual,manual_test7,imag_check);
end
if sum([TEST_7_S11_T2,TEST_7_S10_T2,TEST_7_S9_T2,TEST_7_S8_T2])>=37
    pf_hdl(1,19)=1;
else
    pf_hdl(1,19)=0;
end
t_T2=toc;
%22.write results into Excel file
tic;
disp('Finished test and writing result into Excel');
A={'Localiser','Distortion (T1 S1)','','Distortion (T1 S5)','','','',...%v2
    'Distortion (T2 S1)','','Distortion (T2 S5)','','','',...
    'High Contrast','','High Contrast','','Slice Thickness','',...
    'Slice Position','','','','PIU','','PSG','',...
    'LCOD T1','','','','LCOD T2','','','';...%1st row
    'Distortion','RL','AP','RL','AP','NG','PG','RL','AP','RL','AP','NG','PG',...
    'UL T1','RL T1','UL T2','RL T2','T1','T2',...
    'T1 S1','T1 S11','T2 S1','T2 S11','T1','T2','T1','T2',...
    'S11','S10','S9','S8','S11','S10','S9','S8';...%2nd row
    TEST_1_loc,TEST_1_S1_hori,TEST_1_S1_vert,TEST_1_S5_hori,...
    TEST_1_S5_vert,TEST_1_S5_ng,TEST_1_S5_pg,...
    TEST_1_S1_hori_T2,TEST_1_S1_vert_T2,TEST_1_S5_hori_T2,...
    TEST_1_S5_vert_T2,TEST_1_S5_ng_T2,TEST_1_S5_pg_T2,...
    TEST_2_S1(1,1),TEST_2_S1(2,1),TEST_2_S1_T2(1,1),TEST_2_S1_T2(2,1)...
    TEST_3_S1,TEST_3_S1_T2,TEST_4_S1,TEST_4_S11,TEST_4_S1_T2,TEST_4_S11_T2,...
    TEST_5_S7*100,TEST_5_S7_T2*100,TEST_6_S7,TEST_6_S7_T2,...
    TEST_7_S11,TEST_7_S10,TEST_7_S9,TEST_7_S8,...
    TEST_7_S11_T2,TEST_7_S10_T2,TEST_7_S9_T2,TEST_7_S8_T2};
% xlswrite('ACRQA_result.xlsx',A);
save_file_name=inputdlg('Name your Excel file here:','Save...',1);
save_file_name=[save_file_name{1} '.xlsx'];
% save_path=fun_ACR_CompStr(dir_name_loc,dir_name);
xlswrite([save_path save_file_name],A);%v2
t_log=toc;
disp('The report has been created under following path: ');
disp([save_path save_file_name]);
%23.create log.txt
fun_ACR_SaveLog(save_path,pf_hdl,TEST_1_loc,TEST_1_S1_hori,...
    TEST_1_S1_vert,TEST_1_S5_hori,TEST_1_S5_vert,TEST_1_S5_ng,...
    TEST_1_S5_pg,TEST_1_S1_hori_T2,TEST_1_S1_vert_T2,TEST_1_S5_hori_T2,...
    TEST_1_S5_vert_T2,TEST_1_S5_ng_T2,TEST_1_S5_pg_T2,TEST_2_S1,...
    TEST_2_S1_T2,TEST_3_S1,TEST_3_S1_T2,TEST_4_S1,TEST_4_S11,TEST_4_S1_T2,...
    TEST_4_S11_T2,TEST_5_S7,TEST_5_S7_T2,TEST_6_S7,TEST_6_S7_T2,TEST_7_S11,...
    TEST_7_S10,TEST_7_S9,TEST_7_S8,TEST_7_S11_T2,TEST_7_S10_T2,...
    TEST_7_S9_T2,TEST_7_S8_T2,t_loc,t_T1,t_T2,t_log);
disp('A Log file has been created under following path:');
disp([save_path 'log.txt']);