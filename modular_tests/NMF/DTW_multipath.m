function [paths, C] = DTW_multipath(D)
 
    % cost initialization
    C               = zeros(size(D));
%     C(1,:)          = cumsum(D(1,:));
    C(1,:)          = D(1,:);
    C(:,1)          = cumsum(D(:,1));
    % traceback initialization
    DeltaP          = zeros(size(D));
    DeltaP(1,2:end) = 3; % (0,-1)
    DeltaP(2:end,1) = 2; % (-1,0)
    
    % recursion
    for (n_A = 2:size(D,1))
        for (n_B = 2:size(D,2))
            % find preceding min (diag, column, row)
            [fC_min, DeltaP(n_A,n_B)]   = min([C(n_A-1,n_B-1), C(n_A-1,n_B), C(n_A,n_B-1)]);
            C(n_A, n_B)                 = D(n_A,n_B) + fC_min;
        end
    end
    
    
    % traceback from minimum cost element in last row of cost matrix
    iDec= [-1 -1; -1 0; 0 -1]; % compare DeltaP contents: diag, vert, hori
    
    
    % Process last row of cost matrix to reduce false positives:
    last_row = C(end,:);
    filt = medfilt1(last_row);
    filtered_row = last_row - filt;
    filtered_row(filtered_row > 0) = 0;
    filtered_row = filtered_row*-1;
    [~,locs]= findpeaks(filtered_row);
    paths = cell(numel(locs),1);
    for i = 1:numel(locs)
        p   = [size(D,1),locs(i)];
    %     p   = size(D);  % start with the last element
    %     n   = [size(D,1), size(D,2)]; %[n_A, n_B];
        n  = p;
%         while ((n(1) > 1) || (n(2) > 1))
        while (n(1) > 1)
            n = n + iDec(DeltaP(n(1),n(2)),:);

            % update path (final length unknown)
            p   = [n; p];
        end   
        paths{i} = p;
    end

    % traceback from last element in matrix
%     iDec= [-1 -1; -1 0; 0 -1]; % compare DeltaP contents: diag, vert, hori
%     p   = size(D);  % start with the last element
%     n   = [size(D,1), size(D,2)]; %[n_A, n_B];
%     while ((n(1) > 1) || (n(2) > 1))
%         n = n + iDec(DeltaP(n(1),n(2)),:);
% 
%         % update path (final length unknown)
%         p   = [n; p];
%     end   
end