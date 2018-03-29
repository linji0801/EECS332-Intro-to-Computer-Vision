function [T_low, T_high] = FindThreshold(Mag, percentageOfNonEdge)
    
    % Convert the percentage into a decimal.
    p = (percentageOfNonEdge / 100);
    
    % Get the maximum value of the input matrix.
    mag_max = max(Mag(:));
    if (mag_max > 0)
        % Normalize the input matrix.
        mag_norm = (Mag / mag_max);
    else
        mag_norm = Mag;
    end
    
    % Create a histogram of the normalized matrix.
    mag_hist = imhist(mag_norm, 64);
    
    % Calculate the threshold values.
    T_high = (find((cumsum(mag_hist) > (p * size(Mag, 1) * ...
                    size(Mag, 2))), 1, 'first') / 64);
    T_low = (T_high * 0.5);
    
end