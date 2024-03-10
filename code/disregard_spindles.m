function [NoDisregard_idx, Disregard_idx] = disregard_spindles(spindles_PSD, min_fq, max_fq, vis)
% This function is looking for the spindles' peaks and adds the indeces of
% spindles that are good into the return array
n_trials = size(spindles_PSD, 2);
NoDisregard_idx = [];
Disregard_idx = [];
% NoDisregard_idx = nan(1, n_trials);

for trial=1:n_trials
    psd = spindles_PSD{1, trial};
    freq = spindles_PSD{2, trial};
    
    [pks,locs] = findpeaks(psd, SortStr="descend", MinPeakHeight=(max(psd)-min(psd)) / 2); % Sort the peaks


    % isBad == 1 when there is nothing bad about the spindle
    isBad = 1;
    for peak=1:length(pks)
        if freq(locs(peak)) < min_fq || freq(locs(peak)) > max_fq
            % isBad == 0 when there is a peak out of bounds of frequencies
            isBad = 0;
        end
    end
    
    if isBad == 0
        if vis == true
            figure(trial)
            plot(freq,psd,freq(locs),pks,"o")
            xlabel("Frequency [Hz]")
            ylabel("Amplitude [\muV]")
            title("Bad spindle PSD - peaks out of range [" + min_fq + ", " + max_fq + "]")
            axis tight
        end

        Disregard_idx = [Disregard_idx, trial];
    else
        if vis == true
            figure(trial)
            plot(freq,psd,freq(locs),pks,"o")
            xlabel("Frequency [Hz]")
            ylabel("Amplitude [\muV]")
            title("Good spindle PSD - no peaks out of range [" + min_fq + ", " + max_fq + "]")
            axis tight
        end
        
        NoDisregard_idx = [NoDisregard_idx, trial];
    end

    % Now this array contains 1 and 0, where 1 means we are leaving the
    % spindle in our dataset and 0 meaning we are disregarding the spindle
    % due to its inconsistency with the frequency requirements
%     NoDisregard_idx(trial) = isBad;

end

end