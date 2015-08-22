color = require "onecolor"

# input -> primary color (H+S) L=0.5
# secondary(S) -> S+(primary.H + 0.5 % 1)
# base(lightness) -> bg, foreground, selection
# base ma uhel jako secondary, snizis saturaci a hibes lighntes

# jedno ohnisko ve stredu kolecka
# druhe ohnisko urcene primary a vyskou B
# B - vyska elipsy
# accents(B, n) = []

# vsechen text base(1)
# primary -> stringy constatny
# secondary commenty

xyToAngle = (x, y) ->
  if Math.abs(x) < 1e-10
    if y > 0
      Math.PI/2
    else
      3*Math.PI/2
  else if Math.abs(y) < 1e-10
    if x > 0
      0
    else
      Math.PI
  else 
    Math.atan y/x

# all args are in 0..1 range
generator = (primaryHue, primarySat, secondarySat, height) ->
  primary = color("black").hsl().lightness(0.5).hue(primaryHue).saturation(primarySat)
  secondary = primary.saturation(secondarySat).hue(primaryHue + 0.5 % 1)
 
  baseBase = secondary.saturation(secondary.saturation() * 0.3)
  
  width = (primarySat + secondarySat) / 2
  alpha = primaryHue * 2 * Math.PI
  u1 = Math.cos alpha
  u2 = Math.sin alpha
  v1 = - Math.sin alpha
  v2 = Math.cos alpha
  xShift = width - secondarySat
  
  base = (lightness) ->
    baseBase.lightness(lightness).hex()
    
  accent = (step) ->
    angle = Math.PI * 2 * step
    x = xShift + width * u1 * Math.cos(angle) + height * v1 * Math.sin(angle)
    y =          width * u2 * Math.cos(angle) + height * v2 * Math.sin(angle)
    sat = Math.sqrt(x*x + y*y)
    xyAngle = xyToAngle(x,y)
    hue = xyAngle / (2 * Math.PI)
    color("black").hsl().lightness(0.5).saturation(sat).hue(hue).hex()
    
  accents = (n) ->
    step = 1.0 / n
    shift = 1 / (2 * n)
    [1..n].map (index) ->
      accent shift + (index - 1) * step
 
  {
    primary: primary.hex()
    secondary: secondary.hex()
    base: base
    accent: accent
    accents: accents
  }

module.exports = generator

g = generator(0, 0.7, 0.2, 0.5)
console.log g.primary
console.log g.secondary
for c in g.accents 5
  console.log c
#console.log g.base(0), g.base(0.3), g.base(0.6), g.base(1) 
