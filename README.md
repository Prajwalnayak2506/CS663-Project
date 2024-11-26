# PS1 : Image Compression Using Modified JPEG Algorithm

## Project Overview

This project implements an image compression engine using an approach inspired by the JPEG algorithm, tailored to meet specific requirements. The system efficiently compresses grayscale images while maintaining a balance between image quality and compression ratio. The algorithm involves preprocessing the image, computing frequency components, quantization, and entropy encoding.

## Features

- Grayscale image compression
- Preprocessing of images to center pixel values
- Division of images into 8x8 blocks for localized processing
- Quantization of frequency coefficients
- Huffman encoding for lossless compression

# PS2 : Image compression for cartoon-images using a research paper

## Project Overview

This project focuses on edge detection and lossless image compression using advanced techniques from image processing and the JBIG (Joint Bi-level Image Experts Group) compression standard. The main objective is to implement a system that detects edges in grayscale images and encodes the resulting edge image using JBIG, a lossless compression method suited for bi-level images. Edge detection is performed using the Marr-Hildreth method, which applies Gaussian smoothing and Laplacian filtering to detect zero-crossings. Following edge detection, the binary image is compressed using the JBIG standard to achieve efficient storage and transmission of edge data.

- Automated Edge Detection: Detects edges using Marr-Hildreth method.
- Customizable Thresholds: Adjustable low and high thresholds for edge refinement.
- Lossless JBIG Compression: Compresses binary edge images using JBIG standard.
- MATLAB Integration: Entire process automated through MATLAB script.
- Flexible: Supports different image formats and parameters.
- Scalable: Can handle large datasets and be extended for other features.
- Cross-Platform: Compatible with Windows, Linux, and macOS.
- Efficient Storage: Reduces file size with lossless compression.
