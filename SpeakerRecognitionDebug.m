myTrainDir = uigetdir;
myTrainFiles = dir(fullfile(myTrainDir,'*.wav'));
fprintf("Num files %d\n", length(myTrainFiles));
for k = 1:length(myTrainFiles)
  baseFileName = myTrainFiles(k).name;
  fullFileName = fullfile(myTrainDir, baseFileName);
  fprintf(1, 'Now reading %s\n', fullFileName);
  [x_array{k}, fs] = audioread(fullFileName);
  if (size(x_array{k},2) ~= 1)
  x_array{k}(:,2) = [];
  end
  x_array{k} = x_array{k} - mean(x_array{k});
  x_array{k} = x_array{k} / max(abs(x_array{k}));
  threshold = 0.1;
  thresholdIndices = [];
  thresholdIndices = find(abs(x_array{k}) > threshold);
  if ~isempty(thresholdIndices)
    firstIndex = thresholdIndices(1);
    lastIndex = thresholdIndices(end);
    x_array{k} = x_array{k}(firstIndex:lastIndex);
  end
  N = 128;
  [f_array{k},t_array{k},mfcc_array{k}] = mfcc(x_array{k}, fs, N);
end
disp("Done reading files and converting to MFCC");

M = 8;
for k = 1:size(mfcc_array,2)
    speaker_mfcc = mfcc_array{k};
    disp("Entering LBG");
    codebook{k} = LBG(speaker_mfcc, M);
end
disp("Done creating user codebooks");

myTestDir = uigetdir;
myTestFiles = dir(fullfile(myTestDir,'*.wav'));
classification = zeros(1,length(myTestFiles));
for p = 1:(length(myTestFiles))
  baseFileName = myTestFiles(p).name;
  fullFileName = fullfile(myTestDir, baseFileName);
  [x_test_array{p}, fs] = audioread(fullFileName);
  if (size(x_test_array{p},2) ~= 1)
  x_test_array{p}(:,2) = [];
  end
  x_test_array{p} = x_test_array{p} - mean(x_test_array{p});
  x_test_array{p} = x_test_array{p} / max(abs(x_array{p}));
  threshold = 0.1;
  thresholdIndices = [];
  thresholdIndices = find(abs(x_test_array{p}) > threshold);
  if ~isempty(thresholdIndices)
    firstIndex = thresholdIndices(1);
    lastIndex = thresholdIndices(end);
    x_test_array{p} = x_test_array{p}(firstIndex:lastIndex);
  end
  N = 128;
  [f_test_array{p},t_test_array{p},mfcc_test_array{p}] = mfcc(x_test_array{p}, fs, N);

  test_speaker_mfcc = mfcc_test_array{p};
  test_speaker_mfcc(1,:) = [];
  centroid_distances = zeros(1, size(test_speaker_mfcc,2));
  average_centroid_distance = zeros(1, size(codebook,2));

  for i = 1:size(codebook,2)
      for j = 1:size(test_speaker_mfcc,2)
          distances = zeros(1, M);
          for l = 1:M
              distances(l) = norm(test_speaker_mfcc(:, j) - cell2mat(codebook{i}(:,l)));
          end
          centroid_distances(j) = min(distances);
      end
        average_centroid_distance(i) = mean(centroid_distances);
  end

  [~, classification(p)] = min(average_centroid_distance);
end