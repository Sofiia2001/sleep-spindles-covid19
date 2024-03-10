function [result] = calculate_spectrum(avg_spindles, SamplingRate)
% This function is calculating a power spectrum of given signals and returns
% a cell with number of trials where each cell is power spectrum estimate
% (1st row) or the frequencies (2nd row) in a result
result = cell(2, size(avg_spindles, 3));

for trial=1:size(avg_spindles, 3)
    signal = avg_spindles(:, :, trial);
%     disp(length(signal));
    [pxx, f] = pwelch(signal, length(signal), 0, 0.6:0.1:20,SamplingRate);
    result{1, trial} = pxx;
    result{2, trial} = f;
end

end