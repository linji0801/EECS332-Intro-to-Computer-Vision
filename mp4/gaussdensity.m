function p = gaussdensity(data, mn, cv)

[rows, cols] = size(data);

if cols == 3
    dmn = [data(:,1)-mn(1) data(:,2)-mn(2) data(:,3)-mn(3)];
elseif cols == 2
    dmn = [data(:,1)-mn(1) data(:,2)-mn(2)];
end

coeff = 1/((2*pi)^(3/2) * sqrt(det(cv)));

mexp1 = dmn * inv(cv);
mexp2 = mexp1 .* dmn;
msum = sum(mexp2,2);

p = coeff * exp(-0.5 * msum);
end

