clc
close all
clear all

I = diag([1 2 3]); %Inertia matrix

w0 = [pi/10 pi/6 pi/8]'; %Initial body-frame angular velocity
q0 = [0 0 0 1]'; %Initial attitude quaternion (body from to inertial frame rotation)
x0 = [q0; w0; 0; 0; 0]; %Initial state vector for ODE45 [q; w; r]

dt = .1;
end_time = 5*60;

% ----- Input torques - try all three! ----- %
%tau_hist = zeros(3,1+end_time/dt);
tau_hist = [0*ones(1,1+end_time/dt); .1*ones(1,1+end_time/dt); 0*ones(1,1+end_time/dt)];
%tau_hist = [.01*cos(2*pi*(0:dt:end_time)/end_time); .01*sin(2*pi*(0:dt:end_time)/end_time); -.01*cos(2*pi*(0:dt:end_time)/end_time)];


%Standard ODE45 Solution
soln = ode45(@(t,x) gyrostatODE(I, @(t,x) constant_torque([0 0 0]',t,x), @(t,x) sampled_torque(tau_hist, dt, t, x), t, x), [0 end_time], x0);
xhist = deval(soln, 0:dt:end_time);
qhist1 = xhist(1:4,:);
whist1 = xhist(5:7,:);

%My Solution
[t, qhist2, whist2] = ForcedRB(I, q0, w0, tau_hist, dt, [0 end_time]);

%Plot Input Torques
figure(1)
subplot(3,1,1);
plot(t, tau_hist(1,:));
title('Input Torque Components');
subplot(3,1,2);
plot(t, tau_hist(2,:));
subplot(3,1,3);
plot(t, tau_hist(3,:));

%Plot Quaternions
figure(2)
subplot(4,1,1);
plot(t, qhist1(1,:));
hold on
plot(t, qhist2(1,:), 'g');
title('Attitude Quaternion Components');
legend('ODE45', 'Variational');
subplot(4,1,2);
plot(t, qhist1(2,:));
hold on
plot(t, qhist2(2,:), 'g');
subplot(4,1,3);
plot(t, qhist1(3,:));
hold on
plot(t, qhist2(3,:), 'g');
subplot(4,1,4);
plot(t, qhist1(4,:));
hold on
plot(t, qhist2(4,:), 'g');

%Plot Omega
figure(3)
subplot(3,1,1);
plot(t, whist1(1,:));
hold on
plot(t, whist2(1,:), 'g');
title('Body Angular Velocity Components');
legend('ODE45', 'Variational');
subplot(3,1,2);
plot(t, whist1(2,:));
hold on
plot(t, whist2(2,:), 'g');
subplot(3,1,3);
plot(t, whist1(3,:));
hold on
plot(t, whist2(3,:), 'g');

%Plot Inertial Frame Angular Momentum
for k = 1:length(whist1)
    hhist1(:,k) = qrot(qhist1(:,k), I*whist1(:,k));
    hhist2(:,k) = qrot(qhist2(:,k), I*whist2(:,k));
end
figure(4)
subplot(3,1,1);
plot(t, hhist1(1,:));
hold on
plot(t, hhist2(1,:), 'g');
title('Inertial Angular Momentum Components');
legend('ODE45', 'Variational');
subplot(3,1,2);
plot(t, hhist1(2,:));
hold on
plot(t, hhist2(2,:), 'g');
subplot(3,1,3);
plot(t, hhist1(3,:));
hold on
plot(t, hhist2(3,:), 'g');

%Plot Energy
for k = 1:length(whist1)
    E1(k) = .5*whist1(:,k)'*I*whist1(:,k);
    E2(k) = .5*whist2(:,k)'*I*whist2(:,k);
end
figure(5)
plot(t, E1);
hold on
plot(t, E2, 'g');
title('Energy');
legend('ODE45', 'Variational');
