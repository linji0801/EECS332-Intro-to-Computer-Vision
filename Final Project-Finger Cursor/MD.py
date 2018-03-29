import cv2
import numpy as np


def MotionDect(frame,frame_pre,es):
    if frame_pre is None:
        frame_pre = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        frame_pre = cv2.GaussianBlur(frame_pre, (17, 17), 1)
    else:
        frame_pre = cv2.cvtColor(frame_pre, cv2.COLOR_BGR2GRAY)
        frame_pre = cv2.GaussianBlur(frame_pre, (17, 17), 1)
    gray_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    gray_frame = cv2.GaussianBlur(gray_frame, (17, 17), 1)
    diff = cv2.absdiff(frame_pre, gray_frame)
    diff = cv2.threshold(diff, 25, 255, cv2.THRESH_BINARY)[1]
    diff = cv2.dilate(diff, es, iterations=3)

    return diff