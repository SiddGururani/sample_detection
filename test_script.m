for i = 10:25
    [testmat, ~] = featureExtract(costs{i}, locs{i}, slope_dev{i});
    l = predict(ens,testmat');
    l = cell2mat(l);
    if(numel(l(l == 't')) > 0)
        fprintf('%d : true\n', i);
    else
        fprintf('%d : false\n', i);
    end
end