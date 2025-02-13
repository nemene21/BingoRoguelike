local ffi = require("ffi")

ffi.cdef [[
typedef float FNLfloat;

typedef enum
{
    FNL_NOISE_OPENSIMPLEX2,
    FNL_NOISE_OPENSIMPLEX2S,
    FNL_NOISE_CELLULAR,
    FNL_NOISE_PERLIN,
    FNL_NOISE_VALUE_CUBIC,
    FNL_NOISE_VALUE
} fnl_noise_type;

typedef enum
{
    FNL_ROTATION_NONE,
    FNL_ROTATION_IMPROVE_XY_PLANES,
    FNL_ROTATION_IMPROVE_XZ_PLANES
} fnl_rotation_type_3d;

typedef enum
{
    FNL_FRACTAL_NONE,
    FNL_FRACTAL_FBM,
    FNL_FRACTAL_RIDGED,
    FNL_FRACTAL_PINGPONG,
    FNL_FRACTAL_DOMAIN_WARP_PROGRESSIVE,
    FNL_FRACTAL_DOMAIN_WARP_INDEPENDENT
} fnl_fractal_type;

typedef enum
{
    FNL_CELLULAR_DISTANCE_EUCLIDEAN,
    FNL_CELLULAR_DISTANCE_EUCLIDEANSQ,
    FNL_CELLULAR_DISTANCE_MANHATTAN,
    FNL_CELLULAR_DISTANCE_HYBRID
} fnl_cellular_distance_func;

typedef enum
{
    FNL_CELLULAR_RETURN_TYPE_CELLVALUE,
    FNL_CELLULAR_RETURN_TYPE_DISTANCE,
    FNL_CELLULAR_RETURN_TYPE_DISTANCE2,
    FNL_CELLULAR_RETURN_TYPE_DISTANCE2ADD,
    FNL_CELLULAR_RETURN_TYPE_DISTANCE2SUB,
    FNL_CELLULAR_RETURN_TYPE_DISTANCE2MUL,
    FNL_CELLULAR_RETURN_TYPE_DISTANCE2DIV,
} fnl_cellular_return_type;

typedef enum
{
    FNL_DOMAIN_WARP_OPENSIMPLEX2,
    FNL_DOMAIN_WARP_OPENSIMPLEX2_REDUCED,
    FNL_DOMAIN_WARP_BASICGRID
} fnl_domain_warp_type;

typedef struct fnl_state
{
    int seed;
    float frequency;
    fnl_noise_type noise_type;
    fnl_rotation_type_3d rotation_type_3d;
    fnl_fractal_type fractal_type;
    int octaves;
    float lacunarity;
    float gain;
    float weighted_strength;
    float ping_pong_strength;
    fnl_cellular_distance_func cellular_distance_func;
    fnl_cellular_return_type cellular_return_type;
    float cellular_jitter_mod;
    fnl_domain_warp_type domain_warp_type;
    float domain_warp_amp;
} fnl_state;

fnl_state fnlCreateState();
float fnlGetNoise2D(fnl_state *state, FNLfloat x, FNLfloat y);
float fnlGetNoise3D(fnl_state *state, FNLfloat x, FNLfloat y, FNLfloat z);
]]

local cfnl = ffi.load("fnl/FastNoiseLite.so")

local FnlState = {}
FnlState.__index = FnlState

function FnlState:getNoise2D(x, y)
  return cfnl.fnlGetNoise2D(self.cstate, x, y)
end
function FnlState:getNoise3D(x, y, z)
  return cfnl.fnlGetNoise3D(self.cstate, x, y, z)
end

local noise_type = {
  opensimplex2 = cfnl.FNL_NOISE_OPENSIMPLEX2,
  opensimplex2s = cfnl.FNL_NOISE_OPENSIMPLEX2S,
  cellular = cfnl.FNL_NOISE_CELLULAR,
  perlin = cfnl.FNL_NOISE_PERLIN,
  valuecubic = cfnl.FNL_NOISE_VALUE_CUBIC,
  value = cfnl.FNL_NOISE_VALUE,
}

local c_noise_type = {
  [cfnl.FNL_NOISE_OPENSIMPLEX2] = "opensimplex2",
  [cfnl.FNL_NOISE_OPENSIMPLEX2S] = "opensimplex2s",
  [cfnl.FNL_NOISE_CELLULAR] = "cellular",
  [cfnl.FNL_NOISE_PERLIN] = "perlin",
  [cfnl.FNL_NOISE_VALUE_CUBIC] = "valuecubic",
  [cfnl.FNL_NOISE_VALUE] = "value",
}

local cellular_return_type = {
  cellvalue = cfnl.FNL_CELLULAR_RETURN_TYPE_CELLVALUE,
  distance = cfnl.FNL_CELLULAR_RETURN_TYPE_DISTANCE,
  distance2 = cfnl.FNL_CELLULAR_RETURN_TYPE_DISTANCE2,
  distance2_add = cfnl.FNL_CELLULAR_RETURN_TYPE_DISTANCE2ADD,
  distance2_sub = cfnl.FNL_CELLULAR_RETURN_TYPE_DISTANCE2SUB,
  distance2_mul = cfnl.FNL_CELLULAR_RETURN_TYPE_DISTANCE2MUL,
  distance2_div = cfnl.FNL_CELLULAR_RETURN_TYPE_DISTANCE2DIV,
}

local c_cellular_return_type = {
  [cfnl.FNL_CELLULAR_RETURN_TYPE_CELLVALUE] = "cellvalue",
  [cfnl.FNL_CELLULAR_RETURN_TYPE_DISTANCE] = "distance",
  [cfnl.FNL_CELLULAR_RETURN_TYPE_DISTANCE2] = "distance2",
  [cfnl.FNL_CELLULAR_RETURN_TYPE_DISTANCE2ADD] = "distance2_add",
  [cfnl.FNL_CELLULAR_RETURN_TYPE_DISTANCE2SUB] = "distance2_sub",
  [cfnl.FNL_CELLULAR_RETURN_TYPE_DISTANCE2MUL] = "distance2_mul",
  [cfnl.FNL_CELLULAR_RETURN_TYPE_DISTANCE2DIV] = "distance2_div",
}

function FnlState:setNoiseType(type)
  self.cstate.noise_type = noise_type[type]
end
function FnlState:setCellularReturnType(return_type)
  self.cstate.cellular_return_type = cellular_return_type[return_type]
end
function FnlState:setSeed(seed)
  self.cstate.seed = seed
end
function FnlState:setFrequency(frequency)
  self.cstate.frequency = frequency
end
function FnlState:setOctaves(octaves)
  octaves = math.floor(octaves)
  self.cstate.octaves = octaves
end
function FnlState:setLacunarity(lacunarity)
  self.cstate.lacunarity = lacunarity
end
function FnlState:setGain(gain)
  self.cstate.gain = gain
end

function FnlState:getNoiseType()
  return c_noise_type[self.cstate.noise_type]
end
function FnlState:getCellularReturnType()
  return c_cellular_return_type[self.cstate.cellular_return_type]
end
function FnlState:getSeed()
  return self.cstate.seed
end
function FnlState:getFrequency()
  return self.cstate.frequency
end
function FnlState:getOctaves()
  return self.cstate.octaves
end
function FnlState:getLacunarity()
  return self.cstate.lacunarity
end
function FnlState:getGain()
  return self.cstate.gain
end

local fnl = {}

function fnl.createState()
  local fnl_state = setmetatable({}, FnlState)
  fnl_state.cstate = cfnl.fnlCreateState()
  return fnl_state
end

return fnl
