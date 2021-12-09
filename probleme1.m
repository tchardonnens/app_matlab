clear
clc

nombrePlotsX = 4;
nombrePlotsY = 3;

f0 = 1000; %Fréquence du sinus
fe = 16000; %Fréquence d'échantillonage
A=2;
T0 = 1/f0;
Te = 1/fe;
D = 2;
t = (0:Te:D);
nt0 = ceil(5*(T0/Te)); % nbre d'échantillons
K = ((D/T0)-1)/2;

figure;
subplot(nombrePlotsX,nombrePlotsY,1);
x1 = A*sin(2*pi*f0*t);
analyze(t, x1, fe, nt0);

x2 = abs(x1);
subplot(nombrePlotsX,nombrePlotsY,4);
analyze(t, x2, fe, nt0);

x3 = [];
modulo = mod(t,T0);
for i = 1:length(modulo)
    index = modulo(1,i);
    if index<(T0/2) && index>=0
        x3 = [x3, 2];
    else
        x3 = [x3, 0.5];
    end
end
subplot(nombrePlotsX,nombrePlotsY,7);
analyze(t, x3, fe, nt0);
% les superposer
% max d'intercollération 
% autocorrélation

nt0 = ceil(5*(T0/Te));
B=1.80; % à corriger
%f0 = 1/80^(-3);
f0 = 1000;
T0 = 1/f0;
nt0 = ceil(5*(T0/Te));
phi = pi/3;
y = B*sin(2*pi*f0*t+phi);
subplot(nombrePlotsX,nombrePlotsY,10);
analyze(t, y, fe, nt0);

% Autocorrélation 
Cx1 = intercorellation(t, x1, x1, nt0, Te, 2);
Cx2y = intercorellation(t, x2, y, nt0, Te, 5);
Cx3y = intercorellation(t, x3, y, nt0, Te, 8);
Cx1y = intercorellation(t, x1, y, nt0, Te, 11);

%Sample the signal, sound it and plot it.

marteaufile = 'MarteauPiqueur01.mp3';
jardin1file = 'Jardin01.mp3';
jardin2file = 'Jardin02.mp3';
ville1file = 'Ville01.mp3';

disp(puissanceinstant(fileToSignal(fe, marteaufile), nt0, K))
subplot(nombrePlotsX,nombrePlotsY,3)
plot(getTime(fe, marteaufile),fileToSignal(fe, marteaufile))
title('MarteauPiqueur01.mp3 : Temporal signal variation')
xlabel('time(s)')

disp(puissanceinstant(fileToSignal(fe, jardin1file), nt0, K))
subplot(nombrePlotsX,nombrePlotsY,6)
plot(getTime(fe, jardin1file),fileToSignal(fe, jardin1file))
title('Jardin01.mp3 : Temporal signal variation')
xlabel('time(s)')

disp(puissanceinstant(fileToSignal(fe, jardin2file), nt0, K))
subplot(nombrePlotsX,nombrePlotsY,9)
plot(getTime(fe, jardin2file),fileToSignal(fe, jardin2file))
title('Jardin02.mp3 : Temporal signal variation')
xlabel('time(s)')

disp(puissanceinstant(fileToSignal(fe, ville1file), nt0, K))
subplot(nombrePlotsX,nombrePlotsY,12)
plot(getTime(fe, ville1file),fileToSignal(fe, ville1file))
title('Ville01.mp3 : Temporal signal variation')
xlabel('time(s)')

function time = getTime(Fs, file)
[y,Fs]=audioread(file);
n=length(y);
time=(0:(n-1))/Fs;
end

function signal = fileToSignal(Fs, file)
[y,Fs]=audioread(file);
signal = y;
end

function Cxy = intercorellation(t, x, y, nt0, T0, emplacement)
Cxy = [];
n = length(x);
y1 = [y,zeros(1,n-1)];
for i=1:n
    Cxy = [Cxy, (1/n)*sum(x.*y1(i:n+i-1))];
end
subplot(4, 3, emplacement)
plot(t(1:nt0),x(1:nt0), 'b');
hold on
plot(t(1:nt0),y(1:nt0), 'g');
hold on
plot(t(1:nt0),Cxy(1:nt0), 'r');
xlabel('seconds');
title('Intercorrelation in the time domain');
zoom xon;
end

function P = puissanceinstant(x,nt0,K)
P=1;
for n=K+1:nt0-K
    P = (1/(2*K+1)*sum(x(n-K:n+K).^2));
end
end

function f = analyze(t, x, fe, nt0)
plot(t(1:nt0),x(1:nt0));
xlabel('seconds');
title('Signal in the time domain - 5 periods');
zoom xon;
disp("Fréquence échantillonage : "+ fe);
% valeur moyenne
% valeur_moyenne = (1/n2)*sum(x);
Vm = mean(x(1:nt0));
disp("Vm = "+ Vm)
% puissance moyenne
Pm = mean(x(1:nt0).^2);
Pdbm = 10*log10((Pm/10^(-3)));
disp("Pm = "+ Pm +" W") % en W
disp("Pdbm = "+ Pdbm +" dBm") % en dBm
% valeur efficace
Aeff = sqrt(Pm);
disp("Aeff = "+ Aeff+ " W^(1/2)")
disp("------------------------------------")
end