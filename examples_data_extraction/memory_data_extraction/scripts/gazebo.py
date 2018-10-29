import rospy
from gazebo_msgs.srv import *
from gazebo_msgs.msg import *
import random
import math

def get_pos():
    arc = 50.0
    arc = arc / 180.0 * 3.14159
    radius = (random.random() / 2.8) + 0.55
    angle = (random.random() * arc) - (arc / 2)
    x = radius * math.cos(angle) - 0.05
    y = radius * math.sin(angle) - 0.19
    return (x, y)

def get_valid_pos():
    x = 0
    y = 0
    while ((x < 0.5) | (x > 0.9)):
        (x, y) = get_pos()
    return (x, y)
    

if __name__=='__main__':
    rospy.init_node('omni_im_study')
    while not rospy.is_shutdown():
        something = raw_input()
        (x, y) = get_valid_pos()
        rospy.wait_for_service('/gazebo/set_model_state')
        set_model_state = rospy.ServiceProxy('/gazebo/set_model_state', SetModelState)
        model_state = ModelState()
        model_state.model_name = 'ball'
        model_state.pose.position.x = x
        model_state.pose.position.y = y
        model_state.pose.position.z = 0.55
        model_state.pose.orientation.x = 0
        model_state.pose.orientation.y = 0
        model_state.pose.orientation.z = 0
        model_state.pose.orientation.w = 0
        model_state.twist.linear.x = 0.0
        model_state.twist.linear.y = 0
        model_state.twist.linear.z = 0
        model_state.twist.angular.x = 0.0
        model_state.twist.angular.y = 0
        model_state.twist.angular.z = 0.0
        model_state.reference_frame = 'world'
        set_model_state(model_state)
        rospy.loginfo("Coke can position set to %f, %f.", x, y)

