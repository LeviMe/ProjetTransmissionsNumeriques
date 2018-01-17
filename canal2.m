function [ signalBruiteI, signalBruiteQ]= canal( dB, signalI, signalQ)
%CANAL simule l'ajout du bruit lors du passage du signal a travers le canal AWGN
%   Addition du bruit au signal avec le dB specifie

%Calcul de la puissance du bruit : sigma_a = 1 (variance des symboles),
%et somme du carre de h... = 1 car on a norme
%Es=2*Eb donc sigma^2 = 1./(4.*Eb/N0)
% et Eb/N0dB = 10log(Eb/N0) d'ou Eb/n0 = 10^(dB/10)
sigma = sqrt(1./(4.*10.^(dB/10)))

puissance_log = 10*log(sigma_n_carre);
bruitI = wgn(1, npts*nb_bits,puissance_log);
bruitQ = wgn(1, npts*nb_bits,puissance_log);
%bruitcomplexe = bruitI + j*bruitQ ; 


signalBruiteI = signalI + bruitI;
signalBruiteQ = signalQ + bruitQ;

%signalBruite = signalBruiteI + j * signalBruiteQ


end
