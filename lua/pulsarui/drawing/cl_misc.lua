

function PulsarUI.DrawRoundedTextBox(text, font, x, y, xAlign, textCol, boxRounding, boxPadding, boxCol)
    local boxW, boxH = PulsarUI.GetTextSize(text, font)

    local dblPadding = boxPadding * 2
    if xAlign == TEXT_ALIGN_CENTER then
        PulsarUI.DrawRoundedBox(boxRounding, x - boxW / 2 - boxPadding, y - boxPadding, boxW + dblPadding, boxH + dblPadding, boxCol)
    elseif xAlign == TEXT_ALIGN_RIGHT then
        PulsarUI.DrawRoundedBox(boxRounding, x - boxW - boxPadding, y - boxPadding, boxW + dblPadding, boxH + dblPadding, boxCol)
    else
        PulsarUI.DrawRoundedBox(boxRounding, x - boxPadding, y - boxPadding, boxW + dblPadding, boxH + dblPadding, boxCol)
    end

    PulsarUI.DrawText(text, font, x, y, textCol, xAlign)
end

function PulsarUI.DrawFixedRoundedTextBox(text, font, x, y, xAlign, textCol, boxRounding, w, h, boxCol, textPadding)
    PulsarUI.DrawRoundedBox(boxRounding, x, y, w, h, boxCol)

    if xAlign == TEXT_ALIGN_CENTER then
        PulsarUI.DrawSimpleText(text, font, x + w / 2, y + h / 2, textCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        return
    end

    if xAlign == TEXT_ALIGN_RIGHT then
        PulsarUI.DrawSimpleText(text, font, x + w - textPadding, y + h / 2, textCol, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        return
    end

    PulsarUI.DrawSimpleText(text, font, x + textPadding, y + h / 2, textCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

local blurPassesCvar = CreateClientConVar("pulsar_ui_blur_passes", "4", true, false, "Amount of passes to draw blur with. 0 to disable blur entirely.", 0, 15)
local blurPassesNum = blurPassesCvar:GetInt()

cvars.AddChangeCallback("pulsar_ui_blur_passes", function(_, _, passes)
    blurPassesNum = math.floor(tonumber(passes) + 0.05)
end )

local blurMat = Material("pp/blurscreen")
local scrW, scrH = ScrW, ScrH
function PulsarUI.DrawBlur(panel, localX, localY, w, h)
    if blurPassesNum == 0 then return end
    local x, y = panel:LocalToScreen(localX, localY)
    local scrw, scrh = scrW(), scrH()

    surface.SetMaterial(blurMat)
    surface.SetDrawColor(255, 255, 255)

    for i = 0, blurPassesNum do
        blurMat:SetFloat("$blur", i * .33)
        blurMat:Recompute()
    end
    render.UpdateScreenEffectTexture()
    surface.DrawTexturedRect(x * -1, y * -1, scrw, scrh)
end