--[[
	PIXEL UI - Copyright Notice
	© 2023 Thomas O'Sullivan - All rights reserved

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <https://www.gnu.org/licenses/>.
--]]

local PANEL = {}
AccessorFunc(PANEL, "IsToggle", "IsToggle", FORCE_BOOL)
AccessorFunc(PANEL, "Toggle", "Toggle", FORCE_BOOL)
AccessorFunc(PANEL, "Clicky", "Clicky", FORCE_BOOL)
AccessorFunc(PANEL, "Sounds", "Sounds", FORCE_BOOL)

function PANEL:Init()
    self:SetIsToggle(false)
    self:SetToggle(false)
    self:SetMouseInputEnabled(true)
    self:SetCursor("hand")
    self:SetClicky(false)
    self:SetSounds(true)
    local btnSize = PIXEL.Scale(30)
    self:SetSize(btnSize, btnSize)
    self.NormalCol = PIXEL.CopyColor(PIXEL.Colors.Primary)
    self.HoverCol = PIXEL.OffsetColor(self.NormalCol, -15)
    self.ClickedCol = PIXEL.OffsetColor(self.NormalCol, 15)
    self.DisabledCol = PIXEL.CopyColor(PIXEL.Colors.Disabled)
    self.ClickyCol = PIXEL.OffsetColor(self.NormalCol, -35)
    self.BackgroundCol = self.NormalCol
    self.BackgroundClickyCol = self.ClickyCol
    self.ClickyScale = PIXEL.Scale(3)
    self.Clicky = self:GetClicky()
    self.ClickyMove = false
end

function PANEL:PerformLayout()
    local tall = self:GetTall()

    if tall > 75 then
        self.ClickyScale = self:GetTall() / 25
    elseif tall > 50 then
        self.ClickyScale = self:GetTall() / 17
    elseif tall > 25 then
        self.ClickyScale = self:GetTall() / 10
    elseif tall > 15 then
        self.ClickyScale = self:GetTall() / 5
    end
end

function PANEL:DoToggle(...)
    if not self:GetIsToggle() then return end
    self:SetToggle(not self:GetToggle())
    self:OnToggled(self:GetToggle(), ...)
end

local localPly

function PANEL:OnMousePressed(mouseCode)
    if not self:IsEnabled() then return end
    self.ClickyMove = true

    if self:GetSounds() then
        PIXEL.PlayButtonSound()
    end

    if not localPly then
        localPly = LocalPlayer()
    end

    if self:IsSelectable() and mouseCode == MOUSE_LEFT and (input.IsShiftDown() or input.IsControlDown()) and not (localPly:KeyDown(IN_FORWARD) or localPly:KeyDown(IN_BACK) or localPly:KeyDown(IN_MOVELEFT) or localPly:KeyDown(IN_MOVERIGHT)) then return self:StartBoxSelection() end
    self:MouseCapture(true)
    self.Depressed = true
    self:OnPressed(mouseCode)
    self:DragMousePress(mouseCode)
end

function PANEL:OnMouseReleased(mouseCode)
    self:MouseCapture(false)
    if not self:IsEnabled() then return end
    if not self.Depressed and dragndrop.m_DraggingMain ~= self then return end
    self.ClickyMove = false

    if self.Depressed then
        self.Depressed = nil
        self:OnReleased(mouseCode)
    end

    if self:DragMouseRelease(mouseCode) then return end

    if self:IsSelectable() and mouseCode == MOUSE_LEFT then
        local canvas = self:GetSelectionCanvas()

        if canvas then
            canvas:UnselectAll()
        end
    end

    if not self.Hovered then return end
    self.Depressed = true

    if mouseCode == MOUSE_RIGHT then
        self:DoRightClick()
    elseif mouseCode == MOUSE_LEFT then
        self:DoClick()
    elseif mouseCode == MOUSE_MIDDLE then
        self:DoMiddleClick()
    end

    self.Depressed = nil
end

function PANEL:PaintExtra(w, h)
end

function PANEL:Paint(w, h)
    if not self:IsEnabled() then
        PIXEL.DrawRoundedBox(PIXEL.Scale(6), 0, 0, w, h, self.DisabledCol)
        self:PaintExtra(w, h)

        return
    end

    local bgCol = self.NormalCol

    if self:IsDown() or self:GetToggle() then
        bgCol = self.ClickedCol
    elseif self:IsHovered() and not self.Clicky then
        bgCol = self.HoverCol
    end

    if not self.Clicky then
        self.BackgroundCol = PIXEL.LerpColor(FrameTime() * 12, self.BackgroundCol, bgCol)
    end

    if not self:GetClicky() then
        PIXEL.DrawRoundedBox(8, 0, 0, w, h, self.BackgroundCol)
    else
        if self.ClickyMove then
            PIXEL.DrawRoundedBox(8, 0, self.ClickyScale, w, h - self.ClickyScale, self.BackgroundCol)
        else
            PIXEL.DrawRoundedBox(8, 0, 0, w, h, self.ClickyCol)
            PIXEL.DrawRoundedBox(8, 0, 0, w, h - self.ClickyScale, self.BackgroundCol)
        end
    end

    self:PaintExtra(w, h)
end

function PANEL:IsDown()
    return self.Depressed
end

function PANEL:OnPressed(mouseCode)
end

function PANEL:OnReleased(mouseCode)
end

function PANEL:OnToggled(enabled)
end

function PANEL:DoClick(...)
    self:DoToggle(...)
end

function PANEL:DoRightClick()
end

function PANEL:DoMiddleClick()
end

vgui.Register("PIXEL.Button", PANEL, "Panel")