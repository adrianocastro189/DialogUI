---@diagnostic disable: undefined-global

-- ==========================================
-- DialogUI - Frame Position Management
-- ==========================================

-- Apply saved (x, y) position to both main frames.
-- x and y are offsets from UIParent's TOPLEFT anchor (x positive right, y negative down).
local function DialogUI_ApplySavedPosition()
    local frames = { DQuestFrame, DGossipFrame };
    for _, frame in ipairs(frames) do
        frame:ClearAllPoints();
        if DialogUIDB.x and DialogUIDB.y then
            frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", DialogUIDB.x, DialogUIDB.y);
        else
            frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0);
        end
    end
end

-- Called when a frame is dragged; saves position and syncs the other frame.
function DialogUI_OnFrameDragStop(movedFrame)
    movedFrame:StopMovingOrSizing();
    local x = movedFrame:GetLeft();
    local y = movedFrame:GetTop() - UIParent:GetHeight();
    DialogUIDB.x = x;
    DialogUIDB.y = y;
    local otherFrame;
    if movedFrame == DGossipFrame then
        otherFrame = DQuestFrame;
    else
        otherFrame = DGossipFrame;
    end
    otherFrame:ClearAllPoints();
    otherFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", x, y);
end

-- Initialise saved-variables and apply the saved (or default) position
-- once the player enters the world for the first time after login/reload.
local dialogUIFrame = CreateFrame("Frame", "DialogUI_PositionManagerFrame", UIParent);
dialogUIFrame:RegisterEvent("PLAYER_LOGIN");
dialogUIFrame:SetScript("OnEvent", function()
    if not DialogUIDB then
        DialogUIDB = {};
    end
    DialogUI_ApplySavedPosition();
end);
