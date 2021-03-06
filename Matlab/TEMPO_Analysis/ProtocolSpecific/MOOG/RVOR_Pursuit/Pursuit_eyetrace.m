function Rotation3D_eyetrace(data, Protocol, Analysis, SpikeChan, StartCode, StopCode, BegTrial, EndTrial, StartOffset, StopOffset, PATH, FILE); 

TEMPO_Defs;
Path_Defs;
ProtocolDefs; %contains protocol specific keywords - 1/4/01 BJP

%  % Old Basement Que's Data is required this uncommented lines %%%%%%%
LEFT_EYE_1_2=7;% accordin to order in Eye Channel dialoguein tempo_gui
RIGHT_EYE_3_4=8;

TargetHoriCh=5;%Target Ch.
TargetVertCh=6;

% %%  For Lothar, after 05/23/07 recordings %%%%%
% LEFT_EYE_1_2=9;% accordin to order in Eye Channel dialoguein tempo_gui
% RIGHT_EYE_3_4=10;
% 
% TargetHoriCh=7;%Target Ch.
% TargetVertCh=8;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Hori=1; Vert=2;%defalt is left = Ch. 1 and 2

%************************************************************************%
%plot Vertical vs. Horizontal
switch (data.eye_flag)
    case (LEFT_EYE_1_2),Eye_Select='Left Eye'
        Hori=1
            Vert=2
    case(RIGHT_EYE_3_4),Eye_Select='Right Eye'
        Hori=3       
        Vert=4
end

%%%%%%%%%%%%%%%%%%%%%%%%%%
%get the Sample Rate
filename = [PATH FILE];
fid = htbOpen(filename);
h = htbGetHd(fid, 1); %Make Sure: Database#1: Eye Traces
SR=(h.speed_units/h.speed)/(h.skip+1);%Sample Rate
SR
h.speed_units
h.speed
h.skip
clear filename fid h ;
%%%%%%%%%%%%%%%%%%%%%%%%%%

StartPoint=SR*1+1;EndPoint=SR*3;
NewX(:,:)=data.eye_data(Hori,StartPoint:EndPoint,:);
NewY(:,:)=data.eye_data(Vert,StartPoint:EndPoint,:);
figure(2);plot(NewX, NewY,'b');xlabel('Horizontal Position');ylabel('Vertical Position');title([FILE,'/',Eye_Select]);orient landscape;

%************************************************************************%
%position vs. time and velocity vs. time according to different direction
TimeLabel=(StartPoint:EndPoint)/SR*1000;%ms
temp_rot_elevation=data.moog_params(ROT_ELEVATION,:,MOOG);
temp_fp_rotate = data.moog_params(FP_ROTATE,:,MOOG);
temp_stim_type = data.moog_params(STIM_TYPE,:,MOOG);

for i=1:8
   clear Select_Trial; Select_Trial=find(temp_stim_type==1 & temp_fp_rotate==0 & temp_rot_elevation==(i-1)*45);%FP_ROTATE=1 means world-fixed
   %FP_rotate=0 means head-fixed now select 0
    clear Position_H1 Position_H2  Position_TH1 Position_TH2 Position_V1 Position_V2  Position_TV1 Position_TV2;
    Position_H1(:,:)=data.eye_data(Hori,StartPoint:EndPoint,Select_Trial);%Horizontal_Rotation
    Position_TH1(:,:)=data.eye_data(TargetHoriCh,StartPoint:EndPoint,Select_Trial);%Target_Horizontal_Rotation
    Position_V1(:,:)=data.eye_data(Vert,StartPoint:EndPoint,Select_Trial);%Vertical_Rotation   
    Position_TV1(:,:)=data.eye_data(TargetVertCh,StartPoint:EndPoint,Select_Trial);%Target_Vertical_Rotation
  
    clear Select_Trial;Select_Trial=find(temp_stim_type==1 & temp_fp_rotate==2 & temp_rot_elevation==(i-1)*45);%FP_ROTATE=2 means pursuit only
    Position_H2(:,:)=data.eye_data(Hori,StartPoint:EndPoint, Select_Trial);%Horizontal_Pursuit
    Position_TH2(:,:)=data.eye_data(TargetHoriCh,StartPoint:EndPoint,Select_Trial);%Target_Horizontal_Pursuit
    Position_V2(:,:)=data.eye_data(Vert,StartPoint:EndPoint,Select_Trial);%Vertical_Pursuit
    Position_TV2(:,:)=data.eye_data(TargetVertCh,StartPoint:EndPoint,Select_Trial);%Target_Vertical_Pursuit   

    figure(3);subplot(2,4,i);plot(TimeLabel,Position_H1(:,1), 'b', TimeLabel,Position_H2(:,1),'r',TimeLabel,Position_TH1(:,1),'k',TimeLabel,Position_TH2,'c'); 
    %legend('Rotation','Pursuit only','Target // Rotation','Target // Pursuit only',2); 
    hold on;plot(TimeLabel,Position_H1(:,2:end), 'b', TimeLabel,Position_H2(:,2:end),'r',TimeLabel,Position_TH1(:,2:end),'k',TimeLabel,Position_TH2(:,2:end),'c'); 
    xlabel('Time (ms)');ylabel('Horizontal Position');title([FILE,'/',Eye_Select,'/',num2str((i-1)*45)]);axis([1000 3000 -12 12]);
 orient landscape;
 
    figure(4);subplot(2,4,i);plot(TimeLabel,Position_V1(:,1), 'b', TimeLabel,Position_V2(:,1),'r',TimeLabel,Position_TV1(:,1),'k',TimeLabel,Position_TV2,'c'); 
    %legend('Rotation','Pursuit only','Target // Rotation','Target // Pursuit only',2); 
    hold on;plot(TimeLabel,Position_V1(:,2:end), 'b', TimeLabel,Position_V2(:,2:end),'r',TimeLabel,Position_TV1(:,2:end),'k',TimeLabel,Position_TV2(:,2:end),'c'); 
    xlabel('Time (ms)');ylabel('Vertical Position');title([FILE,'/',Eye_Select,'/',num2str((i-1)*45)]);axis([1000 3000 -12 12]);
    orient landscape;
    
    clear Velocity_H1 Velocity_H2  Velocity_TH1 Velocity_TH2 Velocity_V1 Velocity_V2 Velocity_TV1 Velocity_TV2 ;      
    for j=1:size(Position_H1,2)
        Velocity_H1(:,j)=fderiv(Position_H1(:,j),15,SR);%Horizontal_Rotation
        Velocity_H2(:,j)=fderiv(Position_H2(:,j),15,SR);%Horizontal_Pursuit
        Velocity_TH1(:,j)=fderiv(Position_TH1(:,j),15,SR);%Target_Horizontal_Rotation
        Velocity_TH2(:,j)=fderiv(Position_TH2(:,j),15,SR);%Target_Horizontal_Pursuit
        
        Velocity_V1(:,j)=fderiv(Position_V1(:,j),15,SR);%Vertical_Rotation
        Velocity_V2(:,j)=fderiv(Position_V2(:,j),15,SR);%Vertical_Pursuit
        Velocity_TV1(:,j)=fderiv(Position_TV1(:,j),15,SR);%Target_Vertical_Rotation
        Velocity_TV2(:,j)=fderiv(Position_TV2(:,j),15,SR);%Target_Vertical_Pursuit        
    end    
    figure(5);subplot(2,4,i);plot(TimeLabel,Velocity_H1(:,1), 'b', TimeLabel,Velocity_H2(:,1),'r',TimeLabel,Velocity_TH1(:,1),'k',TimeLabel, Velocity_TH2(:,1),'c');
    %legend('Rotation','Pursuit only','Target // Rotation','Target // Pursuit only',2); 
    hold on; plot(TimeLabel,Velocity_H1(:,2:end), 'b', TimeLabel,Velocity_H2(:,2:end),'r',TimeLabel,Velocity_TH1(:,2:end),'k',TimeLabel, Velocity_TH2(:,2:end),'c');
    xlabel('Time (ms)');ylabel(' Horizontal Velocity');title([FILE,'/',Eye_Select,'/',num2str((i-1)*45)]);axis([1000 3000 -30 30]);   
    orient landscape;
    
    figure(6);subplot(2,4,i);plot(TimeLabel,Velocity_V1(:,1), 'b', TimeLabel,Velocity_V2(:,1),'r',TimeLabel,Velocity_TV1(:,1),'k',TimeLabel, Velocity_TV2(:,1),'c');
    %legend('Rotation','Pursuit only','Target // Rotation','Target // Pursuit only',2); 
    hold on; plot(TimeLabel,Velocity_V1(:,2:end), 'b', TimeLabel,Velocity_V2(:,2:end),'r',TimeLabel,Velocity_TV1(:,2:end),'k',TimeLabel, Velocity_TV2(:,2:end),'c');
    xlabel('Time (ms)');ylabel(' Vertical Velocity');title([FILE,'/',Eye_Select,'/',num2str((i-1)*45)]);axis([1000 3000 -30 30]);  
    orient landscape;
end

return


% function Rotation3D_eyetrace(data, Protocol, Analysis, SpikeChan, StartCode, StopCode, BegTrial, EndTrial, StartOffset, StopOffset, PATH, FILE); 
% 
% TEMPO_Defs;
% Path_Defs;
% ProtocolDefs; %contains protocol specific keywords - 1/4/01 BJP
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
% % Target channel For Que 
% % LEFT_EYE_1_2=7;
% % RIGHT_EYE_3_4=8;
% % For Lothar
% % LEFT_EYE_1_2=9;
% % RIGHT_EYE_3_4=10;
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if size(data.eye_data,1)>6
%     LEFT_EYE_1_2=9;
%     RIGHT_EYE_3_4=10;
% else
%     LEFT_EYE_1_2=7;
%     RIGHT_EYE_3_4=8;
% end
% %plot Vertical vs. Horizontal
% switch (data.eye_flag)
%     case (LEFT_EYE_1_2)
%         Eye_Select='Left Eye'
%         Hor=1;        Ver=2;
%     case(RIGHT_EYE_3_4)
%         Eye_Select='Right Eye'
%         Hor=3;        Ver=4;
% end
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
% % Hor=1;        Ver=2;% For Xavier Every time using left eye No more need upper sentences
% %%%%%%%%%%%%%%%%%%%%%%%%%%
% %get the Sample Rate
% filename = [PATH FILE];
% fid = htbOpen(filename);
% h = htbGetHd(fid, 1); %Make Sure: Database#1: Eye Traces
% SR=(h.speed_units/h.speed)/(h.skip+1);%Sample Rate
% clear filename fid h ;
% %%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% StartPoint=SR*1+1;EndPoint=SR*3;
% 
% %position vs. time and velocity vs. time according to different direction
% TimeLabel=(StartPoint:EndPoint)/SR*1000;%ms
% temp_rot_elevation=data.moog_params(ROT_ELEVATION,:,MOOG);
% temp_fp_rotate = data.moog_params(FP_ROTATE,:,MOOG);
% temp_stim_type = data.moog_params(STIM_TYPE,:,MOOG);
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % plot eye signal for 8 directions
% NewX(:,:)=data.eye_data(Hor,StartPoint:EndPoint,:);
% NewY(:,:)=data.eye_data(Ver,StartPoint:EndPoint,:);
% figure(2);plot(NewX, NewY,'b');xlabel('Horizontal Position');ylabel('Vertical Position');title([FILE,'/',Eye_Select]);
% 
% 
% for i=1:8
%     clear Position_H1 Position_H2  Position_TH1 Position_TH2 Position_V1 Position_V2  Position_TV1 Position_TV2  %Position_H0  Position_V0;
%     
% %     clear Select_Trial; Select_Trial=find(temp_stim_type==2 & temp_fp_rotate==0 & temp_rot_elevation==(i-1)*45);%FP_rotate=0 means head-fixed now select 0
% %     Position_H0(:,:)=data.eye_data(Hor,StartPoint:EndPoint,Select_Trial);%Horizontal_Rotation
% %     Position_V0(:,:)=data.eye_data(Ver,StartPoint:EndPoint,Select_Trial);%Vertical_Rotation
% 
%     %  For Exavior temporaly
%     clear Select_Trial; Select_Trial=find(temp_stim_type==1 & temp_fp_rotate==1 & temp_rot_elevation==(i-1)*45);%FP_ROTATE=1 means world-fixed
%     Position_H1(:,:)=data.eye_data(Hor,StartPoint:EndPoint,Select_Trial);%Horizontal_Rotation
%     Position_V1(:,:)=data.eye_data(Ver,StartPoint:EndPoint,Select_Trial);%Vertical_Rotation   
%   
%     clear Select_Trial; Select_Trial=find(temp_stim_type==1 & temp_fp_rotate==2 & temp_rot_elevation==(i-1)*45);%FP_ROTATE=2 means pursuit only
%     Position_H2(:,:)=data.eye_data(Hor,StartPoint:EndPoint, Select_Trial);%Horizontal_Pursuit
%     Position_V2(:,:)=data.eye_data(Ver,StartPoint:EndPoint,Select_Trial);%Vertical_Pursuit
%  
%     Position_TH1(:,:)=data.eye_data(5,StartPoint:EndPoint,Select_Trial);%Target_Horizontal_Rotation
%     Position_TV1(:,:)=data.eye_data(6,StartPoint:EndPoint,Select_Trial);%Target_Vertical_Rotation
%     %%%%%%% Position data is units, which are from tempo side, it should be
%     %%%%%%% converted.
%         Position_TH1(:,:)=Position_TH1(:,:)/655.36;%+or-5V; 2^15=32768units; corresponds to whole display 100degrees/2 (because+-5V)
%         Position_TV1(:,:)=Position_TV1(:,:)/655.36;%so 1 degree=655.36 units
%         
% %     Position_TH2(:,:)=data.eye_data(7,StartPoint:EndPoint,Select_Trial);%Target_Horizontal_Pursuit  
% %     Position_TV2(:,:)=data.eye_data(8,StartPoint:EndPoint,Select_Trial);%Target_Vertical_Pursuit    
% 
% %     figure(3);set(3,'Position', [5,15 980,650], 'name',FILE);
% %     subplot(2,4,i);plot(TimeLabel,Position_H1(:,:), 'b', TimeLabel,Position_H2(:,:),'r',TimeLabel,Position_TH1(:,1),'k');
% %     hold on;
% %     title([Eye_Select,'/',num2str((i-1)*45)]);axis([1000 3000 -12 12]);set(gca, 'xtick', [] );
% % 
% %     figure(4);set(4,'Position', [5,15 980,650], 'name',FILE);
% %     subplot(2,4,i);plot(TimeLabel,Position_V1(:,:), 'b', TimeLabel,Position_V2(:,:),'r',TimeLabel,Position_TV1(:,1),'k');
% %     hold on;
% %     title([Eye_Select,'/',num2str((i-1)*45)]);axis([1000 3000 -12 12]);set(gca, 'xtick', [] );
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     figure(9);%set(9,'Position', [5,5 980,650], 'name',FILE);
%     subplot(2,8,i);plot(TimeLabel,Position_H1(:,:), 'b', TimeLabel,Position_H2(:,:),'r',TimeLabel,Position_TH1(:,1),'k');
% %     subplot(2,8,i);plot(TimeLabel, Position_H2(:,:),'r',TimeLabel,Position_TH1(:,1),'k');% for Xavior
%     
%     title(['Hor ',num2str((i-1)*45)]);
%     hold on;
%     axis([1000 3000 -12 12]);set(gca, 'xtick', [] );
%     subplot(2,8,i+8);plot(TimeLabel,Position_V1(:,:), 'b', TimeLabel,Position_V2(:,:),'r',TimeLabel,Position_TV1(:,1),'k');
% %     subplot(2,8,i+8);plot(TimeLabel,Position_V2(:,:),'r',TimeLabel,Position_TV1(:,1),'k');
%     title(['Ver ',num2str((i-1)*45)]);
%     hold on;
%     axis([1000 3000 -12 12]);set(gca, 'xtick', [] );
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     
%     clear Velocity_H1 Velocity_H2  Velocity_V1 Velocity_V2 Velocity_TH1 Velocity_TV1%Velocity_V0 Velocity_V0 ;      
%     for j=1:size(Position_H2,2)
% %         Velocity_H1(:,j)=fderiv(Position_H1(:,j),15,SR);%Horizontal_Rotation
%         Velocity_H2(:,j)=fderiv(Position_H2(:,j),15,SR);%Horizontal_Pursuit
%         Velocity_TH1(:,j)=fderiv(Position_TH1(:,j),15,SR);%Target_Horizontal_Rotation
% %         Velocity_TH2(:,j)=fderiv(Position_TH2(:,j),15,SR);%Target_Horizontal_Pursuit
%         
% %         Velocity_V1(:,j)=fderiv(Position_V1(:,j),15,SR);%Vertical_Rotation
%         Velocity_V2(:,j)=fderiv(Position_V2(:,j),15,SR);%Vertical_Pursuit
%         Velocity_TV1(:,j)=fderiv(Position_TV1(:,j),15,SR);%Target_Vertical_Rotation
% %         Velocity_TV2(:,j)=fderiv(Position_TV2(:,j),15,SR);%Target_Vertical_Pursuit        
%     end    
% %     figure(5);set(5,'Position', [5,15 980,650], 'name','Horisontal');
% %     subplot(2,4,i);plot(TimeLabel,Velocity_H1(:,:), 'b',TimeLabel,Velocity_TH1(:,1),'k');%,TimeLabel, Velocity_TH2(:,1),'c'
% %     hold on;
% %     title(['1/H/',num2str((i-1)*45)]);axis([1000 3000 -30 30]);set(gca, 'xtick', [] );
% %     
% %     figure(6);set(6,'Position', [5,15 980,650], 'name','Vertical');
% %     subplot(2,4,i);plot(TimeLabel,Velocity_V1(:,:), 'b',TimeLabel,Velocity_TV1(:,1),'k');%,TimeLabel, Velocity_TV2(:,1),'c'
% %     hold on;
% %     title(['1/V/',num2str((i-1)*45)]);axis([1000 3000 -30 30]);set(gca, 'xtick', [] );
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
%      figure(7);%set(7,'Position', [5,15 980,650], 'name','Horisontal');
%   
%     subplot(2,4,i);plot(TimeLabel,Velocity_H2(:,:),'r',TimeLabel,Velocity_TH1(:,1),'k');%,TimeLabel, Velocity_TH2(:,1),'c'
%     hold on;
%     title(['Hor ',num2str((i-1)*45)]);axis([1000 3000 -30 30]);set(gca, 'xtick', [] );
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5 
%     figure(8);%set(8,'Position', [5,15 980,650], 'name','Vertical');
%     subplot(2,4,i);plot(TimeLabel,Velocity_V2(:,:),'r',TimeLabel,Velocity_TV1(:,1),'k');%,TimeLabel, Velocity_TV2(:,1),'c'
%     hold on;
%     title(['Ver ',num2str((i-1)*45)]);axis([1000 3000 -30 30]);set(gca, 'xtick', [] );
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5   
% %     figure(8);set(8,'Position', [5,5 980,650], 'name',FILE);
% %     subplot(2,8,i);plot(TimeLabel,Velocity_H1(:,:), 'b', TimeLabel,Velocity_H2(:,:),'r',TimeLabel,Position_TH1(:,1),'k');%,TimeLabel, Velocity_TH2(:,1),'c'
% %     title([Eye_Select,'/',num2str((i-1)*45)]);
% %     hold on;
% %     axis([1000 3000 -30 30]);set(gca, 'xtick', [] );
% %     subplot(2,8,i+8);plot(TimeLabel,Velocity_V1(:,:), 'b', TimeLabel,Velocity_V2(:,:),'r',TimeLabel,Position_TV1(:,1),'k');%,TimeLabel, Velocity_TV2(:,1),'c'
% %     title([Eye_Select,'/',num2str((i-1)*45)]);
% %     hold on;
% %     axis([1000 3000 -30 30]);set(gca, 'xtick', [] ); 
%    
%    
% end
% % 
%  figure(9);set(9,'Position', [5,5 980,650], 'name',FILE);orient landscape;
%  axes('position',[0 0 1 1]); 
%     xlim([-50,50]);
%     ylim([-50,50]);
%     text(5,47, 'Eye Position');
%     text(-10,47,FILE);hold on; axis off;
%  figure(7);set(7,'Position', [5,15 980,650], 'name','Horisontal');orient landscape;
%   axes('position',[0 0 1 1]); 
%     xlim([-50,50]);
%     ylim([-50,50]);
%     text(5,47, 'Horisontal Velocity');
%     text(-10,47,FILE);hold on; axis off;
%  figure(8);set(8,'Position', [5,15 980,650], 'name','Vertical');orient landscape;
%   axes('position',[0 0 1 1]); 
%     xlim([-50,50]);
%     ylim([-50,50]);
%     text(5,47, 'Vertical Velocity');
%     text(-10,47,FILE);hold on; axis off;
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % % output to text file
% % % sprint_txt = ['%s'];
% % % for i = 1 : 48
% % %      sprint_txt = [sprint_txt, ' %1.2f'];    
% % % end
% % % %for j= 1:repeat
% % % 	buff= sprintf(sprint_txt, FILE, azimuth_verg_LR(j,:) );
% % %     %end
% % % 	outfile = [BASE_PATH 'ProtocolSpecific\MOOG\3Dtuning\Eye_azimuthLR_Nor.dat'];
% % % 	printflag = 0;
% % % 	if (exist(outfile, 'file') == 0)    %file does not yet exist
% % %         printflag = 1;
% % % 	end
% % % 	fid = fopen(outfile, 'a');
% % % 	if (printflag)
% % %         fprintf(fid, 'FILE\t');
% % %         fprintf(fid, '\r\n');
% % % 	end
% % % for j=1:repeat
% % % 	fprintf(fid, '%s', buff{j});
% % %     fprintf(fid, '\r\n');
% % % end
% % % 	fclose(fid);
% 
% return;
% 
