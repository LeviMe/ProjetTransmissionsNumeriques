%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%               TRAME CHAINE DE TRANSMISSION DE BASE                      %
%                        MAI 2017 - TPs TR1                               %
%                   Auteur : Nathalie Thomas                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    A COMPLETER ET MODIFIER :                                            %
%    - pour tracer le TEB en fonction de Eb/N0 en dB                      %
%    - pour considerer differents filtres d'emission et reception         %
%    - pour considerer differents mapping                                 %
%    - pour travailler en bande de base ou en chaine passe-bas equivalente%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


close all
clear all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  PARAMETRES GENERAUX
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Nombre de bits a generer (si ne proviennent pas d'un texte ou d'une image)
nb_bits=2000;
%nombre d'echantillons par symboles
npts=50;
%Periode d'echantillonnage
Te=1;
%Periode symbole
Ts=npts*Te;
%Niveau de Eb/N0 teste en dB

Eb_sur_N0_dB = -2 ;
Eb_sur_N0=10^(Eb_sur_N0_dB);
%------------------------------------------------------------------------%
%----------------INFORMATION BINAIRE A TRANSMETTRE-----------------------%
%------------------------------------------------------------------------%
% Generation d'une duite de bits 0, 1
%bits=randi(2,1,nb_bits)-1;

%OU
%Generation d'une suite de bits 0, 1 associee a un texte a envoyer
bits = str2bin('Ce fut alors que le prisonnier se mit a chanter.
Les paroles etaient en francais,mais meme ceux qui ne comprenaient pas
la langue devinaient a sa plaintive melodie qu''il s''agissait
d''un chant de tristesse et d''adieu ...').';
nbbits=length(bits);
%OU
%Generation d'une suite de bits 0, 1 associee a une image a transmettre
% image_emise = imread('barbara.png');
% image_binaire=de2bi(image_emise);
% bits=double(reshape(image_binaire.',1,size(image_binaire,1)*size(image_binaire,2)));

%------------------------------------------------------------------------%
%------------------------------- MODULATEUR------------------------------%
%------------------------------------------------------------------------%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  MAPPING BITS -> SYMBOLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
symboles=2*bits - 1;%symboles possèdent 1752 caractères -1 ou 1.
1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  EMBROUILLAGE DES SYMBOLES
% Permet d'uniformiser le spectre d'energie - Cette etape est necessaire
% lorsqu'on transmet un texte ou une image mais peut etre conservee meme
% si vous utilisez randi pour generer votre information binaire

% Un bit à 0 conserve sa valeur tandis qu'un bit à 1 a une chance sur 2 de
% passer à -1. L'information est conservé avec des bits mais si les
% symboles sont {1,-1} elle est perdue. D'ou mon interrogation sur
% l'utilité de cette étape.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
alea = 1 - 2 * randi([0,1], 1, length(symboles));
symboles = symboles .* alea;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  SURECHANTILLONNAGE                                                     %
%  <=> GENERATION DE LA SUITE DE DIRACS PONDERES PAR LES SYMBOLES         %


% Sous forme numérique un dirac est une suite possédant 1 en 0 et 0 partout
% ailleurs. Echantilloné sur une période symbole Ts, le dirac est la suite
% 1 suivis de Ts-1 0.
%Le produit de Kronecker permet alors d'enchainer les diracs pondérés par
%les symboles
% Le vecteur suite_dirac_ponderes possède ainsi len(symboles)*Ts
% composantes.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
suites_diracs_ponderes = kron(symboles, [1, zeros(1,Ts-1)]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  FILTRAGE DE MISE EN FORME
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Generation des jeux de coefficients definissant le filtre de mise en forme
%Pour le moment on considère un filtre de mise en forme rectangulaire.
% Dans le cas d'un filtre numérique RIF, la suite des coefficients définissant
%la fonction de transfert est simplement l'échantillonage de sa réponse
%impulsionnelle, ici une fonction porte de largeur Ts d'ou le code
%ci-dessous.

B_Tx=ones(1,Ts);
A_Tx=1;
%Filtrage de mise ne forme
signal_mis_en_forme=filter(B_Tx,A_Tx,suites_diracs_ponderes);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  OBSERVATIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Calcul de la densite spectrale de puissance du signal mis en forme
% La forme de la DSP calculée et la bonne, puisqu'elle est celle d'un
%d'un NRZ polaire i.e. A²Tsinc²(fT), reste à savoir la correlation entre
%son amplitude et son axe de symétrie avec la nature de la suite de
%symboles.

padded_shaped_signal=[signal_mis_en_forme zeros(1,1000)];

nfft=2^nextpow2(nbbits*npts);
DSP_signal_mis_en_forme = abs(fft(padded_shaped_signal, nfft)).^2 /length(padded_shaped_signal);

y=fftshift(DSP_signal_mis_en_forme);
f = linspace(-0.5,0.5,length(y));

%affichage du signal et de sa DSP
%plot(f,y);
%title('DSO signal_mis_en_forme')
%xlabel('Frequence normalisee')


%Trace du diagramme de l'oeil a l'emission (trace realise sur 2Ts)
%%%%%Après recherche sur internet, la fonction reshape, comme son nom
%%%%%l'indique redimensionne un vecteur, ici le signal_mis_en forme, qui
%%%%%désormais sera une matrice dont les dimensions seront:
%%%%% 2*Ts,length(signal_mis_en_forme)/(2*Ts)
%%%%% de telle sorte, les éléments situés sur un un intervalle de largeur
%%%%% 2Ts auront un affichage superposé.

% La figure qui apparait est plus ou moins conforme à celle obtenue p
%h=eyediagram(signal_mis_en_forme,2*Ts);
%plot(h);
oeil=reshape(signal_mis_en_forme,2*Ts,length(signal_mis_en_forme)/(2*Ts));

figure
plot(oeil)
title('Diagramme de l''oeil en sortie du filtre de mise en forme')
xlabel('Numero d''echantillon')
ylabel('Oeil')


%------------------------------------------------------------------------%
%--------------------------------- CANAL --------------------------------%
%------------------------------------------------------------------------%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  GENERATION DU BRUIT A UNE PUISSANCE CORRESPONDANT AU Eb/N0 SOUHAITE

%_sigma_n^2=\frac{\sum_k |h(k)|^2 \sigma_a^2}{2\log_2(M) \frac{E_b}{N_0}}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Calcul de sigma_n^2

M=length(symboles);
sigma_a_carre=1; % car le signal est NRZ polaire uniformément distribué
sigma_n_carre=(  sum(B_Tx.^2)*sigma_a_carre)/(2*log2(2)*Eb_sur_N0)
%Generation d'un bruit gaussien a la bonne puissance
bruit=wgn(1, length(symboles)*Ts,10*log(sigma_n_carre)); % sigma_n_carre);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  AJOUT DU BRUIT AU SIGNAL EMIS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
signal_recu = signal_mis_en_forme+bruit;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  OBSERVATIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%affichage du signal bruite
plot(signal_mis_en_forme(1:500));
hold;
plot(signal_recu(1:500));


%-------------------------------------------------------------------------%
%------------------------------- DEMODULATEUR-----------------------------%
%-------------------------------------------------------------------------%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  FILTRAGE DE RECEPTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Generation des jeux de coefficients definissant le filtre de reception
B_Rx=ones(1,Ts);
A_Rx= [1];
%Filtrage de reception
signal_sortie_filtre_reception=filter(B_Rx,A_Rx,signal_recu);

mx=max(signal_sortie_filtre_reception);
signal_sortie_filtre_reception=signal_sortie_filtre_reception/mx;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  OBSERVATIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%affichage du signal en sortie du filtre de reception
plot(signal_sortie_filtre_reception(1:500));
%observation du diagramme de l'oeil en sortie du filtre de reception
%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  ECHANTILLONNAGE A t0+mTs

% le signal d'origine est échantilloné à
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%choix de t0
t0=input('Instant de decision t0 ?\n');
%echantillonnage
signal_echantillonne=signal_sortie_filtre_reception(t0:Ts:length(signal_sortie_filtre_reception));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  DECISIONS SUR LES SYMBOLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
symboles_decides=sign(signal_echantillonne);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  DESEMBROUILLAGE DES SYMBOLES
% Cette etape est necessaire lorsque l'on a realise un embrouillage
% au niveau de l'emetteur
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
symboles_decides = symboles_decides .* alea;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  DEMAPPING POUR RETOUR AUX BITS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
bits_decides=(symboles_decides+1)/2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  CALCUL DU TEB (POUR LA VALEUR FIXEE DE Eb/N0)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TEB_SIMULE=sum(bits_decides!=bits)/nb_bits;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  COMPARAISON DU TEB SIMULE ET DU TEB THEORIQUE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TEB_THEORIQUE=1 - normcdf(sqrt(2*Eb_sur_N0))
