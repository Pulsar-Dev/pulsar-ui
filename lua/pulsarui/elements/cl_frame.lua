local PANEL = {}
AccessorFunc(PANEL, "Draggable", "Draggable", FORCE_BOOL)
AccessorFunc(PANEL, "Sizable", "Sizable", FORCE_BOOL)
AccessorFunc(PANEL, "MinWidth", "MinWidth", FORCE_NUMBER)
AccessorFunc(PANEL, "MinHeight", "MinHeight", FORCE_NUMBER)
AccessorFunc(PANEL, "ScreenLock", "ScreenLock", FORCE_BOOL)
AccessorFunc(PANEL, "RemoveOnClose", "RemoveOnClose", FORCE_BOOL)

AccessorFunc(PANEL, "Title", "Title", FORCE_STRING)
AccessorFunc(PANEL, "ImgurID", "ImgurID", FORCE_STRING) -- Deprecated
AccessorFunc(PANEL, "ImageURL", "ImageURL", FORCE_STRING)

function PANEL:SetImgurID(id)
	assert(type(id) == "string", "bad argument #1 to SetImgurID, string expected, got " .. type(id))
	print("[PulsarUI] PulsarUI.Frame:SetImgurID is deprecated, use PulsarUI.Frame:SetImageURL instead")
	self:SetImageURL("https://i.imgur.com/" .. id .. ".png")
	self.ImgurID = id
end

function PANEL:GetImgurID()
	print("[PulsarUI] PulsarUI.Frame:GetImgurID is deprecated, use PulsarUI.Frame:GetImageURL instead")
	return (self:GetImageURL() or ""):match("https://i.imgur.com/(.-).png")
end

PulsarUI.RegisterFont("UI.FrameTitle", "Rubik", 20, 700)

function PANEL:Init()
	self.CloseButton = vgui.Create("PulsarUI.ImageButton", self)
	self.CloseButton:SetImageURL("https://pixel-cdn.lythium.dev/i/fh640z2o")
	self.CloseButton:SetNormalColor(PulsarUI.Colors.PrimaryText)
	self.CloseButton:SetHoverColor(PulsarUI.Colors.Negative)
	self.CloseButton:SetClickColor(PulsarUI.Colors.Negative)
	self.CloseButton:SetDisabledColor(PulsarUI.Colors.DisabledText)
	self.CloseButton:SetFrameEnabled(true)
	self.CloseButton:SetRounded(8)

	self.CloseButton.DoClick = function(s)
		self:Close()
	end

	self.ExtraButtons = {}
	self:SetTitle("PulsarUI Frame")
	self:SetDraggable(true)
	self:SetScreenLock(true)
	self:SetRemoveOnClose(true)
	local size = PulsarUI.Scale(200)
	self:SetMinWidth(size)
	self:SetMinHeight(size)
	local oldMakePopup = self.MakePopup

	function self:MakePopup()
		oldMakePopup(self)
		self:Open()
	end
end

function PANEL:DragThink(targetPanel, hoverPanel)
	local scrw, scrh = ScrW(), ScrH()
	local mousex, mousey = math.Clamp(gui.MouseX(), 1, scrw - 1), math.Clamp(gui.MouseY(), 1, scrh - 1)

	if targetPanel.Dragging then
		local x = mousex - targetPanel.Dragging[1]
		local y = mousey - targetPanel.Dragging[2]

		if targetPanel:GetScreenLock() then
			x = math.Clamp(x, 0, scrw - targetPanel:GetWide())
			y = math.Clamp(y, 0, scrh - targetPanel:GetTall())
		end

		targetPanel:SetPos(x, y)
	end

	local _, screenY = targetPanel:LocalToScreen(0, 0)

	if (hoverPanel or targetPanel).Hovered and targetPanel:GetDraggable() and mousey < (screenY + PulsarUI.Scale(30)) then
		targetPanel:SetCursor("sizeall")

		return true
	end
end

function PANEL:SizeThink(targetPanel, hoverPanel)
	local scrw, scrh = ScrW(), ScrH()
	local mousex, mousey = math.Clamp(gui.MouseX(), 1, scrw - 1), math.Clamp(gui.MouseY(), 1, scrh - 1)

	if targetPanel.Sizing then
		local x = mousex - targetPanel.Sizing[1]
		local y = mousey - targetPanel.Sizing[2]
		local px, py = targetPanel:GetPos()
		local screenLock = self:GetScreenLock()

		if x < targetPanel.MinWidth then
			x = targetPanel.MinWidth
		elseif x > scrw - px and screenLock then
			x = scrw - px
		end

		if y < targetPanel.MinHeight then
			y = targetPanel.MinHeight
		elseif y > scrh - py and screenLock then
			y = scrh - py
		end

		targetPanel:SetSize(x, y)
		targetPanel:SetCursor("sizenwse")

		return true
	end

	local screenX, screenY = targetPanel:LocalToScreen(0, 0)

	if (hoverPanel or targetPanel).Hovered and targetPanel.Sizable and mousex > (screenX + targetPanel:GetWide() - PulsarUI.Scale(20)) and mousey > (screenY + targetPanel:GetTall() - PulsarUI.Scale(20)) then
		(hoverPanel or targetPanel):SetCursor("sizenwse")

		return true
	end
end

function PANEL:Think()
	if self:DragThink(self) then return end
	if self:SizeThink(self) then return end
	self:SetCursor("arrow")

	if self.y < 0 then
		self:SetPos(self.x, 0)
	end
end

function PANEL:OnMousePressed()
	local screenX, screenY = self:LocalToScreen(0, 0)
	local mouseX, mouseY = gui.MouseX(), gui.MouseY()

	if self.Sizable and mouseX > (screenX + self:GetWide() - PulsarUI.Scale(30)) and mouseY > (screenY + self:GetTall() - PulsarUI.Scale(30)) then
		self.Sizing = {mouseX - self:GetWide(), mouseY - self:GetTall()}

		self:MouseCapture(true)

		return
	end

	if self:GetDraggable() and mouseY < (screenY + PulsarUI.Scale(30)) then
		self.Dragging = {mouseX - self.x, mouseY - self.y}

		self:MouseCapture(true)

		return
	end
end

function PANEL:OnMouseReleased()
	self.Dragging = nil
	self.Sizing = nil
	self:MouseCapture(false)
end

function PANEL:CreateSidebar(defaultItem, imageURL, imageScale, imageYOffset, buttonYOffset)
	if IsValid(self.SideBar) then return end
	self.SideBar = vgui.Create("PulsarUI.Sidebar", self)

	if defaultItem then
		timer.Simple(0, function()
			if not IsValid(self.SideBar) then return end
			self.SideBar:SelectItem(defaultItem)
		end)
	end

	if imageURL then
		local imgurMatch = (imageURL or ""):match("^[a-zA-Z0-9]+$")
		if imgurMatch then
			imageURL = "https://i.imgur.com/" .. imageURL .. ".png"
		end

		self.SideBar:SetImageURL(imageURL)
	end

	if imageScale then self.SideBar:SetImageScale(imageScale) end
	if imageYOffset then self.SideBar:SetImageOffset(imageYOffset) end
	if buttonYOffset then self.SideBar:SetButtonOffset(buttonYOffset) end

	return self.SideBar
end

function PANEL:AddHeaderButton(elem, size)
	elem.HeaderIconSize = size or .45

	return table.insert(self.ExtraButtons, elem)
end

function PANEL:Open()
	self:SetVisible(false)
	self:SetAlpha(0)
	self:SetVisible(true)
	self:AlphaTo(255, .1, 0)
end

function PANEL:Close()
	self:AlphaTo(0, .1, 0, function(anim, pnl)
		if not IsValid(pnl) then return end
		pnl:SetVisible(false)
		pnl:OnClose()

		if pnl:GetRemoveOnClose() then
			pnl:Remove()
		end
	end)
end

function PANEL:OnClose()
end

function PANEL:PerformLayout(w, h)
	self.HeaderH = PulsarUI.Scale(30)
	local btnPad = PulsarUI.Scale(6)
	local btnSpacing = PulsarUI.Scale(6)

	if IsValid(self.CloseButton) then
		local btnSize = self.HeaderH
		self.CloseButton:SetSize(btnSize, btnSize)
		self.CloseButton:SetPos(w - btnSize, (self.HeaderH - btnSize) / 2)
		btnPad = btnPad + btnSize + btnSpacing
	end

	for _, btn in ipairs(self.ExtraButtons) do
		local btnSize = self.HeaderH * (.6 or btn.HeaderIconSize)
		btn:SetSize(btnSize, btnSize)
		btn:SetPos(w - btnSize - btnPad, (self.HeaderH / 2) - (btnSize / 2))
		btnPad = btnPad + btnSize + btnSpacing
	end

	if IsValid(self.SideBar) then
		self.SideBar:SetPos(0, self.HeaderH)
		self.SideBar:SetSize(PulsarUI.Scale(200), h - self.HeaderH)
	end

	self.ContentPadding = PulsarUI.Scale(8)
	self:DockPadding(self.SideBar and PulsarUI.Scale(200) or self.ContentPadding, self.HeaderH, self.ContentPadding, self.ContentPadding)
	self:LayoutContent(w, h)
end

function PANEL:LayoutContent(w, h)
end

function PANEL:PaintHeader(x, y, w, h)
	PulsarUI.DrawRoundedBoxEx(PulsarUI.Scale(8), x, y, w, h, PulsarUI.Colors.Header, true, true)

	local imageURL = self:GetImageURL()
	if imageURL then
		local iconSize = h * .6
		PulsarUI.DrawImage(PulsarUI.Scale(6), x + (h - iconSize) / 2, y + iconSize, iconSize, imageURL, color_white)
		PulsarUI.DrawSimpleText(self:GetTitle(), "UI.FrameTitle", x + PulsarUI.Scale(12) + iconSize, y + h / 2, PulsarUI.Colors.PrimaryText, nil, TEXT_ALIGN_CENTER)
		return
	end

	PulsarUI.DrawSimpleText(self:GetTitle(), "UI.FrameTitle", x + PulsarUI.Scale(12), y + h / 2, PulsarUI.Colors.PrimaryText, nil, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
end

function PANEL:PaintMore(w, h)
end

function PANEL:Paint(w, h)
	PulsarUI.DrawRoundedBox(8, 0, 0, w, h, PulsarUI.Colors.Header)
	local contentX = self.SideBar and PulsarUI.Scale(200) or self.ContentPadding
	local contentY = self.HeaderH
	PulsarUI.DrawRoundedBoxEx(8, contentX, contentY, w - contentX - self.ContentPadding, h - contentY, PulsarUI.Colors.Background, true, true, true, true)
	self:PaintHeader(0, 0, w, self.HeaderH)
	self:PaintMore(w, h)
end

vgui.Register("PulsarUI.Frame", PANEL, "EditablePanel")