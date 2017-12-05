



nb_bits=16;
N=4; % nombre d'échantillons par symbole
Te=64; % Période d'échantillonage
Ts=N*Te; % période symbole

%Mapping complexe
bitsI=2*[randi([0,1],1,nb_bits)]-1;
bitsQ=2*[randi([0,1],1,nb_bits)]-1;


%Echantillonage du filtre de mise en forme en racine 
% de cosinus surrelevé en vue de sa convolution par le signal d'entrée.
filtre_RCS=rcosdesign(0.35,10,Te,'sqrt');
%convolution pour mise en forme. 
%symboles = 
suite_diracs_ponderesI=[kron(bitsI,[1,zeros(1,Ts-1)]),zeros(1,nb_bits*Ts)];
suite_diracs_ponderesQ=[kron(bitsQ,[1,zeros(1,Ts-1)]),zeros(1,nb_bits*Ts)];
%size(suite_diracs_ponderesI)
signal_mis_en_formeI=2*filter(filtre_RCS,1,suite_diracs_ponderesI);
%signal_mis_en_formeI=signal_mis_en_formeI(1:1:end-nb_bits*(Ts-1));

signal_mis_en_formeQ=filter(filtre_RCS,1,suite_diracs_ponderesQ);




%Convolution par un filtre de reception
filtre_reception=filtre_RCS;
signal_recuI=9/Te*filter(filtre_reception,1,signal_mis_en_formeI);
signal_recuQ=9/Te*filter(filtre_reception,1,signal_mis_en_formeQ);

offset=Ts+Ts/2;
A=offset+Ts:Ts:nb_bits*(Ts)+offset+1;
%size(signal_recuI)

%Affichage de trois figures, le signal d'entrée, le signal reçu et les
%bits correspondants aux valeurs aux instants d'échantillonage. 
figure(1);
hold on;
plot(signal_mis_en_formeI(1:1:5000));
plot(signal_recuI(1:1:5000),'red');
bar(A,0.3*bitsI,0.01);

%normalisation du signal detecté en vue de la comparaison avec le signal
%d'emission.
signal_detecteI=(1/max(signal_recuI(A)))*signal_recuI(A);
%decision par detecteur à seuil, implanté ici via un arrondi à l'entier le
%plus proche.
bits_decides=round(signal_detecteI)
%Taux d'erreur confirmé nul en l'absence de bruit
taux_d_erreur=sum(bits_decides-bitsI)/nb_bits

