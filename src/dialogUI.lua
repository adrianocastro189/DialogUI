---@diagnostic disable: undefined-global

-- ==========================================
-- DialogUI - Frame Position Management
-- ==========================================

-- Apply saved (x, y) position to both main frames.
-- x = left edge distance from screen left; y = top edge distance from screen bottom.
-- Both values come directly from GetLeft()/GetTop() so we restore via BOTTOMLEFT anchor.
-- y must be positive (> 0); a negative or zero value indicates stale data from an older
-- coordinate system and will be discarded so the frame defaults to centered.
local function DialogUI_ApplySavedPosition()
    local frames = { DQuestFrame, DGossipFrame };
    for _, frame in ipairs(frames) do
        frame:ClearAllPoints();
        if DialogUIDB.x and DialogUIDB.y and DialogUIDB.y > 0 then
            frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", DialogUIDB.x, DialogUIDB.y);
        else
            DialogUIDB.x = nil;
            DialogUIDB.y = nil;
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

-- Records an NPC conversation in the persistent history.
-- Skips blank texts and ignores entries already present (same npc + text).
function DialogUI_AddToHistory(npcName, gossipText)
    if not gossipText or gossipText == "" then
        return;
    end
    if not npcName or npcName == "" then
        npcName = "Unknown NPC";
    end
    local subzone = GetSubZoneText() or "";
    local zone = GetZoneText() or "";

    if not DialogUIDB.history then
        DialogUIDB.history = {};
    end

    for i = 1, getn(DialogUIDB.history) do
        local entry = DialogUIDB.history[i];
        if entry.npc == npcName and entry.text == gossipText then
            return;
        end
    end

    table.insert(DialogUIDB.history, {
        npc = npcName,
        subzone = subzone,
        zone = zone,
        text = gossipText
    });
end

-- /dialogui dump  – opens an on-screen text field with the full history so the
-- player can select and copy it (Ctrl+A, Ctrl+C), then clears the log.
SlashCmdList["DIALOGUI"] = function(msg)
    if msg == "dump" then
        if not DialogUIDB.history or getn(DialogUIDB.history) == 0 then
            DEFAULT_CHAT_FRAME:AddMessage("[DialogUI] No history to dump.");
            return;
        end
        local lines = {};
        for i = 1, getn(DialogUIDB.history) do
            local entry = DialogUIDB.history[i];
            local location;
            if entry.subzone ~= "" then
                location = entry.subzone .. ", " .. entry.zone;
            else
                location = entry.zone;
            end
            table.insert(lines, entry.npc .. ", " .. location);
            table.insert(lines, entry.text);
            table.insert(lines, "----");
        end
        DialogUIDB.history = {};
        DDialogUIDumpFrame_Show(table.concat(lines, "\n"));
    end
end;
SLASH_DIALOGUI1 = "/dialogui";

-- Initialise saved-variables and apply the saved (or default) position
-- once the player enters the world for the first time after login/reload.
local dialogUIFrame = CreateFrame("Frame", "DialogUI_PositionManagerFrame", UIParent);
dialogUIFrame:RegisterEvent("PLAYER_LOGIN");
dialogUIFrame:SetScript("OnEvent", function()
    if not DialogUIDB then
        DialogUIDB = {};
    end
    if not DialogUIDB.history then
        DialogUIDB.history = {};
    end
    DialogUI_ApplySavedPosition();
end);
