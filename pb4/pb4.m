clc
clear
file = "scieTronc.mp3";
getNoise(file)

function noise = getNoise(file)

load('lowpass.mat')
[y, Fs] = audioread(file);

Ts = 1/Fs;
duration = (length(y)-1)*Ts;
t = 0:Ts:duration;
N = length(t);

Ta = 5E-2;
K = round(Ta*Fs);
if(mod(K,2) ~= 0)
    K = K + 1;
end
P = zeros(1,N);
for i = K+1:N-K
    x = mean(y(i-K:i+K).^2);
    P(i) = x;
end

noiseTrigger = 3.16E-5;
infos = zeros(ceil(duration/0.5),3);
status = 0;

if P(1) > noiseTrigger
    status = 1;
    infos(1,1) = 1;
end
noiseDuration = 0;
n = 1;
for i = 1:N
    if P(i) < noiseTrigger
        if status == 1
            if noiseDuration*Ts >= 1 && (n == 1 || infos(n-1, 1) == 0)
                infos(n, 1) = status;
                infos(n, 2) = i-noiseDuration;
                infos(n, 3) = i;
                n = n + 1;
            else
                infos(max(1,n-1), 3) = infos(max(1,n-1), 3) + noiseDuration;
            end
            noiseDuration = 0;
            status = 0;
        end
    else
        if status == 0
            if noiseDuration*Ts >= 0.5 && (n == 1 || infos(n-1, 1) == 1)
                infos(n, 1) = status;
                infos(n, 2) = i-noiseDuration;
                infos(n, 3) = i;
                n = n + 1;
            else
                infos(max(1,n-1), 3) = infos(max(1,n-1), 3) + noiseDuration;
            end
            noiseDuration = 0;
            status = 1;
        end
    end
    noiseDuration = noiseDuration + 1;
end
infos(n, 3) = noiseDuration;

noiseSquare = zeros(1,N);

noiseIndices = infos(find(infos(:,1) == 1), 2:3);
Py = mean(y(noiseIndices(:,1):noiseIndices(:,2)).^2);

for i = 1:n
    if infos(i,1) == 1
        aigus = filter(h1,1,y(infos(i,2):infos(i,3)));
        Ppenible = mean(aigus.^2);
        if(Ppenible/Py > 0.2)
            noiseSquare(infos(i,2):infos(i,3)) = 1;
        end
    end
end

figure
subplot(2,1,1);
plot(t,y);
title("Signal" + file)
xlabel("Temps en secondes")
ylabel("Amplitude")

subplot(2,1,2);
plot(t,noiseSquare);
title("Est un son pénible")
xlabel("Temps en secondes")
ylabel("pénible: 1, sinon: 0")

end