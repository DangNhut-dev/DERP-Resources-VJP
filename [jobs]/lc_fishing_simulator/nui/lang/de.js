if (Lang == undefined) {
	var Lang = [];
}
Lang["de"] = {
	common: {
		confirm: "Bestätigen",
		weight_unit: "kg",
		level_abbreviate: "Level.",
		skill_point: "Fähigkeitspunkt",
		areas: {
			sea: "Meer",
			lake: "See",
			river: "Fluss",
			swamp: "Sumpf",
			all: "Alle",
		},
	},
	sidebar: {
		profile: "Dein Profil",
		bank: "Bank",
		deliveries: "Sonderlieferungen",
		dives: "Tauchgänge",
		upgrades: "Upgrades",
		equipments: "Ausrüstungen",
		store: "Shop",
		owned_vehicles: "Eigene Fahrzeuge",
		owned_property: "Eigenes Eigentum",
		guide: "Guide",
		close: "Schließen",
		property: "Immobilie",
		fish_store: "Fischladen",
	},
	modals: {
		confirmation: {
			sell_vehicle: "Sind Sie sicher, dass Sie dieses Fahrzeug verkaufen möchten?",
			sell_propertty: "Sind Sie sicher, dass Sie diese Immobilie verkaufen möchten? Alle eingelagerten Gegenstände gehen verloren",
			loan_payoff: "Sind Sie sicher, dass Sie den gesamten Restbetrag bezahlen möchten? {0}?",
			sell_all_fishes: "Durch diese Aktion werden alle Fische in Ihrem Inventar verkauft. Sind Sie sicher, dass Sie fortfahren möchten?",
		},
	},
	statistics_page: {
		title: "Statistiken",
		desc: "Statistiken, um den Fortschritt Ihres Angellebens zu verfolgen",
		money_earned: "Gesamtverdientes Geld",
		money_spent: "Gesamtes ausgegebenes Geld",
		total_mythic_fish: "Total Mythische Fische gefangen",
		total_legendary_fish: "Total Legendärere Fische gefangen",
		total_all_fish: "Gesamtzahl der gefangenen Fische",
		total_dives: "Gesamtzahl der abgeschlossenen Tauchgänge",
		total_deliveries: "Gesamtlieferungen abgeschlossen",
		total_exp: "Insgesamt verdiente EXP",
		total_upgrades: "Insgesamt gekaufte Upgrades",
		top_users: {
			title: "Spitzenfischer",
			desc: "Die 10 besten Fischer der Stadt",
			fishes_caught: "Gefangene Fische: {0}",
			exp: "EXP: {0}",
		},
	},
	deliveries_page: {
		title: "Lieferungen",
		desc: "Schließen Sie Bestellungen ab, um Sonderpreise für Fische zu erhalten.",
		contracts_time: "Neue Verträge alle {0} Min",
		reward: "Belohnung",
		required_items: "Benötigte Artikel",
		start_button: "Vertrag starten",
		cancel_button: "Vertrag stornieren",
		see_location: "Siehe Standort",
		missing_item: "Fehlender Gegenstand",
	},
	dives_page: {
		start_button: "Tauchgang beginnen",
		cancel_button: "Tauchgang abbrechen",
		title: "Tauchgänge",
		desc: "Schließe Tauchgänge ab, um besondere Belohnungen zu erhalten.",
		time: "Neue Tauchgänge alle {0} Min",
	},
	bank_page: {
		title: "Bank",
		desc: "Sehen Sie sich hier die Bankkontoinformationen Ihres Unternehmens an",
		withdraw: "Geld abheben",
		deposit: "Geld einzahlen",
		balance: "Ihr Guthaben beträgt:",
		active_loans: "Aktive Kredite",

		loan_title: "Kredite",
		loan_desc: "Nehmen Sie Kredite auf, um in Ihr Unternehmen zu investieren!<BR>(Maximaler Kredit: {0})",
		loan_button: "Nehmen Sie einen Kredit auf",
		loan_value_title: "Kreditbetrag",
		loan_daily_title: "Tägliche Kosten",
		loan_remaining_title: "Restbetrag",
		loan_date_title: "Nächste Zahlung (Auto-Lastschrift)",
		loan_pay: "Tilgungsdarlehen",

		loan_modal_desc: "Wählen Sie eine der Kreditarten:",
		loan_modal_item: "({0}% Zinssatz, rückzahlbar in {1} Tagen)",
		loan_modal_submit: "Nehmen Sie einen Kredit auf",

		deposit_modal_title: "Geld einzahlen",
		deposit_modal_desc: "Wie viel möchten Sie einzahlen?",
		deposit_modal_submit: "Geld einzahlen",

		withdraw_modal_title: "Geld abheben",
		withdraw_modal_desc: "Wie viel möchten Sie abheben?",
		withdraw_modal_submit: "Geld abheben",

		modal_placeholder: "Menge",
		modal_money_available: "Verfügbares Geld: {0}",
		modal_cancel: "Abbrechen",
	},
	upgrades_page: {
		title: "Fähigkeiten",
		desc: "Nutzen Sie Ihre gesammelten Fertigkeitspunkte, um neue Fähigkeiten freizuschalten, die Ihr Angelerlebnis verbessern. Es gibt eine Vielzahl von Fähigkeiten, die Sie zu einem besseren Fischer machen können",
		vehicles: {
			title: "Fahrzeuge",
			desc: "Erweitern Sie die Kapazität Ihrer Garage, um mehr Fahrzeuge für den Transport Ihrer Fische unterzubringen.",
			level: "+{0} Fahrzeugplätze in Ihrer Garage<BR>+ Schaltet neue Fahrzeuge zum Kauf frei",
		},
		boats: {
			title: "Boote",
			desc: "Erweitern Sie die Kapazität Ihres Docks, um mehr Boote für den Transport Ihrer Fische unterzubringen.",
			level: "+{0} Bootsplätze in Ihrem Dock<BR>+ Schaltet neue Boote zum Kauf frei",
		},
		properties: {
			title: "Immobilien",
			desc: "Schalten Sie neue Immobilien frei, um sie käuflich zu machen.",
			level: "Schaltet neue Immobilien zum Kauf frei",
		},
		lake: {
			title: "See",
			desc: "Verbessere deine Fähigkeiten im See, um mehr Fischarten zu fangen.",
			level: "Schaltet neue Fischarten im See frei",
		},
		river: {
			title: "Fluss",
			desc: "Verbessere deine Flussfähigkeiten, um mehr Fischarten zu fangen.",
			level: "Schaltet neue Fischarten im Fluss frei",
		},
		swamp: {
			title: "Sumpf",
			desc: "Verbessere deine Sumpffähigkeiten, um mehr Fischarten zu fangen.",
			level: "Schaltet neue Fischarten im Sumpf frei",
		},
		sea: {
			title: "Meer",
			desc: "Verbessere deine Seefähigkeiten, um mehr Fischarten zu fangen.",
			level: "Schaltet neue Fischarten im Meer frei",
		},
	},
	equipments_page: {
		title: "Ausrüstung",
		desc: "Kaufen Sie neue Angelausrüstung, um Ihre Angeltechniken zu verbessern. Verbessern Sie die Wurf- und Hakengeschwindigkeit und locken Sie seltenere Fische an. Investieren Sie in Ihre Ausrüstung, um die Effektivität und den Erfolg Ihrer Fischerei zu steigern",
		name: "Name",
		price: "Preis",
		bonus: "Bonus",
		amount: "Menge",
		buy_button: "Kaufen",
		unlock_text: "Erreiche <b>Level {0}</b>, um diese Ausrüstung freizuschalten",
		rod: {
			title: "Stange",
			desc: "Rüsten Sie Ihre Angelrute auf, um die Chancen zu erhöhen, seltenere Fische zu fangen",
		},
		reel: {
			title: "Spule",
			desc: "Rüsten Sie Ihre Rolle auf, um die Aufrollleistung zu steigern und den Aufrollfortschritt zu beschleunigen",
		},
		hook: {
			title: "Haken",
			desc: "Verbessern Sie Ihren Haken, um die Reaktionszeit beim Anhaken eines Fisches zu verlängern und ihn so einfacher zu fangen",
		},
		line: {
			title: "Schnur",
			desc: "Durch dieses Upgrade wird Ihre Schnur stärker, was bedeutet, dass Sie die Spannung leichter kontrollieren und den Fisch schneller fangen können",
		},
		bait: {
			title: "Köder",
			desc: "Verbessern Sie Ihren Köder, um die Wartezeit bis zum Anbeißen eines Fisches zu verkürzen und so früher mit dem Angeln zu beginnen",
		},
		other : {
			title: "Andere",
			desc: "Weitere Ausrüstung zur Verbesserung Ihres Angelerlebnisses",
		},
	},
	store_page: {
		title: "Flotten und Immobiliengeschäft",
		desc: "Kaufen Sie Fahrzeuge, Boote und Immobilien, um Ihre Lieferfähigkeiten zu verbessern. Wählen Sie aus einer Vielzahl von Optionen, um Ihre Effizienz zu verbessern und Ihren Betrieb zu erweitern",
		buy_button: "Kaufen",
		tabs: {
			vehicle: "Fahrzeuge",
			boat: "Boote",
			property: "Immobilien",
		},
		vehicle: {
			name: "Fahrzeug",
			price: "Preis",
			trunk: "Kofferraum",
		},
		property: {
			name: "Eigentum",
			capacity: "Kapazität",
			owned: "Sie sind bereits Eigentümer dieser Immobilie",
		},
	},
	owned_vehicles_page: {
		title: "Meine Fahrzeuge",
		desc: "Sehen und verwalten Sie Ihre Garage, in der Sie den Zustand und den Kraftstoffstand Ihrer Boote und Fahrzeuge überwachen können",
		vehicle_plate: "Kennzeichen:",
		unregistered: "Leer",
		distance: "Kilometerzähler: {0} km",
		vehicle_condition: "Fahrzeugzustand",
		vehicle_fuel: "Tank",
		repair: "Reparatur {0}",
		refuel: "Tanken {0}",
		spawn: "Fahrzeug ausparken",
		sell: "Verkaufen",
		unlock_text: {
			vehicle: "Werte die Fahrzeuggarage auf <b>Level {0}</b> auf, um dieses Fahrzeug freizuschalten",
			boat: "Werte die Bootsgarage auf <b>Level {0}</b> auf, um dieses Boot freizuschalten",
			property: "Verbessere die Immobilie auf <b>Stufe {0}</b>, um diese Eigenschaft freizuschalten",
		},
		tabs: {
			vehicle: "Fahrzeuge",
			boat: "Boote",
		},
	},
	owned_properties_page: {
		title: "Meine Immobilie",
		desc: "Verwalten Sie hier Ihre Immobilien. Sehen Sie sich die Lagerkapazität und den Zustand an, legen Sie Wegpunkte fest, verkaufen Sie Immobilien und reparieren Sie sie, sobald sie sich verschlechtern, damit sie weiterhin ordnungsgemäß funktionieren",
		see: "Immobilienbestand ansehen",
		repair: "Reparatur {0}",
		sell: "Immobilie verkaufen",
		stock_percentage: "Lagerkapazität",
		stock_condition: "Lagerzustand",
		address: "Adresse: {0}",
		set_waypoint: "Wegpunkt setzen",
	},
	guide_page: {
		title: "Guide",
		desc: "Ein Leitfaden, der Fischer dabei unterstützen soll, mehr über die Fischarten zu erfahren, die an den einzelnen Orten vorkommen.",
		fish_weight: "Gewicht",
		fish_value: "Wert",
		filter_label: "Nach Namen filtern",
    	filter_placeholder: "Fischname",
	},
	stock_page: {
		title: "Immobilienbestand ({0})",
		desc:"Hier können Sie alle in Ihrem Eigentum gelagerten Gegenstände sehen und mit ihnen interagieren",
		property_stock_title: "Immobilienbestand",
		player_inventory_title: "Ihr Inventar",
		table_empty:"Vorrat leer",
		bar_title: "Lagerkapazität",
		inventory_table: {
			header_name: "Name",
			header_amount: "Menge",
			header_weight: "Gewicht",
			header_value: "Wert",
		},
		deposit_modal_title: "Artikel einlagern",
		deposit_modal_item_available: "Im Inventar: {0}",
		withdraw_modal_title: "Artikel zurückziehen",
		withdraw_modal_item_available: "Auf Lager: {0}",
		withdraw_modal_amount: "Menge",
		withdraw_modal_cancel: "Abbrechen",
	},
	tournaments: {
		join_tournament_alert: {
			title: "Angelturnier",
			body: "Nehmen Sie an unseren Angelturnieren teil, um die Chance auf große Preise zu haben! Das nächste Turnier beginnt <b>{0}</b> um <b>{1}</b>. Um teilzunehmen, klicken Sie vor Beginn der Veranstaltung auf die Schaltfläche \"Am Turnier teilnehmen\".",
			footer: "Bereiten Sie Ihre Ausrüstung vor und zielen Sie auf den Hauptpreis, indem Sie den größten und seltensten Fisch fangen. Verpassen Sie nicht Ihre Chance, bis zu <b>{0}</b> zu gewinnen!",
			button: "Am Turnier teilnehmen",
		},
		joined_tournament_alert: {
			title: "Turnierteilnahme bestätigt",
			body: "Sie haben sich erfolgreich für das kommende Angelturnier angemeldet! Es beginnt <b>{0}</b> um <b>{1}</b>. Vergessen Sie nicht, rechtzeitig dort zu sein.",
			footer: "Alles ist bereit! Rüsten Sie sich aus, um für den Hauptpreis und die Chance, den größten und seltensten Fisch zu fangen, zu konkurrieren. Bis zu <b>{0}</b> an Preisen warten!",
			button: "Ort im GPS markieren",
		},
		scoreboard_dialog: {
			title: "Turnier-Punktestand",
			table_name: "Name",
			table_points: "Punkte",
		},
		join_tournament_dialog: {
			title: "Am Angelturnier teilnehmen",
			body: `
				<p>Sie sind dabei, am Angelturnier teilzunehmen. Unten finden Sie die Details des Turniers:</p>
		
				<ul>
					<li><strong>Turnierstartzeit:</strong> {0} um {1}</li>
					<li><strong>Startgebühr:</strong> {2}</li>
					<li><strong>Dauer:</strong> {3} Minuten</li>
				</ul>
		
				<p><strong>Preise:</strong></p>
				<ul>
					<li><strong>1. Platz:</strong> {4}</li>
					<li><strong>2. Platz:</strong> {5}</li>
					<li><strong>3. Platz:</strong> {6}</li>
				</ul>
		
				<p><strong>Ziel:</strong> Fangen Sie so viele Fische wie möglich, um Ihre Gesamtpunktzahl zu erhöhen, wobei seltenere Fische Ihre Punktzahl stärker erhöhen als gewöhnliche! 🏆</p>
		
				<p>Sind Sie bereit?</p>`,
		},
		today_text: "Heute",
		week_days: new Array("Sonntag", "Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag", "Samstag"),
	},
	fish_store_page: {
		desc: "Hier können Sie Ihren Fang zu festgelegten Preisen verkaufen. Nutzen Sie die Filteroptionen, um bestimmte Fische schnell nach Namen zu finden oder Preisspannen anzupassen. Erhalten Sie den besten Gegenwert für Ihre Bemühungen und halten Sie Ihren Bestand frisch",
		amount: "Menge",
		sell_button: "Fisch verkaufen",
		sell_all_button: "Verkaufe alle Fische",
		filters: {
			title: "Filter",
			name_placeholder: "Nach Namen filtern",
			name: "Name:",
			price: "Preis:",
			min: "Min:",
			max: "Max:",
			filter_btn: "Filter",
			only_owned: "Nur im Besitz:",
		},
		others_tab: "Andere",
	},
	fishing_game: {
		get_ready: "Machen Sie sich bereit, den Fisch zu fangen!",
		hook_fish: "Drücken Sie <strong>LMB</strong>, um den Fisch zu fangen!",
		instructions: {
			title: "Hilfestellung",
			hook_command: "Aktion (Haken/Rolle)",
			exit_fishing: "Beenden Sie das Angelspiel",
		},
		progress_bar_labels: {
			tension: {
				low: "Niederspannung",
				avg: "Optimale Spannung",
				max: "Hochspannung",
			},
			progress: {
				low: "Gestartet",
				avg: "Fortschritte",
				max: "Erwischt",
			},
		},
		fish_details: {
			rarity: {
				common: "Gefangen",
				uncommon: "Ungewöhnlich",
				rare: "Selten",
				legendary: "Legendär",
				mythic: "Mythisch",
			},
			weight: "Gewicht",
			exp: "EXP",
			price: "Preis",
			keep: "Mitnehmen",
			release: "Freilassen",
			illegal: "Illegal",
		},
	},
};