---@diagnostic disable: undefined-global

local LINE_HEIGHT_PX = 14; -- approximate pixels per line for the 12 pt EditBox font

-- Populates the dump frame EditBox with the formatted history text and shows
-- the frame centred on screen so the player can select and copy the content.
function DDialogUIDumpFrame_Show(text)
    DDialogUIDumpEditBox:SetText(text);

    -- Resize the EditBox to fit the content.
    local _, lineCount = string.gsub(text, "\n", "");
    lineCount = lineCount + 1;
    DDialogUIDumpEditBox:SetHeight(math.max(lineCount * LINE_HEIGHT_PX, 60));

    DDialogUIDumpScrollFrame:UpdateScrollChildRect();
    DDialogUIDumpScrollFrame:SetVerticalScroll(0);
    DDialogUIDumpEditBox:SetCursorPosition(0);
    DDialogUIDumpFrame:Show();
    DDialogUIDumpEditBox:SetFocus();
end
