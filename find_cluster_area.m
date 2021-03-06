% find_cluster_area
% uses clustered data from previous step
% match clusters between 2 channels


do_2c =1; %for 2 color analysis
bin_size = 25; %nm
PxSize=160; %nm

CatSelect1 = 1;
CatSelect2 = 2; %categories

im_scale=10; %for optional rendering/debugging

r=OpenMolList;  %open clustered .bin file

bin_size_sq = bin_size.^2;



if do_2c==1
    CatInd1 = find(r.cat==CatSelect1);
    CatInd2 = find(r.cat==CatSelect2);
    center_max_1 = max(r.frame(CatInd1));
    center_max_2 = max(r.frame(CatInd2));
    
    x1=r.xc(CatInd1)*PxSize;
    y1=r.yc(CatInd1)*PxSize;
    z1=r.zc(CatInd1);
    area_out_1 = ones(center_max_1,1);
    centers_1 = zeros(center_max_1,2);
    
    x2=r.xc(CatInd2)*PxSize;
    y2=r.yc(CatInd2)*PxSize;
    z2=r.zc(CatInd2);    
    area_out_2 = ones(center_max_2,1);
    centers_2 = zeros(center_max_2,2);
else if do_2c==0
    CatInd1 = find(r.cat==CatSelect1);
    center_max_1 = max(r.frame(CatInd1));
    else
        warning('Check category options!')
    end
end

    



%%
for i=1:center_max_1
    
    idx_use = find(r.frame(CatInd1)==i);
    num = numel(idx_use);
    x_use = x1(idx_use);
    y_use = y1(idx_use);
    
    centers_1(i,:) = [mean(x_use) mean(y_use)];
    
    nbins_X = ceil((max(x_use)-min(x_use))/bin_size);
    nbins_Y = ceil((max(y_use)-min(y_use))/bin_size);   
    xbins = min(x_use):bin_size:((nbins_X*bin_size)+min(x_use));
    ybins = min(y_use):bin_size:((nbins_Y*bin_size)+min(y_use));   
    [count edges mid loc] = histcn([y_use, x_use],ybins,xbins);    
    area_out_1(i) = numel(find(count))*(bin_size_sq);
end
if do_2c==1
    for i=1:center_max_2
    
        idx_use = find(r.frame(CatInd2)==i);
        num = numel(idx_use);
        x_use = x2(idx_use);
        y_use = y2(idx_use);

        centers_2(i,:) = [mean(x_use) mean(y_use)];

        nbins_X = ceil((max(x_use)-min(x_use))/bin_size);
        nbins_Y = ceil((max(y_use)-min(y_use))/bin_size);   
        xbins = min(x_use):bin_size:((nbins_X*bin_size)+min(x_use));
        ybins = min(y_use):bin_size:((nbins_Y*bin_size)+min(y_use));   
        [count edges mid loc] = histcn([y_use, x_use],ybins,xbins);    
        area_out_2(i) = numel(find(count))*(bin_size_sq);
    end
    %% find matches based on area-weighted distance
    % iterate through cluster centers in cat 1
    area_weight = 0.0001;   %higher = stricter area-based matching
    dist_thresh = 1000000;

    mat1 = [centers_1 area_weight.*area_out_1];
    mat2 = [centers_2 area_weight.*area_out_2];
    %delete each first index
    mat1=mat1(2:end,:);
    mat2=mat2(2:end,:);

    dist2 = sqrt(l2_dist_mat(mat1',mat2'));

    dist_size = size(dist2);

    [min_dist min_dist_ind] = min(dist2);

    match_idx = [1:length(min_dist_ind); min_dist_ind]'+1;

    outlier_thresh=4000;
    plot(x1,y1,'k.')
    hold on
    plot(x2,y2,'m.')
    plot(centers_1(:,1),centers_1(:,2),'b+')
    plot(centers_2(:,1),centers_2(:,2),'g+')

    for i=1:length(match_idx)
        cat1_center_match = match_idx(i,2);
        cat2_center_match = match_idx(i,1);

        x=[centers_1(cat1_center_match,1) centers_2(cat2_center_match,1)];
        y=[centers_1(cat1_center_match,2) centers_2(cat2_center_match,2)];
        if dist(i)>outlier_thresh
            line(x,y,'Color','red')
        else
            line(x,y)
        end
    end

end

% idx_delete = find(dist>outlier_thresh);
% match_idx_filter = match_idx;
% match_idx_filter(idx_delete,:)=[];


% plotting
% keyboard
%     clf
%     x_shift = (x_use-min(x_use))/bin_size*im_scale;
%     y_shift = (y_use-min(y_use))/bin_size*im_scale;
%     imshow(imadjust(imresize(count,im_scale)))
%     hold on
%     plot(x_shift,y_shift,'m.')

