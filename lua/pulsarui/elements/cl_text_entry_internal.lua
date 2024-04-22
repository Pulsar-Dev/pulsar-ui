---@class PulsarUI.TextEntryInternal : TextEntry
---@field SetEnterAllowed fun(self: PulsarUI.TextEntryInternal, allowed: boolean)
---@field GetEnterAllowed fun(self: PulsarUI.TextEntryInternal): boolean
---@field SetUpdateOnType fun(self: PulsarUI.TextEntryInternal, update: boolean)
---@field GetUpdateOnType fun(self: PulsarUI.TextEntryInternal): boolean
---@field SetNumeric fun(self: PulsarUI.TextEntryInternal, numeric: boolean)
---@field GetNumeric fun(self: PulsarUI.TextEntryInternal): boolean
---@field SetHistoryEnabled fun(self: PulsarUI.TextEntryInternal, enabled: boolean)
---@field GetHistoryEnabled fun(self: PulsarUI.TextEntryInternal): boolean
---@field SetTabbingDisabled fun(self: PulsarUI.TextEntryInternal, disabled: boolean)
---@field GetTabbingDisabled fun(self: PulsarUI.TextEntryInternal): boolean
---@field SetPlaceholderText fun(self: PulsarUI.TextEntryInternal, text: string)
---@field GetPlaceholderText fun(self: PulsarUI.TextEntryInternal): string
---@field SetFont fun(self: PulsarUI.TextEntryInternal, font: string, isPixel: boolean)
---@field SetEditable fun(self: PulsarUI.TextEntryInternal, enabled: boolean)
local PANEL = {}

AccessorFunc(PANEL, "m_bAllowEnter", "EnterAllowed", FORCE_BOOL)
AccessorFunc(PANEL, "m_bUpdateOnType", "UpdateOnType", FORCE_BOOL)
AccessorFunc(PANEL, "m_bNumeric", "Numeric", FORCE_BOOL)
AccessorFunc(PANEL, "m_bHistory", "HistoryEnabled", FORCE_BOOL)
AccessorFunc(PANEL, "m_bDisableTabbing", "TabbingDisabled", FORCE_BOOL)
AccessorFunc(PANEL, "m_txtPlaceholder", "PlaceholderText", FORCE_STRING)
AccessorFunc(PANEL, "m_txtFont", "Font", FORCE_STRING)
Derma_Install_Convar_Functions(PANEL)
PulsarUI.RegisterFont("UI.TextEntry", "Rubik", 18)

function PANEL:SetFont(font, isPixel)
    if isPixel then
        self:SetFontInternal(PulsarUI.GetRealFont(font))
    else
        self:SetFontInternal(font)
    end
end

function PANEL:Init()
    self:SetHistoryEnabled(false)
    self.History = {}
    self.HistoryPos = 0
    self:SetPaintBorderEnabled(false)
    self:SetPaintBackgroundEnabled(false)
    self:SetEnterAllowed(true)
    self:SetUpdateOnType(false)
    self:SetNumeric(false)
    self:SetAllowNonAsciiCharacters(true)
    self:SetTall(PulsarUI.Scale(34))
    self.m_bLoseFocusOnClickAway = true
    self:SetCursor("beam")
    self:SetFontInternal(PulsarUI.GetRealFont("UI.TextEntry"))
end

function PANEL:IsEditing()
    return self == vgui.GetKeyboardFocus()
end

function PANEL:OnKeyCodeTyped(code)
    self:OnKeyCode(code)

    if code == KEY_ENTER and not self:IsMultiline() and self:GetEnterAllowed() then
        if IsValid(self.Menu) then
            self.Menu:Remove()
        end

        self:FocusNext()
        self:OnEnter()
        self.HistoryPos = 0
    end

    if self:GetHistoryEnabled() or IsValid(self.Menu) then
        if code == KEY_UP then
            self.HistoryPos = self.HistoryPos - 1
            self:UpdateFromHistory()
        end

        if code == KEY_DOWN or code == KEY_TAB then
            self.HistoryPos = self.HistoryPos + 1
            self:UpdateFromHistory()
        end
    end
end

function PANEL:OnKeyCode(code)
    local parent = self:GetParent()
    if not parent then return end

    ---@diagnostic disable-next-line: undefined-field
    if parent.OnKeyCode then parent:OnKeyCode() end
end

function PANEL:UpdateFromHistory()
    if IsValid(self.Menu) then return self:UpdateFromMenu() end
    local pos = self.HistoryPos

    if pos < 0 then
        pos = #self.History
    end

    if pos > #self.History then
        pos = 0
    end

    local text = self.History[pos]

    if not text then
        text = ""
    end

    self:SetText(text)
    self:SetCaretPos(text:len())
    self:OnTextChanged()
    self.HistoryPos = pos
end

function PANEL:UpdateFromMenu()
    local pos = self.HistoryPos
    local num = self.Menu:ChildCount()
    self.Menu:ClearHighlights()

    if pos < 0 then
        pos = num
    end

    if pos > num then
        pos = 0
    end

    local item = self.Menu:GetChild(pos)

    if not item then
        self:SetText("")
        self.HistoryPos = pos

        return
    end

    self.Menu:HighlightItem(item)
    local txt = item:GetText()
    self:SetText(txt)
    self:SetCaretPos(txt:len())
    self:OnTextChanged(true)
    self.HistoryPos = pos
end

function PANEL:OnTextChanged(noMenuRemoval)
    self.HistoryPos = 0

    if self:GetUpdateOnType() then
        self:UpdateConvarValue()
        self:OnValueChange(self:GetText())
    end

    if IsValid(self.Menu) and not noMenuRemoval then
        self.Menu:Remove()
    end

    local tab = self:GetAutoComplete(self:GetText())

    if tab then
        self:OpenAutoComplete(tab)
    end

    self:OnChange()
end

function PANEL:OnChange()
    local parent = self:GetParent()
    if not parent then return end

    ---@diagnostic disable-next-line: undefined-field
    if parent.OnChange then parent:OnChange() end
end

function PANEL:OpenAutoComplete(tab)
    if not tab then return end
    if #tab == 0 then return end
    self.Menu = DermaMenu()

    for k, v in pairs(tab) do
        self.Menu:AddOption(v, function()
            self:SetText(v)
            self:SetCaretPos(v:len())
            self:RequestFocus()
        end)
    end

    local x, y = self:LocalToScreen(0, self:GetTall())
    self.Menu:SetMinimumWidth(self:GetWide())
    self.Menu:Open(x, y, true, self)
    self.Menu:SetPos(x, y)
    self.Menu:SetMaxHeight((ScrH() - y) - 10)
end

function PANEL:Think()
    self:ConVarStringThink()
end

function PANEL:OnEnter()
    self:UpdateConvarValue()
    self:OnValueChange(self:GetText())
    local parent = self:GetParent()
    if not parent then return end

    ---@diagnostic disable-next-line: undefined-field
    if parent.OnEnter then
        ---@diagnostic disable-next-line: undefined-field
        parent:OnEnter()
    end
end

function PANEL:UpdateConvarValue()
    self:ConVarChanged(self:GetValue())
end

function PANEL:Paint(w, h)
    self:DrawTextEntryText(color_white, PulsarUI.Colors.Primary, PulsarUI.Colors.Primary)
end

function PANEL:SetValue(value)
    if self:IsEditing() then return end
    self:SetText(value)
    self:OnValueChange(value)
    self:SetCaretPos(self:GetCaretPos())
end

function PANEL:OnValueChange(value)
    local parent = self:GetParent()
    if not parent then return end

    ---@diagnostic disable-next-line: undefined-field
    if parent.OnValueChange then
        ---@diagnostic disable-next-line: undefined-field
        parent:OnValueChange(value)
    end
end

local numericChars = "1234567890.-"

function PANEL:CheckNumeric(value)
    if not self:GetNumeric() then return false end
    if not string.find(numericChars, value, 1, true) then return true end

    return false
end

function PANEL:AllowInput(value)
    if self:CheckNumeric(value) then return true end
    local parent = self:GetParent()
    if not parent then return end

    ---@diagnostic disable-next-line: undefined-field
    if parent.AllowInput and parent:AllowInput(value) then return true end
end

function PANEL:SetEditable(enabled)
    self:SetKeyboardInputEnabled(enabled)
    self:SetMouseInputEnabled(enabled)
end

function PANEL:OnGetFocus()
    hook.Run("OnTextEntryGetFocus", self)
    local parent = self:GetParent()
    if not parent then return end

    ---@diagnostic disable-next-line: undefined-field
    if parent.OnGetFocus then parent:OnGetFocus() end
end

function PANEL:OnLoseFocus()
    self:UpdateConvarValue()
    hook.Call("OnTextEntryLoseFocus", nil, self)
    local parent = self:GetParent()
    if not parent then return end

    ---@diagnostic disable-next-line: undefined-field
    if parent.OnLoseFocus then parent:OnLoseFocus() end
end

function PANEL:OnMousePressed(mcode)
    self:OnGetFocus()
end

function PANEL:AddHistory(txt)
    if not txt or txt == "" then return end
    table.RemoveByValue(self.History, txt)
    table.insert(self.History, txt)
end

function PANEL:GetAutoComplete(txt)
    local parent = self:GetParent()
    if not parent then return end

    ---@diagnostic disable-next-line: undefined-field
    if parent.GetAutoComplete then parent:GetAutoComplete() end
end

function PANEL:GetInt()
    local num = tonumber(self:GetText())
    if not num then return end

    return math.floor(num + 0.5)
end

function PANEL:GetFloat()
    return tonumber(self:GetText())
end

vgui.Register("PulsarUI.TextEntryInternal", PANEL, "TextEntry")