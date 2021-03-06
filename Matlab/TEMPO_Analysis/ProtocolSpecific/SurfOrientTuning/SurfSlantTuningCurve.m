%-----------------------------------------------------------------------------------------------------------------------
%-- SurfTuningCurve.m -- Plots a horizontal disparity gradient tuning curve.  These tuning curves will plot
%--   varying angles of gradient rotation vs. responses for different mean disparities on a single graph.  multiple
%--   graphs in a single column represent different gradient magnitudes for one aperture size.  Graphs in 
%--   different columns differ by aperture size.  All graphs include	monoc and uncorrelated control conditions.
%--	JDN 8/07/04
%-----------------------------------------------------------------------------------------------------------------------
function SurfSlantTuningCurve(data, Protocol, Analysis, SpikeChan, StartCode, StopCode, BegTrial, EndTrial, StartOffset, StopOffset, PATH, FILE);

TEMPO_Defs;

symbols = {'bo' 'ro' 'go' 'ko' 'b*' 'r*' 'g*' 'k*' 'c*'};
lines = {'b-' 'r-' 'g-' 'k-' 'b--' 'r--' 'g--' 'k--' 'c--'};
color_dots = {'b.' 'r.' 'g.' 'k.'};
color_lines = {'b*' 'r*' 'g*' 'k*'};

%get the x_ctr and y_ctr to calculate eccentricity
x_ctr = data.one_time_params(RF_XCTR);
y_ctr = data.one_time_params(RF_YCTR);

eccentricity = sqrt((x_ctr^2) + (y_ctr^2));

%--------------------------------------------------------------------------
%get all variables
%--------------------------------------------------------------------------
%get entire list of slants for this experiment
slant_list = data.dots_params(DOTS_SLANT,BegTrial:EndTrial,PATCH1);

%get indices of any NULL conditions (for measuring spontaneous activity)
null_trials = logical( (slant_list == data.one_time_params(NULL_VALUE)) );

unique_slant = munique(slant_list(~null_trials)');	
num_slant = length(unique_slant);

%get entire list of tilts for this experiment
tilt_list = data.dots_params(DOTS_TILT,BegTrial:EndTrial,PATCH1);
unique_tilt = munique(tilt_list(~null_trials)');
shift_negativetilt = logical(tilt_list < 0);
shift_positivetilt = logical(tilt_list > 360);

tilt_list(shift_negativetilt) = tilt_list(shift_negativetilt) + 360;
tilt_list(shift_positivetilt) = tilt_list(shift_positivetilt) - 360;
unique_tilt = munique(tilt_list(~null_trials)');

%get list of Stimulus Types
stim_list = data.dots_params(DOTS_STIM_TYPE, BegTrial:EndTrial, PATCH1);
unique_stim = munique(stim_list(~null_trials)');

%get motion coherency value
coh_dots = data.dots_params(DOTS_COHER, BegTrial:EndTrial,PATCH1);
unique_coh = munique(coh_dots(~null_trials)');

%get the column of mean depth values
mean_depth_list = data.dots_params(DEPTH_DIST_SIM,BegTrial:EndTrial,PATCH1);

%get indices of monoc. and uncorrelated controls
control_trials = logical( (mean_depth_list == LEYE_CONTROL) | (mean_depth_list == REYE_CONTROL) | (mean_depth_list == UNCORR_CONTROL) );

%display monoc control switch
no_display_monoc = 0;

%display monoc or not?
if no_display_monoc == 1
    unique_mean_depth = munique(mean_depth_list(~null_trials & ~control_trials)');
else
    unique_mean_depth = munique(mean_depth_list(~null_trials)');
end

num_mean_depth = length(unique_mean_depth);

%get the column of different aperture sizes
ap_size = data.dots_params(DOTS_AP_XSIZ,BegTrial:EndTrial,PATCH1);
unique_ap_size = munique(ap_size(~null_trials)');

%get the average horizontal eye positions to calculate vergence
Leyex_positions = data.eye_positions(1, :);
Reyex_positions = data.eye_positions(3, :);

vergence = Leyex_positions - Reyex_positions;

%now, remove trials from hor_disp and spike_rates that do not fall between BegTrial and EndTrial
trials = 1:length(slant_list);		% a vector of trial indices
select_trials = ( (trials >= BegTrial) & (trials <= EndTrial) );
stringarray = [];

%now, print out some useful information in the upper subplot
gen_data_fig = figure;
subplot(2, 1, 1);
PrintGeneralData(data, Protocol, Analysis, SpikeChan, StartCode, StopCode, BegTrial, EndTrial, StartOffset, StopOffset, PATH, FILE);

%prepare the main graphing window where the graphs will be drawn
graph = figure;
set(gcf,'PaperPosition', [.2 .2 8 10.7], 'Position', [500 50 500 773], 'Name', 'Tilt Tuning Curve');
ver_graph = figure;
set(gcf,'PaperPosition', [.2 .2 8 10.7], 'Position', [0 50 500 773], 'Name', 'Tilt vs. Horizontal Vergence');

data_string = '';
slant_string = '';
angle_out = '';
TDI_mdisp_out = '';
IndTDI_vs_ALLTDI = '';
%resp_data = []; verg_data=[];
p_val = zeros(length(unique_stim), length(unique_mean_depth));
pref_tilt = zeros(length(unique_stim), length(unique_mean_depth));

%for each stim type, plot out the tilt tuning curve and vergence data
%now, get the firing rates for all the trials 
spike_rates = data.spike_rates(SpikeChan, :);

%store one time data values (Ap Size, X ctr, Y ctr, ecc, pref dir)
line = sprintf('\t%3.1f\t%2.5f\t%2.5f\t%2.5f\t%3.2f', unique_ap_size(1), x_ctr, y_ctr, eccentricity, data.neuron_params(PREFERRED_DIRECTION, 1));
data_string = strcat(data_string, line);

PATHOUT = 'Z:\Users\jerry\SurfAnalysis\';

%print grad metrics
outfile = [PATHOUT 'Con_SLANT_TDI_12.15.04.dat'];
printflag = 0;
if (exist(outfile, 'file') == 0)    %file does not yet exist
    printflag = 1;
end
fCon = fopen(outfile, 'a');
if (printflag)
    fprintf(fCon, 'FILE\t StimType\t Slant\t NSigTDI\t SigTDI\t PVal\r\n');
end


outfile = [PATHOUT 'Vel_SLANT_TDI_12.15.04.dat'];
printflag = 0;
if (exist(outfile, 'file') == 0)    %file does not yet exist
    printflag = 1;
end
fVel = fopen(outfile, 'a');
if (printflag)
    fprintf(fVel, 'FILE\t StimType\t Slant\t NSigTDI\t SigTDI\t PVal\r\n');
end

outfile = [PATHOUT 'Disp_SLANT_TDI_12.15.04.dat'];
printflag = 0;
if (exist(outfile, 'file') == 0)    %file does not yet exist
    printflag = 1;
end
fDisp = fopen(outfile, 'a');
if (printflag)
    fprintf(fDisp, 'FILE\t StimType\t Slant\t NSigTDI\t SigTDI\t PVal\r\n');
end

outfile = [PATHOUT 'Txt_SLANT_TDI_12.15.04.dat'];
printflag = 0;
if (exist(outfile, 'file') == 0)    %file does not yet exist
    printflag = 1;
end
fTxt = fopen(outfile, 'a');
if (printflag)
    fprintf(fTxt, 'FILE\t StimType\t Slant\t NSigTDI\t SigTDI\t PVal\r\n');
end



for stim_count = 1:length(unique_stim)
    TDIdata = [];
    TDIvergdata = [];
    ancova_var = [];
    list_angles = [];
    total_slant = [];
    verg_ancova_var = [];
    verg_list_angles = [];
    verg_total_slant = [];
    m_disp_max = zeros(length(unique_slant), 1);
    m_disp_min = zeros(length(unique_slant), 1);
    start = zeros(length(unique_slant), 1);
    stop = zeros(length(unique_slant), 1);
    start_verg = zeros(length(unique_slant), 1);
    stop_verg = zeros(length(unique_slant), 1);
    for slant_count = 1:length(unique_slant)

        
%         %extract all tilts and responses for vector average calculation
%         depth_select = logical((stim_list == unique_stim(stim_count)) &(slant_list == unique_slant(slant_count)));
%         plot_x = tilt_list(depth_select & ~null_trials & select_trials);
%         plot_y = spike_rates(depth_select & ~null_trials & select_trials);
%         %calculate vector average
%         rad_x = plot_x * 3.14159/180;
%         [x_comp, y_comp] = pol2cart(rad_x, plot_y);
%         sum_x = sum(x_comp);
%         sum_y = sum(y_comp);
%         mag = sum(sqrt(x_comp.^2+y_comp.^2));
%         vect_xavg(stim_count) = sum_x/mag;
%         vect_yavg(stim_count) = sum_y/mag;
%         [th_avg(stim_count), r_avg(stim_count)] = cart2pol(vect_xavg(stim_count), vect_yavg(stim_count));
        
            spike = [];
            verg = [];
            figure(graph);
            hold on;
            subplot(length(unique_stim), num_mean_depth, stim_count);
                
            depth_select = logical((stim_list == unique_stim(stim_count)) &(slant_list == unique_slant(slant_count)));
            plot_x = tilt_list(depth_select & ~null_trials & select_trials);
            plot_y = spike_rates(depth_select & ~null_trials & select_trials);
            ver = vergence(depth_select & ~null_trials & select_trials);
            
            %NOTE: inputs to PlotTuningCurve must be column vectors, not row vectors, because of use of munique()
            [px, py, perr, spk_max, spk_min] = PlotTuningCurve(plot_x', plot_y', symbols{slant_count}, lines{slant_count}, 1, 1);
            
%             %calculate vector average
%             rad_x = plot_x * 3.14159/180;
%             [x_comp, y_comp] = pol2cart(rad_x, plot_y);
%             sum_x = sum(x_comp);
%             sum_y = sum(y_comp);
%             mag = sum(sqrt(x_comp.^2+y_comp.^2));
%             vector_xavg(stim_count,mdepth_count) = sum_x/mag;
%             vector_yavg(stim_count,mdepth_count) = sum_y/mag;
            
            p_val(stim_count,slant_count) = calc_anovap(plot_x, plot_y);
            [value, index_max] = max(py);
            pref_tilt(stim_count,slant_count) = spk_max.x;
            [single_TDI(stim_count,slant_count), var_term] = Compute_DDI(plot_x, plot_y);
            
            mdepth_count = length(unique_mean_depth);

            printSLANT = 1;
            if (printSLANT == 1)
                sig_color = 0;
                if (p_val(stim_count, slant_count) > 0.01)
                    sig_color = 2;
                    slant_string = sprintf('\t%1.0f\t%3.4f\t%1.4f\t%1.4f\t%1.0d\t', unique_stim(stim_count), unique_slant(slant_count), single_TDI(stim_count, slant_count), p_val(stim_count, slant_count), sig_color);
                else
                    sig_color = 1;
                    slant_string = sprintf('\t%1.0f\t%3.4f\t%1.4f\t%1.4f\t%1.0d\t', unique_stim(stim_count), unique_slant(slant_count), single_TDI(stim_count, slant_count), p_val(stim_count, slant_count), sig_color);
                end
                line = sprintf('%s\t', FILE);
                slant_string = strcat(line, slant_string);
                if (unique_stim(stim_count) == 0)
                    fprintf(fCon, '%s', [slant_string]);
                    fprintf(fCon, '\r\n');
                elseif (unique_stim(stim_count) == 1)
                    fprintf(fVel, '%s', [slant_string]);
                    fprintf(fVel, '\r\n');
                elseif (unique_stim(stim_count) == 2)
                    fprintf(fDisp, '%s', [slant_string]);
                    fprintf(fDisp, '\r\n');
                elseif (unique_stim(stim_count) == 3)
                    fprintf(fTxt, '%s', [slant_string]);
                    fprintf(fTxt, '\r\n');
                end
            end
            %save out each curve so that we can 
            %mean shift them to calculate an avg TDI value
            start(slant_count) = length(TDIdata)+1;
            stop(slant_count) = length(plot_x)+start(slant_count)-1;
            TDIdata(start(slant_count):stop(slant_count), 1) = plot_x';
            TDIdata(start(slant_count):stop(slant_count), 2) = plot_y';
            
            %------Spike ANOVAN code-----------------------------------------
            %save out each data point to use in ANOVAN function
            spike(:,1) = plot_x';
            spike(:,2) = plot_y';
            sortedspikes = sortrows(spike, [1]);
            ancova_var(length(ancova_var)+1:length(ancova_var)+length(sortedspikes),:) = sortedspikes;
            for temp_tilt = 1:length(unique_tilt)
                tilt_ind = find(sortedspikes(:,1) == unique_tilt(temp_tilt));
                sortedspikes(tilt_ind(1):tilt_ind(length(tilt_ind)), 1) = temp_tilt;
            end
            %to do anovan
            slant_array = zeros(length(sortedspikes), 1);
            slant_array = slant_array + slant_count;
            total_slant(length(total_slant)+1:length(total_slant)+length(sortedspikes),:) = slant_array;
            list_angles(length(list_angles)+1:length(list_angles)+length(sortedspikes),:) = sortedspikes;
            %--------------------------------------------------------------
            
            null_x = [min(px) max(px)];
            null_rate = mean(data.spike_rates(SpikeChan, null_trials & select_trials));
            null_y = [null_rate null_rate];
            hold on;
            plot(null_x, null_y, 'k--');
%            yl = YLim;
%            YLim([0 yl(2)])	% set the lower limit of the Y axis to zero
            hold off;
            hold on
            
            figure(ver_graph)
            hold on;
            subplot(length(unique_stim), num_mean_depth, stim_count);
            [ver_px, ver_py, ver_perr, ver_max, ver_min] = PlotTuningCurve(plot_x', ver', symbols{slant_count}, lines{slant_count}, 1, 1);
            p_val_ver(stim_count,slant_count) = calc_anovap(plot_x, ver);
            
            %save out each vergence curve so that we can 
            %mean shift them to calculate an avg TDI value  (same way as
            %neural data)
            start_verg(slant_count) = length(TDIvergdata)+1;
            stop_verg(slant_count) = length(plot_x)+start_verg(slant_count)-1;
            TDIvergdata(start_verg(slant_count):stop_verg(slant_count), 1) = plot_x';
            TDIvergdata(start_verg(slant_count):stop_verg(slant_count), 2) = ver';
            
            %------Verg ANOVAN code----------------------------------------
            %save out each data point to use in ANOVAN function
            verg(:,1) = plot_x';
            verg(:,2) = ver';
            sortedverg = sortrows(verg, [1]);
            verg_ancova_var(length(verg_ancova_var)+1:length(verg_ancova_var)+length(sortedverg),:) = sortedverg;
            for temp_tilt = 1:length(unique_tilt)
                tilt_ind = find(sortedverg(:,1) == unique_tilt(temp_tilt));
                sortedverg(tilt_ind(1):tilt_ind(length(tilt_ind)), 1) = temp_tilt;
            end
            %to do anovan
            verg_slant_array = zeros(length(sortedspikes), 1);
            verg_slant_array = slant_array + slant_count;
            verg_total_slant(length(verg_total_slant)+1:length(verg_total_slant)+length(sortedverg),:) = verg_slant_array;
            verg_list_angles(length(verg_list_angles)+1:length(verg_list_angles)+length(sortedverg),:) = sortedverg;
            %--------------------------------------------------------------
            
            printcurves = 0;
            if printcurves == 1
                %print out each individual tuning curve for origin
                pathsize = size(PATH,2) - 1;
                while PATH(pathsize) ~='\'	%Analysis directory is one branch below Raw Data Dir
                    pathsize = pathsize - 1;
                end   
                PATHOUT = 'Z:\Users\Jerry\SurfAnalysis\Surf_curves\';
                filesize = size(FILE,2) - 1;
                while FILE(filesize) ~='.'
                    filesize = filesize - 1;
                end
                FILEOUT = [FILE(1:filesize) 'slant_curve'];
                fileid = [PATHOUT FILEOUT];
                printflag = 0;
                if (exist(fileid, 'file') == 0)    %file does not yet exist
                    printflag = 1;
                end
                proffid = fopen(fileid, 'a');
                if (printflag)
                    fprintf(proffid,'HDisp\tAvgResp\tStdErr\tSpon\n');
                    printflag = 0;
                end
                    
                for go=1:length(px)
                    if (go<=2)
                        fprintf(proffid,'%6.2f\t%6.2f\t%6.3f\t%6.2f\t%6.2f\n', px(go), py(go), perr(go), null_x(go),null_y(go));
                    else
                        fprintf(proffid,'%6.2f\t%6.2f\t%6.3f\t\t\n', px(go), py(go), perr(go));
                    end
                end
                fclose(proffid);
            end %end printcurves;
        end %end mean depth loop
        
        %----ANOVAN--------------------------------------------------------
        list_angles = [total_slant list_angles];
        [p,T,STATS,TERMS] = anovan(list_angles(:, 3), {list_angles(:, 2) list_angles(:, 1)}, 'full', 3, {'Tilt Angles';'M. Depth'}, 'off');
        MS_error = T{4, 6};
        MS_treatment = T{2, 6};
        F_index = MS_treatment/ (MS_error + MS_treatment);
        
        verg_list_angles = [verg_total_slant verg_list_angles];
        [verg_p,verg_T,verg_STATS,verg_TERMS] = anovan(verg_list_angles(:, 3), {verg_list_angles(:, 2) verg_list_angles(:, 1)}, 'full', 3, {'Tilt Angles';'M. Depth'}, 'off');
        verg_MS_error = verg_T{4, 6};
        verg_MS_treatment = verg_T{2, 6};
        verg_F_index = verg_MS_treatment/ (verg_MS_error + verg_MS_treatment);
        %------------------------------------------------------------------

        %now that we have all the mean depth curves, mean shift the
        %responses
        %calc average TDI
        [avgTDI(stim_count), var_term] = compute_DDI(TDIdata(:,1)', TDIdata(:,2)');
        
        %readjust mean disparity responses to fall on the same mean
        %then calc avg TDI
        total_mean = mean(TDIdata(:,2));
        for count_slant = 1:length(unique_slant)
            slant_mean = mean(TDIdata(start(count_slant):stop(count_slant),2));
            difference = total_mean - slant_mean;
            TDIdata(start(count_slant):stop(count_slant),2) = TDIdata(start(count_slant):stop(count_slant),2) + difference;
        end

        [avgTDI_adj(stim_count), var_term] = compute_DDI(TDIdata(:,1)', TDIdata(:,2)');
        [px, py, perr, spk_max, spk_min] = PlotTuningCurve(TDIdata(:,1), TDIdata(:,2), symbols{count_slant+1}, lines{count_slant+1}, 1, 0);
        Rmax_adj = spk_max;
        Rmin_adj = spk_min;
        
        zero_data = min(TDIvergdata(:,2));
        TDIvergdata(:,2) = TDIvergdata(:,2) + abs(zero_data);
        [avgTDIverg(stim_count), var_term] = compute_DDI(TDIvergdata(:,1)', TDIvergdata(:,2)');
        
        %readjust mean disparity responses to fall on the same mean
        %then calc avg vergence TDI
        total_mean = mean(TDIvergdata(:,2));
        for count_slant = 1:length(unique_mean_depth)
            slant_mean = mean(TDIvergdata(start_verg(count_slant):stop_verg(count_slant),2));
            difference = total_mean - slant_mean;
            TDIvergdata(start_verg(count_slant):stop_verg(count_slant),2) = TDIvergdata(start_verg(count_slant):stop_verg(count_slant),2) + difference;
        end
        
        [avgTDIverg_adj(stim_count), var_term] = compute_DDI(TDIvergdata(:,1)', TDIvergdata(:,2)');
        [px_verg, py_verg, perr_verg, verg_max, verg_min] = PlotTuningCurve(TDIvergdata(:,1), TDIvergdata(:,2), symbols{count_slant+1}, lines{count_slant+1}, 1, 0);
        
        figure(graph);
        subplot(length(unique_stim), num_mean_depth, stim_count);
            
        yl = YLim;
        YLim([0 yl(2)]);	% set the lower limit of the Y axis to zero
        
        YLabel('Response (spikes/sec)');
        
        height = axis;
        yheight = height(4);
        if (unique_stim(stim_count) == 0)
            XLabel('Congruent Case - Tilt Angle (deg)');
        elseif (unique_stim(stim_count) == 1)
            XLabel('Speed Only Case - Tilt Angle (deg)');
        elseif (unique_stim(stim_count) == 2)
            XLabel('Disparity Only Case - Tilt Angle (deg)');
        elseif (unique_stim(stim_count) == 3)
            XLabel('Texture Only Case - Tilt Angle (deg)');
        end
            
        string = sprintf('TDI (mean adj) = %2.4f, Vergence TDI (mean adj) = %2.4f', avgTDI_adj(stim_count), avgTDIverg_adj(stim_count));
        text(height(1)+2, 0.95*yheight, string, 'FontSize', 8);
        string = sprintf('P-Values = %1.4f %1.4f %1.4f', p);
        text(height(1)+2, 0.85*yheight, string, 'FontSize', 8);
        
        figure(ver_graph);
        subplot(length(unique_stim), num_mean_depth, stim_count);
        
        YLabel('Response (spikes/sec)');
        
        height = axis;
        yheight = height(4);
        if (unique_stim(stim_count) == 0)
            XLabel('Congruent Case - Tilt Angle (deg)');
        elseif (unique_stim(stim_count) == 1)
            XLabel('Speed Only Case - Tilt Angle (deg)');
        elseif (unique_stim(stim_count) == 2)
            XLabel('Disparity Only Case - Tilt Angle (deg)');
        elseif (unique_stim(stim_count) == 3)
            XLabel('Texture Only Case - Tilt Angle (deg)');
        end
        
        string = sprintf('P-Values = %1.4f %1.4f %1.4f', verg_p);
        text(height(1)+2, 0.95*yheight, string, 'FontSize', 8);        
        
        %store data for postprocessing (stimulus type, TDI_neuron,
        %TDI_vergence, max tilt_neuron, max_tilt_ver, spike p-val, verg p-val, spont)
        line = sprintf('\t%3.2f\t%1.5f\t%1.5f\t%3.2f\t%1.5f\t%1.5f\t%1.5f\t%3.2f', unique_stim(stim_count), avgTDI_adj(stim_count), avgTDIverg_adj(stim_count), spk_max.x, verg_max.x, p(1), verg_p(1), null_y(1));
        data_string = strcat(data_string, line);
        
    end %end slant angle
end %end stim type
fclose(fCon);
fclose(fVel);
fclose(fDisp);
fclose(fTxt);

printme = 0;
if (printme==1)
    %pathsize = size(PATH,2) - 1;
    %while PATH(pathsize) ~='\'	%Analysis directory is one branch below Raw Data Dir
    %    pathsize = pathsize - 1;
    %end   
    PATHOUT = 'Z:\Users\jerry\SurfAnalysis\';
    
    line = sprintf('%s\t', FILE);
    data_string = strcat(line, data_string);
    
    %print grad metrics
    outfile = [PATHOUT 'Slant_metrics_12.01.04.dat'];
    printflag = 0;
    if (exist(outfile, 'file') == 0)    %file does not yet exist
        printflag = 1;
    end
    fid = fopen(outfile, 'a');
    if (printflag)
        %(Ap Size, X ctr, Y ctr, ecc, pref dir, stimulus type, TDI_neuron, TDI_vergence, max tilt_neuron, max_tilt_ver, spike p-val, verg p-val, spont)
        fprintf(fid, 'File\tApSize\tX\tY\tEcc\tPrefDir\tStimType\tTDI\tTDIverg\tPrefTiltNeuron\tPrefTiltVerg\tPSpike\tPVerg\tSpont\tStimType1\tTDI1\tTDIverg1\tPrefTiltNeuron1\tPrefTiltVerg1\tPSpike1\tPVerg1\tSpont1\tStimType2\tTDI2\tTDIverg2\tPrefTiltNeuron2\tPrefTiltVerg2\tPSpike2\tPVerg2\tSpont2\tStimType3\tTDI3\tTDIverg3\tPrefTiltNeuron3\tPrefTiltVerg3\tPSpike3\tPVerg3\tSpont3\n');
        printflag = 0;
    end
    fprintf(fid, '%s', [data_string]);
    fprintf(fid, '\r\n');
    fclose(fid);
end

return;