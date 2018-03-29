import cv2
import numpy as np
import math

def Segment(img,parameter,threshold):
    M_i=parameter[1]
    B=img[:,:,0]-parameter[0][0]
    G=img[:,:,1]-parameter[0][1]
    R=img[:,:,2]-parameter[0][2]
    
    Dist=M_i[0,0]*B*B+2*M_i[0,1]*B*G+2*M_i[0,2]*B*R+M_i[1,1]*G*G+2*M_i[1,2]*G*R+M_i[2,2]*R*R
    img_out=img*(cv2.merge([Dist,Dist,Dist])<threshold)

    return img_out


def Gaussian(train_data):
    #Mean
    Count=0;
    Mean=np.zeros(3)
    data=[];
    for i in range(len(train_data)):
        img=train_data[i]
        Mean=Mean+np.sum(np.sum(img,axis=0),axis=0)
        Count=Count+img.shape[0]*img.shape[1]
    Mean=Mean/Count
    
    #Var
    Var=np.zeros([3,3])
    for i in range(len(train_data)):
        img=train_data[i]
        temp=img-Mean
        for j in range(img.shape[0]):
            for k in range(img.shape[1]):
                Var=Var+np.outer(temp[j,k,:],temp[j,k,:])
                
    Var=Var/Count
    return [Mean,np.linalg.inv(Var)]