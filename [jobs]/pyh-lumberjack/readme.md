# Hướng dẫn cài đặt pyh-lumberjack

---

## NPC Contact (pyh-contacts)

Thêm đoạn sau vào config của `pyh-contacts`:

```lua
{
    name   = "Axel Woodstone",
    text   = "Chào bạn, tôi là Axel, người quản lý xưởng gỗ này. Bạn muốn gia nhập đội của chúng tôi hay chỉ muốn xem tiến độ công việc?",
    domain = "Lumberjack",
    ped      = "a_m_m_hillbilly_01",
    scenario = "WORLD_HUMAN_BUM_STANDING",
    police   = true,
    coords   = vector4(-580.5613, 5368.8198, 69.3830, 340.4991),
    options  = {
        {
            label       = "Tôi muốn làm việc",
            requiredrep = 0,
            type        = "add",
            event       = "",
            data        = {
                text    = "Sẵn sàng cho một ngày làm việc chăm chỉ?",
                options = {
                    {
                        label       = "Chấm công vào / ra",
                        requiredrep = 0,
                        event       = "pyh-lumberjack:Sign",
                        type        = "client",
                        args        = {}
                    },
                    {
                        label = "Kết thúc hội thoại",
                        event = "",
                        type  = "none",
                        args  = {}
                    },
                }
            },
            args = {}
        },
        {
            label       = "Mở cửa hàng",
            requiredrep = 0,
            type        = "shop",
            items       = {
                {
                    name        = "axe",
                    description = "Dụng cụ",
                    requiredrep = 0,
                    price       = 350
                },
            },
            event = "",
            args  = {}
        },
        {
            label       = "Thuê xe Bison",
            requiredrep = 0,
            event       = "pyh-lumberjack:rentBison",
            type        = "client",
            args        = {}
        },
        {
            label       = "Bán gỗ",
            requiredrep = 0,
            event       = "pyh-lumberjack:sellWood",
            type        = "server",
            args        = {}
        },
        {
            label       = "Kết thúc hội thoại",
            requiredrep = 0,
            type        = "none",
            args        = {}
        },
    }
},
```

---

## Items (ox_inventory)

Thêm vào file `data/items.lua` của `ox_inventory`:

```lua
['axe'] = {
    label       = 'Rìu',
    weight      = 500,
    stack       = false,
    close       = true,
    description = 'Một chiếc rìu sắc bén.',
},

['log'] = {
    label       = 'Khúc gỗ',
    weight      = 500,
    stack       = true,
    close       = true,
    description = 'Khúc gỗ vừa được chặt.',
},

['cleanlog'] = {
    label       = 'Khúc gỗ sạch',
    weight      = 500,
    stack       = true,
    close       = true,
    description = 'Khúc gỗ đã được làm sạch.',
},

['rawplank'] = {
    label       = 'Ván gỗ thô',
    weight      = 500,
    stack       = true,
    close       = true,
    description = 'Ván gỗ thô chưa qua xử lý.',
},

['sandedplank'] = {
    label       = 'Ván gỗ đã chà nhám',
    weight      = 500,
    stack       = true,
    close       = true,
    description = 'Ván gỗ đã được chà nhám mịn.',
},

['finishwood'] = {
    label       = 'Gỗ thành phẩm',
    weight      = 500,
    stack       = true,
    close       = true,
    description = 'Gỗ đã hoàn thiện, sẵn sàng để bán.',
},
```

> **Lưu ý:** ox_inventory không dùng `unique`, `useable`, `combinable`, `type`, `image` trong items.lua.
> Ảnh item đặt tại `ox_inventory/web/images/<tên_item>.png`.

---

## Lưu ý khi dùng ox_inventory

Đoạn sửa `SaveStashItems` trong README gốc **không cần thiết** khi dùng `ox_inventory` vì ox_inventory tự xử lý stash persistence. Bỏ qua hoàn toàn.