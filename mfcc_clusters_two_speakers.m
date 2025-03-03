mfcc6speaker1 = mfcc_vals(6,:);
mfcc7speaker1 = mfcc_vals(7,:);

mfcc6speaker2 = mfcc_vals2(6,:);
mfcc7speaker2 = mfcc_vals2(7,:);

scatter(mfcc6speaker1, mfcc7speaker1, 'x', 'b');
hold on;

scatter(mfcc6speaker2, mfcc7speaker2, 'o', 'r');
title('mfcc space');
xlabel('mfcc-6');
ylabel('mfcc-7');
legend({'Speaker 1', 'Speaker 2'});
grid on;

hold off;