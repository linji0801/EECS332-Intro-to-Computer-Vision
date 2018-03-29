function [found_rho, found_theta, accumulator] = ...
    hough(img_in, rho_step, theta_step, threshold)

    % Convert the input image into a grayscale, binary format.
    mat = rgb2gray(imread(img_in));

    % Get the edge points for the image using a Canny edge detector.
    edge_mat = edge(mat, 'canny');

    % Setup the matrices for the values of rho and theta.
    rho = 1:rho_step:sqrt((size(edge_mat, 1) ^ 2) + (size(edge_mat, 2) ^ 2));
    theta = 0:theta_step:(180 - theta_step);

    % Initialize the accumulator array.
    accumulator = zeros(length(rho), length(theta));

    % Find the coordinates of the edge points of the image.
    [x, y] = find(edge_mat);

    % Iterate over each edge point, converting Cartesian to polar coordinates.
    for i = 1:numel(x)
        for j = 1:length(theta)
            test_theta = (theta(j) * (pi / 180));
            test_rho = ((x(i) * cos(test_theta)) + (y(i) * sin(test_theta)));

            % Voting procedure for valid values of rho.
            if ((test_rho >= 1) && (test_rho <= rho(end)))
                test_vote = abs(test_rho - rho);
                min_vote = min(test_vote);
                rho_vote = find(test_vote == min_vote);
                for k = 1:length(rho_vote)
                    accumulator(rho_vote(k), j) = ...
                    (accumulator(rho_vote(k), j) + 1);
                end
            end
        end
    end

    % Find [rho, theta] values for peaks in the accumulator matrix.
    peaks = imregionalmax(accumulator);
    [test_rho, test_theta] = find(peaks);

    % Apply the line length threshold to the accumulator matrix.
    test_accumulator = (accumulator - threshold);

    % Setup matrices for final [rho, theta] values
    % (and get rid of that stupid preallocation warning).
    found_rho = zeros(size(test_rho));
    found_theta = zeros(size(test_theta));
    index = 1;

    % Find final [rho, theta] values in the thresholded accumulator matrix.
    for i = 1:numel(test_rho)
        if (test_accumulator(test_rho(i),test_theta(i)) >= 0)
            found_rho(index) = test_rho(i);
            found_theta(index) = test_theta(i);
            index = index + 1;
        end
    end

    % Remove zero values.
    found_rho = found_rho(any(found_rho,2),:);
    found_theta = found_theta(any(found_theta,2),:);

    % Plot the Hough peaks and intersection points using a heat map.
    subplot(1,2,1);
    imshow(imadjust(mat2gray(accumulator)), 'XData', found_theta, 'YData', ...
                    found_rho, 'InitialMagnification', 'fit');
    title('Hough transform of image');
    xlabel('\theta'), ylabel('\rho');
    axis on, axis normal;
    colormap(hot);
    
    % Plot the resulting lines from the Hough transform.
    subplot(1,2,2);
    imagesc(edge_mat);
    hold on;
    for i = 1:size(found_rho)
        plot_theta = theta(found_theta(i));
        plot_rho = rho(round(found_rho(i)));
        
        % Convert polar coordinates to linear equations (y = m * x + b).
        m = -(cosd(plot_theta) / sind(plot_theta));
        b = (plot_rho / sind(plot_theta));
        x = 1:size(edge_mat);
        
        % Plot the resulting equations.
        plot(((m * x) + b), x);
        hold on;
    end
    hold off;
    
end