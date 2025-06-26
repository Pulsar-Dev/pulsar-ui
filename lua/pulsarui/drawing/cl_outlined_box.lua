function PulsarUI.DrawOutlinedBox(x, y, w, h, thickness, col)
    PulsarUI.RNDX.DrawOutlined(0, x, y, w, h, col, thickness)
end

function PulsarUI.DrawOutlinedRoundedBoxEx(borderSize, x, y, w, h, col, thickness, tl, tr, bl, br)
    local flags = PulsarUI.RNDX.SHAPE_CIRCLE

    if tl == false then flags = flags + PulsarUI.RNDX.NO_TL end
    if tr == false then flags = flags + PulsarUI.RNDX.NO_TR end
    if bl == false then flags = flags + PulsarUI.RNDX.NO_BL end
    if br == false then flags = flags + PulsarUI.RNDX.NO_BR end

    PulsarUI.RNDX.DrawOutlined(borderSize, x, y, w, h, col, thickness, flags)
end

function PulsarUI.DrawOutlinedRoundedBox(borderSize, x, y, w, h, col, thickness)
    PulsarUI.DrawOutlinedRoundedBoxEx(borderSize, x, y, w, h, col, thickness, true, true, true, true)
end
