Config = {
    -- Teleport and exit markers
    teleportMarker = {
        pos = {x = 2500.97754, y = -1667.07861, z = 13.35529},
        size = 1.5,
        color = {255, 255, 0, 150}
    },
    exitMarker = {
        pos = {x = 3571.89453, y = -994.34784, z = 4712.78271},
        size = 1.0,
        color = {255, 255, 0, 200}
    },
    exitTeleport = {
        x = 1974.37427,
        y = -1994.42529,
        z = 13.55390,
        rotation = 0
    },
    -- Safe configurations
    safeMarkers = {
        {
            pos = {x = 3588.41284, y = -989.32190, z = 4712.78271},
            range = {min = 500000, max = 3000000}
        },
        {
            pos = {x = 3588.41284, y = -992.16052, z = 4712.78271},
            range = {min = 100000, max = 999999}
        },
        {
            pos = {x = 3576.13306, y = -993.70245, z = 4713.03271},
            range = {min = 1000000, max = 5000000}
        }
    }
} 