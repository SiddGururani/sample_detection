function H_norm = normalize_activations(H, k, method)

switch method
    case 'global'
        H_norm = H./max(H(:));
    case 'local'
        n = size(H,1)/k;
        for shift = 1:n
            H_shift = H((shift-1)*k+1:shift*k,:);
            H_shift = H_shift./max(H_shift(:));
            H((shift-1)*k+1:shift*k,:) = H_shift;
        end
end