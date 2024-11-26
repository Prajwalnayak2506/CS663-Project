%% Subsampler

% Step 1: Read the input image
im = imread('./data/im3.png');  % Read the input image
[m, n, ~] = size(im);               % Get the dimensions of the image (height, width, channels)

% Step 2: Edge Detection using Canny
ed_im = uint8(edge(rgb2gray(im), 'canny'));  % Convert to grayscale and detect edges using Canny

% Initialize parameters
d = 1;        % Neighborhood radius for mask creation
thres = 0;    % Threshold for neighborhood selection

% Step 3: Pad the edge map and initialize mask images
edd_im = padarray(ed_im, [d, d]);            % Pad the edge map to handle boundary pixels
msk_im = uint8(zeros(m, n));                 % Initialize a mask image (all zeros)
mask_im = padarray(msk_im, [d, d]);          % Pad the mask image
final_mask = uint8(zeros(m, n));             % Initialize the final mask

% Step 4: Iterate through the padded edge map to generate the final mask
for i = 1 + d : m + d
    for j = 1 + d : n + d
        % Check if the current pixel is an edge pixel
        if edd_im(i, j) == 1
            % Create a 3x3 neighborhood window (all ones)
            msk = uint8(ones(2 * d + 1, 2 * d + 1));
            
            % Calculate the sum of the neighborhood in the padded mask image
            val = sum(sum(msk .* mask_im(i - d : i + d, j - d : j + d)));
            
            % If no neighbors are selected (val <= thres), update the final mask
            if val <= thres
                final_mask(i - d, j - d) = 1;  % Mark the pixel in the final mask
                mask_im(i - d : i + d, j - d : j + d) = ones(2 * d + 1, 2 * d + 1);  % Update the mask image
            end
        end
    end
end

% Display the final mask
figure;
imshow(final_mask * 255);
title('Final Mask');

% Step 5: Exclude neighborhood of edge pixels in the mask
window = 3;                          % Size of the exclusion window
pd = (window - 1) / 2;               % Pad distance for the exclusion window
pmsk = padarray(uint8(ones(m, n)), [pd, pd]);  % Pad the initial mask

% Iterate through the padded final mask to exclude neighborhood pixels
for i = pd + 1 : pd + m
    for j = pd + 1 : pd + n
        if final_mask(i - pd, j - pd)  % If the pixel is marked in the final mask
            % Set the neighborhood around the pixel to 0 in the padded mask
            pmsk(i - pd : i + pd, j - pd : j + pd, :) = 0;
        end
    end
end

% Extract the mask back to the original size and exclude boundary pixels
pmsk = pmsk(pd + 1 : pd + m, pd + 1 : pd + n, :);
pmsk(1, :, :) = 0;
pmsk(m, :, :) = 0;
pmsk(:, 1, :) = 0;
pmsk(:, n, :) = 0;

% Display the refined mask
figure;
imshow(pmsk * 255);
title('Refined Mask');

% Save the refined mask as a binary image
imwrite(logical(pmsk), './data/mask.pbm');

% Step 6: Create the masked image by applying the inverted mask
res_im = (1 - pmsk) .* im;
figure;
imshow(res_im);
title('Masked Image');

%% Super-sampler

% Step 7: Pad the final mask and the masked image for super-sampling
win = (2 * d + 1);  % Define the window size
res_ed = padarray(final_mask, [win, win]);  % Pad the final mask
res_resim = padarray(res_im, [win, win]);   % Pad the masked image
col = double(res_resim);                    % Convert the padded image to double for calculations

% Initialize counters for averaging the interpolated values
[sx, sy, ~] = size(res_ed);
cnt = double(ones(sx, sy, 3));

% Step 8: Iterate through the padded mask for super-sampling
for i = 1 + win : m + win
    for j = 1 + win : n + win
        if res_ed(i, j) == 1  % If the current pixel is an edge pixel
            % Iterate through the neighborhood to interpolate values
            for k = i - win : i + win
                for l = j - win : j + win
                    if res_ed(k, l) == 1
                        % Linear interpolation between the current pixel and its neighbor
                        for t = 0 : 0.25 : 1
                            cx = floor(t * i + (1 - t) * k);
                            cy = floor(t * j + (1 - t) * l);
                            
                            % Update the counters and interpolated color values
                            cnt(cx - d : cx + d, cy - d : cy + d, :) = cnt(cx - d : cx + d, cy - d : cy + d, :) + double(ones(win, win, 3));
                            col(cx - d : cx + d, cy - d : cy + d, :) = col(cx - d : cx + d, cy - d : cy + d, :) + double(res_resim(i - d : i + d, j - d : j + d, :)) * t + double(res_resim(k - d : k + d, l - d : l + d, :)) * (1 - t);
                        end
                    end
                end
            end
        end
    end
end

% Normalize the interpolated values using the counters
col = uint8(col ./ cnt);
col = col(1 + win : m + win, 1 + win : n + win, :);

% Display the reconstructed image
figure;
imshow(col);
title('Reconstructed Image');

% Save the reconstructed image
imwrite(col, './data/res_im.png');
