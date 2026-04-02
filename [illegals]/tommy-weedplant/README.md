# tommy-weedplant - Hệ thống trồng và chế biến cần sa

Resource FiveM cho nền tảng QBCore với chức năng trồng và chế biến cần sa hoàn chỉnh, có database persistence.

## 📋 Tính năng

### 🌱 Trồng cây
- Sử dụng hạt giống cần sa để trồng cây
- Kiểm tra loại đất hợp lệ (chỉ trồng được trên đất/cỏ)
- **Giới hạn 3 cây/người chơi**
- **YÊU CẦU: Tưới nước ít nhất 1 lần để cây bắt đầu phát triển**
- **Cooldown tưới nước: 30 phút giữa các lần tưới**
- Hệ thống tưới nước với chai nước
- 3 giai đoạn phát triển của cây
- Animation trồng cây và tưới nước chân thực
- **UI hiển thị thông tin cây: giai đoạn, thời gian còn lại, số lần tưới, cooldown**
- **Lưu trữ persistent vào database**

### 🍃 Thu hoạch
- Thu hoạch khi cây đã lớn đủ
- Phần thưởng phụ thuộc vào số lần tưới nước:
  - Tưới 1 lần: Nhận 1 lá cần sa tươi
  - Tưới 2+ lần: Nhận 2 lá cần sa tươi
- Animation thu hoạch chuyên nghiệp

### 🔥 Chế biến
- Điểm chế biến cần sa với qb-target
- **Minigame vẽ vòng tròn độc đáo:**
  - UI hiển thị lá cần sa tươi và máy sấy
  - Vẽ 10 vòng tròn bằng cách giữ chuột trái
  - Thanh tiến độ % hiển thị quá trình sấy
  - Thời gian: 60 giây
- Thành công: Nhận 1 lá cần sa khô
- Thất bại: Mất lá cần sa tươi

### 🛡️ Anti-Exploit
- **Cooldown giữa các hành động:**
  - Trồng cây: 2 giây
  - Click tưới nước: 3 giây
  - **Cooldown thực sự giữa các lần tưới: 30 phút (configurable)**
  - Thu hoạch: 2 giây
  - Chế biến: 5 giây
- **Kiểm tra khoảng cách:**
  - Tương tác cây: tối đa 5m
  - Chế biến: tối đa 10m
- **Giới hạn số cây:** Mỗi người chỉ trồng được 3 cây
- Kiểm tra ownership (chỉ chủ nhân mới thu hoạch được)
- **Server-side validation cho tất cả actions**

### 💾 Database
- Lưu trữ tất cả cây vào MySQL database
- Cây tồn tại qua resource restart
- Theo dõi: plant_id, citizenid, tọa độ, stage, water count, timestamps
- Auto-load khi resource start
- Auto-save khi resource stop

## 📦 Yêu cầu

- QBCore Framework
- qb-target
- qb-inventory (hoặc inventory tương thích)
- MySQL/MariaDB database
- oxmysql (hoặc mysql-async)

## 🔧 Cài đặt

### Bước 1: Import Database
```sql
-- Chạy file cannabis_plants.sql trong database của bạn
-- File này tạo bảng cannabis_plants để lưu trữ thông tin cây
```

Hoặc chạy SQL sau trực tiếp:
```sql
CREATE TABLE IF NOT EXISTS `cannabis_plants` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `plant_id` VARCHAR(50) NOT NULL,
    `citizenid` VARCHAR(50) NOT NULL,
    `coords` TEXT NOT NULL,
    `stage` INT(11) NOT NULL DEFAULT 1,
    `water_count` INT(11) NOT NULL DEFAULT 0,
    `is_watered` TINYINT(1) NOT NULL DEFAULT 0,
    `is_ready` TINYINT(1) NOT NULL DEFAULT 0,
    `planted_at` BIGINT(20) NOT NULL,
    `last_watered_at` BIGINT(20) DEFAULT NULL,
    `growth_started_at` BIGINT(20) DEFAULT NULL,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `plant_id` (`plant_id`),
    KEY `citizenid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### Bước 2: Copy resource
```bash
# Copy thư mục tommy-weedplant vào resources/[qb]/ hoặc resources/
```

### Bước 3: Thêm vào server.cfg
```cfg
ensure tommy-weedplant
```

### Bước 4: Thêm items vào qb-core

Thêm các items sau vào `qb-core/shared/items.lua`:

```lua
['cannabis_seed'] = {
    name = 'cannabis_seed',
    label = 'Hạt Giống Cần Sa',
    weight = 50,
    type = 'item',
    image = 'cannabis_seed.png',
    unique = false,
    useable = true,
    shouldClose = true,
    combinable = nil,
    description = 'Hạt giống cần sa để trồng trọt'
},

['fresh_cannabis'] = {
    name = 'fresh_cannabis',
    label = 'Lá Cần Sa Tươi',
    weight = 100,
    type = 'item',
    image = 'fresh_cannabis.png',
    unique = false,
    useable = false,
    shouldClose = true,
    combinable = nil,
    description = 'Lá cần sa tươi vừa thu hoạch, cần chế biến'
},

['dried_cannabis'] = {
    name = 'dried_cannabis',
    label = 'Lá Cần Sa Khô',
    weight = 80,
    type = 'item',
    image = 'dried_cannabis.png',
    unique = false,
    useable = false,
    shouldClose = true,
    combinable = nil,
    description = 'Lá cần sa đã được sấy khô và chế biến'
}
```

### Bước 5: Thêm hình ảnh items

Thêm các file hình ảnh sau vào `qb-inventory/html/images/`:
- `cannabis_seed.png`
- `fresh_cannabis.png`
- `dried_cannabis.png`

(Bạn cần tự tạo hoặc tìm hình ảnh phù hợp)

### Bước 6: Khởi động lại server

```
restart qb-core
restart tommy-weedplant
```

## ⚙️ Cấu hình

Mở file `config.lua` để tùy chỉnh:

### Giới hạn trồng cây
```lua
Config.MaxPlantsPerPlayer = 3 -- Số cây tối đa/người (mặc định: 3)
```

### Cài đặt trồng cây
```lua
Config.RequireWaterToGrow = true -- Cây phải tưới ít nhất 1 lần mới bắt đầu lớn
Config.GrowthTime = 5 * 60 * 1000 -- Thời gian phát triển SAU KHI tưới (5 phút)
Config.WaterItemName = 'water_bottle' -- Item dùng để tưới
Config.MaxWaterCount = 2 -- Số lần tưới tối đa
Config.WaterCooldown = 30 * 60 * 1000 -- Cooldown giữa các lần tưới (30 phút)
```

### Phần thưởng
```lua
Config.HarvestReward = {
    [1] = 1, -- Tưới 1 lần = 1 fresh_cannabis
    [2] = 2, -- Tưới 2+ lần = 2 fresh_cannabis
}
```

### Địa điểm chế biến
```lua
Config.ProcessingLocation = vector3(2333.13, 3126.87, 48.21)
```

### Minigame vẽ vòng tròn
```lua
Config.CircleDrawing = {
    RequiredCircles = 10, -- Số vòng tròn cần vẽ
    TimePerCircle = 5000, -- Thời gian mỗi vòng (5s)
    TotalTime = 60000, -- Tổng thời gian (60s)
    AccuracyRequired = 70, -- Độ chính xác (%)
}
```

### Anti-Exploit
```lua
Config.AntiExploit = {
    MinTimeBetweenPlants = 2000, -- Cooldown trồng (2s)
    MinTimeBetweenWatering = 3000, -- Cooldown click tưới (3s)
    MinTimeBetweenHarvest = 2000, -- Cooldown thu hoạch (2s)
    MinTimeBetweenProcessing = 5000, -- Cooldown chế biến (5s)
    MaxDistanceFromPlant = 5.0, -- Khoảng cách tối đa (5m)
    MaxDistanceFromProcessing = 10.0, -- Khoảng cách chế biến (10m)
}
```

## 🎮 Cách sử dụng

### Trồng cây
1. Có hạt giống cần sa trong túi
2. Đứng trên đất hoặc cỏ
3. Sử dụng hạt giống từ inventory
4. Cây sẽ xuất hiện tại vị trí của bạn
5. **Cây chưa phát triển cho đến khi được tưới lần đầu**
6. **Giới hạn: Tối đa 3 cây/người**

### Xem thông tin cây
1. Sử dụng qb-target nhắm vào cây
2. Chọn "Xem Thông Tin"
3. UI hiển thị:
   - Giai đoạn phát triển (1/3, 2/3, 3/3)
   - Thời gian còn lại (nếu đã tưới)
   - Số lần đã tưới nước
   - Thời gian cho đến khi có thể tưới lại
   - Trạng thái cây
4. Nhấn ESC hoặc nút X để đóng

### Tưới nước
1. Có chai nước trong túi
2. Sử dụng qb-target để tương tác với cây
3. Chọn "Tưới Nước"
4. **Lần tưới đầu tiên: Cây bắt đầu phát triển**
5. **Cooldown: Phải đợi 30 phút trước khi tưới lần tiếp theo**
6. Cây sẽ phát triển nhanh hơn khi được tưới đủ

### Thu hoạch
1. Đợi cây lớn đủ (5 phút sau khi tưới lần đầu)
2. Sử dụng qb-target để tương tác
3. Chọn "Thu Hoạch"
4. Nhận lá cần sa tươi (1-2 tùy số lần tưới)

### Chế biến
1. Đến điểm chế biến (tọa độ trong config)
2. Có ít nhất 1 lá cần sa tươi
3. Sử dụng qb-target
4. Chọn "Cắt và Sấy Cần Sa"
5. **Minigame:**
   - Giữ chuột trái và vẽ vòng tròn
   - Vẽ 10 vòng tròn để hoàn thành
   - Có 60 giây để hoàn thành
   - Thanh tiến độ hiển thị % hoàn thành
6. Thành công → Nhận lá cần sa khô
7. Thất bại → Mất lá cần sa tươi

## 🐛 Debug

Bật debug mode trong `config.lua`:
```lua
Config.Debug = true
```

Điều này sẽ hiển thị thông tin chi tiết trong console về:
- Plants saved/loaded from database
- Plant watered status
- Growth updates
- Processing results

## 📝 Lưu ý

- **Cây được lưu vào database và tồn tại qua restart**
- Mỗi người chơi chỉ trồng được tối đa 3 cây
- Hệ thống anti-exploit ngăn chặn spam và exploit
- Cây PHẢI được tưới ít nhất 1 lần để bắt đầu phát triển
- Cooldown 30 phút giữa các lần tưới (configurable)
- UI sử dụng NUI (HTML/CSS/JS) tích hợp
- Minigame vẽ vòng tròn sử dụng Canvas API

## 🎨 Cấu trúc Files

```
tommy-weedplant/
├── fxmanifest.lua
├── config.lua
├── README.md
├── cannabis_plants.sql (NEW)
├── client/
│   └── main.lua
├── server/
│   └── main.lua
├── shared/
│   └── items.lua
└── html/
    ├── index.html
    ├── style.css
    ├── script.js
    └── images/
        └── (placeholder)
```

## 🔄 Changelog

### Version 2.1.0 (Current)
- ✅ **DATABASE SUPPORT: Lưu cây vào MySQL database**
- ✅ **YÊU CẦU TƯỚI: Cây phải tưới ít nhất 1 lần mới phát triển**
- ✅ **COOLDOWN TƯỚI NƯỚC: 30 phút giữa các lần tưới (configurable)**
- ✅ Thêm timestamps: planted_at, last_watered_at, growth_started_at
- ✅ Persistent storage qua restart
- ✅ UI hiển thị thời gian cooldown tưới nước
- ✅ Tracking đầy đủ lifecycle của cây

### Version 2.0.0
- ✅ Thêm UI xem thông tin cây
- ✅ Minigame vẽ vòng tròn cho chế biến
- ✅ Giới hạn 3 cây/người chơi
- ✅ Hệ thống anti-exploit hoàn chỉnh
- ✅ Kiểm tra khoảng cách
- ✅ Cooldown giữa các hành động
- ✅ UI/UX được cải thiện

### Version 1.0.0
- ✅ Hệ thống trồng cây cơ bản
- ✅ Tưới nước và thu hoạch
- ✅ Chế biến với skillbar
- ✅ Config.lua dễ chỉnh sửa

## 📞 Hỗ trợ

Nếu gặp vấn đề, hãy kiểm tra:
1. Console F8 để xem lỗi client-side
2. Server console để xem lỗi server-side
3. Đảm bảo database đã được import
4. Kiểm tra oxmysql/mysql-async đang hoạt động
5. Đảm bảo tất cả dependencies đã được cài đặt
6. Kiểm tra items đã được thêm vào qb-core
7. Kiểm tra qb-target đang hoạt động

## 🚀 Tính năng tương lai

- [ ] Multiple processing locations
- [ ] Different plant types
- [ ] Fertilizer system
- [ ] Disease/pest system
- [ ] Weather effects on growth
- [ ] Watering can item
- [ ] Plant health system
- [ ] Mobile responsive UI
- [ ] Achievements system

## 📄 License

Miễn phí sử dụng cho mục đích cá nhân và thương mại.

---

**Version:** 2.1.0  
**Author:** Your Name  
**Framework:** QBCore  
**Dependencies:** qb-core, qb-target, MySQL
