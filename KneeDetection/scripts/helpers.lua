-------------------------------------
-- Basic helper functions -----------
-------------------------------------

local function getDeco(rgba, lineWidth, pointSize)
  lineWidth = lineWidth or 1
  pointSize = pointSize or 1
  rgba = rgba or {0, 0, 0}

  if #rgba == 3 then
    rgba[4] = 255
  end

  local deco = View.ShapeDecoration.create()
  deco:setLineColor(rgba[1], rgba[2], rgba[3], rgba[4])
  deco:setFillColor(rgba[1], rgba[2], rgba[3], rgba[4])
  deco:setLineWidth(lineWidth)
  deco:setPointSize(pointSize)
  return deco
end

local function graphDeco(color, title, overlay)
  local deco = View.GraphDecoration.create()
  deco:setGraphColor(color[1], color[2], color[3], color[4] or 255)
  deco:setGraphType('LINE')
  deco:setDrawSize(0.5)
  deco:setAspectRatio('EQUAL')
  deco:setYBounds(-15, 42)
  deco:setTitle(title or '')
  if overlay then
    deco:setAxisVisible(false)
    deco:setBackgroundVisible(false)
    deco:setGridVisible(false)
    deco:setLabelsVisible(false)
    deco:setTicksVisible(false)
  end
  return deco
end


local helper = {}
helper.getDeco = getDeco
helper.graphDeco = graphDeco
return helper