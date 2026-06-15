========================================================================
                      PRP-PETTYCRIME SETUP GUIDE
========================================================================

Cac buoc thiet lap de folder [prodigy] va prp-pettycrime hoat dong:

1. Sua loi folder prp-bridge bi long trong (Nesting Folder)
   - Di chuyen toan bo noi dung tu "prp-bridge/prp-bridge/*" ra thu muc goc "prp-bridge/".
   - Viec nay giup cac resource khac load duoc "@prp-bridge/import.lua" ma khong bi loi.

2. Loai bo dependency '/assetpacks' khong ton tai
   - Vo hieu hoa dong `dependency '/assetpacks'` trong ca 2 file fxmanifest.lua:
     + resources/[prodigy]/prp-pettycrime/fxmanifest.lua
     + resources/[prodigy]/prp-pettycrime-assets/fxmanifest.lua
   - Giup ngan chan loi thieu dependency khong khoi dong duoc resource tren FiveM.

3. Dang ky cac Item moi vao ox_inventory
   - Them khai bao cac item vao file: resources/[ox]/ox_inventory/data/items.lua
   - Cac item duoc khai bao bao gom:
     + envelope (Envelope)
     + catalog_envelope (Catalog Envelope)
     + letter (Letter)
     + pp_large_1 (Large Package)
     + pp_medium_1 (Medium Package)
     + pp_small_1 (Small Package A)
     + pp_small_2 (Small Package B)
     + pp_small_3 (Small Package C)

4. Copy Icons vat pham sang ox_inventory
   - Sao chep tat ca hinh anh (.png) tu thu muc:
     "resources/[prodigy]/prp-pettycrime/installation/inventory icons"
   - Sang thu muc web cua ox_inventory:
     "resources/[ox]/ox_inventory/web/images"
   - Dieu nay giup hien thi dung hinh anh vat pham trong tui do.

5. Cau hinh co so du lieu (SQL Database)
   - Script tu dong khoi chay ham `CreatePPTable()` khi bat dau, tu dong tao bang `porch_pirate_locations` neu chua co.
   - Ban khong can phai chay file SQL bang tay.

6. Khai bao khoi dong trong server.cfg
   - Trong file server.cfg cua ban da co san dong: `ensure [prodigy]`
   - Do do, ca 3 resources con (prp-bridge, prp-pettycrime, prp-pettycrime-assets) se tu dong duoc chay khi mo server.

========================================================================
             HUONG DAN CHI TIET TUNG NGHE (HOAT DONG PHAM TOI VAT)
========================================================================

Resource prp-pettycrime bao gom 6 hoat dong pham phap duong pho:

1. Moc tui (Pickpocket)
   - Cach thuc hien: Dung mat kinh/Target vao NPC va chon "Moc tui" (Pickpocket).
   - Cach choi: Hoan thanh minigame bam phim mui ten (rythmArrows).
   - Phan thuong: Tien mat le, dien thoai (phone), hoac dong xu vang (gold_coin).
   - Luu y: Co thoi gian hoi chieu (cooldown) tren ca nguoi choi va NPC.

2. Dap pha cot do xe (Parking Meters)
   - Yeu cau: Trang bi vu khi nhu WEAPON_BAT, WEAPON_CROWBAR, WEAPON_CHRISTMASBAT.
   - Cach thuc hien: Target vao cot do xe va chon "Dap pha" (Smash Up).
   - Cach hoat dong: Nguoi choi phai hoan thanh minigame nhip dieu bam phim mui ten (rythmArrows) truoc, sau do nhan vat moi bi co dinh tai cho de thuc hien dong tac dap pha cot do xe lap di lap lai lien tuc trong vong 1 phut de dap pha thanh cong.
   - Phan thuong: Tien le ben trong cot do xe.
   - Luu y: Dap pha se tang stress va co ti le bao dong Canh sat (10-90).

3. Cay hom thu ca nhan (Letterbox)
   - Yeu cau: Co dung cu be khoa (lockpick).
   - Cach thuc hien: Target vao hom thu truoc nha dan va chon "Be khoa" (Break Into).
   - Cach choi: Hoan thanh minigame match lo (holeMatch) voi dong tac be khoa cua PostBox. Neu thanh cong se chay tiep thanh tien trinh 5s luc hom thu (stealProgressBar) truoc khi nhan qua.
   - Phan thuong: Phong bi (envelope), phong bi catalog (catalog_envelope), thu (letter).
   - Luu y: Be khoa se lam hao mon do ben cua lockpick. Neu huy hoac fail giua chung thi khong bi tinh cooldown diem do.

4. Trom hom thu cong cong (Post Box)
   - Yeu cau: Co dung cu be khoa (lockpick).
   - Cach thuc hien: Target vao hom thu lon mau do/xanh tren pho, chon "Be khoa" (Lockpick) va luc loi.
   - Phan thuong: Nhieu phong bi thu voi cac do hiem ngau nhien.
   - CO CHE KET TAY: Co ti le 45% tay ban se bi ket. Bam phim lam minigame de tu go (unstuck).

5. Cuop buu pham truoc cua nha (Porch Pirate)
   - Cach thuc hien: Den khu dan cu co bieu kien dat san truoc nha, Target va "Lay buu pham" (Steal).
   - Cach mo: Goi nho mo luon, goi trung & lon phai co Dao (weapon_knife hoac weapon_switchblade) de rach.
   - Phan thuong: Tien mat, lockpick, thiet bi hack ATM, bom ATM, hat giong can sa, Ruby, v.v.
   - BAY KIM TUYEN (Glitterbomb): Mot so buu kien co bom kim tuyen. Khi mo se no gay ban va dinh GPS canh sat.
   - Admin: Dung lenh /ppadmin de tao/sua/tp toi diem spawn buu pham.

6. Boc thu & Ban thu cho Blackhat (Mail & Sell Letters)
   - Boc thu: Su dung (Use) vat pham envelope, catalog_envelope de lay thu (letter) hoac tien mat ben trong.
   - Ban thu: Tim den NPC Blackhat tren ban do, Target va chon "Ban thu" de doi lay tien mat.
   - Dac diem Blackhat: Tu dong doi vi tri ngau nhien sau moi 6-10 phut.
   - Admin: Dung lenh /bhadmin de mo menu dich chuyen nhanh hoac doi vi tri NPC.

========================================================================
                       HOAN TAT THIET LAP!
========================================================================
