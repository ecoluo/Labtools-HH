function EyeCalibration2(data, Protocol, Analysis, SpikeChan, StartCode, StopCode, BegTrial, EndTrial, StartOffset, StopOffset, PATH, FILE);

TEMPO_Defs;
ProtocolDefs;	%needed for all protocol specific functions - contains keywords - BJP 1/4/01

figure;  % uncommented JWN 121206
subplot (2,1,1);
hold on;

%plot the positions of the LEFT eye in blue
lh = data.eye_positions(LEYE_H, :);
lv = data.eye_positions(LEYE_V, :);
plot(lh, lv, 'ro');

%plot the positions of the RIGHT eye in blue
rh = data.eye_positions(REYE_H, :);
rv = data.eye_positions(REYE_V, :);
plot(rh, rv, 'bo');

%plot the positions of the fixation point
fh = data.targ_params(TARG_XCTR, :, FP);
fv = data.targ_params(TARG_YCTR, :, FP);
plot(fh, fv, 'g+');

title(FILE);
hold off;
 
%%
subplot (2,1,2)
hold on;

LB=[-10.0; 0.01; -10.0; -0.5];
UB=[10.0; 100.0; 10.0; 0.5];
[L_horiz_pars, L_vert_pars] = EyeCalib2_Fitter(lh, lv, fh, fv, LB, UB, LB, UB);
[calib_lh, calib_lv] = ComputeCalibratedEyePosn2(lh, lv, L_horiz_pars, L_vert_pars);
% [L_horiz_pars, L_vert_pars] = EyeCalib2_Fitter(mean_lh, mean_lv, cond(:,1)', cond(:,2)', LB, UB, LB, UB);
% [calib_lh, calib_lv] = ComputeCalibratedEyePosn2(mean_lh, mean_lv, L_horiz_pars, L_vert_pars);
plot(calib_lh, calib_lv, 'ro');
hold on; plot(fh, fv, 'g+');

%%

[R_horiz_pars, R_vert_pars] = EyeCalib2_Fitter(rh, rv, fh, fv, LB, UB, LB, UB);
[calib_rh, calib_rv] = ComputeCalibratedEyePosn2(rh, rv, R_horiz_pars, R_vert_pars);  
plot(calib_rh, calib_rv, 'bo');

%plot the positions of the fixation point
fh = data.targ_params(TARG_XCTR, :, FP);
fv = data.targ_params(TARG_YCTR, :, FP);
plot(fh, fv, 'g+');

title ('Linear Fit with Interaction');
hold off;

keyboard;

%write calibration params out to a file
M = [L_horiz_pars' L_vert_pars' R_horiz_pars' R_vert_pars'];
i = size(PATH,2) - 1;
while PATH(i) ~='\'	%Analysis directory is one branch below Raw Data Dir
    i = i - 1;
end   
PATHOUT = [PATH(1:i) 'Analysis\Eye_Calibration\'];

run_loc = find(FILE == 'r');
file_root_name = FILE(1:run_loc-1);
outname = [PATHOUT file_root_name '_linear_eye_calib'];
% save(outname, 'M');
return;