if (Lang == undefined) {
	var Lang = [];
}
Lang["hu"] = {
	common: {
		confirm: "Megerősítés",
		weight_unit: "kg",
		level_abbreviate: "Szint",
		skill_point: "Képességpont",
		areas: {
			sea: "Tenger",
			lake: "Tó",
			river: "Folyó",
			swamp: "Mocsár",
			all: "Mind",
		},
	},
	sidebar: {
		profile: "Saját Profil",
		bank: "Bank",
		deliveries: "Speciális szállítmányok",
		dives: "Merülések",
		upgrades: "Fejlesztések",
		equipments: "Felszerelések",
		store: "Áruház",
		owned_vehicles: "Saját járművek",
		owned_property: "Saját ingatlanok",
		guide: "Útmutató",
		close: "Bezárás",
		property: "Ingatlan",
		fish_store: "Halbolt",
	},
	modals: {
		confirmation: {
			sell_vehicle: "Biztos el akarod adni ezt a járművet?",
			sell_propertty: "Biztos el akarod adni ezt az ingatlant? Az összes tárolt tárgy elveszik.",
			loan_payoff: "Biztos ki akarod fizetni a teljes összeget: {0}?",
			sell_all_fishes: "Ez a művelet eladja az összes halat a tárolójából. Biztos ezt szeretnéd tenni?",
		},
	},
	statistics_page: {
		title: "Statisztikák",
		desc: "Statisztikák a horgászat fejlődésének követésére",
		money_earned: "Összes megkeresett pénz",
		money_spent: "Összes elköltött pénz",
		total_mythic_fish: "Összes kifogott misztikus hal",
		total_legendary_fish: "Összes kifogott legendás hal",
		total_all_fish: "Összes kifogott halak",
		total_dives: "Összes befejezett merülés",
		total_deliveries: "Összes teljesített szállítmány",
		total_exp: "Összes szerzett XP",
		total_upgrades: "Összes vásárolt fejlesztés",
		top_users: {
			title: "Legjobb horgászok",
			desc: "A város 10 legjobb horgásza",
			fishes_caught: "Kifogott halak: {0}",
			exp: "EXP: {0}",
		},
	},
	deliveries_page: {
		title: "Szállítások",
		desc: "Teljesíts megrendeléseket, hogy speciális áron vásárolhass halat. Válassz szerződést és szállítsd le a megrendelő által kért halakat.",
		contracts_time: "Új szerződések minden {0} percenként",
		reward: "Fizettség",
		required_items: "Szükséges tárgyak",
		start_button: "Szerződés kezdése",
		cancel_button: "Szerződés megszakítása",
		see_location: "Helyszín megtekintése",
		missing_item: "Hiányzó tárgy",
	},
	dives_page: {
		start_button: "Merülés indítása",
		cancel_button: "Merülés megszakítása",
		title: "Merülések",
		desc: "Teljesíts víz alatti expedíciókat, hogy kincseket és ritka tárgyakat találhass. Válassz merülési küldetést a kezdéshez, és szerezz egyedi jutalmakat. Fontos megjegyezni, hogy a kincsek helyszínei nem pontosak a GPS-en, így még a legtapasztaltabbak számára is kihívást jelenthet.",
		time: "Új merülés minden {0} percenként",
	},
	bank_page: {
		title: "Bank",
		desc: "Itt tekintheted meg a cég banki számlaadatait",
		withdraw: "Pénzfelvétel",
		deposit: "Pénzbefizetés",
		balance: "Egyenleg:",
		active_loans: "Aktív kölcsönök",
		loan_title: "Kölcsönök",
		loan_desc: "Vegyél fel kölcsönt a vállalkozásodba való befektetéshez!<BR>(Maximális kölcsön: {0})",
		loan_button: "Kölcsön felvétele",
		loan_value_title: "Kölcsön összege",
		loan_daily_title: "Napi költség",
		loan_remaining_title: "Fennmaradó összeg",
		loan_date_title: "Következő fizetés (Automatikus terhelés)",
		loan_pay: "Kölcsön visszafizetése",

		loan_modal_desc: "Válassz egy kölcsönt:",
		loan_modal_item: "({0}% kamat, visszafizetendő {1} nap alatt)",
		loan_modal_submit: "Kölcsön felvétele",

		deposit_modal_title: "Pénzbefizetés",
		deposit_modal_desc: "Mennyit szeretnél befizetni?",
		deposit_modal_submit: "Pénzbefizetés",

		withdraw_modal_title: "Pénzfelvétel",
		withdraw_modal_desc: "Mennyit szeretnél felvenni?",
		withdraw_modal_submit: "Pénzfelvétel",

		modal_placeholder: "Összeg",
		modal_money_available: "Rendelkezésre álló összeg: {0}",
		modal_cancel: "Mégse",
	},
	upgrades_page: {
		title: "Képességek",
		desc: "Használd felgyülemlett képességpontjaidat új képességek feloldására, amelyek javítják horgászati élményedet. Számos különböző képesség áll rendelkezésedre, amelyek jobb horgásszá tehetnek.",
		vehicles: {
			title: "Járművek",
			desc: "Növeld a garázs kapacitását több jármű szállításához.",
			level: "+{0} jármű hely a garázsban<BR>+ Új járművek vásárlásának feloldása",
		},
		boats: {
			title: "Csónakok",
			desc: "Növeld a dokk kapacitását több csónak szállításához.",
			level: "+{0} jármű hely a garázsban<BR>+ Új csónakok vásárlásának feloldása",
		},
		properties: {
			title: "Ingatlanok",
			desc: "Felold új ingatlanokat, hogy megvásárolhasd azokat.",
			level: "Új ingatlanok vásárlásának feloldása",
		},
		lake: {
			title: "Tó",
			desc: "Növeld a tóval kapcsolatos horgászi képességeidet, hogy többféle halat foghass.",
			level: "Új halak fajták feloldása a tóban",
		},
		river: {
			title: "Folyó",
			desc: "Növeld a folyóval kapcsolatos horgászi képességeidet, hogy többféle halat foghass.",
			level: "Új halak fajták feloldása a folyóban",
		},
		swamp: {
			title: "Mocsár",
			desc: "Növeld a mocsárral kapcsolatos horgászi képességeidet, hogy többféle halat foghass.",
			level: "Új halak fajták feloldása a mocsárban",
		},
		sea: {
			title: "Tenger",
			desc: "Növeld a tengerrel kapcsolatos horgászi képességeidet, hogy többféle halat foghass.",
			level: "Új halfajták feloldása a tengerben",
		},
	},
	equipments_page: {
		title: "Felszerelések",
		desc: "Vásárolj új horgászfelszereléseket, hogy javítsd horgásztechnikádat. Növeld reakcióidődet valamint a ritka halak kifogásának esélyeit, és csökkentsd a kapásra várakozási időt. Fejleszd felszerelésedet a horgászat hatékonyságának és sikerének növelése érdekében.",
		name: "Név",
		price: "Ár",
		bonus: "Bónusz",
		amount: "Mennyiség",
		buy_button: "Vásárlás",
		unlock_text: "Érd el a <b>{0}. szintet</b>, hogy felold ezt a felszerelést",
		rod: {
			title: "Horgászbot",
			desc: "Fejleszd horgászbotodat, hogy növeld a ritkább halak kifogásának esélyeit",
		},
		reel: {
			title: "Orsó",
			desc: "Fejleszd orsódat, hogy növeld a húzás teljesítményét, gyorsabbá téve a horgot",
		},
		hook: {
			title: "Horog",
			desc: "Fejleszd horogodat, hogy növeld a reakcióidőt, amikor halat akasztasz, így könnyebb lesz elkapni",
		},
		line: {
			title: "Damil",
			desc: "Ez a fejlesztés erősíti a damilt, ami könnyebbé teszi a feszültség kezelését és gyorsítja a hal elkapását",
		},
		bait: {
			title: "Csali",
			desc: "Fejleszd csalidat, hogy csökkentsd a halak kapására várakozási időt, így hamarabb elkezdheted a horgászatot",
		},
		other: {
			title: "Egyéb",
			desc: "Egyéb felszerelések, hogy javítsd horgászati élményedet",
		},
	},
	store_page: {
		title: "Jármű és Ingatlan Kereskedés",
		desc: "Vásárolj járműveket, csónakokat és ingatlanokat, hogy javítsd szállítási képességeidet. Válassz a különböző lehetőségek közül, hogy növeld hatékonyságodat és bővítsd lehetőségeidet.",
		buy_button: "Vásárlás",
		tabs: {
			vehicle: "Járművek",
			boat: "Csónakok",
			property: "Ingatlanok",
		},
		vehicle: {
			name: "Jármű",
			price: "Ár",
			trunk: "Teherbírás",
		},
		property: {
			name: "Ingatlan",
			capacity: "Kapacitás",
			owned: "Már birtoklod ezt az ingatlant",
		},
	},
	owned_vehicles_page: {
		title: "Saját járművek",
		desc: "Tekintsd meg és kezeld garázsod, ahol nyomon követheted járműveid és csónakjaid állapotát és üzemanyagszintjét.",
		vehicle_plate: "Rendszám:",
		unregistered: "Üres",
		distance: "Óraállás: {0} km",
		vehicle_condition: "Jármű állapota",
		vehicle_fuel: "Üzemanyag",
		repair: "Javítás {0}",
		refuel: "Újratöltés {0}",
		spawn: "Jármű kikérése",
		sell: "Eladás",
		unlock_text: {
			vehicle: "A jármű garázs fejlesztése <b>{0}. szintre</b> szükséges ennek a járműnek a feloldásához",
			boat: "A csónak garázs fejlesztése <b>{0}. szintre</b> szükséges ennek a csónaknak a feloldásához",
			property: "Az ingatlan képesség fejlesztése <b>{0}. szintre</b> szükséges ennek az ingatlannak a feloldásához",
		},
		tabs: {
			vehicle: "Járművek",
			boat: "Csónakok",
		},
	},
	owned_properties_page: {
		title: "Birtokolt ingatlanok",
		desc: "Kezeld ingatlanjaidat. Tekintsd meg a raktárkapacitást, állapotot, állíts be útvonalpontokat, add el az ingatlanokat, és javítsd meg őket ha elhasználódnak hogy tovább működhessenek.",
		see: "Raktárkészlet megtekintése",
		repair: "Javítás {0}",
		sell: "Ingatlan eladása",
		stock_percentage: "Raktárkapacitás",
		stock_condition: "Raktár állapota",
		address: "Cím: {0}",
		set_waypoint: "Útvonalpont beállítása",
	},
	guide_page: {
		title: "Segédlet",
		desc: "Ez a segédlet segít a horgászoknak megismerni az egyes helyszíneken megtalálható halak fajtáit",
		fish_weight: "Súly",
		fish_value: "Érték",
		filter_label: "Szűrés név szerint",
    	filter_placeholder: "Hal neve",
	},
	stock_page: {
		title: "Raktárkészlet ({0})",
		desc: "Megtekintheted és kezelheted az ingatlanodban tárolt összes tárgyat",
		property_stock_title: "Ingatlan raktár",
		player_inventory_title: "Saját készleted",
		table_empty: "A raktár üres",
		bar_title: "Raktárkapacitás",
		inventory_table: {
			header_name: "Tárgy neve",
			header_amount: "Mennyiség",
			header_weight: "Súly",
			header_value: "Érték",
		},
		deposit_modal_title: "Tárgy behelyezése",
		deposit_modal_item_available: "Nálad: {0}",
		withdraw_modal_title: "Tárgy kivétele",
		withdraw_modal_item_available: "A raktárban: {0}",
		withdraw_modal_amount: "Mennyiség",
		withdraw_modal_cancel: "Mégse",
	},
	tournaments: {
		join_tournament_alert: {
			title: "Horgászverseny",
			body: "Csatlakozzon horgászversenyeinkhez, hogy esélye legyen nagy nyereményekre! A következő verseny <b>{0}</b> nap <b>{1}</b> órakor kezdődik. A részvételhez kattintson a „Csatlakozás a versenyhez” gombra az esemény kezdete előtt.",
			footer: "Készítse elő a felszerelését, és célozza meg a fődíjat a legnagyobb és legritkább halak fogásával. Ne hagyja ki a lehetőséget, hogy akár <b>{0}</b> nyereményt is elnyerjen!",
			button: "Csatlakozás a versenyhez",
		},
		joined_tournament_alert: {
			title: "Versenyen való részvétel megerősítve",
			body: "Sikeresen csatlakozott a közelgő horgászversenyhez! A verseny <b>{0}</b> nap <b>{1}</b> órakor kezdődik. Ne felejtsen el időben ott lenni.",
			footer: "Minden készen áll! Készüljön fel, hogy megküzdjön a fődíjért és az esélyért, hogy elkapja a legnagyobb és legritkább halakat. Akár <b>{0}</b> értékű díjak várnak Önre!",
			button: "Helyszín megjelölése a GPS-en",
		},
		scoreboard_dialog: {
			title: "Verseny eredménytáblája",
			table_name: "Név",
			table_points: "Pontok",
		},
		join_tournament_dialog: {
			title: "Csatlakozás a horgászversenyhez",
			body: `
				<p>Éppen csatlakozik a horgászversenyhez. Íme a verseny részletei:</p>
		
				<ul>
					<li><strong>Verseny kezdete:</strong> {0} nap {1} órakor</li>
					<li><strong>Nevezési díj:</strong> {2}</li>
					<li><strong>Időtartam:</strong> {3} perc</li>
				</ul>
		
				<p><strong>Díjak:</strong></p>
				<ul>
					<li><strong>1. hely:</strong> {4}</li>
					<li><strong>2. hely:</strong> {5}</li>
					<li><strong>3. hely:</strong> {6}</li>
				</ul>
		
				<p><strong>Cél:</strong> Minél több halat fogjon, hogy növelje összpontszámát, a ritkább halak több pontot érnek, mint a gyakoriak! 🏆</p>
		
				<p>Készen áll?</p>`,
		},
		today_text: "Ma",
		week_days: new Array("Vasárnap", "Hétfő", "Kedd", "Szerda", "Csütörtök", "Péntek", "Szombat"),
	},
	fish_store_page: {
		desc: "Eladhatod fogásaidat meghatározott árakon. Használd a szűrő lehetőségeket, hogy gyorsan megtalálhasd a halakat név alapján, vagy állítsd be az ársávokat. Érd el a legjobb értéket a munkádért és tartsd frissen a készletedet.",
		amount: "Mennyiség",
		sell_button: "Halak eladása",
		sell_all_button: "Összes hal eladása",
		filters: {
			title: "Szűrők",
			name_placeholder: "Szűrés név alapján",
			name: "Név:",
			price: "Ár:",
			min: "Min:",
			max: "Max:",
			filter_btn: "Szűrés",
			only_owned: "Csak tulajdonolt:",
		},
		others_tab: "Egyéb",
	},
	fishing_game: {
		get_ready: "Készülj fel, a kapásra!",
		hook_fish: "Nyomd meg a <strong>bal egérgombot</strong> a hal kifogásához!",
		instructions: {
			title: "ÚTMUTATÓ",
			hook_command: "Kifogás/Húzás",
			exit_fishing: "Befejezés",
		},
		progress_bar_labels: {
			tension: {
				low: "Alacsony",
				avg: "Optimális",
				max: "Magas",
			},
			progress: {
				low: "Éppen csak elkezdve",
				avg: "Haladás",
				max: "Majdnem kifogva",
			},
		},
		fish_details: {
			rarity: {
				common: "Általános",
				uncommon: "Szokatlan",
				rare: "Ritka",
				legendary: "Legendás",
				mythic: "Misztikus",
			},
			weight: "Súly",
			exp: "XP",
			price: "Érték",
			keep: "Megtartás",
			release: "Elengedés",
			illegal: "Illegális",
		},
	},
};