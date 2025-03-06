function [codebook] = LBG(speaker_mfcc, M)
speaker_mfcc(1,:) = [];
codebook{1} = mean(speaker_mfcc,2);
m = 1;

while(m < M)
    new_codebook = {};
    for i = 1:m
        c = codebook{i};
        epsilon = 0.01;
        c_plus = c.*(1 + epsilon);
        c_minus = c.*(1 - epsilon);
           
        new_codebook{end+1} = c_plus;
        new_codebook{end+1} = c_minus;
    end

    m = 2*m;
    D_prime = inf;
    while(1)
        codebook = new_codebook;
        cluster_assignments = zeros(1, size(speaker_mfcc,2));
        for i = 1:size(speaker_mfcc,2)
            distances = zeros(1,m);
            for j = 1:m
                distances(j) = norm(speaker_mfcc(:,i) - codebook{j});
                [~, cluster_assignments(i)] = min(distances);
            end
        end
    
        new_codebook = cell(1, m);
        d = [];
        for j = 1:m
            cluster = speaker_mfcc(:, cluster_assignments == j);
            if ~isempty(cluster)
                new_codebook{j} = mean(cluster,2);
            else
                new_codebook{j} = codebook{j};
            end
            for k = 1:size(cluster,2)
                d(end+1) = norm(cluster(:,k) - new_codebook{j});
            end
        end
        D = mean(d);
        if((D_prime - D)/D < epsilon)
            break
        end
        D_prime = D;
    end
    codebook = new_codebook;
end
end