if (window)
  color = one.color
else
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

colorToPointC = (hex) ->
  c = color(hex)
  colorToPoint c.hue(), c.saturation()


colorToPoint = (hue, sat) ->
  delta = hue * 2 * Math.PI
  if hue >= 0 && hue < 0.25
    tan = Math.tan(delta)
    x = Math.sqrt(sat*sat / (1 + tan*tan))
    {
      x: x
      y: x * tan
    }
  else if hue >= 0.25 && hue < 0.5
    tan = Math.tan(Math.PI - delta)
    x = Math.sqrt(sat*sat / (1 + tan*tan))
    {
      x: - x
      y: x * tan
    }
  else if hue >= 0.5 && hue < 0.75
    tan = Math.tan(delta - Math.PI)
    x = Math.sqrt(sat*sat / (1 + tan*tan))
    {
      x: - x
      y: - x * tan
    }
  else
    tan = Math.tan((2 * Math.PI) - delta)
    x = Math.sqrt(sat*sat / (1 + tan*tan))
    {
      x: x
      y: - x * tan
    }


# all args are in 0..1 range
generator = (primaryHue, primarySat, secondarySat, height) ->
  primary = color("black").hsl().lightness(0.5).hue(primaryHue).saturation(primarySat)
  secondary = primary.saturation(secondarySat).hue(primaryHue + 0.5 % 1)
 
  baseBase = secondary.saturation(secondary.saturation() * 0.3)

  prim = colorToPointC primary.hex()
  sec = colorToPointC secondary.hex()
  centerX = (prim.x + sec.x) / 2
  centerY = (prim.y + sec.y) / 2
  xDiff = prim.x - sec.x
  yDiff = prim.y - sec.y
  radiusX = Math.sqrt(xDiff*xDiff + yDiff*yDiff) / 2
  radiusY = height
  rotationAngle = primaryHue * 2 * Math.PI

  base = (lightness) ->
    baseBase.lightness(lightness).hex()
    
  accent = (step) ->
    angle = Math.PI * 2 * step
    x = centerX + radiusX * Math.cos(angle) * Math.cos(rotationAngle) - radiusY * Math.sin(angle) * Math.sin(rotationAngle)
    y = centerY + radiusX * Math.cos(angle) * Math.sin(rotationAngle) + radiusY * Math.sin(angle) * Math.cos(rotationAngle)
    
    sat = Math.sqrt(x*x + y*y)
    xyAngle = Math.atan2(y, x)
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
    height: height
    base: base
    accent: accent
    accents: accents
  }

