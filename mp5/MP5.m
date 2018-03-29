function MP5(img_in, N, sigma, percentNonEdge)
    %Enable large recursion.
    set(0,'RecursionLimit',1000);
    
    % Gaussian smoothing.
    S = GaussSmoothing(img_in, N, sigma);
    
    % Image gradient.
    [Mag, Theta] = ImageGradient(S);
    
    % Threshold values.
    [T_low, T_high] = FindThreshold(Mag, percentNonEdge);
    
    % Nonmaxima suppression.
    Mag = NonmaximaSuppress(Mag, Theta, img_in);
    
    % Edge linking.
    Mag = EdgeLinking(T_low, T_high, Mag);

    % Display final result.
    figure, imshow(Mag);
    title('Image after canny edge detection');
end


function S = GaussSmoothing(I, N, Sigma)   
    % Setup an NxN matrix.
    x = -floor(N / 2):floor(N / 2);
    y = -floor(N / 2):floor(N / 2);
    [X, Y] = meshgrid(x, y);
    
    % Calculate the Gaussian distribution on the matrix.
    grid = exp(-((X .^ 2) + (Y .^ 2)) / (2 * (Sigma ^ 2)));
    
    % Weight the distribution with a corner value k.
    k = (1 / grid(N, N));
    kernel_nonnormal = (grid * k);
    
    % Normalize the distribution.
    kernel = (kernel_nonnormal / (sum(sum(kernel_nonnormal))));
    
    % Read in the input image into a double matrix.
    mat = im2double(rgb2gray(imread(I)));
    
    % Convolute the kernel with the original image.
    S = conv2(mat, kernel, 'same');
end

function [Mag, Theta,Gx,Gy] = ImageGradient(img_in)
    % Setup the output matrices.
    Mag = zeros(size(img_in));
    Theta = zeros(size(img_in));

    % Apply the Sobel operator over the entire image.
    for i = 1:(size(img_in, 1) - 2)
        for j = 1:(size(img_in, 2) - 2)
            % Partial derivatives for pixel (i, j).
            Gx = ((img_in((i + 2), j) + (2 * img_in((i + 2), (j + 1))) + ...
                   img_in((i + 2), (j + 2))) - (img_in(i, j) + ...
                   (2 * img_in(i, (j + 1))) + img_in(i, (j + 2))));
            Gy = ((img_in(i, (j + 2)) + (2 * img_in((i + 1), (j + 2))) + ...
                   img_in((i + 2), (j + 2))) - (img_in(i , j) + ...
                   (2 * img_in((i + 1), j)) + img_in((i + 2), j)));

            % Magnitude of the pixel (i, j).
            Mag(i, j) = sqrt((Gx .^ 2) + (Gy .^ 2));

            % Direction of the pixel (i, j).
            Theta(i, j) = atan(Gy / Gx);
        end
    end
    
end

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

function Mag_out = NonmaximaSuppress(Mag, Theta, im)
    % Perform non-maximum suppression using interpolation
    % Setup the output matrix.
    [m, n] = size(Mag);
    Mag_out = zeros(size(Mag));
    %X=[-1,0,+1 ;-1,0,+1 ;-1,0,+1];
	%Y=[-1,-1,-1 ;0,0,0 ;+1,+1,+1];
    %x = [0 1];
    Gx = SobelFilter(imread(im), 'x');
    Gy = SobelFilter(imread(im), 'y');
    Gx = imgaussfilt(Gx,1);
    Gy = imgaussfilt(Gy,1);
    
    % Apply nonmaxima suppression over the entire input image.
    for i = 2:(m-1)
        for j = 2:(n-1)
             if (Theta(i,j)>=0 && Theta(i,j)<=45) || ...
                    (Theta(i,j)<-135 && Theta(i,j)>=-180)
                yBot = [Mag(i,j+1) Mag(i+1,j+1)];
                yTop = [Mag(i,j-1) Mag(i-1,j-1)];
                x_est = abs(Gy(i,j)/Mag(i,j)); % y
                if (Mag(i,j) >= ((yBot(2)-yBot(1))*x_est+yBot(1)) && ...
                    Mag(i,j) >= ((yTop(2)-yTop(1))*x_est+yTop(1))) % interpolation
                    Mag_out(i,j)= Mag(i,j);
                else
                    Mag_out(i,j)=0;
                end
            elseif (Theta(i,j)>45 && Theta(i,j)<=90) || ...
                    (Theta(i,j)<-90 && Theta(i,j)>=-135)
                yBot = [Mag(i+1,j) Mag(i+1,j+1)];
                yTop = [Mag(i-1,j) Mag(i-1,j-1)];
                x_est = abs(Gx(i,j)/Mag(i,j));
                if (Mag(i,j) >= ((yBot(2)-yBot(1))*x_est+yBot(1)) && ...
                    Mag(i,j) >= ((yTop(2)-yTop(1))*x_est+yTop(1)))
                    Mag_out(i,j)= Mag(i,j);
                else
                    Mag_out(i,j)=0;
                end
            elseif (Theta(i,j)>90 && Theta(i,j)<=135) || ...
                    (Theta(i,j)<-45 && Theta(i,j)>=-90)
                yBot = [Mag(i+1,j) Mag(i+1,j-1)];
                yTop = [Mag(i-1,j) Mag(i-1,j+1)];
                x_est = abs(Gx(i,j)/Mag(i,j));
                if (Mag(i,j) >= ((yBot(2)-yBot(1))*x_est+yBot(1)) && ...
                    Mag(i,j) >= ((yTop(2)-yTop(1))*x_est+yTop(1)))
                    Mag_out(i,j)= Mag(i,j);
                else
                    Mag_out(i,j)=0;
                end
            elseif (Theta(i,j)>135 && Theta(i,j)<=180) || ...
                    (Theta(i,j)<0 && Theta(i,j)>=-45)
                yBot = [Mag(i,j-1) Mag(i+1,j-1)];
                yTop = [Mag(i,j+1) Mag(i-1,j+1)];
                x_est = abs(Gx(i,j)/Mag(i,j));
                if (Mag(i,j) >= ((yBot(2)-yBot(1))*x_est+yBot(1)) && ...
                    Mag(i,j) >= ((yTop(2)-yTop(1))*x_est+yTop(1)))
                    Mag_out(i,j)= Mag(i,j);
                else
                    Mag_out(i,j)=0;
                end
            end           
        end
    end
    
end

function E = EdgeLinking(T_low, T_high, Mag)

    % Setup the output matrix and the two threshold matrices.
    [m, n] = size(Mag);
    E = zeros(m, n);
    Mag2 = Mag;
    Mag(Mag < T_low) = 0;
    Mag2(Mag2 < T_high) = 0;
    
    % Operate on each element of the high threshold matrix.
    for i = 1:m
        for j = 1:n
            if (Mag2(i, j) ~= 0)
                % Recursive call to check 8-neighbors.
                CheckCandidates(i, j, T_low, T_high, Mag, Mag2, E);
            end
        end
    end
    
    % Set the output to the modified high threshold matrix.
    E = Mag2;
    
end

function candidate = CheckCandidates(i, j, T_low, T_high, Mag, Mag2, E)

    % Canary value for successful completion.
    candidate = 0;
    
    % Opeate on each 8-neighbor of the input pixel.
    for k = (i - 1):(i + 1)
        % Ignore pixels outside the image.
        if ((k < 1) || (k > size(Mag, 1)))
            continue;
        end
        
        for l = (j - 1):(j + 1)
            % Ignore pixels outside the image, the starting pixel,
            % and pixels that have already been checked.
            if (((l < 1) || (l > size(Mag, 2))) || ...
                ((i == k) && (l == j)) || (E(k, l) == 1))
                continue;
            end
            
            % Mark pixels above the high threshold, and cascade the match.
            if (Mag(k, l) > T_high)
                Mag2(k, l) = Mag(k, l);
                E(k, l) = 1;
                candidate = 1;
                return;

            % Recursively check pixels above the low threshold.
            elseif (Mag(k, l) > T_low)
                % Mark this pixel as visited.
                E(k, l) = 1;
                % Perform the recurisve call.
                candidate = CheckCandidates(k, l, T_low, T_high, Mag, Mag2, E);
                
                % Cascade the call stack if a match is found.
                if (candidate == 1)
                    Mag2(k, l) = Mag(k, l);
                    return;
                end
            end
        end
    end
    
end

function[A] = SobelFilter(A, filterDirection)
    switch filterDirection
        case 'x' 
            Gx = [-1 0 +1; -2 0 +2; -1 0 +1];
            A = imfilter(A, double(Gx), 'conv', 'replicate');
        case 'y'
            Gy = [-1 -2 -1; 0 0 0; +1 +2 +1];
            A = imfilter(A, double(Gy), 'conv', 'replicate');
        otherwise
            error('Bad filter direction - try inputs ''x'' or ''y''');
    end
end
