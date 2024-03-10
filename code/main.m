%% MAIN CODE

clear all, close all, clc

%% STEP 1: Load the data 

ICUdata = load('HM_1_2022_23/ICU023_nap.mat');
CTRLdata = load("HM_1_2022_23/CTRL033_nap.mat");
EEG_204_chanlocs = readlocs('HM_1_2022_23/GSN_204.sfp');

SamplingRate = 250;
n_channels = 204;

%% STEP 2: Filtering [9-12] Hz (slow track)
fc=9; % High-pass filtering @ 9 Hz
[b, a] = butter(4, fc/(SamplingRate/2), 'high');
ICU_EEG_slow = filtfilt(b, a, ICUdata.EEG);
CTRL_EEG_slow = filtfilt(b, a, CTRLdata.EEG);
% fvtool(b, a);

fc=12; % Low-pass filtering @ 12 Hz
[b, a] = butter(4, fc/(SamplingRate/2), 'low');
ICU_EEG_slow = filtfilt(b, a, ICU_EEG_slow);
CTRL_EEG_slow = filtfilt(b, a, CTRL_EEG_slow);
% fvtool(b, a);

%% STEP 2: Filtering [12-16] Hz (fast track)
fc=12; % High-pass filtering @ 12 Hz
[b, a] = butter(4, fc/(SamplingRate/2), 'high');
ICU_EEG_fast = filtfilt(b, a, ICUdata.EEG);
CTRL_EEG_fast = filtfilt(b, a, CTRLdata.EEG);
% fvtool(b, a);

fc=16; % Low-pass filtering @ 16 Hz
[b, a] = butter(4, fc/(SamplingRate/2), 'low');
ICU_EEG_fast = filtfilt(b, a, ICU_EEG_fast);
CTRL_EEG_fast = filtfilt(b, a, CTRL_EEG_fast);
% fvtool(b, a);

%% STEP 3: Identify the spindles
spindlesDur=0.5; %s (or 500 ms)
ICU_spindles_timing = load("HM_1_2022_23/spindles_timing_023.mat");
CTRL_spindles_timing = load("HM_1_2022_23/spindles_timing_033.mat");

ICU_spindles_fast = identify_spindles(ICU_EEG_fast, ICU_spindles_timing.fast, n_channels, spindlesDur, SamplingRate);
ICU_spindles_slow = identify_spindles(ICU_EEG_slow, ICU_spindles_timing.slow, n_channels, spindlesDur, SamplingRate);
CTRL_spindles_fast = identify_spindles(CTRL_EEG_fast, CTRL_spindles_timing.fast, n_channels, spindlesDur, SamplingRate);
CTRL_spindles_slow = identify_spindles(CTRL_EEG_slow, CTRL_spindles_timing.slow, n_channels, spindlesDur, SamplingRate);

%% STEP 4: Average spindles for all EEG channels

% The size of the following is (n_samples, 1, n_trials)
ICU_spindles_avg_fast = mean(ICU_spindles_fast, 2);
ICU_spindles_avg_slow = mean(ICU_spindles_slow, 2);
CTRL_spindles_avg_fast = mean(CTRL_spindles_fast, 2);
CTRL_spindles_avg_slow = mean(CTRL_spindles_slow, 2);

%% STEP 5: Compute the spectrum of each signal

% The following structure is a cell (2 x n_trials), where {1, trial} 
% is a trial's PSD estimate and {2, trial} is trial's PSD frequencies
ICU_pwelch_fast = calculate_spectrum(ICU_spindles_avg_fast, SamplingRate);
ICU_pwelch_slow = calculate_spectrum(ICU_spindles_avg_slow, SamplingRate);
CTRL_pwelch_fast = calculate_spectrum(CTRL_spindles_avg_fast, SamplingRate);
CTRL_pwelch_slow = calculate_spectrum(CTRL_spindles_avg_slow, SamplingRate);

%% Plot the spectrum of each spindle & disregard the "bad" spindles

% Identifying the bad spindles 
[ICU_bad_trials_fast_good, ICU_bad_trials_fast_bad] = disregard_spindles(ICU_pwelch_fast, 12, 16, false);
[ICU_bad_trials_slow_good, ICU_bad_trials_slow_bad] = disregard_spindles(ICU_pwelch_slow, 9, 12, false);
[CTRL_bad_trials_fast_good, CTRL_bad_trials_fast_bad] = disregard_spindles(CTRL_pwelch_fast, 12, 16, false);
[CTRL_bad_trials_slow_good, CTRL_bad_trials_slow_bad] = disregard_spindles(CTRL_pwelch_slow, 9, 12, false);

%%
% [CTRL_bad_trials_fast_good, CTRL_bad_trials_fast_bad] = disregard_spindles(CTRL_pwelch_fast, 12, 16, true);


%% Average good spindles

ICU_spindles_avg_fast_final = mean(ICU_spindles_fast(:,:, ICU_bad_trials_fast_good), 3);
ICU_spindles_avg_slow_final = mean(ICU_spindles_slow(:,:, ICU_bad_trials_slow_good), 3);
CTRL_spindles_avg_fast_final = mean(CTRL_spindles_fast(:,:, CTRL_bad_trials_fast_good), 3);
CTRL_spindles_avg_slow_final = mean(CTRL_spindles_slow(:,:, CTRL_bad_trials_slow_good), 3);

%%
% time = 0:1:124; % Assuming 125 time points (0 to 124)
% figure;
% axes('NextPlot', 'add');
% 
% for i = 1:204
%     plot(time, CTRL_spindles_avg_fast_final(:, i));
% end
% 
% averageSignal = mean(CTRL_spindles_avg_fast_final, 2); % Calculate the average signal along the second dimension
% plot(time, averageSignal, 'LineWidth', 2, 'Color', 'r');
% 
% xlabel('Time');
% ylabel('Amplitude');
% legend('Channel Signals', 'Average');


%% Save the data into .mat files

save('ICU_spindles_avg_fast_final.mat', 'ICU_spindles_avg_fast_final');
save('ICU_spindles_avg_slow_final.mat', 'ICU_spindles_avg_slow_final');
save('CTRL_spindles_avg_fast_final.mat', 'CTRL_spindles_avg_fast_final');
save('CTRL_spindles_avg_slow_final.mat', 'CTRL_spindles_avg_slow_final');

%% Average the spindles over time and plot the topoplot

% ICU_spindles_avg_fast_tp = mean(abs(ICU_spindles_avg_fast_final), 1);
% ICU_spindles_avg_slow_tp = mean(abs(ICU_spindles_avg_slow_final), 1);
% CTRL_spindles_avg_fast_tp = mean(abs(CTRL_spindles_avg_fast_final), 1);
% CTRL_spindles_avg_slow_tp = mean(abs(CTRL_spindles_avg_slow_final), 1);

ICU_spindles_avg_fast_tp = mean(ICU_spindles_avg_fast_final, 1);
ICU_spindles_avg_slow_tp = mean(ICU_spindles_avg_slow_final, 1);
CTRL_spindles_avg_fast_tp = mean(CTRL_spindles_avg_fast_final, 1);
CTRL_spindles_avg_slow_tp = mean(CTRL_spindles_avg_slow_final, 1);

%% Read channel logs and plot topoplots

% ICU fast
figure(1)
topoplot(ICU_spindles_avg_fast_tp, EEG_204_chanlocs, 'style', 'both', 'electrodes', 'on');
title("ICU spindles average -- fast track [12-16 Hz]")
colormap('jet')
colorbar ; 
caxis([min([ICU_spindles_avg_fast_tp, ICU_spindles_avg_slow_tp, CTRL_spindles_avg_fast_tp, CTRL_spindles_avg_slow_tp]) ...
    max([ICU_spindles_avg_fast_tp, ICU_spindles_avg_slow_tp, CTRL_spindles_avg_fast_tp, CTRL_spindles_avg_slow_tp])])

% ICU slow
figure(2)
topoplot(ICU_spindles_avg_slow_tp, EEG_204_chanlocs, 'style', 'both', 'electrodes', 'on');
title("ICU spindles average -- slow track [9-12 Hz]")
colormap('jet')
colorbar ; 
caxis([min([ICU_spindles_avg_fast_tp, ICU_spindles_avg_slow_tp, CTRL_spindles_avg_fast_tp, CTRL_spindles_avg_slow_tp]) ...
    max([ICU_spindles_avg_fast_tp, ICU_spindles_avg_slow_tp, CTRL_spindles_avg_fast_tp, CTRL_spindles_avg_slow_tp])])

% CTRL fast
figure(3)
topoplot(CTRL_spindles_avg_fast_tp, EEG_204_chanlocs, 'style', 'both', 'electrodes', 'on');
title("CTRL spindles average -- fast track [12-16 Hz]")
colormap('jet')
colorbar ; 
caxis([min([ICU_spindles_avg_fast_tp, ICU_spindles_avg_slow_tp, CTRL_spindles_avg_fast_tp, CTRL_spindles_avg_slow_tp]) ...
    max([ICU_spindles_avg_fast_tp, ICU_spindles_avg_slow_tp, CTRL_spindles_avg_fast_tp, CTRL_spindles_avg_slow_tp])])

% CTRL slow
figure(4)
topoplot(CTRL_spindles_avg_slow_tp, EEG_204_chanlocs, 'style', 'both', 'electrodes', 'on');
title("CTRL spindles average -- slow track [9-12 Hz]")
colormap('jet')
colorbar ; 
caxis([min([ICU_spindles_avg_fast_tp, ICU_spindles_avg_slow_tp, CTRL_spindles_avg_fast_tp, CTRL_spindles_avg_slow_tp]) ...
    max([ICU_spindles_avg_fast_tp, ICU_spindles_avg_slow_tp, CTRL_spindles_avg_fast_tp, CTRL_spindles_avg_slow_tp])])










