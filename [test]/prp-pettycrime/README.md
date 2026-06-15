# Hướng dẫn Setup prp-pettycrime (trong folder [prodigy])

Dưới đây là các bước đã được tự động thiết lập để folder `[prodigy]` chạy được:

## 1. Sửa lỗi thư mục lồng nhau (Nesting Folder)
- Di chuyển toàn bộ mã nguồn của thư mục con `prp-bridge/prp-bridge` ra ngoài thư mục gốc `prp-bridge/` để FiveM nhận diện đúng resource và load được `@prp-bridge/import.lua` mà các tài nguyên khác phụ thuộc vào.

## 2. Loại bỏ Dependency lỗi
- Vô hiệu hóa dòng `dependency '/assetpacks'` trong `fxmanifest.lua` của cả hai thư mục `prp-pettycrime` và `prp-pettycrime-assets`. Việc này giúp loại bỏ lỗi thiếu dependency trên console Server FiveM.

## 3. Khai báo các Item trong Inventory
- Đã đăng ký đầy đủ các item mới cần thiết cho tính năng trộm cắp vặt vào `resources/[ox]/ox_inventory/data/items.lua`:
  - `envelope` (Envelope)
  - `catalog_envelope` (Catalog Envelope)
  - `letter` (Letter)
  - `pp_large_1` (Large Package)
  - `pp_medium_1` (Medium Package)
  - `pp_small_1` (Small Package A)
  - `pp_small_2` (Small Package B)
  - `pp_small_3` (Small Package C)

## 4. Đồng bộ hóa Icons vật phẩm
- Đã sao chép toàn bộ các file ảnh icons vật phẩm từ `prp-pettycrime/installation/inventory icons` vào thư mục lưu trữ ảnh của inventory `resources/[ox]/ox_inventory/web/images/` để hiển thị đầy đủ hình ảnh của hòm đồ.

## 5. Cơ sở dữ liệu (SQL)
- Hệ thống tự động khởi tạo bảng SQL `porch_pirate_locations` lúc khởi chạy script, do đó bạn không cần import database bằng tay.

## 6. Khai báo khởi động Server
- Dòng `ensure [prodigy]` đã được khai báo sẵn trong file `server.cfg`, hệ thống sẽ tự động chạy toàn bộ các thư mục con bên trong `[prodigy]`.



```lua
['envelope'] = {
    label = 'Bao Thư',
    weight = 10,
    stack = true,
    close = true,
},
['catalog_envelope'] = {
    label = 'Cuộn Thư',
    weight = 15,
    stack = true,
    close = true,
},
['letter'] = {
    label = 'Lá Thư',
    weight = 5,
    stack = true,
    close = true,
},

['kimloaisieucung'] = {
    label = 'Kim loại siêu cứng',
    weight = 5000,
    stack = false,
    close = true,
},

['banhrang'] = {
    label = 'Bánh răng',
    weight = 5000,
    stack = false,
    close = true,
},

['giaygoiymot'] = {
    label = 'Giấy gợi ý điểm ẩn',
    weight = 1000,
    stack = false,
    close = true,
    description = 'Đi đến nơi có gió',
},

['banvesung'] = {
    label = 'Bản vẻ súng lục',
    weight = 1000,
    stack = false,
    close = true,
},

['hoachattayrua'] = {
    label = 'Hóa chất tẩy rửa',
    weight = 2000,
    stack = false,
    close = true,
},
```

---

# Hướng Dẫn Chi Tiết Từng Nghề (Các hoạt động phạm tội vặt)

Resource `prp-pettycrime` bao gồm 6 hoạt động phạm pháp đường phố khác nhau:

### 1. Móc túi (Pickpocket)
- **Cách thực hiện:** Tiếp cận các NPC đi bộ trên đường phố, dùng mắt kính/phím Target vào NPC và chọn **"Móc túi" (Pickpocket)**.
- **Cách hoạt động:** Người chơi cần hoàn thành minigame nhịp điệu bấm phím mũi tên (`rythmArrows`).
- **Phần thưởng:** Tiền mặt lẻ, điện thoại (`phone`), hoặc đồng xu vàng (`gold_coin`).
- **Lưu ý:** Có thời gian hồi chiêu (cooldown) áp dụng cho cả người chơi (ngăn spam) và trên NPC (NPC sẽ cảnh giác hơn nếu vừa bị móc túi hụt).

### 2. Đập phá cột đỗ xe (Parking Meters)
- **Yêu cầu:** Trang bị vũ khí cận chiến được phép (Gậy bóng chày `WEAPON_BAT`, Xà beng `WEAPON_CROWBAR`, hoặc Gậy Noel `WEAPON_CHRISTMASBAT`).
- **Cách thực hiện:** Đến gần các cột đỗ xe (Parking Meter) trên vỉa hè, dùng Target chọn **"Đập phá" (Smash Up)**.
- **Cách hoạt động:** Người chơi phải hoàn thành minigame nhịp điệu bấm phím mũi tên (`rythmArrows`) trước, sau đó nhân vật mới bị cố định tại chỗ để thực hiện động tác đập phá cột đỗ xe lặp đi lặp lại liên tục trong vòng 1 phút để đập phá thành công.
- **Phần thưởng:** Nhận được tiền mặt từ các đồng xu bên trong cột.
- **Lưu ý:** Hành động đập phá sẽ tăng chỉ số stress của người chơi và có cơ hội gửi thông báo cảnh báo (Dispatch) cho Cảnh sát (10-90).

### 3. Cạy hòm thư cá nhân (Letterbox / Hòm thư nhà dân)
- **Yêu cầu:** Có dụng cụ bẻ khóa (`lockpick`).
- **Cách thực hiện:** Tiếp cận hòm thư trước các căn hộ/nhà dân, dùng Target chọn **"Bẻ khóa" (Break Into)**.
- **Cách hoạt động:** Hoàn thành minigame căn khớp lỗ (`holeMatch`) cùng động tác bẻ khóa của PostBox (`postboxlockpick`). Nếu thành công, dụng cụ bẻ khóa sẽ bị hao mòn và nhân vật tiếp tục thực hiện thanh tiến trình lục hòm thư (`stealProgressBar`) trong vòng 5 giây trước khi nhận phần thưởng.
- **Phần thưởng:** Nhận được Phong bì (`envelope`), Phong bì Catalog (`catalog_envelope`), Thư (`letter`) hoặc không có gì.
- **Lưu ý:** Mỗi lần thử bẻ khóa sẽ làm hao mòn độ bền của dụng cụ bẻ khóa (Lockpick). Cảnh sát có thể nhận được thông báo báo động. Nếu hủy bỏ giữa chừng hoặc bẻ khóa thất bại, hòm thư sẽ không bị rơi vào trạng thái hồi chiêu và có thể thử lại.

### 4. Trộm hòm thư công cộng (Post Box)
- **Yêu cầu:** Có dụng cụ bẻ khóa (`lockpick`).
- **Cách thực hiện:** Tìm các hòm thư công cộng lớn màu đỏ/xanh lá trên phố, Target chọn **"Bẻ khóa" (Lockpick)**.
- **Cách hoạt động:** Vượt qua minigame khớp lỗ (`holeMatch`) để mở khóa hòm thư công cộng và tiến hành lục lọi (Search).
- **Phần thưởng:** Nhận được nhiều phong bì thư với các độ hiếm ngẫu nhiên.
- **CƠ CHẾ KẸT TAY:** Có tỉ lệ khoảng **45%** tay của người chơi sẽ bị kẹt bên trong khe hòm thư. Khi bị kẹt, màn hình sẽ hiển thị nút bấm để gỡ tay ra (`unstuck`) thông qua minigame. Nếu thất bại, bạn tiếp tục bị kẹt và có thể bị cảnh sát bắt quả tang.

### 5. Cướp bưu phẩm trước cửa nhà (Porch Pirate)
- **Cách thực hiện:** Tìm các bưu kiện/gói hàng được giao trước cửa nhà dân. Target chọn **"Lấy bưu phẩm" (Steal)** để ôm gói hàng đi.
- **Mở gói hàng:** 
  - Gói hàng nhỏ (`pp_small`): Có thể mở trực tiếp.
  - Gói hàng trung (`pp_medium`) và lớn (`pp_large`): **Yêu cầu phải có Dao** trong người (`weapon_knife` hoặc `weapon_switchblade`) để rạch gói hàng.
- **Phần thưởng:** Tiền mặt, Lockpick, Thiết bị hack ATM (`atm_hack_device`), Bom ATM (`atm_bomb`), Hạt giống cần sa (`seeds_weed`), Đá Ruby, v.v.
- **CƠ CHẾ BẪY KIM TUYẾN (Glitterbomb):** Một số bưu phẩm sẽ chứa bẫy Glitterbomb. Khi mở ra, bom kim tuyến phát nổ làm bẩn người chơi, đồng thời kích hoạt cảnh báo GPS báo cho Cảnh sát. Bạn phải thực hiện hành động phủi bụi kim tuyến để làm sạch bản thân. Cảnh sát có nhiệm vụ có thể tiến hành gỡ bom kim tuyến này.
- **Dành cho Admin:** Dùng lệnh `/ppadmin` để mở Menu Porch Pirate nhằm tạo, sửa hoặc dịch chuyển nhanh đến các điểm spawn bưu kiện.

### 6. Bóc thư & Bán thư cho Blackhat (Mail & Sell Letters)
- **Bóc phong bì:** Sử dụng (Use) các vật phẩm `envelope` hoặc `catalog_envelope` trong túi đồ của bạn để bóc chúng ra và nhận các bức thư (`letter`) hoặc tiền mặt ẩn bên trong.
- **Bán thư:** Thu thập các bức thư (`letter`), tìm đến NPC Blackhat để bán thư lấy tiền mặt nhanh.
- **Đặc điểm NPC Blackhat:** NPC này sẽ liên tục thay đổi vị trí ngẫu nhiên sau một khoảng thời gian (khoảng 6-10 phút) để tránh bị cảnh sát phát hiện.
- **Dành cho Admin:** Dùng lệnh `/bhadmin` để mở Menu Blackhat giúp dịch chuyển đến vị trí NPC hoặc ra lệnh chuyển NPC sang địa điểm ngẫu nhiên tiếp theo.


