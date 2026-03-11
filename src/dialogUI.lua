---@diagnostic disable: undefined-global

-- ==========================================
-- DialogUI - Frame Position Management
-- ==========================================

-- Apply saved (x, y) position to both main frames.
-- x = left edge distance from screen left; y = top edge distance from screen bottom.
-- Both values come directly from GetLeft()/GetTop() so we restore via BOTTOMLEFT anchor.
local function DialogUI_ApplySavedPosition()
    local frames = { DQuestFrame, DGossipFrame };
    for _, frame in ipairs(frames) do
        frame:ClearAllPoints();
        if DialogUIDB.x and DialogUIDB.y then
            frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", DialogUIDB.x, DialogUIDB.y);
        else
            frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0);
        end
    end
end

-- Called when a frame is dragged; saves position and syncs the other frame.
function DialogUI_OnFrameDragStop(movedFrame)
    movedFrame:StopMovingOrSizing();
    -- GetLeft() = x from screen left; GetTop() = y of top edge from screen bottom.
    -- Store raw screen coordinates so restore via BOTTOMLEFT works without needing
    -- UIParent:GetHeight(), which can return inconsistent values in vanilla 1.12.1.
    local x = movedFrame:GetLeft();
    local y = movedFrame:GetTop();
    DialogUIDB.x = x;
    DialogUIDB.y = y;
    local otherFrame;
    if movedFrame == DGossipFrame then
        otherFrame = DQuestFrame;
    else
        otherFrame = DGossipFrame;
    end
    otherFrame:ClearAllPoints();
    otherFrame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x, y);
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
