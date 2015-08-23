g = null

config = {
  primaryHue: 0,
  primarySat: 0.5,
  secondarySat: 0.2
  ellipseHeight: 0.25
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
  drawColorWheel ctx
  drawPivot ctx
  drawEllipse ctx, g
  drawColorCircle ctx, g.primary
  drawColorCircle ctx, g.secondary
  $('.code .primary').css({color: g.primary})
  $('.code .secondary').css({color: g.secondary})
  $('.code .background').css({backgroundColor: g.base(0)})
  $('.code .foreground').css({color: g.base(1)})
  $('.code .selection').css({backgroundColor: g.base(0.5)})
  ctx.strokeStyle = "gray"
  i = 1
  for c in g.accents 6
    drawColorCircle ctx, c
    $('.code .accent' + i++).css({color: c})
  drawColorCircle ctx, g.base(0.5)
  null
  
drawEllipse = (ctx, g) ->
  prim = colorToPointC g.primary
  sec = colorToPointC g.secondary
  cx = (prim.x + sec.x) / 2
  cy = (prim.y + sec.y) / 2
  xDiff = prim.x - sec.x
  yDiff = prim.y - sec.y
  rx = Math.sqrt(xDiff*xDiff + yDiff*yDiff) / 2
  ry = g.height
  angle = color(g.primary).hsl().hue() * 2 * Math.PI
  doDrawEllipse ctx, cx, cy, rx, ry, angle
  ctx.stroke()
  

doDrawEllipse = (ctx, centerX, centerY, radiusX, radiusY, rotationAngle) ->
  for angle in [0..(2 * Math.PI)] by 0.05
    x = centerX + radiusX * Math.cos(angle) * Math.cos(rotationAngle) - radiusY * Math.sin(angle) * Math.sin(rotationAngle)
    y = centerY + radiusX * Math.cos(angle) * Math.sin(rotationAngle) + radiusY * Math.sin(angle) * Math.cos(rotationAngle)
    point = shiftPoint {x: x, y: y}
    if (angle == 0)
      ctx.moveTo point.x, point.y
    else
      ctx.lineTo point.x, point.y

drawColorCircle = (ctx, circleColor) ->
  center = shiftPoint(colorToPointC circleColor)
  ctx.beginPath()
  ctx.arc(center.x, center.y, 10, 0, 2*Math.PI, false)
  ctx.closePath()
  ctx.fillStyle = circleColor
  ctx.fill()
  ctx.stroke()

drawColorWheel = (ctx) ->
  for x in [-1..1] by 0.025
    maxY = Math.sqrt(1 - x*x)
    for y in [0..maxY] by 0.025
      drawColorWheelPoint ctx, x, y
      drawColorWheelPoint ctx, x, -y
  null

drawColorWheelPoint = (ctx, x, y) ->
  hs = pointToColor x, y
  point = shiftPoint { x:x, y:y }
  ctx.fillStyle = color("black").hsl().lightness(0.5).hue(hs.hue).saturation(hs.sat).hex()
  rad = 6
  ctx.fillRect point.x-(rad/2), point.y-(rad/2), rad, rad

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
  document.querySelector("#primaryHue").oninput = makeSliderListener("primaryHue")
  document.querySelector("#primarySat").oninput = makeSliderListener("primarySat")
  document.querySelector("#secondarySat").oninput = makeSliderListener("secondarySat")
  document.querySelector("#ellipseHeight").oninput = makeSliderListener("ellipseHeight")
  updateGenerator()

onLoad()
