function y = nanstomean(x)

% fills internal NaN with arithmetic of two flanking values
% flanking NaNs are not altered
%
%x = [NaN 1   NaN   NaN     5   NaN     3 NaN NaN];

y = x;

for i = 1:numel(y)
    if isnan(y(i))
        k=i;
        while isnan(y(k))
            if k > 2
                k = k-1;
            else
                break
            end
        end
        
        m=i;
        while isnan(y(m))
            if m < numel(y)
                m = m+1;
            else
                break
            end
        end
        
        n = mean([y(k) y(m)]);
        y(k+1:m-1) = n;
    end
end
