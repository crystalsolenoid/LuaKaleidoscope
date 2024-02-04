local gfx = playdate.graphics
local geo = playdate.geometry

local w = 400
local h = 240
local d = 467 -- diagonal

local angle_conversion = 2 * math.pi / 360

local images = {
    playdate.graphics.image.new("images/035nest1.png"),
    playdate.graphics.image.new("images/021hex0n.png"),
    playdate.graphics.image.new("images/036noise0.png"),
    playdate.graphics.image.new("images/042scallops0n.png"),
    playdate.graphics.image.new("images/047stones1n.png"),
    playdate.graphics.image.new("images/077flowers0n.png"),
}

gfx.setColor(gfx.kColorBlack)

local topLeft = geo.point.new(0, 0)
local topRight = geo.point.new(w, 0)
local botLeft = geo.point.new(0, h)
local botRight = geo.point.new(w, h)
local center = geo.point.new(w/2, h/2)

local topEdge = geo.lineSegment.new(0, 0, w, 0)
local bottomEdge = geo.lineSegment.new(0, h, w, h)
local leftEdge = geo.lineSegment.new(0, 0, 0, h)
local rightEdge = geo.lineSegment.new(w, 0, w, h)
local edges = {topEdge, rightEdge, bottomEdge, leftEdge}

local function spinner(a)
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

    local crank = playdate.getCrankChange()
    crankCounter = crankCounter + crank
    local line1 = spinner(crankCounter)
    local line2 = spinner(0.5 * crankCounter + 20)
    local line3 = spinner(0.2 * crankCounter + -10)

    local edgePts = {{}, {}, {}, {}}

    local lines = {line1, line2, line3}

    for l = 1, #lines do
        for i = 1, 4 do
            local edge = edges[i]
            local inter, pt = lines[l]:intersectsLineSegment(edge)
            if inter then
                edgePts[i][#edgePts[i] + 1] = pt
            end
        end
    end

    table.sort(edgePts[1], function(a, b) return a.x < b.x end)
    table.sort(edgePts[2], function(a, b) return a.y < b.y end)
    table.sort(edgePts[3], function(a, b) return b.x < a.x end)
    table.sort(edgePts[4], function(a, b) return b.y < a.y end)
    local topPts = edgePts[1]
    local rightPts = edgePts[2]
    local bottomPts = edgePts[3]
    local leftPts = edgePts[4]

    local firstTop = topPts[1]
    local lastTop = topPts[#topPts]
    local firstRight = rightPts[1]
    local lastRight = rightPts[#rightPts]
    local firstBottom = bottomPts[1]
    local lastBottom = bottomPts[#bottomPts]
    local firstLeft = leftPts[1]
    local lastLeft = leftPts[#leftPts]

    local wedges = {}

    -- polygon containing topLeft as the first corner
    if firstTop then --if any lines are intersecting the top edge
        if lastLeft then
            local wedge = geo.polygon.new(firstTop, topLeft, lastLeft, center)
            wedge:close()
            table.insert(wedges, wedge)
        end
    else
        local wedge = geo.polygon.new(firstRight, topRight, topLeft, lastLeft, center)
        wedge:close()
        table.insert(wedges, wedge)
    end

    -- polygons exclusively on top
    for i = 1, #topPts - 1 do
        local ptA = topPts[i]
        local ptB = topPts[i + 1]
        local wedge = geo.polygon.new(ptA, ptB, center)
        wedge:close()
        table.insert(wedges, wedge)
    end

    -- polygon containing topRight as the first corner
    if firstRight then --if any lines are intersecting the right edge
        if lastTop then
            local wedge = geo.polygon.new(firstRight, topRight, lastTop, center)
            wedge:close()
            table.insert(wedges, wedge)
        end
    else
        local wedge = geo.polygon.new(firstBottom, botRight, topRight, lastTop, center)
        wedge:close()
        table.insert(wedges, wedge)
    end

    -- polygons exclusively on right
    for i = 1, #rightPts - 1 do
        local ptA = rightPts[i]
        local ptB = rightPts[i + 1]
        local wedge = geo.polygon.new(ptA, ptB, center)
        wedge:close()
        table.insert(wedges, wedge)
    end

    -- polygon containing botRight as the first corner
    if firstBottom then --if any lines are intersecting the bottom edge
        if lastRight then
            local wedge = geo.polygon.new(firstBottom, botRight, lastRight, center)
            wedge:close()
            table.insert(wedges, wedge)
        end
    else
        local wedge = geo.polygon.new(firstLeft, botLeft, botRight, lastRight, center)
        wedge:close()
        table.insert(wedges, wedge)
    end

    -- polygons exclusively on bottom
    for i = 1, #bottomPts - 1 do
        local ptA = bottomPts[i]
        local ptB = bottomPts[i + 1]
        local wedge = geo.polygon.new(ptA, ptB, center)
        wedge:close()
        table.insert(wedges, wedge)
    end

    -- polygon containing botLeft as the first corner
    if firstLeft then --if any lines are intersecting the left edge
        if lastBottom then
            local wedge = geo.polygon.new(firstLeft, botLeft, lastBottom, center)
            wedge:close()
            table.insert(wedges, wedge)
        end
    else
        local wedge = geo.polygon.new(firstTop, topLeft, botLeft, lastBottom, center)
        wedge:close()
        table.insert(wedges, wedge)
    end

    -- polygons exclusively on left
    for i = 1, #leftPts - 1 do
        local ptA = leftPts[i]
        local ptB = leftPts[i + 1]
        local wedge = geo.polygon.new(ptA, ptB, center)
        wedge:close()
        table.insert(wedges, wedge)
    end

    local debugPts = {}
    table.insert(debugPts, topLeft)
    for i = 1, #topPts do
        table.insert(debugPts, topPts[i])
    end
    table.insert(debugPts, topRight)
    for i = 1, #rightPts do
        table.insert(debugPts, rightPts[i])
    end
    table.insert(debugPts, botRight)
    for i = 1, #bottomPts do
        table.insert(debugPts, bottomPts[i])
    end
    table.insert(debugPts, botLeft)
    for i = 1, #leftPts do
        table.insert(debugPts, leftPts[i])
    end

    gfx.pushContext()
    gfx.setColor(gfx.kColorXOR)
    for i = 1, #debugPts do
        local pt = debugPts[i]
        gfx.fillRect(pt.x - 5, pt.y - 5, 10, 10)
    end
    gfx.popContext()

    for i = 1, #wedges do
        local wedge = wedges[i]

        -- draw a stencil in a wedge shape
        local wedgeImg = gfx.image.new(w, h, gfx.kColorBlack)
        gfx.pushContext(wedgeImg)
            gfx.setColor(gfx.kColorWhite)
            gfx.fillPolygon(wedge)
        gfx.popContext()

        -- draw a tiled image with that stencil
        gfx.pushContext()
            gfx.setStencilImage(wedgeImg)
            images[i]:drawTiled(0, 0, w, h)
        gfx.popContext()
    end

end
