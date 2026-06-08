if (Lang == undefined) {
	var Lang = [];
}
Lang["ja"] = {
	common: {
		confirm: "確認する",
		weight_unit: "kg",
		level_abbreviate: "Lvl.",
		skill_point: "スキルポイント",
		areas: {
			sea: "海",
			lake: "湖",
			river: "川",
			swamp: "沼",
			all: "すべて",
		},
	},
	sidebar: {
		profile: "プロフィール",
		bank: "銀行",
		deliveries: "特別配達ミッション",
		dives: "ダイビングミッション",
		upgrades: "アップグレード",
		equipments: "装備",
		store: "ショップ",
		owned_vehicles: "所有乗り物",
		owned_property: "所有物件",
		guide: "ガイド",
		close: "閉じる",
		property: "物件",
		fish_store: "フィッシュマーケット",
	},
	modals: {
		confirmation: {
			sell_vehicle: "この乗り物を販売してよろしいですか？",
			sell_propertty: "この物件を販売してよろしいですか？倉庫の中身のアイテムはすべて失われます",
			loan_payoff: "ローンの残高をすべて支払いますか？ {0}",
			sell_all_fishes: "この操作を行うと在庫にある魚がすべて販売されます、続行してもよろしいですか？",
		},
	},
	statistics_page: {
		title: "統計",
		desc: "フィッシングライフの進捗状況を追跡するための統計",
		money_earned: "総収入額",
		money_spent: "総支出額",
		total_mythic_fish: "捕獲した神話級の魚の総数",
		total_legendary_fish: "捕獲した伝説級の魚の総数",
		total_all_fish: "捕獲した魚の総数",
		total_dives: "完了したダイビングミッションの総数",
		total_deliveries: "完了した特別配達ミッションの総数",
		total_exp: "獲得した経験値の総数",
		total_upgrades: "購入したアップグレードの合計",
		top_users: {
			title: "釣り師ランキング",
			desc: "街の釣り師Top10",
			fishes_caught: "漁獲数: {0}",
			exp: "経験値: {0}",
		},
	},
	deliveries_page: {
		title: "特別配達ミッション",
		desc: "クエストを完了すると報酬をが受けとる事ができます、契約を選択して要求された魚捕獲しクライアントに配達します",
		contracts_time: " {0} 分ごとに契約リストが更新されます",
		reward: "報酬",
		required_items: "必要なアイテム",
		start_button: "契約する",
		cancel_button: "キャンセルする",
		see_location: "場所を確認する",
		missing_item: "あなたはこれの所有者ではありません",
	},
	dives_page: {
		start_button: "ダイビングを開始する",
		cancel_button: "キャンセルする",
		title: "ダイビングミッション",
		desc: "水中探検を完了して、宝物や珍しいアイテムを見つけましょう。ダイビングミッションを選択して開始しユニークな報酬を獲得してください。ただし、宝箱の位置はGPSでは正確ではないため、経験豊富な人でも難しいことに注意してください",
		time: " {0} 分ごとにダイビングポイントリストが更新されます",
	},
	bank_page: {
		title: "銀行",
		desc: "会社の銀行口座情報をここで確認します",
		withdraw: "引き出し",
		deposit: "預け入れ",
		balance: "口座残高:",
		active_loans: "契約中のローン",

		loan_title: "ローン",
		loan_desc: "ローンでお金を借りてビジネスに投資しよう！<BR>(現在の最大額: {0})",
		loan_button: "お金を借りる",
		loan_value_title: "ローン金額",
		loan_daily_title: "1日あたりの費用",
		loan_remaining_title: "ローン残額",
		loan_date_title: "次の支払い (Auto-Debit)",
		loan_pay: "ローン返済",

		loan_modal_desc: "ローンの種類を1つ選択してください:",
		loan_modal_item: "({0}% interest rate, repayable in {1} days)",
		loan_modal_submit: "お金を借りる",

		deposit_modal_title: "お金を預ける",
		deposit_modal_desc: "いくら預け入れしますか？",
		deposit_modal_submit: "預ける",

		withdraw_modal_title: "お金を引き出す",
		withdraw_modal_desc: "いくら引き出しますか？",
		withdraw_modal_submit: "引き出す",

		modal_placeholder: "金額",
		modal_money_available: "利用可能な金額: {0}",
		modal_cancel: "キャンセル",
	},
	upgrades_page: {
		title: "スキル",
		desc: "獲得したスキルポイントを使って新しい能力をアンロックして能力を向上させましょう、優れた釣り師になるための様々なスキルがあります",
		vehicles: {
			title: "車両",
			desc: "ガレージの容量をアップグレードして、魚を輸送するための車両をもっと収容できるようにしましょう",
			level: "+{0} のスロットがガレージに追加されます<BR>+ 購入できる新しい車両をアンロックします",
		},
		boats: {
			title: "ボート",
			desc: "ドックの容量をアップグレードして、魚を輸送するためのボートをもっと収容できるようにしましょう",
			level: "+{0} のスロットがドックに追加されます<BR>+ 購入できる新しいボートをアンロックします",
		},
		properties: {
			title: "物件",
			desc: "新しい物件のロックを解除して購入できるようにします",
			level: "購入できる新しい物件のロックを解除します",
		},
		lake: {
			title: "湖",
			desc: "湖での釣りスキルをアップグレードして、より多くの種類の魚を捕まえましょう",
			level: "湖で新たな魚をアンロックします",
		},
		river: {
			title: "川",
			desc: "川での釣りスキルをアップグレードして、より多くの種類の魚を捕まえましょう",
			level: "川で新たな魚をアンロックします",
		},
		swamp: {
			title: "沼",
			desc: "沼での釣りスキルをアップグレードして、より多くの種類の魚を捕まえましょう",
			level: "沼で新たな魚をアンロックします",
		},
		sea: {
			title: "海",
			desc: "海での釣りスキルをアップグレードして、より多くの種類の魚を捕まえましょう",
			level: "海で新たな魚をアンロックします",
		},
	},
	equipments_page: {
		title: "装備",
		desc: "新しい釣り道具を購入して、釣りのテクニックを向上させましょう。反応時間を改善し、珍しい魚を釣る可能性を高め、魚が食いつくまでの待ち時間を短縮しましょう。釣りの効率と成功率を高めるために、道具に投資しましょう",
		name: "名前",
		price: "価格",
		bonus: "追加効果",
		amount: "数量",
		buy_button: "買う",
		unlock_text: "この装備のロックを解除するには <b>レベル {0}</b> が必要です",
		rod: {
			title: "釣り竿",
			desc: "釣り竿をアップグレードして、より珍しい魚を釣るチャンスを増やしましょう",
		},
		reel: {
			title: "リール",
			desc: "リールをアップグレードして巻き取り性能を向上させ、釣り上げる速度を向上させましょう",
		},
		hook: {
			title: "釣り針",
			desc: "釣り針をアップグレードすると、魚がかかった時の反応タイミングが長くなり、釣りやすくなります",
		},
		line: {
			title: "釣り糸",
			desc: "このアップグレードにより釣り糸が切れにくくなり、張力のコントロールがしやすく、魚を捕まえるのが速くなります",
		},
		bait: {
			title: "餌",
			desc: "餌をアップグレードすると、魚が食いつくまでの待ち時間が短縮され、釣りを早く始めることができます",
		},
		other : {
			title: "その他",
			desc: "釣り体験を向上させるその他の装備",
		},
	},
	store_page: {
		title: "乗り物＆物件ショップ",
		desc: "車両、ボート、不動産を購入して配送能力を向上させましょう。さまざまなオプションから選択して効率を高め、業務を拡大しましょう",
		buy_button: "買う",
		tabs: {
			vehicle: "車両",
			boat: "ボート",
			property: "物件",
		},
		vehicle: {
			name: "名前",
			price: "価格",
			trunk: "積載量",
		},
		property: {
			name: "物件名",
			capacity: "容量",
			owned: "所有済み物件",
		},
	},
	owned_vehicles_page: {
		title: "所有乗り物",
		desc: "ガレージ（ドック）を表示および管理し、車両（ボート）の状態や燃料レベルを監視できます",
		vehicle_plate: "ナンバープレート:",
		unregistered: "Empty",
		distance: "走行距離: {0} km",
		vehicle_condition: "乗り物の状態",
		vehicle_fuel: "燃料",
		repair: "修理 {0}",
		refuel: "給油 {0}",
		spawn: "乗り物を出す",
		sell: "売る",
		unlock_text: {
			vehicle: "この車両をアンロックするには、ガレージを <b>レベル {0}</b> にアップグレードしてください",
			boat: "このボートをアンロックするには、ドックを <b>レベル {0}</b> にアップグレードしてください",
			property: "この物件のロックを解除するには、物件スキルを <b>レベル {0}</b> にアップグレードしてください",
		},
		tabs: {
			vehicle: "車両",
			boat: "ボート",
		},
	},
	owned_properties_page: {
		title: "所有物件",
		desc: "ここで物件を管理します。倉庫容量、状態の確認、ウェイポイントの設定、物件の販売、劣化した物件の修理などを行い、正常に機能し続けるようにします",
		see: "倉庫を見る",
		repair: "修理 {0}",
		sell: "物件を売る",
		stock_percentage: "倉庫容量",
		stock_condition: "倉庫の状態",
		address: "住所: {0}",
		set_waypoint: "ウェイポイントの設定",
	},
	guide_page: {
		title: "ガイド",
		desc: "釣り師が各地域で見つけることができる魚種について学ぶのを支援するために設計されたガイド",
		fish_weight: "重量",
		fish_value: "価値",
		filter_label: "名前でフィルタリング",
		filter_placeholder: "魚の名前",
	},
	stock_page: {
		title: "倉庫の在庫 ({0})",
		desc: "ここでは、あなたの物件に保存されているすべてのアイテムを表示し、操作することができます",
		property_stock_title: "倉庫の在庫",
		player_inventory_title: "あなたのインベントリ―",
		table_empty:"在庫はありません",
		bar_title: "倉庫容量",
		inventory_table: {
			header_name: "アイテム名",
			header_amount: "数量",
			header_weight: "重量",
			header_value: "価値",
		},
		deposit_modal_title: "アイテムを預ける",
		deposit_modal_item_available: "有効なアイテム: {0}",
		withdraw_modal_title: "アイテムを取り出す",
		withdraw_modal_item_available: "有効なアイテム: {0}",
		withdraw_modal_amount: "数量",
		withdraw_modal_cancel: "キャンセル",
	},
	tournaments: {
		join_tournament_alert: {
			title: "釣り大会",
			body: "当社の釣り大会に参加して、大賞を獲得するチャンスをつかもう！次の大会は<b>{0}</b>に<b>{1}</b>で始まります。参加するには、イベントが始まる前に「大会に参加」ボタンをクリックしてください。",
			footer: "装備を準備して、最大かつ最も珍しい魚を捕まえることでトップ賞を狙いましょう。最大<b>{0}</b>の賞金を獲得するチャンスをお見逃しなく！",
			button: "大会に参加",
		},
		joined_tournament_alert: {
			title: "大会エントリー確認",
			body: "次の釣り大会に正常に参加しました！大会は<b>{0}</b>に<b>{1}</b>で始まります。時間に遅れないようにしてください。",
			footer: "すべて設定されました！トップ賞を競い、最大かつ最も珍しい魚を捕まえるチャンスをつかむために装備を整えましょう。賞金は最大<b>{0}</b>です！",
			button: "GPSに場所をマーク",
		},
		scoreboard_dialog: {
			title: "大会スコアボード",
			table_name: "名前",
			table_points: "ポイント",
		},
		join_tournament_dialog: {
			title: "釣り大会への参加",
			body: `
				<p>これから釣り大会にエントリーします。以下に大会の詳細を示します：</p>

				<ul>
					<li><strong>大会の開始時間：</strong> {0}に{1}</li>
					<li><strong>エントリー料：</strong> {2}</li>
					<li><strong>持続時間：</strong> {3}分</li>
				</ul>

				<p><strong>賞品：</strong></p>
				<ul>
					<li><strong>1位：</strong> {4}</li>
					<li><strong>2位：</strong> {5}</li>
					<li><strong>3位：</strong> {6}</li>
				</ul>

				<p><strong>目標：</strong> できるだけ多くの魚を捕まえて総得点を増やし、珍しい魚で得点をさらにアップしましょう！ 🏆</p>

				<p>準備はいいですか？</p>`,
		},
		today_text: "今日",
		week_days: new Array("日曜日", "月曜日", "火曜日", "水曜日", "木曜日", "金曜日", "土曜日"),
	},
	fish_store_page: {
		desc: "ここでは釣った魚を販売できます。名前や価格帯でフィルタリングして特定の魚をすばやく見つける事ができます。努力に見合った収入を得ると共にインベントリ―を健全に保ちましょう",
		amount: "数量",
		sell_button: "魚を売る",
		sell_all_button: "すべての魚を売る",
		filters: {
			title: "フィルター",
			name_placeholder: "名前でフィルタリング",
			name: "名前:",
			price: "価格:",
			min: "最小:",
			max: "最大:",
			only_owned: "所有物のみ:",
			filter_btn: "フィルター",
		},
		others_tab: "その他",
	},
	fishing_game: {
		get_ready: "魚を釣る準備をしましょう！",
		hook_fish: "アタリがきたら <strong>左クリック</strong> でフッキングしましょう！",
		instructions: {
			title: "操作説明",
			hook_command: "Action (hook/reel)",
			exit_fishing: "Exit fishing game",
		},
		progress_bar_labels: {
			tension: {
				low: "糸の張りが弱い",
				avg: "安全な張り具合",
				max: "糸が切れるかも！",
			},
			progress: {
				low: "釣り始め",
				avg: "魚とバトル中！",
				max: "間もなく釣り上げます",
			},
		},
		fish_details: {
			rarity: {
				common: "コモン",
				uncommon: "アンコモン",
				rare: "レア",
				legendary: "伝説級",
				mythic: "神話級",
			},
			weight: "重量",
			exp: "経験値",
			price: "価格",
			keep: "キープする",
			release: "リリースする",
			illegal: "違法",
		},
	},
};