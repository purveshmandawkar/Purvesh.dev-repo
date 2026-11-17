clc;
clear;
close("all");

num_BS = 7;              // Number of base stations
cell_radius = 500;       // Radius of each cell (meters)
num_users = 50;          // Number of users

// Base station coordinates (hexagonal layout)

BS = [
     0    0;
     866  0;
    -866  0;
     433  750;
    -433  750;
     433 -750;
    -433 -750
];

// Generate random users

users = zeros(num_users, 2);

for i = 1:num_users
    users(i,1) = rand() * 3000 - 1500;
    users(i,2) = rand() * 3000 - 1500;
end

// Plot cellular network

clf();
drawlater();

theta = linspace(0, 2 * %pi, 100);

// Set plot limits

plot2d([], [], rect = [-1500, -1500, 1500, 1500]);

// Draw cells and base stations

for i = 1:num_BS

    // Coordinates of circular cell

    x = BS(i,1) + cell_radius * cos(theta);
    y = BS(i,2) + cell_radius * sin(theta);

    // Draw cell boundary

    plot(x, y, "b");

    // Draw base station as red triangle

    plot(BS(i,1), BS(i,2), "r^");

    // Label base station

    xstring(BS(i,1) + 20, BS(i,2) + 20, "BS" + string(i));

end

// Plot mobile users

plot(users(:,1), users(:,2), "go");

// Associate each user with the nearest base station

for i = 1:num_users

    // Calculate distance from current user to every base station

    d = sqrt((BS(:,1) - users(i,1)).^2 + ...
             (BS(:,2) - users(i,2)).^2);

    // Find nearest base station

    [mindist, index] = min(d);

    // Draw connection between user and nearest BS

    x = [users(i,1), BS(index,1)];
    y = [users(i,2), BS(index,2)];

    plot(x, y, "k--");

end

// Labels and title

xlabel("X position (m)");
ylabel("Y position (m)");
title("Simulation of Cellular Network");

drawnow();
