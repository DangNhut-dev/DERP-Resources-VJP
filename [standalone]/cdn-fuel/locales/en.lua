local Translations = {
    -- Nhiên liệu
    set_fuel_debug = "Đặt nhiên liệu thành:",
    cancelled = "Đã hủy.",
    not_enough_money = "Bạn không có đủ tiền!",
    not_enough_money_in_bank = "Tài khoản ngân hàng của bạn không đủ tiền!",
    not_enough_money_in_cash = "Tiền mặt trong túi của bạn không đủ!",
    more_than_zero = "Bạn phải đổ hơn 0L!",
    emergency_shutoff_active = "Các máy bơm hiện đang bị tắt qua hệ thống khóa khẩn cấp.",
    nozzle_cannot_reach = "Vòi bơm không với tới được!",
    station_no_fuel = "Trạm này đã hết nhiên liệu!",
    station_not_enough_fuel = "Trạm không có đủ lượng nhiên liệu này!",
    show_input_key_special = "Nhấn [G] khi đứng gần xe để đổ xăng!",
    tank_cannot_fit = "Bình nhiên liệu của bạn không chứa được!",
    tank_already_full = "Xe của bạn đã đầy nhiên liệu!",
    need_electric_charger = "Tôi cần đến trạm sạc điện!",
    cannot_refuel_inside = "Bạn không thể đổ xăng từ bên trong xe!",
    
    -- 2.1.2 -- Nhận nhiên liệu dự trữ ---
    fuel_order_ready = "Đơn đặt nhiên liệu của bạn đã sẵn sàng để lấy! Xem GPS để tìm điểm nhận hàng!",
    draw_text_fuel_dropoff = "[E] Giao Xe Tải",
    fuel_pickup_success = "Kho dự trữ của bạn đã được nạp đến: %sL",
    fuel_pickup_failed = "Ron Oil vừa giao nhiên liệu đến trạm của bạn!",
    trailer_too_far = "Rơ-moóc không được gắn vào xe tải hoặc ở quá xa!",

    -- 2.1.0
    no_nozzle = "Bạn không có vòi bơm!",
    vehicle_is_damaged = "Xe bị hư hỏng quá nặng, không thể đổ xăng!",
    vehicle_too_far = "Bạn đứng quá xa để đổ xăng cho xe này!",
    inside_vehicle = "Bạn không thể đổ xăng từ bên trong xe!",
    you_are_discount_eligible = "Nếu bạn vào ca làm việc, bạn có thể được giảm giá "..Config.EmergencyServicesDiscount['discount'].."%!",
    no_fuel = "Không có nhiên liệu..",

    -- Xe điện
    electric_more_than_zero = "Bạn phải sạc hơn 0KW!",
    electric_vehicle_not_electric = "Xe của bạn không phải xe điện!",
    electric_no_nozzle = "Xe của bạn không phải xe điện!",

    -- Điện thoại --
    electric_phone_header = "Trạm Sạc Điện",
    electric_phone_notification = "Tổng chi phí điện: $",
    fuel_phone_header = "Trạm Xăng",
    phone_notification = "Tổng chi phí: $",
    phone_refund_payment_label = "Hoàn tiền @ Trạm Xăng!",

    -- Trạm xăng
    station_per_liter = " / Lít!",
    station_already_owned = "Địa điểm này đã có chủ!",
    station_cannot_sell = "Bạn không thể bán địa điểm này!",
    station_sold_success = "Bạn đã bán địa điểm này thành công!",
    station_not_owner = "Bạn không phải chủ sở hữu địa điểm này!",
    station_amount_invalid = "Số lượng không hợp lệ!",
    station_more_than_one = "Bạn phải mua hơn 1L!",
    station_price_too_high = "Giá này quá cao!",
    station_price_too_low = "Giá này quá thấp!",
    station_name_invalid = "Tên này không hợp lệ!",
    station_name_too_long = "Tên không được dài hơn "..Config.NameChangeMaxChar.." ký tự.",
    station_name_too_short = "Tên phải dài hơn "..Config.NameChangeMinChar.." ký tự.",
    station_withdraw_too_much = "Bạn không thể rút nhiều hơn số dư của trạm!", 
    station_withdraw_too_little = "Bạn không thể rút ít hơn $1!",
    station_success_withdrew_1 = "Đã rút thành công $",
    station_success_withdrew_2 = " từ tài khoản của trạm!", -- Giữ khoảng trắng phía trước!
    station_deposit_too_much = "Bạn không thể nạp nhiều hơn số tiền bạn có!", 
    station_deposit_too_little = "Bạn không thể nạp ít hơn $1!",
    station_success_deposit_1 = "Đã nạp thành công $",
    station_success_deposit_2 = " vào tài khoản của trạm!", -- Giữ khoảng trắng phía trước!
    station_cannot_afford_deposit = "Bạn không đủ tiền để nạp $",
    station_shutoff_success = "Đã thay đổi trạng thái van khóa khẩn cấp của địa điểm này thành công!",
    station_fuel_price_success = "Đã thay đổi giá nhiên liệu thành công thành $",
    station_reserve_cannot_fit = "Kho dự trữ không chứa được lượng này!",
    station_reserves_over_max = "Bạn không thể mua số lượng này vì sẽ vượt quá mức tối đa "..Config.MaxFuelReserves.." Lít",
    station_name_change_success = "Đã đổi tên thành công thành: ", -- Giữ khoảng trắng phía sau!
    station_purchased_location_payment_label = "Đã mua một Trạm Xăng: ",
    station_sold_location_payment_label = "Đã bán một Trạm Xăng: ",
    station_withdraw_payment_label = "Đã rút tiền từ Trạm Xăng. Địa điểm: ",
    station_deposit_payment_label = "Đã nạp tiền vào Trạm Xăng. Địa điểm: ",

    -- Thanh tiến trình
    prog_refueling_vehicle = "Đang đổ xăng..",
    prog_electric_charging = "Đang sạc..",
    prog_jerry_can_refuel = "Đang nạp bình can..",
    prog_syphoning = "Đang hút nhiên liệu..",

    -- Menu
    menu_header_cash = "Tiền mặt",
    menu_header_bank = "Ngân hàng",
    menu_header_close = "Hủy",
    menu_pay_with_cash = "Thanh toán bằng tiền mặt.  \nBạn có: $",
    menu_pay_with_bank = "Thanh toán qua ngân hàng.", 
    menu_refuel_header = "Trạm Xăng",
    menu_refuel_accept = "Tôi muốn mua nhiên liệu.",
    menu_refuel_cancel = "Thôi, tôi không muốn đổ xăng nữa.",
    menu_pay_label_1 = "Xăng @ ",
    menu_pay_label_2 = " / L",
    menu_header_jerry_can = "Bình Can",
    menu_header_refuel_jerry_can = "Nạp Bình Can",
    menu_header_refuel_vehicle = "Đổ Xăng Xe",

    menu_electric_cancel = "Thôi, tôi không muốn sạc xe nữa.",
    menu_electric_header = "Trạm Sạc Điện",
    menu_electric_accept = "Tôi muốn thanh toán tiền điện.",
    menu_electric_payment_label_1 = "Điện @ ",
    menu_electric_payment_label_2 = " / KW",

    -- Menu Trạm Xăng
    menu_ped_manage_location_header = "Quản Lý Địa Điểm Này",
    menu_ped_manage_location_footer = "Nếu bạn là chủ sở hữu, bạn có thể quản lý địa điểm này.",

    menu_ped_purchase_location_header = "Mua Địa Điểm Này",
    menu_ped_purchase_location_footer = "Nếu không ai sở hữu địa điểm này, bạn có thể mua nó.",

    menu_ped_emergency_shutoff_header = "Bật/Tắt Khóa Khẩn Cấp",
    menu_ped_emergency_shutoff_footer = "Khóa nhiên liệu trong trường hợp khẩn cấp.   \n Các máy bơm hiện đang ",
    
    menu_ped_close_header = "Kết Thúc Hội Thoại",
    menu_ped_close_footer = "Thôi, tôi không muốn thảo luận gì nữa.",

    menu_station_reserves_header = "Mua Dự Trữ cho ",
    menu_station_reserves_purchase_header = "Mua dự trữ với giá: $",
    menu_station_reserves_purchase_footer = "Có, tôi muốn mua nhiên liệu dự trữ với giá $",
    menu_station_reserves_cancel_footer = "Thôi, tôi không muốn mua thêm dự trữ!",
    
    menu_purchase_station_header_1 = "Tổng chi phí sẽ là: $",
    menu_purchase_station_header_2 = " bao gồm thuế.",
    menu_purchase_station_confirm_header = "Xác Nhận",
    menu_purchase_station_confirm_footer = "Tôi muốn mua địa điểm này với giá $",
    menu_purchase_station_cancel_footer = "Thôi, tôi không muốn mua địa điểm này nữa. Giá điên quá!",

    menu_sell_station_header = "Bán ",
    menu_sell_station_header_accept = "Bán Trạm Xăng",
    menu_sell_station_footer_accept = "Có, tôi muốn bán địa điểm này với giá $",
    menu_sell_station_footer_close = "Thôi, tôi không có gì thêm để thảo luận.",

    menu_manage_header = "Quản Lý ",
    menu_manage_reserves_header = "Nhiên Liệu Dự Trữ  \n",
    menu_manage_reserves_footer_1 = " Lít trên tổng số ",
    menu_manage_reserves_footer_2 = " Lít  \nBạn có thể mua thêm dự trữ bên dưới!",
    
    menu_manage_purchase_reserves_header = "Mua Thêm Nhiên Liệu Dự Trữ",
    menu_manage_purchase_reserves_footer = "Tôi muốn mua thêm nhiên liệu dự trữ với giá $",
    menu_manage_purchase_reserves_footer_2 = " / L!",

    menu_alter_fuel_price_header = "Thay Đổi Giá Nhiên Liệu",
    menu_alter_fuel_price_footer_1 = "Tôi muốn thay đổi giá nhiên liệu tại Trạm Xăng của mình!  \nHiện tại là $",
    
    menu_manage_company_funds_header = "Quản Lý Quỹ Công Ty",
    menu_manage_company_funds_footer = "Tôi muốn quản lý quỹ của địa điểm này.",
    menu_manage_company_funds_header_2 = "Quản Lý Quỹ của ",
    menu_manage_company_funds_withdraw_header = "Rút Tiền",
    menu_manage_company_funds_withdraw_footer = "Rút tiền từ tài khoản của Trạm.",
    menu_manage_company_funds_deposit_header = "Nạp Tiền",
    menu_manage_company_funds_deposit_footer = "Nạp tiền vào tài khoản của Trạm.",
    menu_manage_company_funds_return_header = "Quay Lại",
    menu_manage_company_funds_return_footer = "Tôi muốn thảo luận điều khác!",

    menu_manage_change_name_header = "Đổi Tên Địa Điểm",
    menu_manage_change_name_footer = "Tôi muốn đổi tên địa điểm.",

    menu_manage_sell_station_footer = "Bán trạm xăng của bạn với giá $",

    menu_manage_close = "Thôi, tôi không có gì thêm để thảo luận!", 

    -- Menu Bình Can
    menu_jerry_can_purchase_header = "Mua Bình Can với giá $",
    menu_jerry_can_footer_full_gas = "Bình can của bạn đã đầy!",
    menu_jerry_can_footer_refuel_gas = "Nạp xăng cho bình can!",
    menu_jerry_can_footer_use_gas = "Dùng xăng trong bình can để đổ cho xe!",
    menu_jerry_can_footer_no_gas = "Bình can của bạn không có xăng!",
    menu_jerry_can_footer_close = "Thôi, tôi không muốn mua bình can nữa.",
    menu_jerry_can_close = "Thôi, tôi không muốn dùng cái này nữa.",

    -- Menu Bộ Hút Xăng
    menu_syphon_kit_full = "Bộ hút của bạn đã đầy! Chỉ chứa được " .. Config.SyphonKitCap .. "L!",
    menu_syphon_vehicle_empty = "Bình xăng của xe này đã cạn.",
    menu_syphon_allowed = "Hút xăng từ nạn nhân không hay biết!",
    menu_syphon_refuel = "Dùng xăng đã hút để đổ cho xe!",
    menu_syphon_empty = "Dùng xăng đã hút để đổ cho xe!",
    menu_syphon_cancel = "Thôi, tôi không muốn dùng cái này nữa. Tôi hoàn lương rồi!",
    menu_syphon_header = "Hút Xăng",
    menu_syphon_refuel_header = "Đổ Xăng",

    -- Ô nhập liệu --
    input_select_refuel_header = "Chọn lượng xăng cần đổ.",
    input_refuel_submit = "Đổ Xăng Xe",
    input_refuel_jerrycan_submit = "Nạp Bình Can",
    input_max_fuel_footer_1 = "Tối đa ",
    input_max_fuel_footer_2 = "L xăng.",
    input_insert_nozzle = "Cắm Vòi Bơm", -- Dùng cho Target nữa!

    input_purchase_reserves_header_1 = "Mua Dự Trữ  \nGiá hiện tại: $",
    input_purchase_reserves_header_2 = Config.FuelReservesPrice .. " / Lít  \nDự trữ hiện tại: ",
    input_purchase_reserves_header_3 = " Lít  \nChi phí nạp đầy: $",
    input_purchase_reserves_submit_text = "Mua Dự Trữ",
    input_purchase_reserves_text = 'Mua Nhiên Liệu Dự Trữ.',

    input_alter_fuel_price_header_1 = "Thay Đổi Giá Nhiên Liệu   \nGiá hiện tại: $",
    input_alter_fuel_price_header_2 = " / Lít",
    input_alter_fuel_price_submit_text = "Thay Đổi Giá",

    input_change_name_header_1 = "Đổi Tên ",
    input_change_name_header_2 = ".",
    input_change_name_submit_text = "Xác Nhận Đổi Tên",
    input_change_name_text = "Tên mới..",

    input_withdraw_funds_header = "Rút Tiền  \nSố dư hiện tại: $",
    input_withdraw_submit_text = "Rút",
    input_withdraw_text = "Rút Tiền",

    input_deposit_funds_header = "Nạp Tiền  \nSố dư hiện tại: $",
    input_deposit_submit_text = "Nạp",
    input_deposit_text = "Nạp Tiền",

    -- Target
    grab_electric_nozzle = "Lấy Vòi Sạc Điện",
    insert_electric_nozzle = "Cắm Vòi Sạc Điện",
    grab_nozzle = "Lấy Vòi Bơm",
    return_nozzle = "Trả Vòi Bơm",
    grab_special_nozzle = "Lấy Vòi Bơm Đặc Biệt",
    return_special_nozzle = "Trả Vòi Bơm Đặc Biệt",
    buy_jerrycan = "Mua Bình Can",
    station_talk_to_ped = "Trao Đổi Về Trạm Xăng",

    -- Bình Can
    jerry_can_full = "Bình can của bạn đã đầy!",
    jerry_can_refuel = "Nạp xăng cho bình can!",
    jerry_can_not_enough_fuel = "Bình can không có đủ lượng nhiên liệu này!",
    jerry_can_not_fit_fuel = "Bình can không chứa được lượng nhiên liệu này!",
    jerry_can_success = "Đã nạp đầy bình can thành công!",
    jerry_can_success_vehicle = "Đã đổ xăng xe thành công bằng bình can!",
    jerry_can_payment_label = "Đã mua Bình Can.",

    -- Hút Xăng
    syphon_success = "Đã hút xăng từ xe thành công!",
    syphon_success_vehicle = "Đã đổ xăng xe thành công bằng bộ hút!",
    syphon_electric_vehicle = "Xe này chạy điện!",
    syphon_no_syphon_kit = "Bạn cần có dụng cụ hút xăng.",
    syphon_inside_vehicle = "Bạn không thể hút xăng từ bên trong xe!",
    syphon_more_than_zero = "Bạn phải hút hơn 0L!",
    syphon_kit_cannot_fit_1 = "Bạn không thể hút nhiều như vậy, bình không đủ chỗ! Bạn chỉ có thể chứa thêm: ",
    syphon_kit_cannot_fit_2 = " Lít.",
    syphon_not_enough_gas = "Bạn không có đủ xăng để đổ nhiều như vậy!",
    syphon_dispatch_string = "(10-90) - Trộm Xăng",
}
Lang = Locale:new({phrases = Translations, warnOnMissing = true})