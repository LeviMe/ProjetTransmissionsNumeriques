%Nettoyage de l'espace de travail
clear all; close all; clc;
warning('off', 'all');

%Definition des variables

Nbit = 15040;           %Doit etre multiple de 2 et 188*8bits
Te = 1;                 %Temps echantillonage
N = 4;                  %Nombre de bits par symbole
Ts = N.*Te;             %Temps d'un symbole

dB = 0;                 %Bruit du canal AWGN (note : ecrase si utilisation du for)

n_T = 3;                %Padding pour le filtre
alpha = 0.35;           %Variable du filtre

generator = [171, 133]; %Generateur du treillis (poinconnage)
L = 7;                  %Longueur du treillis
puncture = [1 1 0 1];   %Matrice de poinconnage

nb_erreurs = 0;         %Compteur d'erreurs
Nsuites = 0;            %Nombre de suites envoyees (compteur d'erreurs)
%TEB = zeros(1,5);       %Calcul du TEB

phi_deg = 15;           %Dephasage de la constellation (en degres)
phi = phi_deg*pi/180;   %Dephasage en radiants
d_Rs = 0.0001;          %Ecart de frequence par rapport a Rs
BlT_dB = -3;            %Bande de bruit en dB
BlT = 10.^(BlT_dB);     %Bande de bruit
ordre = 2;              %Ordre du filtre de PLL

%Calculer la pente de la courbe en S du detecteur de la PLL uniquement si
%pas deja fait
try
    pente = 0;
    load pente;             %Pente de la courbe en S (calculee par le fichier fourni)
end
if pente==0
    pente = Pente(dB);
end

%Calcul des coefficients du filtre
if ordre==2
zeta=sqrt(2)/2;
A=16*zeta^2*BlT.*(1+4*zeta^2-4*BlT)/(1+4*zeta^2)./(1+4*zeta^2-8*zeta^2*BlT);
B=64*zeta^2*BlT.^2/(1+4*zeta^2)./(1+4*zeta^2-8*zeta^2*BlT);
elseif ordre==1
   B=0*BlT;
   A=4*BlT;
end
 
A=A/pente;
B=B/pente;

%for dB=-4:0
    while nb_erreurs<100
        
        %Generer une suite binaire
        bits = randi([0 1], 1, Nbit);
        Nsuites = Nsuites + 1;
        
        %Codage Canal
        bits_code = Codage(bits, generator, L, puncture);
        
        %Modulation du signal
        [sig_I, sig_Q] = Modulation(bits_code, alpha, Ts, Te, n_T);
        
        %Passage dans le canal AWGN
        [sig_bI, sig_bQ] = Canal(dB, sig_I, sig_Q); 
        
        %Demodulation du signal
        [sig_bI, sig_bQ] = Demodulation(sig_bI, sig_bQ, alpha, Ts, Te, n_T);
        
        %Dephasage
        [sig_cI, sig_cQ] = Dephasage(phi, d_Rs, sig_bI, sig_bQ);
        
        %Boucle PLL
        [sig_dI, sig_dQ] = PLL(A, B, sig_cI, sig_cQ);
        
        %Decision
        symb = zeros(1, length(sig_dI) + length(sig_dQ));
        symb(1:2:end) = sig_dI;
        symb(2:2:end) = sig_dQ;
        bits_r = Decision(symb); %Uniquement decodage hard
        
        %Decodage canal
        bits_decode = Decodage_hard(bits_r, generator, L, puncture); %Hard
        %bits_decode = Decodage_soft(symb, generator, L, puncture); %Soft
        
        %Nombre d'erreurs
        nb_erreurs = nb_erreurs + length(find(bits~=bits_decode));
        TEB_exp = nb_erreurs/(Nbit*Nsuites)
        
    end
    TEB_th(dB + 5) = 1-normcdf(sqrt(4.*10.^(dB/10)));
    TEB(dB + 5) = nb_erreurs./(Nbit.*Nsuites);
%    nb_erreurs=0;
    
%end
    
plot([-4:0], TEB, 'b');
hold on;
plot([-4:0], TEB_th, 'r');
