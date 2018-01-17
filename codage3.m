x = randi([0 63],20,1); % Original data
nrows = 17; slope = 12; % Interleaver parameters
D = nrows*(nrows-1)*slope; % Delay of interleaver/deinterleaver pair


x_padded = [x; zeros(D,1)]; % Pad x at the end before interleaving.
a1 = convintrlv(x_padded, nrows,slope); % Interleave padded data.

b1 = convdeintrlv(a1, nrows,slope);

[x;b1(D+1:end)]
isequal(x,b1(D+1:end))





