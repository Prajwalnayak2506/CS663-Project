function [psnr, divergence_values, psnr_values] = decodr_new(maskPath, maskedImagePath, origImagePath, savePath)
    % DECODER 
    % takes mask and image with some pixel values missing
    % generates the estimate of original image using homogeneous diffusion
    % the error measure used is PSNR
    % maskImagePath must have .pbm extension

    res_im = imread(maskedImagePath);
    mask_im = imread(maskPath);
    orig_im = imread(origImagePath);
    
    % Homogeneous Diffusion Parameters %
    delta_t = 0.09;
    max_time = 500;

    % Convert mask from logical to double to avoid calculation loss
    msk = double(mask_im);
    msk = cat(3, msk, msk, msk);  % Convert to 3-channel mask
    
    % Use image as double to avoid integer division 
    res_im = double(res_im);
    [m, n, ~] = size(res_im);

    % Initialize arrays to store divergence and PSNR values
    divergence_values = [];  % Empty array to store divergence values
    psnr_values = [];        % Empty array to store PSNR values

    % Homogeneous diffusion process
    for t = 0:delta_t:max_time
        % Calculate the second derivatives (Laplace operator)
        res_xx = res_im(:, [2:n, n], :) - 2 * res_im + res_im(:, [1, 1:n-1], :);
        res_yy = res_im([2:m, m], :, :) - 2 * res_im + res_im([1, 1:m-1], :, :);
        Lap = res_xx + res_yy;

        % Calculate divergence (the Laplacian)
        div = delta_t * Lap;
        divergence_values = [divergence_values, sqrt(sum(sum(div.^2)))];  % Append divergence scalar

        % Update image based on the mask
        res_im = res_im + (div .* msk);

        % Calculate PSNR at this step
        res_im_uint8 = uint8(res_im);
        mse = double(sum(sum(sum((orig_im - res_im_uint8).^2)))) / (3.0 * m * n);
        psnr_value = 10.0 * log10((255.0 * 255.0) / mse);
        psnr_values = [psnr_values, psnr_value];  % Append PSNR scalar
    end

    % Convert the restored image back to uint8
    res_im = uint8(res_im);

    % Final PSNR calculation for the entire process
    mse = double(sum(sum(sum((orig_im - res_im).^2)))) / (3.0 * m * n);
    psnr = 10.0 * log10((255.0 * 255.0) / mse);  % Final PSNR for the entire diffusion process

    % Display Final PSNR
    disp('Final PSNR:');
    disp(psnr);

    % Show the original and restored images
    figure;
    imshow(orig_im);
    title('Original Image');
    pause(2);
    figure;
    imshow(res_im);
    title('Restored Image');

    % Save the restored image
    imwrite(res_im, savePath);
end
