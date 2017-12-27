function [autocorrelation_coeff] = calAutoCorrelation(input)
len = length(input);
autocorrelation_coeff = zeros(len,1);

%calculate coeff(1)
autocorrelation_coeff(1)= sum(input(:).^2)/length(input);

for t=2:len
    for j = 1:len - t;
        autocorrelation_coeff(t)= autocorrelation_coeff(t) + input(j)*input(j+t);
    end
        autocorrelation_coeff(t)= autocorrelation_coeff(t) /(len-t);
end
%normalize coefficients to [0/1] by dividing to coeff(1)
autocorrelation_coeff = autocorrelation_coeff./autocorrelation_coeff(1);

end