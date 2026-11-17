clc;
clear;

//parameter
Hm=2;
Hb=40;
Pt=0.020;
Gt=1;
C=0;

//Mobile antenna height correction factor
aHm= (3.2*log10(11.75*Hm))^2-4.97;



// Hata model constants 
A=69.55 +26.16*log10(6000)-13.82*log10(Hb)-aHm;
B=44.9-6.55*log10(Hb);

//distandce between transmitter and receiver 
d=8:1:15;

//path loss calculation
p1=A+B*log10(d)+C;

//display results
disp(p1);
disp("a(Hm)=",aHm);

disp("A=",A);
disp("B=",B);

//plot
xlabel("Distance between transmitter and receiver");
ylabel("Pathloss");
title("Pathloss vs distance");

plot(d,p1);
xgrid();









