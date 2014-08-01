function prop = calcProps(ebjData)

% 1 - Original melanogaster: 45-65 sec ans = Hz
% 
%     0.0222
% 
%     0.0154
% 
% 2 - All mel & sim: 30-80 sec
% 
%     0.0333
% 
%     0.0125
% 
% 3 - All data: 25-105
% 
%     0.0400
% 
%     0.0095

prop = zeros(3,25);

for i = 1:25
    prop(1,i) = sum(ebjData(:,i) < .0222 & ebjData(:,i) > 0.0154) / numel(ebjData(:,i));
    prop(2,i) = sum(ebjData(:,i) < .0333 & ebjData(:,i) > 0.0125) / numel(ebjData(:,i));
    prop(3,i) = sum(ebjData(:,i) < .04 & ebjData(:,i) > 0.0095) / numel(ebjData(:,i));
end