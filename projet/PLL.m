function [ symb_corrige ] = PLL(A, B, symb)
%PLL Detection et correction du dephasage
%   Detection et correction du dephasage du signal du a la difference de
%   frequence des horloges a l'emission et la reception

symb_corrige = zeros(1, length(symb));
phi_est = zeros(1, length(symb)+1);
out_det = zeros(1, length(symb));
w = zeros(1, length(symb));
NCO_mem=0;      % initialisation NCO
filtre_mem=0;   % initialisation de la memoire du filtre

%PLL
for i=1:length(symb)
    symb_corrige(i) = symb(i)*exp(-j*phi_est(i));
    out_det(i)= -imag(symb_corrige(i).^4);
    
    % filtre de boucle
    w(i)=filtre_mem+out_det(i); % memoire filtre + sortie detecteur 
    filtre_mem=w(i);            
    out_filtre=A*out_det(i)+B*w(i);   % sortie du filtre a l'instant i :  F(z)=A+B/(1-z^-1)
    
    %NCO
    phi_est(i+1)=(out_filtre+NCO_mem); % N(z)=1/(z-1) 
    NCO_mem=phi_est(i+1);
end

end