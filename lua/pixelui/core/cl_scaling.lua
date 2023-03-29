
--[[
PIXEL UI
Copyright (C) 2021 Tom O'Sullivan (Tom.bat)

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
]]

local scrH = scrH or ScrH()
function PIXEL.Scale(value)
    return value * (scrH / 1080)
end

local constants = {}
local scaledConstants = {}
function PIXEL.RegisterScaledConstant(varName, size)
    constants[varName] = size
    scaledConstants[varName] = PIXEL.Scale(size)
end

function PIXEL.GetScaledConstant(varName)
    return scaledConstants[varName]
end

hook.Add("OnScreenSizeChanged", "PIXEL.UI.UpdateScaledConstants", function()
    for varName, size in pairs(constants) do
        scaledConstants[varName] = PIXEL.Scale(size)
    end
    scrH = ScrH()
end)
