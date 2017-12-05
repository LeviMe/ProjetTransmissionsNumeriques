

bitsI=[randi([0,1],1,10)]


% La fonction suivante contient deux matrices.
%   En notant k la taille d'un bloc d'entrée, la première est de dimension
%   k x 1. Elle donne la longueur de contrainte pour les k éléments de ce
%   bloc, i.e. dans toutes les équations régissant les valeurs de sortie,
%   qu'elle est l'ancienneté maximale du i-éme bit de ce bloc nécessaire
%   pour connaitre ces valeurs. 
%   La deuxième est de dimension k*n.
%   pour n symboles de sortie à une itération, qu'elle est le bouclage via
%   un polynome sur les valeurs courante et précédente du premier symbole
%   d'entrée + à (la ligne suivante) le bouclage sur le deuxième + (à la
%   k-ième ligne) le bouclage sur le k-ième.
%   
trellis = poly2trellis([7],[171 133])
encoded=convenc(bitsI,trellis)
decoded = vitdec(encoded,trellis,3,'trunc','hard')
isequal(decoded,bitsI)


%101 111