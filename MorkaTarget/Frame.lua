-- Author      : David
-- Create Date : 2/23/2025 8:35:25 AM

local GLOB_MapId;
local GLOB_POS;
local GLOB_LastDist;

local achievementIdList = {
    --fistful of love:
    1699,
    --Turkey Lurkey:
    3559
}

local GLOB_AchievementId;

-- Function to get the distance between two map positions
local function GetDistanceBetweenPositions(x1, y1, x2, y2)
    -- Calculate the Euclidean distance
    local dx = x2 - x1
    local dy = y2 - y1
    local distance = math.sqrt(dx * dx + dy * dy)
    return distance
end

function UpdateDistance()
    local playerPos = C_Map.GetPlayerMapPosition(GLOB_MapId, "player")
    local distance = GetDistanceBetweenPositions(
        playerPos.x * 100, playerPos.y * 100, GLOB_POS.x * 100, GLOB_POS.y * 100)
    if GLOB_LastDist and distance > GLOB_LastDist then
        print("Further")
    else
        print("Closer")
    end
    GLOB_LastDist = distance
    MO_Text_Distance:SetText(string.format("%.2f", distance))
end

function MorkaTargetMain_OnLoad()
    local EventFrame = CreateFrame("frame", "EventFrame")
    -- EventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
    EventFrame:RegisterEvent("UPDATE_MOUSEOVER_UNIT")

    local function OnTargetChanged(self, event, ...)
        local unit = "mouseover"
        if UnitIsPlayer(unit) then
            local targetRace = UnitRace(unit)
            local targetClass = UnitClass(unit)
            local targetRaceClass = targetRace .. " " .. targetClass
            local totalCriterias = GetAchievementNumCriteria(GLOB_AchievementId)
            Text_MO_Race:SetText(targetRace)
            Text_MO_Class:SetText(targetClass)
            for critIdx = 1, totalCriterias, 1 do
                local criteriaString, criteriaType, completed, quantity, reqQuantity,
                charName, flags, assetID, quantityString, criteriaID = GetAchievementCriteriaInfo(GLOB_AchievementId,
                    critIdx)

                if completed == false then
                    if targetRaceClass == criteriaString then
                        --SOUNDKIT:ALARM_CLOCK_WARNING_2
                        --12867
                        PlaySound(12867)
                        Text_Found_Name:SetText(UnitNameUnmodified(unit))
                        SetRaidTarget(unit, 8)
                    end
                end
            end
        end
    end

    EventFrame:SetScript("OnEvent", OnTargetChanged)

    PopulateItemList()
    print("MorkaTarget loaded")
end

-- Function to populate the item list
function PopulateItemList(filterMe)
    -- Clear existing items in a UIDropDownMenuTemplate
    UIDropDownMenu_Initialize(DropDownFrame, function(self, level, menuList)
        for i, item in ipairs(achievementIdList) do
            local info = UIDropDownMenu_CreateInfo()
            local achiName = select(2, GetAchievementInfo(item))
            info.text = achiName
            info.value = item
            info.func = function(self)
                local achiName = select(2, GetAchievementInfo(self.value))
                UIDropDownMenu_SetText(DropDownFrame, achiName)
                GLOB_AchievementId = self.value
            end
            UIDropDownMenu_AddButton(info)
        end
    end)
end
