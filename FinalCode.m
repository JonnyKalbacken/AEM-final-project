%	Example 1.3-1 Paper Airplane Flight Path
%	Copyright 2005 by Robert Stengel
%	August 23, 2005
    clc;
    clear;
	global CL CD S m g rho	
	S		=	0.017;			% Reference Area, m^2
	AR		=	0.86;			% Wing Aspect Ratio
	e		=	0.9;			% Oswald Efficiency Factor;
	m		=	0.003;			% Mass, kg
	g		=	9.8;			% Gravitational acceleration, m/s^2
	rho		=	1.225;			% Air density at Sea Level, kg/m^3	
	CLa		=	3.141592 * AR/(1 + sqrt(1 + (AR / 2)^2));
							% Lift-Coefficient Slope, per rad
	CDo		=	0.02;			% Zero-Lift Drag Coefficient
	epsilon	=	1 / (3.141592 * e * AR);% Induced Drag Factor	
	CL		=	sqrt(CDo / epsilon);	% CL for Maximum Lift/Drag Ratio
	CD		=	CDo + epsilon * CL^2;	% Corresponding CD
	LDmax	=	CL / CD;			% Maximum Lift/Drag Ratio
	Gam		=	-atan(1 / LDmax);	% Corresponding Flight Path Angle, rad
	V		=	sqrt(2 * m * g /(rho * S * (CL * cos(Gam) - CD * sin(Gam))));
							% Corresponding Velocity, m/s
	Alpha	=	CL / CLa;			% Corresponding Angle of Attack, rad
  
    %% 2
	
%	a) Equilibrium Glide at Maximum Lift/Drag Ratio
    Vlower = 2;             % Initial Lower V Value
    Vhigher = 7.5;          % Initial Higher V Value
    Vnominal = 3.55;        % Nominal V Value
    GammaLower = -0.5;      % Initial Lower Gamma Value
    GammaHigher = 0.4;      % Initial Higher Gamma Value
    GammaNominal = -0.18;   % Nominal Gamma Value
    H		=	2;			% Initial Height, m
	R		=	0;			% Initial Range, m
	to		=	0;			% Initial Time, sec
	tf		=	6;			% Final Time, sec
	tspan	=	[to tf];

	xoVL		=	[Vlower;GammaNominal;H;R];
    xoVH		=	[Vhigher;GammaNominal;H;R];
    xoVN		=	[Vnominal;GammaNominal;H;R];
    xoGL		=	[Vnominal;GammaLower;H;R];
    xoGH		=	[Vnominal;GammaHigher;H;R];
    xoGN		=	[Vnominal;GammaNominal;H;R];
    
	[taL,xaVL]	=	ode23('EqMotion',tspan,xoVL);
    [taH,xaVH]	=	ode23('EqMotion',tspan,xoVH);
    [taN,xaVN]	=	ode23('EqMotion',tspan,xoVN);
    [taL,xaGL]	=	ode23('EqMotion',tspan,xoGL);
    [taH,xaGH]	=	ode23('EqMotion',tspan,xoGH);
    [taN,xaGN]	=	ode23('EqMotion',tspan,xoGN);

	figure
    sgtitle('Height vs Range (Varied Velocity) and \gamma');
	subplot(2,1,1)
    hold on;
    plot(xaVH(:,4),xaVH(:,3), 'g')
    plot(xaVN(:,4),xaVN(:,3), 'b')
    plot(xaVL(:,4),xaVL(:,3), 'r')

    title('Height vs Range (Varied Velocity) (meters)');
	xlabel('Range'), ylabel('Height'), grid
    legend('IVelocity = 2 m/s', ...
        'IVelocity = 7.5 m/s',...
        'IVelocity = 3.55 m/s');
  
	subplot(2,1,2)
    hold on;
    plot(xaGH(:,4),xaGH(:,3), 'g')
    plot(xaGN(:,4),xaGN(:,3), 'b')
    plot(xaGL(:,4),xaGL(:,3), 'r')

    title('Height vs Range (Varied \gamma) (meters)');
    xlabel('Range'), ylabel('Height'), grid
    legend('I \gamma =  -0.5 rad', ...
        'I \gamma =  0.4 rad', ...
        'I \gamma =  -0.18 rad');
    %% 3, 4, & 5
figure;
Range100 = zeros(1,100);
RangeSum = zeros(1,100);
Height100 = zeros(1,100);
HeightSum = zeros(1,100);

Time100 = linspace(to, tf, 100);
for i = 1:100
    Vrand = Vlower + ((Vhigher - Vlower)*rand(1));
    Grand = GammaLower + ((GammaHigher - GammaLower)*rand(1));
    xRand = [Vrand;Grand;H;R];
    [ta,xRand] = ode23('EqMotion',Time100,xRand);
    
    Range100(1,i) = xRand(i,4);
    Height100(1,i) = xRand(i,3);
    for j = 1:100
        RangeSum(1,j) = RangeSum(1,j) + xRand(j,4);
        HeightSum(1,j) = HeightSum(1,j) + xRand(j,3);
    end
    plot(xRand(:,3), xRand(:,4));
    hold on;
    title({'Range vs Height', 'Random V_0 & \gamma_0 (Within Given Range of V & \gamma),' '(Height and Range swapped axis to show larger seperation)'});
    xlabel('Height'), ylabel('Range')
end

for i = 1:100
    RangeSum(1,i) = (RangeSum(1,i)/100);
    HeightSum(1,i) = (HeightSum(1,i)/100);
end

pcoeffRange = polyfit(Time100,RangeSum, 3);
pcoeffHeight = polyfit(Time100,HeightSum, 3);
RangePolyEq = @(x) pcoeffRange(1)*x.^3 + pcoeffRange(2)*x.^2 + ...
    pcoeffRange(3)*x + pcoeffRange(4);

DerivRangePolyEq = @(x) 3*pcoeffRange(1)*x.^2 + 2*pcoeffRange(2)*x + ...
    pcoeffRange(3);

HeightPolyEq = @(x) pcoeffHeight(1)*x.^3 + pcoeffHeight(2)*x.^2 + ...
    pcoeffHeight(3)*x + pcoeffHeight(4);

DerivHeightPolyEq = @(x) 3*pcoeffHeight(1)*x.^2 + 2*pcoeffHeight(2)*x + ...
    pcoeffHeight(3);

plot(Time100, RangePolyEq(Time100), 'r')
plot(Time100, HeightPolyEq(Time100), 'b')
figure;

sgtitle('Derivatives Range and Height vs Time (meters and seconds) ');
subplot(2,1,1)
hold on;
plot(Time100, DerivRangePolyEq(Time100), 'r')
title('Derivative Range vs Time');
xlabel('Time'), ylabel('Range')
subplot(2,1,2)
hold on;
plot(Time100, DerivHeightPolyEq(Time100), 'b')
title('Derivative Height vs Time');
xlabel('Time'), ylabel('Height')