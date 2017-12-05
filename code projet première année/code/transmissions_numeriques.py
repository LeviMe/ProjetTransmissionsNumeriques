# -*- coding: utf-8 -*-
"""
Created on Sun May 14 15:10:56 2017

@author: LeviMe
"""

import numpy as np
import random as rd
import matplotlib.pyplot as plt
import math


NbSymboles=64
Ts=1 #1 symbole/s
Te=16

def to_list(A):
    Ap=[]
    for k in A:
        Ap+=[k]
    return Ap

def cos_srl(t):
    Ts=8
    alpha=0.5
    res=np.sinc(t/Ts)
    res*=np.cos(alpha*np.pi*t/Ts)
    res/=(1-(2*alpha*t/Ts)**2)
    return res

##############generation de symboles############################

bits =[rd.randrange(0,2) for k in range(NbSymboles)]
#print(bits)
##############Mapping des symboles##############################

symboles=[2*bit-1 for bit in bits]

##############Multiplication par un peigne de dirac#############

dirac=[1]+ [0]*(Te-1)

suite_diracs_ponderes=np.kron(symboles,dirac)
suite_diracs_ponderes=to_list(suite_diracs_ponderes)
#print(suite_diracs_ponderes)


###########Convolution par un filtre de mise en forme############

def convolve(U,V):
    N1=len(U)
    N2=len(V)

    W=[]
    for n in range(N1+N2-1):
        s=0
        for k in range(max(0,n-N2+1),min(n+1,N1)):            
            s+=U[k]*V[n-k]
        W+=[s]
    return W

A=[1]*Te


shaped_signal=convolve(A,suite_diracs_ponderes)
#
plt.close() 
#
plt.plot(shaped_signal,marker='.')

#########Ajout d'un bruit blanc Gaussien ##########################
Eb_sur_N0_dB=3

Eb_sur_N0 = 10**(Eb_sur_N0_dB/10);
sigma_n_carre=  sum([k**2 for k in A])*np.var(symboles)**2/(2*np.log2(2)*Eb_sur_N0) 

sigma_n=np.sqrt(sigma_n_carre)
signal_bruite=[k + rd.normalvariate(0,sigma_n) for k in shaped_signal]


#########Convolution par un filtre de reception####################

A2=[1]*(int)(Te)
signal_recu=convolve(A,signal_bruite)
signal_recu=[k/Te for k in signal_recu]
#plt.plot(signal_recu)
plt.show()
signal_detecte=[(signal_recu[k*Te]) for k in range(1,NbSymboles*Ts+1)]
#print(signal_detecte)

################Decision############################################

def decision(A):
    M=[]
    for k in A:
        if ((abs(k+1) ) < (abs(k-1))):
            M+=[0]
        else:
            M+=[1]
    return M

bits_decides=decision(signal_detecte)
#print(bits_decides)


#############Statistiques############################################

Teb=sum((bits[k]!=bits_decides[k]) for k in range(NbSymboles)) / NbSymboles
print("Teb="+str(Teb*100)+" %") 

##########Diagramme de l'oeil signal non-bruité######################
#plt.close()
signal_recu_non_bruite=convolve(A, shaped_signal)
signal_recu_non_bruite=[k/Te for k in signal_recu_non_bruite]

def plot_eye_diagram(signal,Ts):
    plt.close()
    n=len(signal)
    print(n,2*Ts)
    T=[]
    R=[]
    count=0
    for i in range((int)(n/(2*Ts))):
        B=[]
        for k in range(Ts):
            B+=[signal[count]]
            count+=1
        R+=B
        t=np.linspace(0,2,len(B))
        T+=to_list(t)
        plt.plot(t,B)
    plt.show()
    for k in range(len(R)):
        print(R[k],"      ",T[k])

plt.plot(signal_recu_non_bruite)
plt.show()

plot_eye_diagram(signal_recu_non_bruite,16)