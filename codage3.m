
% 
% x = randi([0 1],1,188*8); % Original data
% nrows = 4; % Use 5 shift registers
% slope = 1; % Delays are 0, 3, 6, 9, and 12.
% y = convintrlv(x,nrows,slope); % Interleaving using convintrlv.
% 
% z = convdeintrlv(y,nrows,slope);
% 
% 
% 
% isequal(x, z)



bitsI=[randi([0,1],188*8,1)];
trellis = poly2trellis([7],[171 133]);
encoded=convenc(bitsI,trellis);
decoded = vitdec(encoded,trellis,3,'trunc','hard');
isequal(decoded,bitsI)
