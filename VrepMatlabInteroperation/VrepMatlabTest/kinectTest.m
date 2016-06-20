close all
[err, kinect_depth] = vrep.simxGetObjectHandle(0, 'kinect_depth#0',...
    vrep.simx_opmode_oneshot_wait);
[retCode, res, depth] = ...
    vrep.simxGetVisionSensorDepthBuffer2(0,kinect_depth, vrep.simx_opmode_oneshot_wait);
[err, kinect_rgb] = vrep.simxGetObjectHandle(0, 'kinect_rgb#0',...
    vrep.simx_opmode_oneshot_wait);
[retCode, res, img1] = ...
    vrep.simxGetVisionSensorImage2(0,kinect_rgb, 0, vrep.simx_opmode_oneshot_wait);
figure()
mesh(double(depth))
figure()
image('CData',img1)