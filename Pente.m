function [ pente ] = Pente( dB )
%PENTE calcule la pente de la caracteristique du detecteur de la PLL 
%Calcul de la pente a l'origine de la caracteristique du detecteur de
%phase du PLL

d_phi_deg=-90:10:90;
d_phi = d_phi_deg*pi/180;

EbNo=10.^(dB/10);

N_symb=1000;

for jj=1:length(d_phi_deg)  % boucle sur erreur de phase 
    
    for ii=1:N_symb   % boucle sur symboles
        
        bits=2*randi(1,2)-1;
        IE=bits(1);
        QE=bits(2);

        Es=sum(abs(IE+j*QE).^2);
                
        %bruit
        
        sigma=sqrt(Es/EbNo/4);
        
        noise=randn(2,1)*sigma;
        IE = IE + noise(1);
        QE = QE + noise(2);
       
        %rajouter l'erreur de phase+ le bruit
        
        symb_emis=IE+j*QE;
        recu= symb_emis*exp(j*d_phi(jj));
        
        %  detecteur
        
        %Im()^4
        out_det(ii) = -imag(recu^4);    
        
    end
    
    S_curve(jj)=mean(out_det);

end

% on calcule la pente de la caracteristique (S-Curve) autour de 0 (entre -3 et 3 degres) : 
pente=S_curve((length(S_curve)+1)/2+3)-S_curve((length(S_curve)+1)/2-3);
pente=pente/(6*(d_phi(2)-d_phi(1)));

save pente pente 

% figure(1)
% plot(d_phi_deg,S_curve,'b-')
% grid on
% hold on
% plot([-3:1:3],[-3:1:3]*pente*pi/180,'r-');
% 
% xlabel('erreur de phase')
% ylabel('sortie du detecteur')
% 
% title('caracteristique (S-curve) du detecteur')
end