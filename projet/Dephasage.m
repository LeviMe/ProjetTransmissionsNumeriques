function [ symb_d ] = Dephasage( phi, d_Rs, symb )
%DEPHASAGE simule dephasage du signal lors du passage a travers le canal AWGN
%   Dephasage du signal du phi specifie

%Dephasage de phi : on multiplie le symbole par exp(j*phi)
d_phi = phi.*ones(1,length(symb)) + [1:length(symb)].*2.*pi.*d_Rs;
symb_d = symb.*exp(j*d_phi);
end
