local _Translations = {
    -- TARGET
    target_npc_label    = 'Nhận Đơn Giao Hàng',
    target_police_check = 'Kiểm Tra Hàng Hóa',

    -- BLIPS
    blip_pickup  = 'Điểm Lấy Hàng',
    blip_dropoff = 'Điểm Giao Hàng',

    -- COMMANDS
    cmd_checkcargo      = 'Kiểm tra hàng hóa trong xe tải (Police)',
    cmd_confiscatecargo = 'Tịch thu hàng hóa bất hợp pháp và hủy job (Police)',

    -- SUCCESS
    success_registered      = 'Đăng ký xe thành công! Biển số: %{plate}',
    success_order_accepted  = 'Nhận đơn hàng thành công!',
    success_loaded          = 'Đã bốc %{current}/%{total} kg',
    success_all_loaded      = 'Đã bốc đủ hàng! Hãy đến điểm giao hàng',
    success_delivered       = 'Giao hàng thành công! +$%{money} | +%{exp} EXP',
    success_delivered_box   = 'Đã giao %{current}/%{total} kg',
    success_level_up        = 'Chúc mừng! Bạn đã lên Level %{level}!',
    success_delivered_party = 'Giao hàng thành công! +$%{money} | +%{exp} EXP (Chia 50/50)',
    success_party_created   = 'Tạo nhóm thành công!',
    success_invite_sent     = 'Đã gửi lời mời!',
    success_joined_party    = 'Đã tham gia nhóm!',
    success_member_joined   = '%{name} đã tham gia nhóm!',

    -- ERRORS – job
    error_no_vehicle                 = 'Bạn phải đăng ký xe trước!',
    error_wrong_vehicle              = 'Bạn phải sử dụng xe đã đăng ký!',
    error_vehicle_too_small          = 'Xe của bạn không đủ sức chứa!',
    error_vehicle_not_nearby         = 'Hãy mang xe đến cho tôi kiểm tra trước khi giao đơn!',
    error_vehicle_too_far_npc        = 'Xe quá xa! Hãy lái gần tôi hơn (Tối đa 20m)',
    error_wrong_vehicle_nearby       = 'Xe này không phải xe bạn đã đăng ký!',
    error_trunk_closed               = 'Hãy mở 2 cửa sau xe! (Door 2 & 3)',
    error_too_far                    = 'Xe quá xa! (Tối đa %{distance}m)',
    error_level_required             = 'Yêu cầu Level %{level}!',
    error_order_taken                = 'Đơn hàng đã có người nhận!',
    error_active_job                 = 'Bạn đang có đơn hàng chưa hoàn thành!',
    error_no_whitelisted             = 'Bạn không có xe tải nào phù hợp!',
    error_canceled                   = 'Đã hủy đơn hàng!',
    error_in_vehicle                 = 'Không thể thao tác khi đang trên xe!',
    error_not_behind                 = 'Hãy đứng phía SAU xe!',
    error_cannot_register_during_job = 'Không thể đăng ký xe khi đang làm việc!',
    error_cannot_load                = 'Không thể bốc hàng!',
    error_cannot_deliver             = 'Không thể giao hàng!',
    error_cargo_confiscated          = 'Cảnh sát đã tịch thu hàng cấm! Nhiệm vụ bị hủy.',
    error_order_not_found            = 'Không tìm thấy đơn hàng!',
    error_no_order                   = 'Không có đơn hàng!',
    error_already_loaded             = 'Đã bốc đủ hàng!',
    error_already_delivered          = 'Đã giao đủ hàng!',
    error_teammate_loading           = 'Đồng đội đang bốc thùng cuối!',
    error_teammate_delivering        = 'Đồng đội đang giao thùng cuối!',
    info_cancel_cooldown             = 'Bạn phải đợi %{time} phút nữa mới có thể nhận đơn!',

    -- ERRORS – party
    error_already_in_party   = 'Bạn đã có nhóm rồi!',
    error_has_active_job     = 'Bạn đang có đơn hàng, không thể tạo nhóm!',
    error_no_party           = 'Bạn chưa có nhóm!',
    error_not_leader         = 'Chỉ trưởng nhóm mới được thực hiện!',
    error_party_full         = 'Nhóm đã đủ người!',
    error_player_not_found   = 'Không tìm thấy người chơi!',
    error_target_in_party    = 'Người này đã có nhóm!',
    error_target_has_job     = 'Người này đang có đơn hàng!',
    error_no_invite          = 'Bạn không có lời mời nào!',
    error_party_not_found    = 'Nhóm không tồn tại!',
    error_invite_declined    = 'Lời mời đã bị từ chối!',
    error_not_in_party       = 'Bạn không ở trong nhóm!',
    error_no_member          = 'Nhóm chưa có thành viên!',
    error_party_not_full     = 'Nhóm phải có đủ 2 người mới nhận đơn được!',
    error_member_has_job     = 'Thành viên đang có đơn hàng!',
    error_job_canceled_party = 'Đơn hàng đã bị hủy do nhóm giải tán!',

    -- PARTY system
    party_disbanded           = 'Nhóm đã giải tán!',
    party_member_left         = 'Một thành viên đã rời nhóm, đơn hàng bị hủy!',
    party_member_disconnected = 'Một thành viên đã mất kết nối, đơn hàng bị hủy!',
    party_kicked              = 'Bạn đã bị kick khỏi nhóm!',
    invite_received           = 'mời bạn vào nhóm giao hàng!',

    -- INFO
    info_goto_pickup       = 'Đến điểm lấy hàng được đánh dấu!',
    info_goto_pickup_party = 'Cả nhóm hãy đến điểm lấy hàng được đánh dấu!',
    info_goto_dropoff      = 'Đến điểm giao hàng được đánh dấu!',
    info_start_loading     = 'Bắt đầu bốc hàng...',
    info_start_unloading   = 'Bắt đầu giao hàng...',
    info_taking_cargo      = 'Đang lấy hàng từ xe...',
    info_illegal_cargo     = 'ĐÂY LÀ HÀNG CẤM! Cẩn thận với cảnh sát!',

    -- PROGRESS BARS
    progress_loading   = 'Đang lấy hàng...',
    progress_loaded    = 'Đang xếp hàng lên xe...',
    progress_unloading = 'Đang xếp hàng...',
    progress_taking    = 'Đang lấy hàng từ xe...',

    -- ACTIONS (TextUI)
    action_pickup  = 'Lấy Hàng',
    action_load    = 'Xếp Hàng',
    action_take    = 'Lấy Hàng',
    action_deliver = 'Đặt Hàng Xuống',

    -- DOORS
    door_open          = 'Mở Cửa',
    door_close         = 'Đóng Cửa',
    door_opened_notify = 'Đã mở cửa xe',
    door_closed_notify = 'Đã đóng cửa xe',

    -- POLICE
    police_checking            = 'Đang kiểm tra hàng hóa...',
    police_confiscating        = 'Đang Tịch Thu...',
    police_found_illegal       = 'PHÁT HIỆN HÀNG CẤM!',
    police_found_legal         = 'Hàng hóa hợp pháp',
    police_no_cargo            = 'Xe này không chở hàng',
    police_confiscated_illegal = 'Đã tịch thu hàng cấm!',
    police_no_illegal          = 'Không có hàng cấm trong xe này.',
    error_not_police           = 'Bạn không phải cảnh sát!',
    error_no_truck_nearby      = 'Không có xe tải nào gần đây!',
    error_confiscate_failed    = 'Không thể tịch thu hàng hóa.',
}

function locale(key, params)
    local str = _Translations[key]
    if not str then return key end
    if params then
        str = str:gsub('%%{(%w+)}', function(k)
            return tostring(params[k] or '')
        end)
    end
    return str
end