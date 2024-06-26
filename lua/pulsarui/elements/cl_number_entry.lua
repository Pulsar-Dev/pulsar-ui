---@class PulsarUI.NumberEntry : PulsarUI.TextEntry
---@field SetHideButtons fun(self: PulsarUI.NumberEntry, hide: boolean)
---@field GetHideButtons fun(self: PulsarUI.NumberEntry): boolean
---@field SetInterval fun(self: PulsarUI.NumberEntry, interval: number)
---@field GetInterval fun(self: PulsarUI.NumberEntry): number
---@field SetMin fun(self: PulsarUI.NumberEntry, min: number)
---@field GetMin fun(self: PulsarUI.NumberEntry): number
---@field SetMax fun(self: PulsarUI.NumberEntry, max: number)
---@field GetMax fun(self: PulsarUI.NumberEntry): number
local PANEL = {}
AccessorFunc(PANEL, "HideButtons", "HideButtons", FORCE_BOOL)
AccessorFunc(PANEL, "Interval", "Interval", FORCE_NUMBER)
AccessorFunc(PANEL, "Min", "Min", FORCE_NUMBER)
AccessorFunc(PANEL, "Max", "Max", FORCE_NUMBER)

function PANEL:Init()
    self:SetHideButtons(false)
    self:SetNumeric(true)
    self:SetInterval(1)
    self:SetValue(1)
    self:SetMin(1)
    self:SetMax(100)
    self:SetHistoryEnabled(false)
    self:SetUpdateOnType(true)
    self.UpButton = self:Add("PulsarUI.ImageButton")
    self.UpButton:SetImageURL("https://pixel-cdn.lythium.dev/i/upbutton")

    self.UpButton.DoClick = function(s)
        local current = tonumber(self:GetValue())

        if not current then
            current = self:GetMin() or 0
        end

        local interval = self:GetInterval() or 1
        local new = current + interval

        if (new > self:GetMax()) or (new < self:GetMin()) then
            new = current
        end

        self:SetValue(new)
    end

    self.DownButton = self:Add("PulsarUI.ImageButton")
    self.DownButton:SetImageURL("https://pixel-cdn.lythium.dev/i/downbutton")

    self.DownButton.DoClick = function(s)
        local current = tonumber(self:GetValue())

        if not current then
            current = self:GetMin() or 0
        end

        local interval = self:GetInterval() or 1
        local new = current - interval

        if (new > self:GetMax()) or (new < self:GetMin()) then
            new = current
        end

        self:SetValue(new)
    end

    function self:AllowInput()
        local value = self:GetValue()
        value = tonumber(value)

        if not value then
            value = self:GetMin() or 0
        end

        if value > self:GetMax() then
            self.TextEntry:SetText(self:GetMax())

            return true
        end

        if value < self:GetMin() then
            self.TextEntry:SetText(self:GetMin())

            return true
        end

        return false
    end

    function self:OnValueChange()
        local value = self:GetValue()
        value = tonumber(value)

        if not value then
            value = self:GetMin() or 0
        end

        if value > self:GetMax() then
            self.TextEntry:SetText(self:GetMax())
        elseif value < self:GetMin() then
            self.TextEntry:SetText(self:GetMin())
        end

        self:OnValueChanged(value)
    end

    function self:OnValueChanged()
    end
end

function PANEL:LayoutContent(w, h)
    if self:GetHideButtons() then
        self.UpButton:SetVisible(false)
        self.DownButton:SetVisible(false)
    end

    local height = h / 4
    self.UpButton:SetSize(height, height)
    self.UpButton:SetPos(w - height - (h / 4), (h / 2) - height)
    self.DownButton:SetSize(height, height)
    self.DownButton:SetPos(w - height - (h / 4), h - self.UpButton:GetY() - height)

    local zPos = self:GetZPos()
    self.UpButton:SetZPos(zPos + 1)
    self.DownButton:SetZPos(zPos + 1)
end

vgui.Register("PulsarUI.NumberEntry", PANEL, "PulsarUI.TextEntry")