if exist('Puncte','var') == 0
    %% The angles
    delta_z=57*pi/180;
    np_z=640;
    delta_x=43*pi/180;
    np_x=480;
    d_delta_z=-delta_z/2:delta_z/(np_z-1):delta_z/2;
    d_delta_x=-delta_x/2:delta_x/(np_x-1):delta_x/2;

    %% The data base of mesurements
    poza_1(:,:,1)=scene03_000deg;
    poza_1(:,:,2)=scene03_030deg;
    poza_1(:,:,3)=scene03_060deg;
    poza_1(:,:,4)=scene03_090deg;
    poza_1(:,:,5)=scene03_120deg;
    poza_1(:,:,6)=scene03_150deg;
    poza_1(:,:,7)=scene03_180deg;
    poza_1(:,:,8)=scene03_210deg;
    poza_1(:,:,9)=scene03_240deg;
    poza_1(:,:,10)=scene03_270deg;
    poza_1(:,:,11)=scene03_300deg;
    poza_1(:,:,12)=scene03_330deg;
    beta=[0,30,60,90,120,150,180,210,240,270,300,330]*pi/180;

    %% Filtering the measurements
    for k=1:12 %length(poza_1(1,1,:))
        poza=poza_1(:,:,k);
        poza=double(poza);
        poza(poza==0)=NaN;
        poza = medfilt2(poza,[2 2]);  
        [Dx,Dy]=gradient(poza);
        gradV_abs=sqrt(Dx.^2+Dy.^2);
        poza(gradV_abs > 200) = NaN;
        poza_1(:,:,k)=poza;
    end
end
%% The posiions computation
Ry=[cos(-pi),0,sin(-pi);0,1,0;-sin(-pi),0,cos(-pi)];
PPuncte=[];
nk=12; %length(poza_1(1,1,:));
figure
for k=2:3
    Puncte=[];
    poza=poza_1(:,:,k);
    for i=1:5:np_x
        for j=1:5:np_z
            y=poza(i,j);
            if isnan(y)
            else
                x=y*tan(d_delta_x(1,i));
                z=y*tan(d_delta_z(1,j));
                punct=[z;y;x];
                Puncte=[Puncte,punct];
            end
        end
    end  
  Puncte=Ry*Puncte;
  Puncte=[cos(beta(1,k)),-sin(beta(1,k)),0;sin(beta(1,k)),cos(beta(1,k)),0;0,0,1]*Puncte;
  PPuncte=[PPuncte,Puncte];
  if mod(k,3) == 0
      tmpColor = [1.0,0.4,0.4];
  elseif mod(k,3) == 1
      tmpColor = [1.0,1.0,0.5];
  else
      tmpColor = [0.5,0.3,0.5];
  end
  if k == 2
      p2 = Puncte;
  elseif k == 3
      p3 = Puncte;
  end
      plot3(Puncte(1,1:1:end),Puncte(2,1:1:end),Puncte(3,1:1:end),'.','Color', tmpColor)
  hold on
end


%% The graphical representations of the points clouds
%figure  
%plot3(PPuncte(1,1:1:end),PPuncte(2,1:1:end),PPuncte(3,1:1:end),'.')

xlabel 'X'
ylabel 'Y'
zlabel 'Z'
grid
%view(-13,36)
%colormap('gray')

%% Run ICP (partial data)
tmpColor1 = [1.0,0.4,0.4];
tmpColor2 = [1.0,1.0,0.5];
tmpColor3 = [0.5,0.3,0.5];
tmpColor4 = [0.2,0.7,0.2];
% Partial model point cloud
Mp = p2; %= M(:,Y>=0);

% Boundary of partial model point cloud
%b = (abs(X(Y>=0)) == 2) | (Y(Y>=0) == min(Y(Y>=0))) | (Y(Y>=0) == max(Y(Y>=0)));
%bound = find(b);

% Partial data point cloud
Dp = p3; %D(:,X>=0);

%[Ricp Ticp ER t] = icp(Mp, Dp, 8, 'EdgeRejection', true, 'Boundary', bound, 'Matching', 'kDtree');
[Ricp Ticp] = icp(Mp, Dp, 2, 'EdgeRejection', false, 'Extrapolation', true);

% Transform data-matrix using ICP result
Dicp = Ricp * Dp + repmat(Ticp, 1, size(Dp,2));

% Plot model points blue and transformed points red

figure;

ha(1) = subplot(1,2,1);
hold on
plot3(Mp(1,:),Mp(2,:),Mp(3,:),'.','Color',tmpColor1);
plot3(Dp(1,:),Dp(2,:),Dp(3,:),'.','Color',tmpColor2);
%plot3(p2(1,:),p2(2,:),p2(3,:),'yo',p3(1,:),p3(2,:),p3(3,:),'r.');
axis([-1000 0 0 600 -200 400]);
xlabel('x'); ylabel('y'); zlabel('z');
title('Red: z=sin(x)*cos(y), blue: transformed point cloud');
hold off

% Plot the results
ha(2) = subplot(1,2,2);
hold on
%plot3(Puncte(1,1:1:end),Puncte(2,1:1:end),Puncte(3,1:1:end),'.','Color', tmpColor);
%plot3(Mp(1,:),Mp(2,:),Mp(3,:),'ko',Dicp(1,:),Dicp(2,:),Dicp(3,:),'r.');
plot3(Mp(1,:),Mp(2,:),Mp(3,:),'.','Color',tmpColor3);
plot3(Dicp(1,:),Dicp(2,:),Dicp(3,:),'.','Color',tmpColor4);
%plot3(p21,p22,p23,'ko',p31,p32,p33,'r.');
axis([-1000 0 0 600 -200 400]);
xlabel('x'); ylabel('y'); zlabel('z');
title('ICP result');
hold off
linkprop(ha, {'CameraPosition','CameraTarget','CameraUpVector'});
%linkaxes(ha, 'x'); 
%clear ha;

% Plot RMS curve
%subplot(2,2,[3 4]);
%plot(0:50,ER,'--x');
%xlabel('iteration#');
%ylabel('d_{RMS}');
%legend('partial overlap');
%title(['Total elapsed time: ' num2str(t(end),2) ' s']);
