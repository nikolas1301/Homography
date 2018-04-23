clear all
clc
close all

im1 = iread('ufsc1.jpg', 'double');
im2 = iread('ufsc2.jpg', 'double');
im3 = iread('ufsc3.jpg', 'double');
im4 = iread('ufsc4.jpg', 'double');
im5 = iread('ufsc5.jpg', 'double');

im1_f = isurf(im1);
im2_f = isurf(im2);
im3_f = isurf(im3);
im4_f = isurf(im4);
im5_f = isurf(im5);

%%
[m1, c1] = im1_f.match(im2_f, 'top', 25);
[m2, c2] = im2_f.match(im3_f, 'top', 25);
[m3, c3] = im3_f.match(im4_f, 'top', 25);
[m4, c4] = im4_f.match(im5_f, 'top', 25);

%%
[h12, in1] = m1.ransac(@homography, 0.2);
[h23, in2] = m2.ransac(@homography, 0.2);
[h34, in3] = m3.ransac(@homography, 0.2);
[h45, in4] = m4.ransac(@homography, 0.2);

[out1, o1] = homwarp(h23, im2, 'full');

[out2, o2] = homwarp(h23*h12, im1, 'full');

[out3, o3] = homwarp(inv(h34), im4, 'full');

[out4, o4] = homwarp(inv(h34*h45), im5, 'full');

%%
s1 = size(im3);
s2 = size(out1);
s3 = size(out2);
s4 = size(out3);
s5 = size(out4);

a = s1(1);

if s2(1)>a
    a = s2(1);
end
if s3(1)>a
    a = s3(1);
end
if s4(1)>a
    a = s4(1);
end
if s5(1)>a
    a = s5(1);
end

zero = zeros(a, s1(2)+s2(2)+s3(2)+s4(2)+s5(2)-o4(1)-o3(1)+o2(1)+o1(1)-300);

if -o4(2)>-o2(2)
    sw = -o4(2)+1;
else
    sw = -o2(2)+1;
end

p_1 = ipaste(zero, out3, o3+[-o2(1)+1 sw], 'set');
p_2 = ipaste(p_1, out4, o4+[-o2(1)+1 sw], 'set');
p_3 = ipaste(p_2, out1, o1+[-o2(1)+1 sw], 'set');
p_4 = ipaste(p_3, out2, o2+[-o2(1)+1 sw], 'set');
p_5 = ipaste(p_4, im3, [-o2(1)+1 sw], 'set');
idisp(p_5);