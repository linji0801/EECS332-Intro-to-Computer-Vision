function colortrack(movi,dt,db,hsv,savemov,nf)
% movi - input movie file in matlab format (after aviread)
% dt - rgb  data for the class to be tracked [Nx3]
% db - rgb data for the background [Nx3]
% hsv - 0 for rgb, 1 for hsv, 2 for hs
% savemov - 0 for no save, 1 for save
% nf - number of frames to do tracking (selects evenly among all frames)

if nargin <= 3
    hsv = 0;
    savemov = 0;
    nf = 50;
end

% mask = [ skin foams bck]
mask = [0.7 0.1 0.7];

nframes = length(movi);

avifig1 = figure;
avifig2 = figure;
avifig3 = figure;

if savemov
    set(avifig1,'DoubleBuffer','on');
    set(gca,'xlim',[-80 80],'ylim',[-80 80],...
        'NextPlot','replace','Visible','off')
    movo1 = avifile(fullfile('./','trackim.avi'),'fps',24/int32(nframes/nf));
    set(avifig2,'DoubleBuffer','on');
    set(gca,'xlim',[-80 80],'ylim',[-80 80],...
        'NextPlot','replace','Visible','off')
    movo2 = avifile(fullfile('./','trackskin.avi'),'fps',24/int32(nframes/nf));
    set(avifig3,'DoubleBuffer','on');
    set(gca,'xlim',[-80 80],'ylim',[-80 80],...
        'NextPlot','replace','Visible','off')
    movo3 = avifile(fullfile('./','trackbckg.avi'),'fps',24/int32(nframes/nf));
end
switch hsv
    case 0
        dt = dt;
        db = db;
    case 1
        dt = rgb2hsv(dt);
        db = rgb2hsv(db);
    case 2
        dt = rgb2hs(dt);
        db = rgb2hs(db);
    otherwise
        error('unknown hsv conversion');
end
mnd = mean(dt);
mnb = mean(db);
cvd = cov(dt);
cvb = cov(db);

for i=1:int32(nframes/nf):nframes
    im = movi(i).cdata;
    im = double(im);
    [rows, cols, d] = size(im);
    data_rgb = reshape(im,[rows*cols d]);
    
    switch hsv
        case 0
            data = data_rgb;
        case 1
            data = rgb2hsv(data_rgb);
        case 2
            data = rgb2hs(data_rgb);
        otherwise
            error('unknown hsv conversion');
    end
    
    % calculate conditional density P(rgb | skin)
    P1 = gaussdensity(data, mnd, cvd);
    % calculate conditional density P(rgb | bckg)
    P2 = gaussdensity(data, mnb, cvb);
    % add for outliers
    P3 = ones(rows*cols,1)/256;
    % normalize and get posteriori (P(skin | rgb))
    Psum = P1 + P2 + P3;
    L1 = P1 ./ Psum;
    L2 = P2 ./ Psum;
    L3 = P3 ./ Psum;
    
    Di = L1>L2 & L1>2*mean(L1);
    Di = uint8(reshape(Di,rows,cols));
    D(:,:,1) = Di*mask(1);
    D(:,:,2) = Di*mask(2);
    D(:,:,3) = Di*mask(3);
    
    figure(avifig1);
    image(movi(i).cdata - D.*movi(i).cdata);axis image;
    % store in the avi
    if savemov
        f = getframe(gca);
        movo1 = addframe(movo1,f);
    end
    figure(avifig2);
    imagesc(reshape(L1,rows,cols));axis image;
    % store in the avi
    if savemov
        f = getframe(gca);
        movo2 = addframe(movo2,f);
    end
    figure(avifig3);
    imagesc(reshape(L2,rows,cols));axis image;
    % store in the avi
    if savemov
        f = getframe(gca);
        movo3 = addframe(movo3,f);
    end
end
if savemov
    movo1 = close(movo1);
    movo2 = close(movo2);
    movo3 = close(movo3);
end


function hs = rgb2hs(im)

hsv = rgb2hsv(im);
s = hsv(:,2);
h = hsv(:,1);
hs = [s.*cos(2*pi*h) s.*sin(2*pi*h)];
