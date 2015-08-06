hh = 80; % image height
ww = 160; % image width
blocksize = 8;
ny=floor(hh/blocksize);
nx=floor(ww/blocksize);
ndic = 300;

xgrid = repmat(1:ww, hh, 1);
ygrid = repmat((1:hh)', 1, ww);

xp = (xgrid -1 +0.5)/blocksize - 0.5;
yp = (ygrid -1 +0.5)/blocksize - 0.5;

ixp = round(xp);
iyp = round(yp);

vx0 = xp - ixp;
vy0 = yp - iyp;

vx1 = 1 - vx0;
vy1 = 1 - vy0;

%   MatrixXf xp = (xgrid.array().cast<float>()-1+0.5)/blocksize-0.5;
%   MatrixXf yp = (ygrid.array().cast<float>()-1+0.5)/blocksize-0.5;
%   MatrixXi ixp = xp.cast<int>();       //  -0.4 cast to 0 instead of -1
%   MatrixXi iyp = yp.cast<int>();
%   MatrixXf vx0 = xp-ixp.cast<float>();
%   MatrixXf vy0 = yp-iyp.cast<float>();
%   MatrixXf vx1 = 1.0-vx0.array();
%   MatrixXf vy1 = 1.0-vy0.array();
  
%%
xstart = blocksize/2 + 1 - 1;
xend   = nx*blocksize - blocksize/2 - 1;
ystart = blocksize/2 + 1 - 1;
yend   = ny*blocksize - blocksize/2 - 1;

k = 0;
vals = 0;
histVal = zeros(nx*ny, ndic);
for y = ystart:yend
    for x = xstart:xend
        p = y + x*hh;
        if vx1(y,x)*vy1(y,x) + vx1(y,x)*vy0(y,x) + vx0(y,x)*vy1(y,x) + vx0(y,x)*vy0(y,x) == 1
            vals = vals + 1;
        end
        k = k + 1;
%         histVal(iyp(y,x)+ixp(y,x)*ny, :) = histVal(iyp(y,x)+ixp(y,x)*ny, :) + ...
%             vx1(y,x)*vy1(y,x)
    end
end

% ystart=blocksize/2+1-1; yend=ny*blocksize-blocksize/2-1;
%     xstart=blocksize/2+1-1; xend=nx*blocksize-blocksize/2-1;
% 
%     // discard everthing that's block/2 from boundary
%     for(int y=ystart; y<=yend; y++)
%       for(int x=xstart; x<=xend; x++)
%       {
%         int p=y+x*hh;
%         hist( iyp(y,x)+ixp(y,x)*ny, (int)codes(p,2*s) ) += vx1(y,x)*vy1(y,x)*codes(p,2*s+1);
%         hist( iyp(y,x)+1+ixp(y,x)*ny, (int)codes(p,2*s) ) += vx1(y,x)*vy0(y,x)*codes(p,2*s+1);
%         hist( iyp(y,x)+(ixp(y,x)+1)*ny, (int)codes(p,2*s) ) += vx0(y,x)*vy1(y,x)*codes(p,2*s+1);
%         hist( iyp(y,x)+1+(ixp(y,x)+1)*ny, (int)codes(p,2*s) ) += vx0(y,x)*vy0(y,x)*codes(p,2*s+1);
%       }
