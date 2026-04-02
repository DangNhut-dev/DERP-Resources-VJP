for i = 1, #Config.CustomFonts do
    local font = Config.CustomFonts[i]
    RegisterFontFile(font.filename)
    local fontId = RegisterFontId(font.label)
    table.insert(Config.Fonts, {value = fontId, label = font.label})
end
