---@diagnostic disable: undefined-global

-- ==========================================
-- DialogUI - Frame Position Management
-- ==========================================

local DEFAULT_POSITION = "center";

-- Apply the given position ("center" or "default") to the main frames.
function DialogUI_ApplyPosition(position)
    local frames = { DQuestFrame, DGossipFrame };
    for _, frame in ipairs(frames) do
        frame:ClearAllPoints();
        if position == "center" then
            frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0);
        else
            frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, -104);
        end
    end
end

-- Initialise saved-variables and apply the saved (or default) position
-- once the player enters the world for the first time after login/reload.
local dialogUIFrame = CreateFrame("Frame", "DialogUI_PositionManagerFrame", UIParent);
dialogUIFrame:RegisterEvent("PLAYER_LOGIN");
dialogUIFrame:SetScript("OnEvent", function()
    if not DialogUIDB then
        DialogUIDB = {};
    end
    if not DialogUIDB.position then
        DialogUIDB.position = DEFAULT_POSITION;
    end
    DialogUI_ApplyPosition(DialogUIDB.position);
end);

-- Slash command: /dialogui center | /dialogui default
SLASH_DIALOGUI1 = "/dialogui";
SlashCmdList["DIALOGUI"] = function(msg)
    local cmd = string.lower(msg or "");
    if cmd == "center" then
        DialogUIDB.position = "center";
        DialogUI_ApplyPosition("center");
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00DialogUI:|r Frames centered.");
    elseif cmd == "default" then
        DialogUIDB.position = "default";
        DialogUI_ApplyPosition("default");
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00DialogUI:|r Frames restored to default position.");
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00DialogUI:|r Usage: /dialogui [center|default]");
    end
end;
