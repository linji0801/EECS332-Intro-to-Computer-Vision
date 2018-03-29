import cv2
import numpy as np
import math

def Segment(img,parameter,threshold):
    #img_hs=cv2.cvtColor(img,cv2.COLOR_BGR2HSV)[:,:,0:1]    #the output is black, there are some problems
    img_hs=BGR2HS(img)
    M_i=parameter[1]
    H=img_hs[:,:,0]-parameter[0][0]
    S=img_hs[:,:,1]-parameter[0][1]
    
    Dist=M_i[0,0]*H*H+2*M_i[0,1]*H*S+M_i[1,1]*S*S
    img_out=img*(cv2.merge([Dist,Dist,Dist])<threshold)

    #for i in range(img.shape[0]):
    #    for j in range(img.shape[1]):
    #        vec=img_hs[i,j,:]-parameter[0]
    #        if np.dot(np.dot(vec.T,M_i),vec)<threshold:
    #            img_out[i,j,:]=img[i,j,:]

    return img_out
    
def BGR2HS(img_in):
    #H belongs to [0,2*pi]
    #S belongs to [0,1]

    B=img_in[:,:,0].astype(float)
    G=img_in[:,:,1].astype(float)
    R=img_in[:,:,2].astype(float)
    
    width,height,channel=img_in.shape
    
    #compute S & I
    I=(B+G+R)/3
    index=np.argwhere(I==0)
    for i in range(index.shape[0]):
        I[index[i,0],index[i,1]]=1e-10
    S=1-img_in.min(2)/I

    #compute H
    R_G=(R-G)/255;
    R_B=(R-B)/255;
    G_B=(G-B)/255;
    num=R_G+R_B;
    den=np.sqrt(R_G*R_G + R_B*G_B)*2; 
    theta=np.arccos(num/(den+1e-10));
    H=theta
    
    index=np.argwhere(G_B<0)
    for i in range(index.shape[0]):
        H[index[i,0],index[i,1]]=2*math.pi-theta[index[i,0],index[i,1]]

    return cv2.merge([H,S])

def Gaussian(train_data):
    #Mean
    Count=0;
    Mean=np.zeros(2)
    hs_data=[];
    for i in range(len(train_data)):
        img_hs=BGR2HS(train_data[i])
        hs_data.append(img_hs)
        Mean=Mean+np.sum(np.sum(img_hs,axis=0),axis=0)
        Count=Count+img_hs.shape[0]*img_hs.shape[1]
    Mean=Mean/Count
    
    #Var
    Var=np.zeros([2,2])
    for i in range(len(train_data)):
        img_hs=hs_data[i]
        temp=img_hs-Mean
        for j in range(img_hs.shape[0]):
            for k in range(img_hs.shape[1]):
                Var=Var+np.outer(temp[j,k,:],temp[j,k,:])
                
    Var=Var/Count
    return [Mean,np.linalg.inv(Var)]