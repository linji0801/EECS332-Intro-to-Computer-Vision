from tkinter import *
import time
import random
import cv2


# import final_project

class Ball:
    def __init__(self, x, y, color, radius, ori_speed, stillBalls, ballnum, width, height):
        self.x = x
        self.y = y
        self.color = color
        self.radius = radius
        self.dx = ori_speed
        self.dy = ori_speed
        self.hit_bottom = False
        self.width = width
        self.height = height
        self.num = 0
        # self.canvas.bind_all('<Button-1>', self.turn_sb)
        self.balls = stillBalls
        self.ballnum = ballnum
        self.p_x = 0
        self.p_y = 0
        self.paddle_existence = True

    '''
    def turn_sb(self):
        start = [-3, -2, -1, 1, 2, 3]
        random.shuffle(start)
        self.dx = start[0]
        self.dy = 3
    '''
    def get_pos(self):
        pos = []
        pos.append(self.x - self.radius)
        pos.append(self.y - self.radius)
        pos.append(self.x + self.radius)
        pos.append(self.y + self.radius)
        return pos

    def hit_paddle(self, pos, paddle):
        pos_paddle = paddle.get_pos()
        if pos[3] <= pos_paddle[3] and pos[3] >= pos_paddle[1]:
            if pos[2] >= pos_paddle[0] and pos[0] <= pos_paddle[2]:
                return True
        return False

    def hit_still_ball(self, pos):
        for i in range(0, self.ballnum):
            if self.balls[i].existence == True:
                pos_ball = self.balls[i].pos_ball
                if pos[3] >= pos_ball[1] and pos[2] >= pos_ball[0] and pos[0] <= pos_ball[0] and pos[1] <= pos_ball[
                    1] or pos[3] >= pos_ball[1] and pos[0] <= pos_ball[2] and pos[1] <= pos_ball[1] and pos[2] >= \
                        pos_ball[2] or pos[1] <= pos_ball[3] and pos[2] >= pos_ball[0] and pos[0] <= pos_ball[0] and \
                                pos[3] >= pos_ball[3] or pos[1] <= pos_ball[3] and pos[0] <= pos_ball[2] and pos[2] >= \
                        pos_ball[2] and pos[3] >= pos_ball[3]:
                    return i
        return -1

    def draw(self, canvas, speed, rebound, paddle): #, new_paddle, paddle_x, paddle_y):
        cv2.circle (canvas, (self.x,self.y), self.radius, self.color, -1)
        pos = self.get_pos()
        ret = False
        '''
        if new_paddle == True:
            self.paddle_existence = True
        if self.paddle_existence == True:
            self.paddle.draw((paddle_x - self.p_x), (paddle_y - self.p_y))
            self.p_x = paddle_x
            self.p_y = paddle_y
            pos_paddle = self.canvas.coords(self.paddle.id)
            if self.hit_paddle(pos, pos_paddle) == True:
                self.y = -3
                self.num += 1
                # self.paddle.removepaddle()
                # self.paddle_existence = False
        '''
        if pos[0] <= 0:
            self.dx = speed
        if pos[2] >= self.width:
            self.dx = (-1)*speed
        if pos[1] <= 0:
            self.dy = speed
        if pos[3] >= self.height:
            self.hit_bottom = True
            self.dy = (-1)*speed
        if rebound != 0:
            if self.hit_paddle(pos, paddle) == True:
                self.dy = (-1)*speed
                ret = True
        self.x += self.dx
        self.y += self.dy
        hit_ball = self.hit_still_ball(pos)
        if  hit_ball != -1:
            self.balls[hit_ball].removeball()
        return ret, hit_ball


class StillBall:
    def __init__(self, color, radius, x, y, speed, height):
        self.color = color
        self.radius = radius
        self.x = x
        self.y = y
        pos = []
        pos.append(self.x - self.radius)
        pos.append(self.y - self.radius)
        pos.append(self.x + self.radius)
        pos.append(self.y + self.radius)
        self.pos_ball = pos
        self.existence = True
        self.gold = False
        self.dy = speed
        self.height = height
    def draw(self, canvas):
        if self.existence == True:
            cv2.circle(canvas, (self.x,self.y), self.radius, self.color, -1)
    def gold_hit_paddle(self,pos, paddle):
        pos_paddle = paddle.get_pos()
        if pos[3] <= pos_paddle[3] and pos[3] >= pos_paddle[1]:
            if pos[2] >= pos_paddle[0] and pos[0] <= pos_paddle[2]:
                return True
        return False
    def drawgold(self, canvas, paddle, rebound):
        if self.gold == True:
            #cv2.ellipse(canvas, )
            cv2.circle(canvas, (self.x, self.y), self.radius-10, [0,255,255], -1)
            pos = []
            pos.append(self.x - (self.radius - 10))
            pos.append(self.y - (self.radius - 10))
            pos.append(self.x + (self.radius - 10))
            pos.append(self.y + (self.radius - 10))
            if self.y > self.height:
                self.gold = False
            if rebound != 0:
                if self.gold_hit_paddle(pos, paddle):
                    self.gold = False
                    return True
            self.y += self.dy
        return False
    def removeball(self):
        self.existence = False
        r = random.randrange(3)
        if r == 1:
            self.gold = True




class Paddle:
    def __init__(self, color, ori_x, ori_y, halflength, halfheight):
        self.color = color
        self.x = ori_x
        self.y = ori_y
        self.halflength = halflength
        self.halfheight = halfheight

    def get_pos(self):
        pos = []
        pos.append(self.x - self.halflength)
        pos.append(self.y - self.halfheight)
        pos.append(self.x + self.halflength)
        pos.append(self.y + self.halfheight)
        return pos

    def draw(self, canvas, x, y):
        self.x = x
        self.y = y
        pos = self.get_pos()
        cv2.rectangle(canvas, (pos[0], pos[1]), (pos[2], pos[3]), self.color, -1)

'''
class Paddle:
    def __init__(self, canvas, color, length):
        self.canvas = canvas
        self.id = canvas.create_rectangle(0, 0, length, 5, fill=color)
        self.canvas_width = self.canvas.winfo_width()
        self.canvas.bind_all('<KeyPress-Left>', self.turn_left)
        self.canvas.bind_all('<KeyPress-Right>', self.turn_right)
    def draw(self, x, y):
        self.canvas.move(self.id, x, y)

        pos = self.canvas.coords(self.id)
        if pos[0] <= 0:
            self.x = 0
        if pos[2] >= self.canvas_width:
            self.x = 0

    def turn_left(self, evt):
        self.x = -4

    def turn_right(self, evt):
        self.x = 4

    def removepaddle(self):
        self.canvas.delete(self.id)

tk = Tk()
tk.title("Game")
tk.resizable(0, 0)
tk.wm_attributes('-topmost', 1)
canvas = Canvas(tk, width=500, height=400, bd=0, highlightthickness=0)
canvas.pack()
tk.update()
bg = PhotoImage(file="/Users/linji0801/Documents/eecs332/finalproject/123.gif")
for x in range(0, 5):
    for y in range(0, 4):
        canvas.create_image(x * 100, y * 100, image=bg, anchor='nw')

length = 300
pos_x_paddle = 150
pos_y_paddle = 330
ballnum = 6

balls = []
for i in range(0, ballnum):
    x = random.randrange(canvas.winfo_width())
    y = random.randrange(pos_y_paddle)
    balls.append(StillBall(canvas, 'blue', x, y))

paddle = Paddle(canvas, 'white', length)
ball = Ball(canvas, paddle, 'red', balls, ballnum)

while 1:
    
    new_paddle = False
    if final_project.FingerTip is not None:
        new_paddle = True
    ball.draw(new_paddle, final_project.FingerTip[0], final_project.FingerTip[1])
    
    ball.draw(True, pos_x_paddle, pos_y_paddle)
    judgeBall = True
    for stillball in balls:
        if stillball.existence == True:
            judgeBall = False
            break
    if ball.hit_bottom == True:
        time.sleep(1)
        canvas.create_text(250, 150, text="You Lose!", font=("Courier", 30), fill='red')
    if judgeBall == True:
        time.sleep(1)
        canvas.create_text(250, 150, text="Congratulate, You Win!", font=("Courier", 30), fill='yellow')
        string = "Paddle Times %s "
        canvas.create_text(250, 180, text=string % ball.num, font=("Courier", 20), fill="yellow")
    tk.update_idletasks()
    tk.update()
    time.sleep(0.01)
'''