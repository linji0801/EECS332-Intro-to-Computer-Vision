import numpy as np
import cv2
import BGR  #this is faster, for no color space transform
import MD
import HS
import copy
import math
import time
import random
import ballgame

def ArrayUnion(array_a,array_b):    #return the elements that appear in both array a and array b
    array_c=None
    for i in range(array_b.shape[0]):
        row_index=np.where((array_a == array_b[i]).all(1))[0]
        if row_index.shape[0]:  #find same point
            if array_c is None:
                array_c=array_b[i,:]
            else:
                array_c=np.concatenate((array_c,array_b[i,:]))
    return array_c

def FindCur(contour,l,threshold_l,threshold_h):
    Contour=np.squeeze(contour)
    vecs1=np.zeros(Contour.shape)
    vecs2=np.zeros(Contour.shape)
    
    #v(0)-v(+l)
    vecs1[:-l,:]=Contour[:-l,:]-Contour[l:,:]
    vecs1[-l:,:]=Contour[-l:,:]-Contour[:l,:]
    Norm1=np.sqrt(np.sum(vecs1*vecs1,axis=1))+1e-10

    #v(0)-v(-l)
    vecs2[:l,:]=Contour[:l,:]-Contour[-l:,:]
    vecs2[l:,:]=Contour[l:,:]-Contour[:-l,:]
    Norm2=np.sqrt(np.sum(vecs2*vecs2,axis=1))+1e-10
    
    CosTheta=np.sum(vecs1*vecs2,axis=1)/Norm1/Norm2
    SinTheta=(vecs1[:,0]*vecs2[:,1]-vecs1[:,1]*vecs2[:,0])/Norm1/Norm2

    Contour=Contour[(CosTheta>threshold_l)*(CosTheta<threshold_h)*(SinTheta<0)]

    Contour=np.expand_dims(Contour, axis=1)
    return Contour
    
def CircleAppend(list,element,length):
    list.append(copy.deepcopy(element))
    if len(list)>length:
        del list[0]
    return list

def FingerTipHisto(Candidates,centroid_hand):
    histo=np.zeros(12)
    vec=Candidates-centroid_hand
    vec_norm=np.sqrt(np.sum(vec*vec,axis=1))+1e-18
    
    theta=30.0
    for i in range(12):
        dir=np.array([np.cos(math.radians(i*theta)),np.sin(math.radians(i*theta))])
        cos=np.dot(vec,dir)/vec_norm
        histo[i]=np.sum(cos>np.cos(math.radians(theta/2)))

    return histo
    
def FingerTipDir(list_FingerTipHisto,PreDirection):
    if len(list_FingerTipHisto):
        Histo=sum(list_FingerTipHisto)  #an array contain 12 elements
        index=np.where(Histo==np.max(Histo))    #largest element's index
        Histo_temp=copy.deepcopy(Histo)
        Histo_temp[index[0]]=0
        if len(index[0])>1 or np.max(Histo)-np.max(Histo_temp)<10: #more than one fingertip direction
            FingerTipDir=PreDirection
        elif np.max(Histo)>0.4*np.sum(Histo):   #obvious fingertip detected
            theta=index[0][0]*30
            FingerTipDir=np.array([np.cos(math.radians(theta)),np.sin(math.radians(theta))])
            if PreDirection is not None:    #only rotate 30 degree at most
                if np.dot(FingerTipDir,PreDirection)<=1e-10:
                    FingerTipDir=np.array([np.cos(math.radians(theta+90)),np.sin(math.radians(theta+90))])
                    if np.dot(FingerTipDir,PreDirection)<=1e-10:
                        FingerTipDir=np.array([np.cos(math.radians(theta-30)),np.sin(math.radians(theta-30))])
                    else:
                        FingerTipDir=np.array([np.cos(math.radians(theta+30)),np.sin(math.radians(theta+30))])
        else:               #no obvious fingertip direction detected
            FingerTipDir=PreDirection
    else:
        FingerTipDir=PreDirection
    return FingerTipDir
    
def FindFingerTip(Candidates,centroid_hand,FingerTipDir):
    if FingerTipDir is not None:
        vec=Candidates-centroid_hand
        vec_norm=np.sqrt(np.sum(vec*vec,axis=1))+1e-18
        proj=np.dot(vec,FingerTipDir)
        cos=proj/vec_norm
        
        FingerTip=Candidates[proj==np.max(proj),:][0]
        
        #if np.max(cos)>0.75:    #detect obvious fingertip
        #    FingerTip=Candidates[proj==np.max(proj),:][0]
        #else:
        #    FingerTip=None
    else:               #no obvious fingertip detected
        FingerTip=None
    return FingerTip

def GestureReg(list_FingerTipHisto):
    if len(list_FingerTipHisto):
        Histo=sum(list_FingerTipHisto)
        Histo_fingertip=Histo[Histo>=10]
        if Histo_fingertip.shape[0]>=2:     #more than 1 fingertip direction
            index1=np.where(Histo==np.max(Histo_fingertip))[0][0]
            Histo_fingertip[Histo_fingertip==np.max(Histo_fingertip)]=0
            if np.max(Histo_fingertip)>0:   #has a second large direction
                index2=np.where(Histo==np.max(Histo_fingertip))[0]
                if index2.shape[0]==1:
                    index2=index2[0]
                elif (index2[0]-index1)**2>(index2[-1]-index1)**2:
                    index2=index2[-1]
                else:
                    index2=index2[0]
            else:
                index2=np.where(Histo==np.max(Histo_fingertip))[0][1]
            dis=min((index1-index2)%12,(index2-index1)%12)
            if dis<=1:
                gesture=1   #one fingertip
            elif dis>=5:
                gesture=0   #noise
            else:
                gesture=2   #two fingertip
        elif Histo_fingertip.shape[0]==1:   #only 1 fingertip direction
            gesture=1
        else:                               #no fingertip direction
            gesture=0
    else:
        gesture=0
    return gesture  # 0 means no fingertip, 1 means one fingertip, 2 means two fingertips

train_data=[]

for i in range(9):
    filename='piece'+str(1+i)+'.jpg'
    im=cv2.imread('training_data/'+filename)
    train_data.append(im)

parameter=BGR.Gaussian(train_data)
threshold_l=12;
threshold_h=15;
num=5;  #frame in memory

es = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (5, 5))

cap = cv2.VideoCapture(0)
bgs_mog=cv2.bgsegm.createBackgroundSubtractorMOG(20)
#opencv3的话用:
fourcc = cv2.VideoWriter_fourcc(*'XVID')
out = cv2.VideoWriter('output.mp4', fourcc, 20.0, (640, 480))
frame_pre=None
frame=None
x1=None
FingerTip=None
list_FingerTipHisto=[]
list_size=[]    #record the size of palm in recent frames
list_rectindex=[]   #record the index of palm in recent frames
list_ployindex=[]   #record the index of palm in recent frames
Direction=None
Gesture=0
frame2=np.zeros([480,640,3])

#BallGame Init:
framewidth = 640
frameheight = 480
paddleheight = 400
ballnum = 10
balls = []

for i in range(0, ballnum):
    x = random.randrange(20,framewidth-20)
    y = random.randrange(20,paddleheight-20)
    r = random.randrange(256)
    g = random.randrange(256)
    b = random.randrange(256)
    balls.append(ballgame.StillBall([r, g, b], 20, x, y, 5, frameheight))


pre_px = int(framewidth/2)
pre_py = paddleheight
ori_speed = 10
paddle = ballgame.Paddle([0,0,0], pre_px, pre_py, 100, 10)
ball = ballgame.Ball(0, 0, [0,0,255], 30, ori_speed, balls, ballnum, framewidth, frameheight)
energy = 100
timer = 400
#End BallGame Init

while True:
    ret,frame = cap.read() #frame:480*640

    if ret == True:
        MotionEdge1=MD.MotionDect(frame,frame_pre,es)    #480*640 0 or 255 
        MotionEdge2=bgs_mog.apply(frame)                #perhaps we only need this instead of MD module
        MotionEdge=(MotionEdge1+MotionEdge2).astype(np.uint8)/255.0
        MotionEdgd_3D=cv2.merge([MotionEdge,MotionEdge,MotionEdge])
        
        #cv2.imshow('edge',MotionEdgd_3D)
        
        HandMov1=BGR.Segment(cv2.GaussianBlur(frame*MotionEdgd_3D, (11, 11), 1),parameter,threshold_l)

        #cv2.imshow('HandMov1',HandMov1.astype(np.uint8))

        hand_binary = cv2.threshold(HandMov1[:,:,0]+HandMov1[:,:,1]+HandMov1[:,:,2], 127, 255, cv2.THRESH_BINARY)[1]
        image, cnts, hierarchy = cv2.findContours(hand_binary.astype(np.uint8), cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
        frame1=frame.copy()

        MovFlag=0

        for c in cnts:
            size=cv2.contourArea(c)
            if size > 400:
                if MovFlag:
                    hulls =  np.concatenate((hulls,c))
                else:   #detect movement, initailize
                    hulls=c
                    centroid_hand=np.zeros(2)
                    list_x=[]
                    list_y=[]
                MovFlag=1
                (x, y, w, h) = cv2.boundingRect(c)
                list_x.append(x)
                list_x.append(x+w)
                list_y.append(y)
                list_y.append(y+h)

        for stillball in balls:
            stillball.draw(frame1)
        rebound = 1

        if MovFlag:   #have detected motion
            t=20
            #bounding rectangle, the hand area
            x1=max(min(list_x)-t,0)
            x2=min(max(list_x)+t,640)
            y1=max(min(list_y)-t,0)
            y2=min(max(list_y)+t,480)
            
            #compare current frame with previous frames
            list_size=CircleAppend(list_size,(x2-x1)*(y2-y1),num)
            list_rectindex=CircleAppend(list_rectindex,[[x1,y1],[x2,y2]],num)
            
            index=list_size.index(max(list_size))
            if (x2-x1)*(y2-y1)>list_size[index]*0.6:   #use current frame if the size is greater than 0.6
                index=len(list_size)-1
            [x1,y1]=list_rectindex[index][0]
            [x2,y2]=list_rectindex[index][1]
            
            #detect hand again
            HandMov2=np.zeros(frame.shape)
            HandMov2[y1:y2,x1:x2,:]=BGR.Segment(cv2.GaussianBlur(frame[y1:y2,x1:x2,:], (11, 11), 1),parameter,threshold_h)
            #cv2.imshow('hand',HandMov2/255)
            
            hand_binary = cv2.threshold(HandMov2[:,:,0]+HandMov2[:,:,1]+HandMov2[:,:,2], 127, 255, cv2.THRESH_BINARY)[1]
            hand_binary=cv2.dilate(hand_binary, es, iterations=2)   #opening
            hand_binary=cv2.erode(hand_binary, es, iterations=2)
            image, cnts, hierarchy = cv2.findContours(hand_binary.astype(np.uint8), cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
            
            LargestHull=None
            temp=0
            for c in cnts:  #find contours of hand
                size=cv2.contourArea(c)
                if size > 500:
                    if size>temp:
                        temp=size
                        LargestHull=c
                    if MovFlag>1:
                        hulls =  np.concatenate((hulls,c))
                    else:   #detect movement, initailize
                        hulls=c
                        MovFlag=2
                    cv2.drawContours(frame1,c,-1,(255,0,0),3)

            #convexhull
            convexHull=cv2.convexHull(hulls)  #height*1*width
            list_ployindex=CircleAppend(list_ployindex,convexHull,num)
            convexHull=list_ployindex[index]
            
            if temp:    #find fingertip candidates -> try to find fingertip direction and gesture
                FingerTipCands=FindCur(LargestHull,15,0.3,0.93)  #20 0.3 0.94 #0.4 0.95
                FingerTipCands=np.squeeze(FingerTipCands)
                FingerTipCands=ArrayUnion(FingerTipCands,convexHull)

                if FingerTipCands is not None: #if we find fingertip candidates
                    for i in range(FingerTipCands.shape[0]):
                        if FingerTipCands.shape[0]>1:
                            cv2.circle(frame1, tuple(FingerTipCands[i,:]), 4, [0,0,255], -1)
                        else:
                            cv2.circle(frame1, tuple(FingerTipCands[0,:]), 4, [0,0,255], -1)
                    #find fingertip histogram
                    Histo=FingerTipHisto(FingerTipCands,[(x1+x2)/2,(y1+y2)/2])
                    if sum(Histo)>4:
                        list_FingerTipHisto=CircleAppend(list_FingerTipHisto,Histo,num)
                    #Histo=sum(list_FingerTipHisto)
                    #print(Histo)
                    
            #recognize gesture
            Gesture=GestureReg(list_FingerTipHisto)
            print(Gesture)
            
            Direction=FingerTipDir(list_FingerTipHisto,Direction)
            #find fingertip
            FingerTip=FindFingerTip(np.squeeze(hulls),[(x1+x2)/2,(y1+y2)/2],Direction)  #find finger from all hulls
            print(FingerTip)
            if FingerTip is not None:
                cv2.circle(frame1, tuple(FingerTip), 4, [255,255,0], -1)
                if Gesture == 1:
                    pre_px = FingerTip[0]
                    pre_py = FingerTip[1]
                    rebound = 0
                if Gesture == 2:
                    cv2.circle(frame2, tuple(FingerTip), 4, [0,0,255], -1)
                    pre_px = FingerTip[0]
                    pre_py = FingerTip[1]
                    rebound = 2
            cv2.rectangle(frame1, (x1, y1), (x2, y2), (0, 255, 0), 2)
        else:   #still
            if x1:  #after motion detected
                if FingerTipCands is not None: #if we find fingertip points
                    for i in range(FingerTipCands.shape[0]):
                        if FingerTipCands.shape[0]>1:
                            cv2.circle(frame1, tuple(FingerTipCands[i,:]), 4, [0,0,255], -1)
                        else:
                            cv2.circle(frame1, tuple(FingerTipCands[0,:]), 4, [0,0,255], -1)
                if FingerTip is not None:
                    cv2.circle(frame1, tuple(FingerTip), 4, [255,255,0], -1)
                    if Gesture == 1:
                        pre_px = FingerTip[0]
                        pre_py = FingerTip[1]
                        rebound = 0
                    if Gesture == 2:
                        pre_px = FingerTip[0]
                        pre_py = FingerTip[1]
                        rebound = 2
                cv2.rectangle(frame1, (x1, y1), (x2, y2), (0, 255, 0), 2)


        judgeBall = ballnum
        for stillball in balls:
            if stillball.existence == False:
                judgeBall -= 1

        paddle.draw(frame1, pre_px, pre_py)

        [hit, hit_ball] = ball.draw(frame1, ori_speed+3*(ballnum-judgeBall), rebound, paddle)

        hitgold = 0
        for stillball in balls:
            h = stillball.drawgold(frame1, paddle, rebound)
            if h == True:
                hitgold += 1

        font = cv2.FONT_HERSHEY_SIMPLEX

        if judgeBall == 0:
            time.sleep(1)
            cv2.putText(frame1, 'Congratulate, You Win!', (120, int(frameheight/2)), font, 1.2, (255, 255, 150), 5)

        if ball.hit_bottom == True or timer == 0:
            cv2.putText(frame1, 'Sorry, You Lose!', (150, int(frameheight/2)), font, 1.2, (0, 0, 255), 5)
            time.sleep(4)

        if hit == True:
            energy = energy - 20
        energy = energy + 5 * hitgold
        if (energy + 1*(ballnum-judgeBall)) >= 100:
            energy = 100 - 1*(ballnum-judgeBall)
        cv2.putText(frame1, 'Player Energy: %s' %(energy+1*(ballnum-judgeBall)), (10, 30), font, 0.8, (255, 255, 200), 2)
        cv2.putText(frame1, 'Reamain Balls: %s' %judgeBall, (275, 30), font, 0.8, (255, 255, 200), 2)

        if energy == 0 and judgeBall !=0:
            time.sleep(1)
            cv2.putText(frame1, 'Sorry, energy runs out and  you Lose!', (110, int(frameheight / 2)), font, 1.2, (0, 0, 255), 5)

        timer = timer - 1
        if timer <=0 :
            timer = 0
        cv2.putText(frame1, 'Timer: %s' %timer, (520, 30), font, 0.8, (255, 255, 200), 2)
        cv2.imshow('My Camera',frame1)
        cv2.imshow('pattern',frame2)
        out.write(frame1)
        if cv2.waitKey(1) &0xFF == ord('q'):
            break
    else:
	    break
    frame_pre=frame

cap.release()
out.release()
cv2.destroyAllWindows()