g = null

config = {
  primaryHue: 0,
  primarySat: 0.7,
  secondarySat: 0.2
  ellipseHeight: 0.5
}

shiftPoint = (p) ->
  {
    x: 200 + 200 * p.x
    y: 200 + 200 * p.y
  }


draw = ->
  canvas = document.getElementById 'plot'
  ctx = canvas.getContext '2d'
  ctx.strokeStyle = "black"
  ctx.fillStyle = "rgb(50,50,50)"
  ctx.fillRect 0, 0, 400, 400
  for hue in [0..360]
    for sat in [0..200]
      drawCirclePoint ctx, hue / 360.0, sat / 200.0
  drawPivot ctx
  drawEllipse ctx, g
  drawColorCircle ctx, g.primary
  drawColorCircle ctx, g.secondary
  ctx.strokeStyle = "gray"
  for c in g.accents 6
    drawColorCircle ctx, c
  null
  
drawEllipse = (ctx, g) ->
  prim = shiftPoint(colorToPointC g.primary)
  sec = shiftPoint(colorToPointC g.secondary)
  cx = (prim.x + sec.x) / 2
  cy = (prim.y + sec.y) / 2
  xDiff = prim.x - sec.x
  yDiff = prim.y - sec.y
  rx = Math.sqrt(xDiff*xDiff + yDiff*yDiff) / 2
  ry = 200 * g.height
  angle = color(g.primary).hsl().hue() * 2 * Math.PI
  doDrawEllipse ctx, cx, cy, rx, ry, angle
  ctx.stroke()
  

doDrawEllipse = (ctx, centerX, centerY, radiusX, radiusY, rotationAngle) ->
  for angle in [0..(2 * Math.PI)] by 0.05
    x = centerX + radiusX * Math.cos(angle) * Math.cos(rotationAngle) - radiusY * Math.sin(angle) * Math.sin(rotationAngle)
    y = centerY + radiusX * Math.cos(angle) * Math.sin(rotationAngle) + radiusY * Math.sin(angle) * Math.cos(rotationAngle)
    if (angle == 0)
      ctx.moveTo x, y
    else
      ctx.lineTo x, y


drawColorCircle = (ctx, circleColor) ->
  center = shiftPoint(colorToPointC circleColor)
  ctx.beginPath()
  ctx.arc(center.x, center.y, 10, 0, 2*Math.PI, false)
  ctx.closePath()
  ctx.fillStyle = circleColor
  ctx.fill()
  ctx.stroke()

drawCirclePoint = (ctx, hue, sat) ->
  point = shiftPoint(colorToPoint hue, sat)
  ctx.fillStyle = color("black").hsl().lightness(0.5).hue(hue).saturation(sat).hex()
  ctx.fillRect point.x, point.y, 3, 3

drawPivot = (ctx) ->
  point = shiftPoint(colorToPoint 0, 0)
  ctx.fillStyle = color("black").hsl().lightness(0.5).hue(0).saturation(0).hex()
  ctx.beginPath()
  ctx.arc(point.x, point.y, 7, 0, 2*Math.PI, false)
  ctx.closePath()
  ctx.fill()
  ctx.stroke()

updateGenerator = ->
  g = generator(config.primaryHue, config.primarySat, config.secondarySat, config.ellipseHeight)
  document.querySelector("#primary").style.backgroundColor = g.primary
  document.querySelector("#secondary").style.backgroundColor = g.secondary
  document.querySelector("#base2").style.backgroundColor = g.base(0.2)
  document.querySelector("#base5").style.backgroundColor = g.base(0.5)
  document.querySelector("#base7").style.backgroundColor = g.base(0.7)
  i = 1
  for c in g.accents 6
    document.querySelector("#accent" + i).style.backgroundColor = c
    i++
  draw()

makeSliderListener = (name) ->
  ->
    input = document.querySelector("#" + name)
    valSpan = document.querySelector("#" + name + "Val")
    val = input.value / 100
    config[name] = val
    valSpan.innerHTML = val
    updateGenerator()

onLoad = ->
  document.querySelector("#primaryHue").onchange = makeSliderListener("primaryHue")
  document.querySelector("#primarySat").onchange = makeSliderListener("primarySat")
  document.querySelector("#secondarySat").onchange = makeSliderListener("secondarySat")
  document.querySelector("#ellipseHeight").onchange = makeSliderListener("ellipseHeight")
  updateGenerator()

onLoad()
