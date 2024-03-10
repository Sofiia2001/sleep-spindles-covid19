function [spindles] = identify_spindles(EEG, spindles_timing, n_channels, spindlesDur, SamplingRate)
% The function is responsible for identifying the spindles using the timing
% data of spindles occuring in a signal given in seconds

spindlesDur_samples = spindlesDur * SamplingRate; % the number of samples in 0.5s
n_spindles = size(spindles_timing, 1);

spindles = nan(spindlesDur_samples, n_channels, n_spindles);

% Going over all spindle time stamps included in the timing data
for t=1:n_spindles
    timestamp = spindles_timing(t);
    % Since we are given a timestamp of a spindle in seconds, to get the 
    % timestamp in samples, we should multiply seconds by the sampling rate
    spindle_start = ceil(timestamp * SamplingRate);
    spindle = EEG(spindle_start:spindle_start + spindlesDur_samples-1, :);
    
    spindles(:, :, t) = spindle;
end
end