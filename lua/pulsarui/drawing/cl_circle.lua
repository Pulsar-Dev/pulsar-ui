

do
    local materials = {
        "https://pixel-cdn.lythium.dev/i/srlt7tk7m", --8
        "https://pixel-cdn.lythium.dev/i/l2km82zi", --16
        "https://pixel-cdn.lythium.dev/i/5mqrguuxd", --32
        "https://pixel-cdn.lythium.dev/i/yxh641f2a", --64
        "https://pixel-cdn.lythium.dev/i/yz2n2neu", --128
        "https://pixel-cdn.lythium.dev/i/v4sxyjdd8", --256
        "https://pixel-cdn.lythium.dev/i/nmp8368j", --512
        "https://pixel-cdn.lythium.dev/i/e425w7lrj", --1024
        "https://pixel-cdn.lythium.dev/i/iinrlgj5b" --2048
    }

    local max = math.max
    function PulsarUI.DrawCircle(x, y, w, h, col)
        local size = max(w, h)
        local id = materials[1]

        local curSize = 8
        for i = 1, #materials do
            if size <= curSize then break end
            id = materials[i + 1] or id
            curSize = curSize + curSize
        end

        PulsarUI.DrawImage(x, y, w, h, id, col)
    end
end

do
    local insert = table.insert
    local rad, sin, cos = math.rad, math.sin, math.cos

    function PulsarUI.CreateCircle(x, y, ang, seg, pct, radius)
        local circle = {}

        insert(circle, {x = x, y = y})

        for i = 0, seg do
            local segAngle = rad((i / seg) * -pct + ang)
            insert(circle, {x = x + sin(segAngle) * radius, y = y + cos(segAngle) * radius})
        end

        return circle
    end
end

local createCircle = PulsarUI.CreateCircle
local drawPoly = surface.DrawPoly
function PulsarUI.DrawCircleUncached(x, y, ang, seg, pct, radius)
    drawPoly(createCircle(x, y, ang, seg, pct, radius))
end