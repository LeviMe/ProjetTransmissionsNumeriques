# -*- coding: utf-8 -*-
"""
Created on Sun May 21 01:54:31 2017

@author: LeviMe
"""

import numpy as np
import random as rd
import matplotlib.pyplot as plt



NbSymboles=1024
Ts=1 #1 symbole/s
Te=16

def cos_srl(t):
    Ts=8
    alpha=1
    res=(1/Ts)*np.sinc(t/Ts)
    res*=np.cos(alpha*np.pi*t/Ts)
    res/=(1-(2*alpha*t/Ts)**2)
    return res

def phi(x):
    return (1/np.sqrt(2*np.pi)* np.exp(-x**2 /2))

def Phi(x):
    if (x==0):
        return 0.5
    if (x<0):
        return 1 - Phi(np.abs(x))
    if (x>0):
        s2=0
        t=np.linspace(0,x,2000)
        step=t[1]
        for k in t:
            s2+=phi(k)
        s2*=step
        return 0.5+s2
    
def to_list(A):
    Ap=[]
    for k in A:
        Ap+=[k]
    return Ap

TEB=[]
TEBtheo=[]

range_Eb_sur_N0_dB=np.linspace(0,6,6*10+1)
for Eb_sur_N0_dB in range_Eb_sur_N0_dB:

    ##############generation de symboles############################

    bits =[rd.randrange(0,2) for k in range(NbSymboles)]

    ##############Mapping des symboles##############################

    symboles=[2*bit-1 for bit in bits]
    
    ##############Multiplication par un peigne de dirac#############

    dirac=[1]+ [0]*(Te-1)
    suite_diracs_ponderes=to_list(np.kron(symboles,dirac))

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

    shaping_filter=cos_srl(np.linspace(-5,5,Te))
    shaped_signal=convolve(shaping_filter,suite_diracs_ponderes)

    #########Ajout d'un bruit blanc Gaussien ###################################
    Eb_sur_N0=10*(Eb_sur_N0_dB/10)
    sigma_n_carre=(sum(shaping_filter[k]**2 for k in range(Te)) * np.var(symboles)**2)
    sigma_n_carre/=(2*np.log2(2) * Eb_sur_N0)
    sigma_n=np.sqrt(sigma_n_carre)
    signal_bruite=[k + rd.normalvariate(0,sigma_n) for k in shaped_signal]

    #########Convolution par un filtre de reception####################

    reception_filter=shaping_filter
    signal_recu=convolve(reception_filter,signal_bruite)
    signal_recu=[2*k/Te for k in signal_recu]

    signal_detecte=[(signal_recu[0+k*Te]) for k in range(1,NbSymboles*Ts+1)]
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

    #############Statistiques############################################

    Teb=sum((bits[k]!=bits_decides[k]) for k in range(NbSymboles)) / NbSymboles
    #print("Eb_sur_N0="+str(Eb_sur_N0)+"   Teb="+str(Teb*100)+" %")
    
    TEB+=[Teb]
    TEBtheoCourant=1-Phi(np.sqrt(2*Eb_sur_N0))
    TEBtheo+=[TEBtheoCourant]
    print(str(Eb_sur_N0)+"   "+str(Teb)+ "    "+ str(TEBtheoCourant))
    
    
plt.close()
plt.plot(range_Eb_sur_N0_dB,TEB)
plt.plot(range_Eb_sur_N0_dB,TEBtheo)

plt.legend("TEB=f(Eb)")
plt.show()
