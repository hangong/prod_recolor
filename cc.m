function r = cc(i,c)
% cc(i,c)
%
% i - original image
% c - new colour (specify RGB values in [0,1])
%
% r - colour changed image
%
% Copyright 2020 Han Gong, University of East Anglia

A = reshape(i,[],3);

% get a background mask
lab1 = rgb2lab(A);
lab2 = rgb2lab(A(1,:));
mask = sqrt(sum((lab1(:,2:3)-lab2(:,2:3)).^2,2))>5;
mask = reshape(mask,size(i,1),size(i,2));

% get a thumbnail sample of LAB colors
is = imresize(i,[32,32]); %is2 = imresize(i,[32,32]);
As = reshape(is,[],3);
As = rgb2lab(As);
m_s = imresize(mask,[32,32]); %m_s2 = imresize(mask,[32,32]);

% run clustering on colors
width = 0.1; n_cluster = inf;
while n_cluster>5
    [AA,idx] = HGMeanShiftCluster(As(m_s,:)',width,'flat');
    n_cluster = size(AA,2);
    width = width * 1.5;
end
AA = AA';
AA = lab2rgb(AA); % convert LAB cluster centres back to RGB

% compute cluster weight (size)
weight = hist(idx,1:max(idx));
% sort cluser according to weight
[~,nidx] = sort(weight,'descend');
AA = AA(nidx,:);
weight = weight(nidx);
weight = weight/sum(weight); % normalise weights

BB = AA;
BB(1,:) = c; % change the primary colour

% solve for a weighted 3x3 colour transform
M = (AA'*diag(weight)*AA+1e-3*eye(3))\(AA'*diag(weight)*BB);
%M = (AA'*AA+1e-3*eye(3))\(AA'*BB);

%%{
n_iter = 10;
ee = zeros(n_iter,1);
g2 = rgb2lab(is);
for ii = 1:n_iter
    
    r = tune_color(is,AA(1,:),ii,M,m_s);

    g1 = rgb2lab(r);
    e11 = edge(g1(:,:,2),'Sobel','nothinning');
    e12 = edge(g2(:,:,2),'Sobel','nothinning');
    e21 = edge(g1(:,:,3),'Sobel','nothinning');
    e22 = edge(g2(:,:,3),'Sobel','nothinning');
    
    ee(ii) = entropy(abs(e11-e12))+entropy(abs(e21-e22));

end
[~,ii] = min(ee);
%}

r = tune_color(i,AA(1,:),ii,M,mask);

% plot the entropy
%plot(ee); figure;

% comment out the below line to enable regrain artefact remover
%r = regrain(i,r);

end

function r = tune_color(i,o,ii,M,mask)
% i - input image
% o - original primary colour
% M - colour correction matrix
% mask - specularity mask

A = reshape(i,[],3);

C = A*M; % apply colour correction

% find colors not to be changed (using color difference)
lab1 = rgb2lab(A);
lab2 = rgb2lab(o);

% computer ab color difference
d = sqrt(sum((lab1(:,2:3)-lab2(:,2:3)).^2,2));
d_max = 10+ii*20;
d = min(d,d_max)/d_max;

% apply mask (to avoid high colour difference being applied)
C = (1-d).*C + d.*A;
C(~mask,:) = A(~mask,:);

r = reshape(C,size(i));

%imshow(r);

end
