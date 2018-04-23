# Homography
Using feature detection and homography to build a panoramic image
The algorithm was developed using matlab 2016a and Peter Corke's computer vision toolbox.

The first thing we did was to get the dataset provided for the job and read it and save it using the function iread. Then we used the Speeded-Up Robust Features (SURF) algorithm to identify the features from all the five images, so this features were used to match with the features from the next image using the match function. Then the ransac function was applied to to calculate the homography with the smallest residue possible, so we passed the homography matrix to the homwarp function to correct the images and return the offset from each one in relation to the main image. Finally a black image was created and we added the central image, which was used as the basis for creating the panoramic, and the images corrected according to their offset in relation to the main image.

Algorithm:

Read the five images in double format: 
im1 = iread('building1.jpg', 'double');
im2 = iread('building2.jpg', 'double');
im3 = iread('building3.jpg', 'double');
im4 = iread('building4.jpg', 'double');
im5 = iread('building5.jpg', 'double');

Indentify the features from each image: 
im1_f = isurf(im1);
im2_f = isurf(im2);
im3_f = isurf(im3);
im4_f = isurf(im4);
im5_f = isurf(im5);

Match the 25 best features from image A to features in image B: image_A_features.match(image_B_features, 'top', number of features that you want to match):
[m1, c1] = im1_f.match(im2_f, 'top', 25);
[m2, c2] = im2_f.match(im3_f, 'top', 25);
[m3, c3] = im3_f.match(im4_f, 'top', 25);
[m4, c4] = im4_f.match(im5_f, 'top', 25);

Use the ransac to calculate the homography matrix, the threshold was defined as 0.2, so points with a residual above this number are considered an outlier. The vector "IN"  describe the inlier point set:
[h12, in1] = m1.ransac(@homography, 0.2);
[h23, in2] = m2.ransac(@homography, 0.2);
[h34, in3] = m3.ransac(@homography, 0.2);
[h45, in4] = m4.ransac(@homography, 0.2);

Homwarp function correct the image in relation to the main image using the homography matrix. The vector "O" has the offset value from each image in relation to the main image: 
[out1, o1] = homwarp(h23, im2, 'full');
[out2, o2] = homwarp(h23*h12, im1, 'full');
[out3, o3] = homwarp(inv(h34), im4, 'full');
[out4, o4] = homwarp(inv(h34*h45), im5, 'full');

Get the size from images:
s1 = size(im3);
s2 = size(out1);
s3 = size(out2);
s4 = size(out3);
s5 = size(out4);

Automatically creates the black image to fit all the corrected images:
zero = zeros(s5(1)+60, s1(2)+s2(2)+s3(2)+s4(2)+s5(2)-o4(1)-o3(1)+o2(1)+o1(1)-300);

Gets the biggest vertical size so the image will start from point [1 1]:
if -o4(2)>-o2(2)
    sw = -o4(2)+1;
else
    sw = -o2(2)+1;
end

Paste the corrected images in the right points using the offset. The option "set" was used to overwrite the pixels in the image:
p_1 = ipaste(zero, out3, o3+[-o2(1)+1 sw], 'set');
p_2 = ipaste(p_1, out4, o4+[-o2(1)+1 sw], 'set');
p_3 = ipaste(p_2, out1, o1+[-o2(1)+1 sw], 'set');
p_4 = ipaste(p_3, out2, o2+[-o2(1)+1 sw], 'set');
p_5 = ipaste(p_4, im3, [-o2(1)+1 sw], 'set');

Show the result:
idisp(p_5);
