function img_out1 = TrainDetector()
%input all of the training images
images = dir(fullfile('/Users/linji0801/Documents/eecs 332/trainingimages/','*.png'));

% Variables for histogram normalisation
sum = 0;
hspairs = zeros(101, 101);

% For each test file
for file = 1:length(images)
    % Process each test file
    img_in_path = images(file).name;
    img_in = imread(img_in_path);
    img_in_hsv = rgb2hsv(img_in);
    [h, s, v] = rgb2hsv(img_in);

    % For each pixel in the HSV color format image
    for i = 1:size(img_in_hsv, 1)
        for j = 1:size(img_in_hsv, 2)
            % Figure out the histogram bin value of each pixel
            adjusted_h = (round(h(i, j) * 100) + 1);
            adjusted_s = (round(s(i, j) * 100) + 1);
            
            % Set the bin value correspondingly in the histogram matrix
            hspairs(adjusted_h, adjusted_s) = hspairs(adjusted_h, adjusted_s) + 1;
            
            % Special case for white pixels
            if (~(adjusted_h == 1 && adjusted_s == 1))
                sum = sum + 1;
            end
        end
    end
end

% normalize the values in the histogram
for i = 1:size(hspairs, 1)
    for j = 1:size(hspairs, 2)
        hspairs(i, j) = hspairs(i, j) / sum;
    end
end

% Output the histogram
img_out1 = hspairs;
end


