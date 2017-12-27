# GaitAuth
Implementation of Authentication Scheme using Gait Signals Captured from Accelerometer. The full paper is available at http://ieeexplore.ieee.org/abstract/document/7518029/ (free version: https://arxiv.org/abs/1602.03199).

# Prerequistite Library

1. libSVM (download link: https://www.csie.ntu.edu.tw/~cjlin/libsvm/)


# Usage
The main functions are located in mainAuthentication.m (for authentication scheme) and mainRecognition.m (for recognition scheme)


# Dataset
## IMPORTANT NOTE: The dataset is only used for academic or research purposes. The authors do not allow anyone to use this dataset for any commercial purposes.

The dataset is located in ``DATASET`` folder, which is collected according to the following configurations

## Configuration
* Device: Google Nexus One Mobile Phone (specs: http://en.wikipedia.org/wiki/Nexus_One)
* Platform: Android 2.3
* Physical sensors used: Accelerometer , Magnetometer
* Sampling rate: 27 Hz  with the configuration of SENSOR_DELAY_FASTEST in Android SDK
* Number of Participants: 38

Data in each walking session is recorded and saved in separate files which are named according to following pattern:
UserID_Gender_SessionID_[DeviceName]DataType_SessionOrder.txt
For example:
ID26_M_173358_[NexusOne]BMA 150 3-axis Accelerometer_10.txt
contains the raw acceleration data of user #26 which is male, recorded in the session #173358 using Nexus One mobile phone.

There are three types of data in this dataset:

1. BMA 150 3-axis Accelerometer: raw acceleration data containing the influence of gravity. Each line consists of 4 components, separated by a comma (,), including the timestamp, the x-dimensional value (a_x), y-dimensional value (a_y), and z-dimensional value (a_z), respectively. The values of x,y, z dimensions are in g unit (i.e. 1g = 9.8 m/s2).

2. Linear Acceleration Sensor: acceleration data in which the influence of gravity is completely removed. Each line consists of 4 components, separated by a comma (,), including the timestamp, the x-dimensional value (a_x), y-dimensional value (a_y), and z-dimensional value (a_z), respectively. The values of x,y, z dimensions are in g unit (i.e. 1g = 9.8 m/s2).

3. Rotation Matrix: contains 9 elements in the 3x3 rotation matrix as presented in the paper.





# Further Information
For any inquiries, bugs, and assistance regarding using the code, please contact Thang Hoang (hoangmin@oregonstate.edu).
