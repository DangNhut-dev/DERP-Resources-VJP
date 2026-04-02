Clothing = {
    Active = false,
    SavedGender = false
}

-- Start clothing selection timer
function Clothing.Timer(gender)
    Clothing.SavedGender = gender
    Clothing.Active = true
    
    SendNUIMessage({
        type = "CREATE_CLOTHING_TIMER",
        time = Config.Identity.ClothingTimer,
        text = Translations.InfoText.clothing_timer_text
    })
end

-- NUI Callback: Clothing Timer Ended
RegisterNUICallback("clothing_timer_end", function(data, cb)
    Clothing.Active = false
    local savedGender = Clothing.SavedGender
    Framework.OpenSkinMenu(savedGender)
    Clothing.SavedGender = false
end)
