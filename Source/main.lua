local gfx = playdate.graphics
local geo = playdate.geometry

local w = 400
local h = 240
local d = 467 -- diagonal

local angle_conversion = 2 * math.pi / 360

gfx.setColor(gfx.kColorBlack)

local topLeft = geo.point.new(0, 0)
local topRight = geo.point.new(w, 0)
local botLeft = geo.point.new(0, h)
local botRight = geo.point.new(w, h)
local center = geo.point.new(w/2, h/2)

local top = geo.lineSegment.new(0, 0, w, 0)
local bottom = geo.lineSegment.new(0, h, w, h)
local left = geo.lineSegment.new(0, 0, 0, h)
local right = geo.lineSegment.new(w, 0, w, h)
local edges = {top, right, bottom, left}

function spinner(a)
  return geo.lineSegment.new(
        (d/2) * math.cos(a * angle_conversion) + w/2,
        (d/2) * math.sin(a * angle_conversion) + h/2,
        -(d/2) * math.cos(a * angle_conversion) + w/2,
        -(d/2) * math.sin(a * angle_conversion) + h/2
  )
end

local crankCounter = 0
function playdate.update()
    gfx.fillRect(0, 0, 400, 240)
    --playdate.drawFPS(0,0)

    gfx.pushContext()
    gfx.setColor(gfx.kColorXOR)

    crank = playdate.getCrankChange()
    crankCounter = crankCounter + crank
    line1 = spinner(crankCounter)
    line2 = spinner(0.5 * crankCounter + 20)
    --gfx.drawLine(line1)
    --gfx.drawLine(line2)

    edgePts = {{}, {}, {}, {}}

    lines = {line1, line2}

    for l = 1, #lines do
        for i = 1, 4 do
            edge = edges[i]
            inter, pt = lines[l]:intersectsLineSegment(edge)
            if inter then
                edgePts[i][#edgePts[i] + 1] = pt
            end
        end
    end

    local edges = {top, right, bottom, left}
    table.sort(edgePts[1], function(a, b) return a.x < b.x end)
    table.sort(edgePts[2], function(a, b) return a.y < b.y end)
    table.sort(edgePts[3], function(a, b) return b.x < a.x end)
    table.sort(edgePts[4], function(a, b) return b.y < a.y end)

    wrapPts = {}
    table.insert(wrapPts, topLeft)
    for i = 1, #edgePts[1] do
        table.insert(wrapPts, edgePts[1][i])
    end
    table.insert(wrapPts, topRight)
    for i = 1, #edgePts[2] do
        table.insert(wrapPts, edgePts[2][i])
    end
    table.insert(wrapPts, botRight)
    for i = 1, #edgePts[3] do
        table.insert(wrapPts, edgePts[3][i])
    end
    table.insert(wrapPts, botLeft)
    for i = 1, #edgePts[4] do
        table.insert(wrapPts, edgePts[4][i])
    end
    -- repeated for wrapping
    table.insert(wrapPts, topLeft)

    --[[
    for i = 1, #wrapPts -1 do
        pt = wrapPts[i]
        gfx.fillRect(pt.x - 5, pt.y - 5, 10, 10)
    end
    --]]

    for i = 1, #wrapPts - 1 do
        wedge = geo.polygon.new(wrapPts[i], wrapPts[i + 1], center)
        wedge:close()
        gfx.fillPolygon(wedge)
        gfx.pushContext()
        gfx.setDitherPattern(i/#wrapPts)
        gfx.fillPolygon(wedge)
        gfx.popContext()
    end

    gfx.popContext()

end
