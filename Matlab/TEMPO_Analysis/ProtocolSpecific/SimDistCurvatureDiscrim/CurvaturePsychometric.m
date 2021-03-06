 %-----------------------------------------------------------------------------------------------------------------------
%-- CurvaturePsychometric.m -- Plot Psychometric functions for curvature discrimination task
%--	GCD, 6/16/04
%-----------------------------------------------------------------------------------------------------------------------

function CurvaturePsychometric(data, Protocol, Analysis, SpikeChan, StartCode, StopCode, BegTrial, EndTrial, StartOffset, StopOffset, PATH, FILE);

TEMPO_Defs;
Path_Defs;
ProtocolDefs; 

temp_dist_sim = data.dots_params(DEPTH_DIST_SIM,:,PATCH1);
temp_depth_setting = data.dots_params(DEPTH_SETTING,:,PATCH1);
temp_depth_sim_conflict = data.dots_params(DEPTH_SIM_CONFLICT,:,PATCH1);

trials = 1:length(temp_dist_sim);		% a vector of trial indices
select_trials = ( (trials >= BegTrial) & (trials <= EndTrial) );

dist_sim = temp_dist_sim( select_trials );
depth_setting = temp_depth_setting( select_trials );
depth_sim_conflict = temp_depth_sim_conflict( select_trials );

unique_dist_sim = munique(dist_sim');
unique_depth_setting = munique(depth_setting');
unique_depth_sim_conflict = munique(depth_sim_conflict');

correct_rate = [];
for i = 1:length(unique_dist_sim)
    for k = 1:length(unique_depth_setting)
         trials =logical( (dist_sim == unique_dist_sim(i)) & (depth_setting == unique_depth_setting(k)) ) ;
         correct_trials = (trials & (data.misc_params(OUTCOME, :) == CORRECT) );
         % make 'S' curve by using the rightward choice for y-axis
         if ( unique_dist_sim(i) < data.one_time_params(VIEW_DIST) )
             correct_rate(k,i) = 1 - 1*sum(correct_trials) / sum(trials); 
         else
             correct_rate(k,i) = 1*sum(correct_trials) / sum(trials); 
         end         
     end
end
     
% plot psychometric function here
h{1} = 'bo';  f{1} = 'b-';
h{2} = 'r+';  f{2} = 'r-';
h{3} = 'gs';  f{3} = 'g-';
h{4} = 'kd';  f{4} = 'k-';
figure(2);
set(2,'Position', [200,200 500,400], 'Name', 'Curvature Discrimination');
axes('position',[0.2,0.2, 0.6,0.6] );
% fit data with cumulative gaussian and plot both raw data and fitted curve
legend_txt = [];
for k = 1:length(unique_depth_setting)
    beta = [57, 1.0];                                                                          % initial estimate parameters(u and sigma)
    [betafit{k},resids{k},J{k}] = nlinfit(unique_dist_sim, correct_rate(k,:)', 'cum_gaussfit', beta);  % fit data with least square
    xi = min(unique_dist_sim) : 0.1 : max(unique_dist_sim);                                                   % define the range of dist_sim in figure 
    ypred_right = nlpredci('cum_gaussfit',betafit{k}(2),betafit{k},resids{k},J{k});              % calculate the correct performance from both 
    ypred_left = 1 - nlpredci('cum_gaussfit',-betafit{k}(2),betafit{k},resids{k},J{k});           % rightward and leftward performance
    ypred{k} = ( ypred_right + ypred_left ) / 2;
    plot(unique_dist_sim, correct_rate(k,:),h{k}, xi,cum_gaussfit(betafit{k}, xi), f{k} );
    xlabel('Simulated Distance (cm)');   
    xlim( [ min(unique_dist_sim), max(unique_dist_sim) ] );
    ylim([0,1]);
    ylabel('Far Choices')
%    title('Psychometric Function');
    grid on; 
    hold on;
    legend_txt{k*2-1} = [num2str(unique_depth_setting(k))];
    legend_txt{k*2} = [''];
end
legend(legend_txt{:},2);

% output some text of basic parameters in the figure
axes('position',[0.2,0.8, 0.6,0.15] );
xlim( [0,50] );
ylim( [2,10] );
text(0, 10, FILE);
text(25,10,'depth conflict =');
text(45,10,num2str(unique_depth_sim_conflict) );
text(10,8, 'u                   sigma             thresh performance(%)');
%text(0,8, con_txt);

for k = 1:length(unique_depth_setting)
    text(0,8-2*k, num2str(unique_depth_setting(k)));
    text(10,8-2*k,num2str(betafit{k}(1)) );
    text(20,8-2*k,num2str(betafit{k}(2)) );
    text(30,8-2*k,num2str(100*ypred{k}));
end

axis off;

%get the average eye positions to calculate vergence
Leyex_positions = data.eye_positions(1, :);
Leyey_positions = data.eye_positions(2, :);
Reyex_positions = data.eye_positions(3, :);
Reyey_positions = data.eye_positions(4, :);

vergence_h = Leyex_positions - Reyex_positions;
vergence_v = Leyey_positions - Reyey_positions;

if (data.eye_calib_done == 1)
    Leyex_positions = data.eye_positions_calibrated(1, :);
    Leyey_positions = data.eye_positions_calibrated(2, :);
    Reyex_positions = data.eye_positions_calibrated(3, :);
    Reyey_positions = data.eye_positions_calibrated(4, :);
    
    vergence_h = Leyex_positions - Reyex_positions;
    vergence_v = Leyey_positions - Reyey_positions;
end

[H, ATAB, CTAB, STATS] = aoctool(dist_sim, vergence_h, depth_setting);

P_depth_setting = ATAB{2,6}
P_dist_sim = ATAB{3,6}
P_interact = ATAB{4,6}
std_verg = std(vergence_h)
mean_verg = mean(vergence_h)
verg_ctr_disp_slope = CTAB{5,2}
num_pts = length(vergence_h)

%close(4); close(5);

% Also, write out some summary data to a cumulative summary file
 if (length(unique_depth_setting)==2)
    bias = [betafit{1}(1),betafit{2}(1)];
    threshold = [betafit{1}(2),betafit{2}(2)];
    buff = sprintf('%s\t  %4.2f\t\t       %4.4f\t      %4.4f\t      %4.4f\t     %4.4f\t', ...
      FILE, unique_depth_sim_conflict,  bias, threshold );
    outfile = [BASE_PATH 'ProtocolSpecific\SimDistCurvatureDiscrim\CurvaturePsychometric.dat'];
    printflag = 0;
    if (exist(outfile, 'file') == 0)    %file does not yet exist
        printflag = 1;
    end
    fid = fopen(outfile, 'a');
    if (printflag)
        fprintf(fid, 'FILE\t          depth_conflict\t  NoCon_bias\t Con_bias\t NoCon_thresh\t Con_thresh\t');
        fprintf(fid, '\r\n');
    end
    fprintf(fid, '%s', buff);
    fprintf(fid, '\r\n');
    fclose(fid);
end
%---------------------------------------------------------------------------------------
return;