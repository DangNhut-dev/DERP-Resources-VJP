if not Lang then Lang = {} end
Lang['ja'] = {
	['open'] = "~y~E~w~ を押して開く",
	['open_main_target'] = "釣りメニューを開く",
	['open_property_target'] = "釣り用不動産を開く",
	['open_store_target'] = "釣りショップを開く",
	['you_died'] = "死んだので乗り物を失いました",
	['insufficient_money'] = "お金が足りません",
	['invalid_value'] = "無効な値です",
	['no_permission'] = "このメニューを開くために必要なジョブがありません",
	['not_enough_level'] = "このアイテムを使用するにはレベルが足りません",
	['fish_store_sold'] = "%sx %s を販売しました",
	['fish_store_all_sold'] = "魚をすべて ¥%s で売りました",
	['fish_store_nothing_sold'] = "この店では売れる魚を持っていません",
	['fish_store_not_enough'] = "販売できる %sx %s を持っていません",
	['exp'] = "経験値",

	['anchor_boat_command'] = "イカリを下ろす",
	['anchor_too_fast'] = "イカリを使うには速度を落としてください",
	['anchor_not_allowed'] = "ここにはイカリを下ろせません",
	['anchor_lowered'] = "イカリを下ろした",
	['anchor_raised'] = "イカリを上げた",

	['contract_invalid'] = "この契約はもう存在しません",
	['contract_started'] = "契約を開始し、必要な製品を目的地に配送します",
	['contract_already_started'] = "すでに契約を結んでいるので、まずはそれを終わらせてください",
	['contract_someone_already_started'] = "すでに他のユーザーがこの契約を開始しています。別の契約を選択してください",
	['contract_waypoint_set'] = "契約遂行へのウェイポイントがGPSにマークされました",
	['contract_finish_delivery'] = "配達を完了するには ~y~E~w~ を押してください",
	['contract_received_money'] = "契約完了のために ¥%s を受け取りました",
	['contract_received_item'] = "契約完了のために %sx %s を受け取りました",
	['contract_received_item_error'] = "%sx %s を受け取るのに十分なスペースがありません",
	['contract_destination_blip'] = "目的地",
	['contract_cancel'] = "契約をキャンセルしました",
	['contract_not_enough_items'] = "必要なアイテムがありません: %s",

	['dive_invalid'] = "このダイビングポイントはもう存在しません",
	['dive_started'] = "ダイビングを開始しました、宝物を探しに行きましょう",
	['dive_already_started'] = "すでにダイビングを開始しています、まずはそれを終了してください",
	['dive_someone_already_started'] = "他の誰かがすでにこのダイビングを開始しています、別のダイビングポイントを選択してください",
	['dive_waypoint_set'] = "ダイビングエリアへのウェイポイントが GPS にマークされました",
	['dive_received_money'] = "ダイビングを終了して ¥%s を受け取りました",
	['dive_received_item'] = "ダイビングを終了して %sx %s を受け取りました",
	['dive_received_item_error'] = "%sx %s を受け取るのに十分なスペースがありません",
	['dive_cancel'] = "ダイビングをキャンセルしました",
	['dive_finish'] = "ダイビングを終了するには ~y~E~w~ を押してください",

	['money_withdrawn'] = "引き出し金額",
	['money_deposited'] = "預け入れ金額",
	['pay_loans'] = "お金を引き出す前にローンを返済する必要があります",
	['loan'] = "ローンが組まれました",
	['no_loan'] = "このローンは利用できません",
	['loan_paid'] = "ローンが支払われました",
	['no_loan_money'] = "ローンを返済するお金がありません、すべてを失いました",

	['upgrade_purchased'] = "アップグレードしました",
	['equipment_purchased'] = "装備を購入しました",
	['insufficient_skill_points'] = "スキルポイントが不足しています",

	['occupied_places'] = "ガレージは使用中です。駐車スペースを塞いでいる障害物があれば取​​り除くことを検討してください",
	['vehicle_blip'] = "乗り物",
	['garage_blip'] = 'ガレージ',
	['press_e_to_store_vehicle'] = '~w~ ~g~[E]~w~ を押して ~b~vehicle~w~ を保管してください',
	['vehicle_already_spawned'] = 'すでに乗り物を所有しています',
	['vehicle_lost'] = '世界のどこかで乗り物を紛失しました',

	['garage_full'] = 'ガレージが満杯です',
	['vehicle_purchased'] = "乗り物を購入しました",
	['vehicle_repaired'] = "乗り物を修理しました",
	['vehicle_refueled'] = "乗り物に給油しました",
	['vehicle_already_repaired'] = "この乗り物は既に修理されています",
	['vehicle_already_refueled'] = "この乗り物は既に給油されています",
	['vehicle_not_found'] = "乗り物が見つかりません",
	['vehicle_damaged'] = "乗り物が損傷しすぎています",
	['vehicle_sold'] = "乗り物を ¥%s で販売しました",
	['vehicle_spawned'] = "乗り物がガレージにあります",
	['vehicle_capacity_full'] = "乗り物の容量がいっぱいです",
	['vehicle_owned_name'] = "所有車両",
	['vehicle_destroyed'] = "車両が破壊されました",

	['stock_item_deposited'] = "預けられたアイテム",
	['dont_have_item'] = "インベントリーに %sx %s 個のアイテムがありません",
	['stock_property_full'] = "倉庫ではそのアイテムを扱うことができません",
	['stock_item_withdrawn'] = "アイテムを取り出した",
	['stock_cannot_withdraw'] = "このアイテムは取り出せません",
	['cant_carry_item'] = "そのアイテムを持ち運ぶことはできません",

	['property_waypoint_set'] = "物件へのウェイポイントが GPS にマークされました",
	['property_needs_repair'] = "所有物件 '%s' を修理しないと、間もなくこの物件を失うことになります",
	['property_not_owned'] = "この物件はあなたの所有物ではありません",
	['property_sold'] = "この物件を売却しました",
	['property_purchased'] = "この物件を購入しました",
	['property_max_amount'] = 'これ以上物件は所有できません',
	['property_not_found'] = "物件が見つかりません",
	['property_already_repaired'] = "この物件はすでに修理されています",
	['property_repaired'] = "この物件は修理されました",

	['tournament_joined'] = "トーナメントに正常に参加しました！トーナメントの場所があなたの地図にマークされました。時間通りに来ることを忘れずに、そして幸運を祈ります！",
	['tournament_waypoint'] = "トーナメントの場所があなたの地図にマークされました",
	['tournament_not_in'] = "あなたはこのトーナメントに参加していません",
	['tournament_not_found'] = "ここで現在進行中のトーナメントはありません",
	['tournament_already_in'] = "あなたはすでにこのトーナメントに参加しています",
	['tournament_not_available'] = "あなたが参加しようとしているトーナメントはもう利用できません",
	['tournament_started'] = "釣り大会が始まりました！釣り竿を持って、可能な限り多くの魚を捕まえて勝つ",
	['tournament_fish_caught'] = "この釣りで得た得点は%s点です！",
	['tournament_ended'] = "トーナメントは終了しました",
	['tournament_cancelled'] = "最低参加者数に達しなかったためトーナメントはキャンセルされました。参加費は返金されました",
	['tournament_prize_received'] = "おめでとうございます！トーナメントでのあなたの順位は：%sです。あなたの賞金は：%s",
	['tournament_prize_not_received'] = "今回は賞を獲得できませんでしたが、次の試みで幸運を祈ります",

	-- Logs
	['logs_date'] = "Date",
	['logs_hour'] = "Time",
	['logs_withdraw'] = "```prolog\n[MONEY WITHDRAW]: %s \n[ID] %s \r```",
	['logs_deposit'] = "```prolog\n[MONEY DEPOSITED]: %s \n[ID] %s \r```",
	['logs_buy_vehicle'] = "```prolog\n[USER]: %s\n[VEHICLE PURCHASED]: %s \n[PRICE]: %s \n[ID]: %s \r```",
	['logs_buy_property'] = "```prolog\n[USER]: %s\n[PROPERTY PURCHASED]: %s \n[PRICE]: %s \n[ID]: %s \r```",
	['logs_fish_sold'] = "```prolog\n[FISH SOLD]: %s\n[AMOUNT]: %s \n[PRICE]: %s \n[ID]: %s \r```",
	['logs_exploit'] = "```prolog\n[POTENTIAL EXPLOIT]: %s\n[PLAYER LOCATION]: %s\n[DATA]: %s\n[USER]: %s \r```",

	-- Fishing Area
	["cannot_fish_in_vehicle"] = "車両に乗っている間は釣りができません",
	["water_not_found"] = "対象の場所に水が見つかりません！釣りをするのに十分な水位があることを確認してください",
	["area_not_found"] = "釣りをするのに有効なエリアにいません",
	['new_level'] = "レベル: %s にアップしました！",
	["fishing_lost"] = "魚をロストしました",

	["missing_equipments"] = {
		["rod"] = "釣り竿を装備する必要があります",
		["hook"] = "釣り針を装備する必要があります",
		["reel"] = "リールを装備する必要があります",
		["bait"] = "餌を装備する必要があります",
		["line"] = "釣り糸を装備する必要があります",
	},
	["equipment_equipped"] = "この装備を装着しました",

	-- Config contracts
	['contracts'] = {
		['chefs_special'] = {
			['name'] = "シェフの特別メニュー",
			['description'] = "地元のシェフが今夜の料理のためにこれらの魚を必要としています。配達できますか？"
		},
		['exotic_collection'] = {
			['name'] = "珍しいコレクション",
			['description'] = "これらの珍しい魚を配達して特別なギアを獲得しましょう！"
		},
		['aquarium_exhibit'] = {
			['name'] = "水族館の展示",
			['description'] = "水族館が展示を拡大しようとしています、報酬としてこれらの魚を提供してください"
		},
		['rare_fish_trader'] = {
			['name'] = "希少魚のトレーダー",
			['description'] = "収集家が町に来て希少種の魚を探しています、これらを届けて大金を稼ぎましょう！"
		},
		['swamp_special'] = {
			['name'] = "沼の名物",
			['description'] = "研究者が沼からサンプルを集めるのを手伝ってください"
		},
		['maritime_donation'] = {
			['name'] = "海洋博物館への寄付",
			['description'] = "地元の海洋博物館が新しい海洋展示用の標本を必要としています、手伝いましょう！"
		},
		['gourmet_market'] = {
			['name'] = "グルメなフィッシュマーケット",
			['description'] = "高級市場が高級魚を探しています、注文に応えて多額の報酬を得ましょう"
		},
		['biological_research'] = {
			['name'] = "生物学研究",
			['description'] = "研究者に水生生物の研究のための標本を提供して支援しましょう"
		},
		['sport_fishing'] = {
			['name'] = "スポーツ フィッシング チャレンジ",
			['description'] = "これらの難しい魚を釣って、地元のスポーツフィッシング大会で賞品を獲得しましょう"
		},
		['fish_fry'] = {
			['name'] = "地元のフィッシュフライ イベント",
			['description'] = "これらの人気の魚を届けて、地域のフィッシュフライ イベントに貢献しましょう"
		},
		['seafood_festival'] = {
			['name'] = "地元のシーフード フェスティバル",
			['description'] = "毎年恒例のシーフード フェスティバルではさまざまな魚を展示する必要があります、彼らのニーズを満たすお手伝いをしましょう"
		},
		['exotic_aquarium'] = {
			['name'] = "エキゾチックな水族館の在庫",
			['description'] = "エキゾチックな水族館がコレクションに希少種を追加しようとしています、提供できますか?"
		},
		['sushi_order'] = {
			['name'] = "寿司レストランの注文",
			['description'] = "高級寿司レストランでは新鮮で最高品質の魚が必要です、注文を時間通りに届けてください！"
		},
		['pet_food'] = {
			['name'] = "グルメペットフードメーカー",
			['description'] = "グルメペットフードメーカーでは新しいプレミアムライン用に高品質の魚が必要です、彼らを助けてください！"
		},
		['research_specimens'] = {
			['name'] = "研究標本",
			['description'] = "海洋研究者は、重要な環境研究のために特定の魚種を必要としています"
		},
		['fish_market_supply'] = {
			['name'] = "魚市場への供給",
			['description'] = "地元の魚市場では棚に魚を補充するために、一般的な魚を安定的に供給する必要があります"
		},
		['bait_supply_order'] = {
			['name'] = "餌の供給注文",
			['description'] = "釣り具店では餌としてさまざまな一般的な魚が必要です、在庫の補充を手伝ってください"
		},
		['cooking_class'] = {
			['name'] = "料理教室",
			['description'] = "コミュニティセンターで料理教室が開催されており、適切な清掃と調理のテクニックを教えるために一般的な地元の魚が必要です"
		},
		['restaurant_daily_special'] = {
			['name'] = "地元のレストランの特別料理",
			['description'] = "地元のレストランでは、日替わりの魚の特別料理を提供しており、新鮮な一般的な魚を毎日配達する必要があります"
		},
		['science_project'] = {
			['name'] = "学校の科学プロジェクト",
			['description'] = "地元の学校では地元の生態系に関する科学プロジェクトのために、さまざまな一般的な魚が必要です"
		},
	},
	['dives'] = {
		['reef_explorer'] = {
			['name'] = "サンゴ礁探索者",
			['description'] = "活気に満ちたサンゴ礁を探索し、海洋生物学者のために珍しい海洋生物のサンプルを見つけます"
		},
		['sunken_armada'] = {
			['name'] = "沈没艦隊",
			['description'] = "大規模な嵐で失われた伝説の艦隊の残骸に潜ります、遺物を回収しましょう！"
		},
		['merchant_lost'] = {
			['name'] = "商人の失われた品物",
			['description'] = "18世紀にここで沈没した商船、貴重な絹や香辛料を運んでいたと噂されています"
		},
		['underwater_city'] = {
			['name'] = "古代の海底都市",
			['description'] = "最近海底で発見された古代の遺跡には、過去の文明の手がかりが隠されている可能性があります"
		},
		['kraken_lair'] = {
			['name'] = "クラーケンの巣",
			['description'] = "神話のクラーケンの巣から宝物を取り戻しましょう、その怒りに注意してください！"
		},
		['meteorite_crash'] = {
			['name'] = "隕石の衝突現場",
			['description'] = "最近隕石が海に衝突し、希少鉱物が豊富に埋蔵されています"
		},
		['ghost_ship'] = {
			['name'] = "幽霊船探検",
			['description'] = "何世紀も前に姿を消し、今や謎の形で再び現れた船を調査するために潜水しましょう"
		},
		['volcanic_vents'] = {
			['name'] = "火山噴出孔の発見",
			['description'] = "ユニークな生命体が生息する深海の火山噴出孔を探索し、研究用のサンプルを収集しましょう"
		},
		['wreck_titan'] = {
			['name'] = "タイタンの難破船",
			['description'] = "タイタンは謎の状況下で沈没した豪華ヨットで、財宝が詰まっていると考えられています"
		},
		['bermuda_triangle'] = {
			['name'] = "バミューダトライアングルの異常",
			['description'] = "バミューダトライアングルの深海で異常現象を調査します、予想外の出来事が起こります"
		},
		['pearl_diver'] = {
			['name'] = "真珠ダイバーの探求",
			['description'] = "熟練のダイバーだけが知っている、密集したカキの養殖場から真珠を集める儲かるダイビングです"
		},
		['cold_war_relic'] = {
			['name'] = "冷戦の遺物",
			['description'] = "沈没した冷戦時代の潜水艦から失われたスパイ機器を回収します"
		},
		['deep_sea_salvage'] = {
			['name'] = "深海サルベージ作戦",
			['description'] = "海底深くに沈んだ貨物船から貴重な貨物を回収します"
		},
		['lost_jewel_atlantis'] = {
			['name'] = "アトランティスの失われた宝石",
			['description'] = "沖合にあると噂され、海の神秘に守られている伝説の失われた宝石を探します"
		},
		['sunken_plane'] = {
			['name'] = "沈没した飛行機の回収",
			['description'] = "最近発見された第二次世界大戦の飛行機の残骸に潜り、失われた歴史的遺物を回収します"
		},
		['sunken_yacht'] = {
			['name'] = "石油王の沈没したヨット",
			['description'] = "億万長者のヨットが謎の状況で沈没しました、貴重品を見つけて回収してください"
		},
		['coral_reef_photography'] = {
			['name'] = "サンゴ礁の写真撮影",
			['description'] = "大手雑誌のためにサンゴ礁の素晴らしい写真を撮影します、品質に対して高い報酬が支払われます！"
		},
		['arctic_shipwreck'] = {
			['name'] = "北極の難破船探検",
			['description'] = "北極圏を横断しようとして沈没した船を発見するために冷たい海を勇敢に乗り越えましょう"
		},
	},
}
