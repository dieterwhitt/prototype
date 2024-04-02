# player_ability_data.gd
# 3/15/24

extends Resource

var factor

# movement data for the player ability
# see default_controller_data.gd for more documentation

# SLOW FACTORS - SAME CONCEPT AS slow_physics() IN DEFAULT CONTROLLER
# TO SLOW BY A FACTOR OF N:
# MULTIPLY VELOCITIES BY 1/N
# MULTIPLY ACCELERATION (EX. GRAVITY) BY 1/N^2

# for the ability we want to slow down only gravity
var GRAVITY : float = 670 # SLOW: multiply by 1/10^2 = 1/100 
var ACCELERATION : float = 1000.0 
var DECELERATION : float = 1500.0 

# jump height and air time (pixels, seconds) used to calculate jump velocity with kinematic eqns
# currently: 0.3s to peak (0.6s total), 30px jump
var JUMP_VELOCITY = -200.0 # -200
var DOWN_MULTIPLIER : float = 1.2 # 1.2
var AIR_ACCEL_MULTIPLIER : float = 0.9 # 0.9
var AIR_DECEL_MULTIPLIER : float = 0.5 # 0.5
var TERMINAL_X : float = 200.0 # 200
var TERMINAL_Y : float = 250 # 250 SLOWED
var INPUT_TERMINAL : float = 120.0 # 120
var COYOTE_TIME : int = 5 # 5
var JUMP_BUFFER : int = 5 # 5