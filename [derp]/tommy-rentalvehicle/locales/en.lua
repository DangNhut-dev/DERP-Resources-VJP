local Translations = {
    error = {
        not_enough_money = 'Bạn không có đủ tiền',
        not_vehicle_nearby = 'Không có phương tiện nào gần đây',
        nospotfound = 'Không còn chỗ trống',
    },
    success = {
        return_01 = 'Đã thuê xe với giá ',
        return_02 = '$, trả lại để nhận lại ',
        return_03 = '$ tiền cọc',
        return_04 = ' phương tiện đã được trả, bạn nhận lại ',
    },
    menu = {
        return_header = 'Trả xe',
        return_text = 'Trả lại tất cả phương tiện của bạn để nhận lại tiền cọc',
    }
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})