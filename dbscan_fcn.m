%dbscan_fcn
function [centers, score, ClusterInd_change] = dbscan_fcn(x,y,MinPts,eps);
%dbscan
%density based clustering
%PARAMETERS
%eps = search radius (in px)
%MinPts = minimum density to add point to search list
%%
N=numel(x);
addpath ../common  %add path for OpenMolList/WriteMolBinNXcYcZc

% MinPts = 30;
% eps = 0.2;

ClusterInd = zeros(length(x),1);

percent = 0;
percent_now = 0;
num_mols_calculated = 0;
xbins = min(x):eps:max(x);
ybins = min(y):eps:max(y);
[num_out edges mid loc] = histcn([y x],ybins,xbins);
ind_out_size = size(num_out);
nrows = ind_out_size(1);
ind_out_vec = nrows*(loc(:,2)-1)+loc(:,1);
[ind_out_vec_sort sorted_ind] = sort(ind_out_vec);
cluster=0;
ClusterCount = 1;
score=[];
for i = 1:numel(ClusterInd)
    if ~ClusterInd(i)
        [out_list] = ExpandCluster(ind_out_vec_sort,sorted_ind,nrows,x,y,i,eps,MinPts);
        u=unique(out_list);
        
        if numel(u)>MinPts
            ClusterInd(u) = ClusterCount;
            score(ClusterCount)=numel(u);
            if score(ClusterCount)<MinPts
                keyboard
            end
            ClusterCount = ClusterCount+1;
        end
        
% debug 
%         clf       
%         plot(x,y,'k.')
%         hold on
%         plot(x(i),y(i),'g+')
%         plot(x(u),y(u),'m.')
%         set(gcf, 'Position', [1, 1, 986, 986]);
%         axis('equal')
%         keyboard
        
%         file_out = sprintf('s\\outpng_%d.png',ClusterCount)
%         saveas(gcf,file_out)

        percent = percent_now;
        
        percent_now = round(100*numel(find(ClusterInd))/N);
        if ~isequal(percent,percent_now)
            fprintf('%d%% complete\n',percent_now)
        end
        
    else
        continue
    end
    %delete molecules from queue
end
%%
score1=[];
for i=1:max(ClusterInd)
    idx = find(ClusterInd==i);
    score_now = numel(idx);
    score1(i) = score_now;
end
%%
%%
%delete empty clusters
u = unique(ClusterInd);
ClusterInd_change = ClusterInd.*0;
ClusterCount_change=1;

for i=1:numel(u)
    idx_change = find(ClusterInd==u(i));
    if numel(idx_change)>=MinPts
        ClusterInd_change(idx_change) = ClusterCount_change;
        ClusterCount_change=ClusterCount_change+1;
    elseif numel(idx_change)>0        
        %non clustered molecules
        ClusterInd(idx_change) = 1;
    else
        continue
    end
end

for i=1:max(ClusterInd_change)
    idx = find(ClusterInd_change==i);
    score_now = numel(idx);
    CoM_X = sum(x(idx))/score_now;
    CoM_Y = sum(y(idx))/score_now;
    
    centers(i,:) = [CoM_X CoM_Y];
    score(i) = score_now;
end


% plot(x,y,'k.')
% hold on
% plot(x(u),y(u),'m.')
