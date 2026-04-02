-- local Translations = {
--     error = {
--         to_far_from_door = 'You are to far away from the Doorbell',
--         nobody_home = 'There is nobody home..',
--         nobody_at_door = 'There is nobody at the door...'
--     },
--     success = {
--         receive_apart = 'You got a apartment',
--         changed_apart = 'You moved apartments',
--     },
--     info = {
--         at_the_door = 'Someone is at the door!',
--     },
--     text = {
--         menu_header = 'Apartments',
--         door_outside = '[E] - Apartments',
--         enter = 'Enter Apartment',
--         ring_doorbell = 'Ring Doorbell',
--         logout = '[E] - Character Logout',
--         change_outfit = '[E] - Change Outfit',
--         open_stash = '[E] - Open Stash',
--         move_here = 'Move Here',
--         open_door = 'Open Door',
--         door_inside = '[E] - Door',
--         leave = 'Leave Apartment',
--         close_menu = '⬅ Close Menu',
--         tennants = 'Tennants',
--     },
-- }

-- Lang = Lang or Locale:new({
--     phrases = Translations,
--     warnOnMissing = true
-- })

local Translations = {
    error = {
        to_far_from_door = 'Bạn đứng quá xa chuông cửa',
        nobody_home = 'Không có ai ở nhà...',
        nobody_at_door = 'Không có ai ở cửa...'
    },
    success = {
        receive_apart = 'Bạn đã nhận được căn hộ',
        changed_apart = 'Bạn đã chuyển căn hộ',
    },
    info = {
        at_the_door = 'Có người ở cửa!',
    },
    text = {
        menu_header = 'Căn Hộ',
        door_outside = '[E] - Căn Hộ',
        enter = 'Vào Căn Hộ',
        ring_doorbell = 'Bấm Chuông',
        logout = '[E] - Đăng Xuất Nhân Vật',
        change_outfit = '[E] - Thay Đồ',
        open_stash = '[E] - Mở Kho Đồ',
        move_here = 'Chuyển Đến Đây',
        open_door = 'Mở Cửa',
        door_inside = '[E] - Cửa',
        leave = 'Rời Khỏi Căn Hộ',
        close_menu = '⬅ Đóng Menu',
        tennants = 'Cư Dân',
    },
}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
