% Supersampler.m
% This script reads an input image, detects edges using the Canny edge detector,
% and generates a final mask with selected edge pixels using a neighborhood-based thresholding process.

% Step 1: Read the input image
im = imread('./data/im1.png');  % Input image path
[m, n, ~] = size(im);           % Get the dimensions of the image (height, width, and channels)

% Step 2: Edge Detection using Canny
% Convert the image to grayscale and apply the Canny edge detector
ed_im = uint8(edge(rgb2gray(im), 'canny'));

% Step 3: Initialize parameters for supersampling
d = 1;        % Neighborhood radius (defines the size of the neighborhood window)
thres = 0;    % Threshold value for selecting edge pixels based on neighborhood sum

% Step 4: Pad the edge map and initialize mask images
% Padding helps handle edge pixels without causing index errors
edd_im = padarray(ed_im, [d, d]);            % Pad the edge map with a border of size 'd'
msk_im = uint8(zeros(m, n));                 % Initialize an empty mask image (all zeros)
mask_im = padarray(msk_im, [d, d]);          % Pad the initialized mask image
final_mask = uint8(zeros(m, n));             % Initialize the final mask image

% Step 5: Iterate over the padded edge map to perform supersampling
for i = 1 + d : m + d
    for j = 1 + d : n + d
        % Check if the current pixel is an edge pixel
        if edd_im(i, j) == 1
            % Create a 3x3 neighborhood window (all ones)
            msk = uint8(ones(2 * d + 1, 2 * d + 1));
            
            % Calculate the sum of the neighborhood in the mask image
            % This checks if any of the neighboring pixels are already selected in the mask
            val = sum(sum(msk .* mask_im(i - d : i + d, j - d : j + d)));
            
            % If the sum is less than or equal to the threshold (no neighbors selected),
            % mark the current pixel in the final mask and update the mask image
            if val <= thres
                final_mask(i - d, j - d) = 1;  % Mark the pixel in the final mask
                mask_im(i - d : i + d, j - d : j + d) = ones(2 * d + 1, 2 * d + 1);  % Update the mask image
            end    
        end
    end
end

% Step 6: Display the final mask
% Multiply by 255 to convert the binary mask to a grayscale image (0 or 255)
imshow(final_mask * 255);
title('Final Mask');
