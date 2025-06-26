function PulsarUI.DrawRoundedBoxEx(borderSize, x, y, w, h, col, topLeft, topRight, bottomLeft, bottomRight)
	return PulsarUI.DrawFullRoundedBoxEx(borderSize, x, y, w, h, col, topLeft, topRight, bottomLeft, bottomRight)

end

function PulsarUI.DrawRoundedBox(borderSize, x, y, w, h, col)
	return PulsarUI.DrawFullRoundedBoxEx(borderSize, x, y, w, h, col, true, true, true, true)
end

function PulsarUI.DrawFullRoundedBoxEx(borderSize, x, y, w, h, col, tl, tr, bl, br)
	local flags = PulsarUI.RNDX.SHAPE_CIRCLE

	if tl == false then flags = flags + PulsarUI.RNDX.NO_TL end
	if tr == false then flags = flags + PulsarUI.RNDX.NO_TR end
	if bl == false then flags = flags + PulsarUI.RNDX.NO_BL end
	if br == false then flags = flags + PulsarUI.RNDX.NO_BR end

	PulsarUI.RNDX.Draw(borderSize, x, y, w, h, col, flags)
end

function PulsarUI.DrawFullRoundedBox(borderSize, x, y, w, h, col)
	return PulsarUI.DrawFullRoundedBoxEx(borderSize, x, y, w, h, col, true, true, true, true)
end