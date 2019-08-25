%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%            Image Reconstruction                %
%               - Suhong Kim -                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc;clear;close all;

imgin = im2double(imread('corn.tif',3));
[imh, imw, nb] = size(imgin);

% the image is grayscale
assert(nb==1);

V = zeros(imh, imw);
V(1:imh*imw) = 1:imh*imw; 
% V(y,x) = (y-1)*imw + x
% use V(y,x) to represent the variable index of pixel (x,y)
% Always keep in mind that in matlab indexing starts with 1, not 0

%% initialize counter, A (sparse matrix) and b.
n_pxl = imh*imw; 
S = imgin(:);
i = zeros(1, n_pxl*5); 
j = zeros(1, n_pxl*5); 
v = zeros(1, n_pxl*5);
b = zeros(n_pxl, 1); 

%% fill the elements in A and b, for each pixel in the image
% add extra constraints
for p = 1:n_pxl
   %corner constraint
   if (p == 1) || (p == imh) || (p == n_pxl-imh) || (p == n_pxl)
       i(p) = p;          j(p) = p;             v(p) = 1;          % v = s
       i(p+1*n_pxl) = p;  j(p+1*n_pxl) = p;     v(p+1*n_pxl) = 0;  % default
       i(p+2*n_pxl) = p;  j(p+2*n_pxl) = p;     v(p+2*n_pxl) = 0;  % default  
       i(p+3*n_pxl) = p;  j(p+3*n_pxl) = p;     v(p+3*n_pxl) = 0;  % default
       i(p+4*n_pxl) = p;  j(p+4*n_pxl) = p;     v(p+4*n_pxl) = 0;  % default
       %b(p) = S(p); 
       % control global lightness and gradient 
       b(1) = S(1)+0.0;         b(n_pxl-imh) = S(n_pxl-imh)+0.0;
       b(imh) = S(imh)+0.0;     b(n_pxl) = S(n_pxl)+0.0;
       
   % horizontal edge
   elseif (1 < p && p < imh) || ((n_pxl-imh) < p && p < n_pxl)
       i(p) = p;          j(p) = p;             v(p) = 2;          % 2*v(x,y)
       i(p+1*n_pxl) = p;  j(p+1*n_pxl) = p+1;   v(p+1*n_pxl) = -1; % -1*v(x+1, y)
       i(p+2*n_pxl) = p;  j(p+2*n_pxl) = p-1;   v(p+2*n_pxl) = -1; % -1*v(x-1, y)     
       i(p+3*n_pxl) = p;  j(p+3*n_pxl) = p;     v(p+3*n_pxl) = 0;  % default
       i(p+4*n_pxl) = p;  j(p+4*n_pxl) = p;     v(p+4*n_pxl) = 0;  % default
       b(p) = 2*S(p) - S(p+1) - S(p-1); 
       
   % vertical edge 
   elseif (mod(p,imh) == 1) || (mod(p, imh) == 0)
       i(p) = p;          j(p) = p;             v(p) = 2;          % 2*v(x,y)
       i(p+1*n_pxl) = p;  j(p+1*n_pxl) = p;     v(p+1*n_pxl) = 0;  % default
       i(p+2*n_pxl) = p;  j(p+2*n_pxl) = p;     v(p+2*n_pxl) = 0;  % default 
       i(p+3*n_pxl) = p;  j(p+3*n_pxl) = p+imh; v(p+3*n_pxl) = -1; % -1*v(x, y+1)
       i(p+4*n_pxl) = p;  j(p+4*n_pxl) = p-imh; v(p+4*n_pxl) = -1; % -1*v(x, y-1)
       b(p) = 2*S(p) - S(p+imh) - S(p-imh); 
   % midle 
   else    
       i(p) = p;          j(p) = p;             v(p) = 4;          % 4*v(x,y)
       i(p+1*n_pxl) = p;  j(p+1*n_pxl) = p+1;   v(p+1*n_pxl) = -1; % -1*v(x+1, y)
       i(p+2*n_pxl) = p;  j(p+2*n_pxl) = p-1;   v(p+2*n_pxl) = -1; % -1*v(x-1, y)     
       i(p+3*n_pxl) = p;  j(p+3*n_pxl) = p+imh; v(p+3*n_pxl) = -1; % -1*v(x, y+1)
       i(p+4*n_pxl) = p;  j(p+4*n_pxl) = p-imh; v(p+4*n_pxl) = -1; % -1*v(x, y-1)
       b(p) = 4*S(p) - S(p+1) - S(p-1) - S(p+imh) - S(p-imh);
   end
end

%% solve the equation
% use "lscov" or "\", please google the matlab documents
A = sparse(i, j, v); 
solution = A\b;
error = sum(abs(A*solution-b));
disp(error)

imgout = reshape(solution,[imh,imw]);
subplot(1,2,1), imshow(imgin); title('Original');  
subplot(1,2,2), imshow(imgout); title('Reconstruction'); 

