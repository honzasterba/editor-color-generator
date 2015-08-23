if (window)
  color = one.color
else
  color = require "onecolor"

pointToColor = (x, y) ->
  if x >= 0 && y >= 0
    tan = y/x
    delta = Math.atan tan
  else if x <= 0 && y >= 0
    tan = -y/x
    alpha = Math.atan tan
    delta = Math.PI - alpha
  else if x <= 0 && y <= 0
    tan = y/x
    alpha = Math.atan tan
    delta = Math.PI + alpha
  else
    tan = -y/x
    alpha = Math.atan tan
    delta = Math.PI * 2 - alpha
  {
    hue: delta / (2 * Math.PI)
    sat: Math.sqrt(x*x*(1 + tan*tan))
  }


colorToPointC = (hex) ->
  c = color(hex).hsl()
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
    hueSat = pointToColor x, y
    color("black").hsl().lightness(0.5).hue(hueSat.hue).saturation(hueSat.sat).hex()
    
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

