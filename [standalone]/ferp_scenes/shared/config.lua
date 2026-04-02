Config = {}

Config.Language = 'vi'-- General Configuration
Config.MaxTextLength = 255
Config.MaxDistance = 20.0
Config.MinDistance = 0.5
Config.DefaultDistance = 5.0
Config.UpdateInterval = 1000 -- ms
Config.FadeSpeed = 0.15

-- Max distance to check nearby scenes
Config.CheckDistance = 50.0

-- Default duration for scenes
Config.DefaultDuration = 4 -- hours
Config.MaxDuration = 168 -- 7 days

-- Scene Limits
Config.MaxScenesPerPlayer = 10 -- Max scenes per player
Config.MaxScenesGlobal = 200 -- Max scenes on server

-- Font Configuration
Config.Fonts = {
    {value = 0, label = 'Default'},
    {value = 1, label = 'Fancy'},
    {value = 2, label = 'Monospace'},
    {value = 4, label = 'Compressed'},
    {value = 7, label = 'GTA'},
}

-- Custom Fonts from stream folder
Config.CustomFonts = {
    {filename = "ArialNarrow", label = "Arial Narrow"},
    {filename = "Lato", label = "Lato"},
    {filename = "Inkfree", label = "Inkfree"},
    {filename = "Kid", label = "Kid"},
    {filename = "Strawberry", label = "Strawberry"},
    {filename = "PaperDaisy", label = "Paper Daisy"},
    {filename = "ALittleSunshine", label = "A Little Sunshine"},
    {filename = "WriteMeASong", label = "Write Me A Song"},
    {filename = "BeatStreet", label = "Beat Street"},
    {filename = "DirtyLizard", label = "Dirty Lizard"},
    {filename = "Maren", label = "Maren"},
    {filename = "HappyDay", label = "Happy Day"},
    {filename = "ImpactLabel", label = "Impact Label"},
    {filename = "Easter", label = "Easter"},
    {filename = "Christmas", label = "Christmas"},
    {filename = "Halloween", label = "Halloween"},
}

-- Font Sizes
Config.FontSizes = {
    {value = 0.3, label = 'Very Small'},
    {value = 0.5, label = 'Small'},
    {value = 0.7, label = 'Medium'},
    {value = 1.0, label = 'Large'},
    {value = 1.3, label = 'Very Large'},
}

-- Available Colors
Config.Colors = {
    {value = 'white', label = 'White', rgb = {255, 255, 255}},
    {value = 'black', label = 'Black', rgb = {0, 0, 0}},
    {value = 'red', label = 'Red', rgb = {255, 0, 0}},
    {value = 'green', label = 'Green', rgb = {0, 255, 0}},
    {value = 'blue', label = 'Blue', rgb = {0, 0, 255}},
    {value = 'yellow', label = 'Yellow', rgb = {255, 255, 0}},
    {value = 'purple', label = 'Purple', rgb = {138, 43, 226}},
    {value = 'orange', label = 'Orange', rgb = {255, 165, 0}},
    {value = 'pink', label = 'Pink', rgb = {255, 192, 203}},
    {value = 'cyan', label = 'Cyan', rgb = {0, 255, 255}},
}

-- Background Configuration
Config.BackgroundStyles = {
    {value = 'none', label = 'No Background'},
    {value = 'solid', label = 'Solid Background'},
    {value = 'transparent', label = 'Transparent Background'},
}

-- Custom Backgrounds
Config.CustomBackgrounds = {
     {value = 'blood', label = 'Blood Background', dict = 'scenes', texture = 'blood'},
     {value = 'blood1', label = 'Blood 1 Background', dict = 'scenes', texture = 'blood1'},
     {value = 'blood2', label = 'Blood 2 Background', dict = 'scenes', texture = 'blood2'},
     {value = 'brush', label = 'Brush Background', dict = 'scenes', texture = 'brush'},
     {value = 'metal', label = 'Metal Background', dict = 'scenes', texture = 'metal'},
     {value = 'note', label = 'Note Background', dict = 'scenes', texture = 'note'},
     {value = 'note1', label = 'Note 1 Background', dict = 'scenes', texture = 'note1'},
     {value = 'note2', label = 'Note 2 Background', dict = 'scenes', texture = 'note2'},
     {value = 'note3', label = 'Note 3 Background', dict = 'scenes', texture = 'note3'},
     {value = 'note4', label = 'Note 4 Background', dict = 'scenes', texture = 'note4'},
     {value = 'note5', label = 'Note 5 Background', dict = 'scenes', texture = 'note5'},
     {value = 'note6', label = 'Note 6 Background', dict = 'scenes', texture = 'note6'},
     {value = 'spray', label = 'Spray Background', dict = 'scenes', texture = 'spray'},
}

-- Permissions
Config.AdminOnly = false -- If true, only admins can create scenes
Config.AdminGroups = {'admin', 'god'}