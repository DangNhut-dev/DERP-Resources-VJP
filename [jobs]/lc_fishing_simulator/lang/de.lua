if not Lang then Lang = {} end
Lang['de'] = {
	['open'] = "Drücken Sie zum Öffnen ~y~E~w~",
	['open_main_target'] = "Öffnen Sie das Angel Dashboard",
	['open_property_target'] = "Öffnen Sie das Angellager",
	['open_store_target'] = "Fischladen Öffnen",
	['you_died'] = "Sie sind gestorben und haben Ihr Fahrzeug verloren",
	['insufficient_money'] = "Zu wenig Geld",
	['invalid_value'] = "Ungültiger Wert",
	['no_permission'] = "Sie verfügen nicht über den erforderlichen Job, um dieses Menü zu öffnen",
	['not_enough_level'] = "Du hast nicht genug Level, um diesen Gegenstand zu verwenden",
	['fish_store_sold'] = "Du hast verkauft %sx %s",
	['fish_store_all_sold'] = "Du hast alle deine Fische verkauft für $%s",
	['fish_store_nothing_sold'] = "Sie haben in diesem Geschäft keinen Fisch zum Verkauf",
	['fish_store_not_enough'] = "Sie haben %sx %s nicht zu verkaufen",
	['exp'] = "EXP",

	['anchor_boat_command'] = "Boot Anker",
	['anchor_too_fast'] = "Machen Sie langsamer, um den Anker zu benutzen",
	['anchor_not_allowed'] = "Sie können hier nicht ankern",
	['anchor_lowered'] = "Anker gesenkt",
	['anchor_raised'] = "Anker gelichtet",

	['contract_invalid'] = "Dieser Vertrag besteht nicht mehr",
	['contract_started'] = "Sie haben einen Vertrag abgeschlossen und die benötigten Produkte an den Bestimmungsort geliefert",
	['contract_already_started'] = "Sie haben bereits einen Vertrag, bitte schließen Sie ihn zuerst ab",
	['contract_someone_already_started'] = "Jemand anderes hat diesen Vertrag bereits abgeschlossen, bitte wählen Sie einen anderen",
	['contract_waypoint_set'] = "Der Wegpunkt zum Vertrag wurde auf Ihrem GPS markiert",
	['contract_finish_delivery'] = "Drücken Sie ~y~E~w~, um die Lieferung abzuschließen",
	['contract_received_money'] = "$%s für den Abschluss des Vertrags erhalten",
	['contract_received_item'] = "%sx %s zum Abschluss des Vertrags erhalten",
	['contract_received_item_error'] = "Sie haben nicht genügend Speicherplatz, um den Artikel %sx %s zu empfangen",
	['contract_destination_blip'] = "Ziel",
	['contract_cancel'] = "Sie haben Ihren Vertrag gekündigt",
	['contract_not_enough_items'] = "Sie haben nicht die erforderlichen Artikel: %s",

	['dive_invalid'] = "Dieser Tauchgang existiert nicht mehr",
	['dive_started'] = "Du hast einen Tauchgang begonnen, hol den Schatz und verwende hierfür das Scuba Item",
	['dive_already_started'] = "Du hast bereits einen Tauchgang, bitte beende ihn zuerst",
	['dive_someone_already_started'] = "Jemand anderes hat diesen Tauchgang bereits begonnen, bitte wählen Sie einen anderen",
	['dive_waypoint_set'] = "Der Wegpunkt zum Tauchgebiet wurde auf Ihrem GPS markiert",
	['dive_received_money'] = "Du hast $%s für die Beendigung des Tauchgangs erhalten",
	['dive_received_item'] = "%sx %s erhalten, um den Tauchgang zu beenden",
	['dive_received_item_error'] = "Sie haben nicht genügend Speicherplatz, um den Artikel %sx %s zu empfangen",
	['dive_cancel'] = "Sie haben Ihren Tauchgang abgesagt",
	['dive_finish'] = "Drücken Sie ~y~E~w~, um den Tauchgang zu beenden",

	['money_withdrawn'] = "Geld abgehoben",
	['money_deposited'] = "Geld eingezahlt",
	['pay_loans'] = "Sie müssen Ihre Kredite abbezahlen, bevor Sie Ihr Geld abheben können",
	['loan'] = "Kredit gemacht",
	['no_loan'] = "Sie können diesen Kredit nicht aufnehmen",
	['loan_paid'] = "Darlehen bezahlt",
	['no_loan_money'] = "Sie haben kein Geld, um Ihren Kredit aus dem Angeljob abzubezahlen. Du hast alles verloren",

	['upgrade_purchased'] = "Upgrade gekauft",
	['equipment_purchased'] = "Ausrüstung gekauft",
	['insufficient_skill_points'] = "Nicht genügend Fertigkeitspunkte",

	['occupied_places'] = "Ihre Garage ist belegt. Ziehen Sie in Betracht, alle Hindernisse zu entfernen, die den Parkplatz des Fahrzeugs blockieren",
	['vehicle_blip'] = "Fahrzeug",
	['garage_blip'] = 'Garage',
	['press_e_to_store_vehicle'] = '~w~Drücke ~g~[E]~w~, um das ~b~Fahrzeug~w~ einzuparken',
	['vehicle_already_spawned'] = 'Sie haben bereits ein Fahrzeug ausgeparkt',
	['vehicle_lost'] = 'Sie haben Ihr Fahrzeug irgendwo auf der Welt verloren',

	['garage_full'] = 'Ihre Garage ist voll',
	['vehicle_purchased'] = "Sie haben das Fahrzeug gekauft",
	['vehicle_repaired'] = "Fahrzeug repariert",
	['vehicle_refueled'] = "Fahrzeug betankt",
	['vehicle_already_repaired'] = "Dieses Fahrzeug ist bereits repariert",
	['vehicle_already_refueled'] = "Dieses Fahrzeug ist bereits betankt",
	['vehicle_not_found'] = "Fahrzeug nicht gefunden",
	['vehicle_damaged'] = "Das Fahrzeug ist zu stark beschädigt",
	['vehicle_sold'] = "Fahrzeug verkauft für $%s",
	['vehicle_spawned'] = "Ihr Fahrzeug steht in Ihrer Garage",
	['vehicle_capacity_full'] = "Die Kapazität Ihres Fahrzeugs ist voll",
	['vehicle_owned_name'] = "Eigenes Fahrzeug",
	['vehicle_destroyed'] = "Ihr Fahrzeug wurde zerstört",

	['stock_item_deposited'] = "Artikel hinterlegt",
	['dont_have_item'] = "Sie haben keine %sx %s Artikel in Ihrem Inventar",
	['stock_property_full'] = "Der Immobilienbestand kann diesen Gegenstand nicht aufnehmen",
	['stock_item_withdrawn'] = "Artikel zurückgezogen",
	['stock_cannot_withdraw'] = "Dieser Artikel kann nicht zurückgezogen werden",
	['cant_carry_item'] = "Sie können diesen Gegenstand nicht tragen",

	['property_waypoint_set'] = "Der Wegpunkt zur Immobilie wurde auf Ihrem GPS markiert",
	['property_needs_repair'] = "Sie werden die Eigenschaft „%s“ sehr bald verlieren, wenn Sie sie nicht reparieren",
	['property_not_owned'] = "Sie sind nicht Eigentümer dieser Immobilie",
	['property_sold'] = "Sie haben die Immobilie verkauft",
	['property_purchased'] = "Sie haben die Immobilie erworben",
	['property_max_amount'] = 'Sie können nicht mehr Immobilien haben',
	['property_not_found'] = "Immobilie nicht gefunden",
	['property_already_repaired'] = "Diese Immobilie ist bereits repariert",
	['property_repaired'] = "Immobilie repariert",

	['tournament_joined'] = "Sie haben erfolgreich am Turnier teilgenommen! Der Turnierort wurde auf Ihrer Karte markiert. Vergessen Sie nicht, rechtzeitig da zu sein und viel Glück!",
	['tournament_waypoint'] = "Der Turnierort wurde auf Ihrer Karte markiert",
	['tournament_not_in'] = "Sie nehmen an diesem Turnier nicht teil",
	['tournament_not_found'] = "Derzeit finden hier keine Turniere statt",
	['tournament_already_in'] = "Sie sind bereits in diesem Turnier",
	['tournament_not_available'] = "Das Turnier, an dem Sie teilnehmen möchten, ist nicht mehr verfügbar",
	['tournament_started'] = "Das Angelturnier hat begonnen! Nehmen Sie Ihre Angelrute und fangen Sie so viele Fische wie möglich, um zu gewinnen",
	['tournament_fish_caught'] = "Sie haben mit diesem Fang %s Punkte erzielt!",
	['tournament_ended'] = "Das Turnier ist beendet",
	['tournament_cancelled'] = "Das Turnier wurde abgesagt, da die Mindestteilnehmerzahl nicht erreicht wurde. Das Startgeld wurde erstattet",
	['tournament_prize_received'] = "Herzlichen Glückwunsch! Ihr Platz im Turnier ist: %s. Ihr Preis beträgt: %s",
	['tournament_prize_not_received'] = "Sie haben diesmal keinen Preis gewonnen, aber viel Glück beim nächsten Versuch",

	-- Logs
	['logs_date'] = "Datum",
	['logs_hour'] = "Zeit",
	['logs_withdraw'] = "```prolog\n[GELD AUSGEZAHLT]: %s \n[ID] %s \r```",
	['logs_deposit'] = "```prolog\n[GELD EINGEZAHLT]: %s \n[ID] %s \r```",
	['logs_buy_vehicle'] = "```prolog\n[USER]: %s\n[FAHRZEUG GEKAUFT]: %s \n[PREIS]: %s \n[ID]: %s \r```",
	['logs_buy_property'] = "```prolog\n[USER]: %s\n[IMMOBILIE GEKAUFT]: %s \n[PREIS]: %s \n[ID]: %s \r```",
	['logs_fish_sold'] = "```prolog\n[FISCH VERKAUFT]: %s\n[MENGE]: %s \n[PREIS]: %s \n[ID]: %s \r```",
	['logs_exploit'] = "```prolog\n[POTENZIELLE AUSNUTZUNG]: %s\n[SPIELERSTANDORT]: %s\n[DATA]: %s\n[USER]: %s \r```",

	-- Fishing Area
	["cannot_fish_in_vehicle"] = "Du kannst nicht angeln, während du in einem Fahrzeug bist",
	["water_not_found"] = "Am Zielort wurde kein Wasser gefunden! Stellen Sie sicher, dass ausreichend Wasser zum Angeln vorhanden ist",
	["area_not_found"] = "Sie befinden sich nicht in einem geeigneten Angelgebiet",
	['new_level'] = "Du hast ein Neues Level erreicht %s !",
	["fishing_lost"] = "Du hast den Fisch verloren",

	["missing_equipments"] = {
		["rod"] = "Sie müssen eine Angelrute ausrüsten",
		["hook"] = "Sie müssen einen Angelhaken ausrüsten",
		["reel"] = "Sie müssen eine Angelrolle ausrüsten",
		["bait"] = "Sie müssen einen Angelköder ausrüsten",
		["line"] = "Sie müssen eine Angelschnur ausrüsten",
	},
	["equipment_equipped"] = "Du hast diese Ausrüstung ausgerüstet",

	-- Config contracts
	['contracts'] = {
		['chefs_special'] = {
			['name'] = "Spezialangebot des Chefkochs",
			['description'] = "Ein lokaler Koch braucht diese Fische heute Abend für ein Gourmetessen. Können Sie liefern?"
		},
		['exotic_collection'] = {
			['name'] = "Exotische Sammlung",
			['description'] = "Liefere diese seltenen Fische ab, um besondere Ausrüstung zu erhalten!"
		},
		['aquarium_exhibit'] = {
			['name'] = "Aquarium-Ausstellung",
			['description'] = "Ein Aquarium möchte seine Ausstellung erweitern. Liefern sie die Fische und erhalten eine Belohnung"
		},
		['rare_fish_trader'] = {
			['name'] = "Seltener Fischhändler",
			['description'] = "Ein Sammler ist in der Stadt auf der Suche nach seltenen Arten. Liefern Sie diese und verdienen Sie viel!"
		},
		['swamp_special'] = {
			['name'] = "Sumpfspezialitäten",
			['description'] = "Helfen Sie einem Forscher, Proben aus dem Sumpf zu sammeln."
		},
		['maritime_donation'] = {
			['name'] = "Schenkung des Schifffahrtsmuseums",
			['description'] = "Das örtliche Schifffahrtsmuseum benötigt Exemplare für seine neue Meeresausstellung. Helfen Sie ihnen!"
		},
		['gourmet_market'] = {
			['name'] = "Gourmet Fischmarkt",
			['description'] = "Ein Gourmet Markt ist auf der Suche nach erstklassigem Fisch. Erfüllen Sie ihre Bestellung und erhalten Sie eine großzügige Auszahlung."
		},
		['biological_research'] = {
			['name'] = "Biologische Forschung",
			['description'] = "Unterstützen Sie Forscher, indem Sie ihnen Proben für ihre Untersuchung des Wasserlebens zur Verfügung stellen."
		},
		['sport_fishing'] = {
			['name'] = "Sportfischer Herausforderung",
			['description'] = "Fangen Sie diese herausfordernden Arten und gewinnen Sie einen Preis beim örtlichen Sportfischerwettbewerb."
		},
		['fish_fry'] = {
			['name'] = "Lokales Fischbrat Event",
			['description'] = "Tragen Sie zum Community Fish brat Event bei, indem Sie diese beliebten Fische liefern."
		},
		['seafood_festival'] = {
			['name'] = "Lokales Meeresfrüchte Festival",
			['description'] = "Beim alljährlichen Meeresfrüchte Festival muss eine Vielfalt an Fischen präsentiert werden. Helfen Sie mit, ihren Bedarf zu decken!"
		},
		['exotic_aquarium'] = {
			['name'] = "Exotischer Aquariumbestand",
			['description'] = "Ein exotisches Aquarium möchte seine Sammlung um seltene Arten erweitern. Können Sie sie bereitstellen?"
		},
		['sushi_order'] = {
			['name'] = "Sushi Restaurantbestellung",
			['description'] = "Ein gehobenes Sushi-Restaurant braucht frischen Fisch von höchster Qualität. Liefern Sie ihre Bestellung pünktlich!"
		},
		['pet_food'] = {
			['name'] = "Gourmet Tierfutterhersteller",
			['description'] = "Ein Gourmet-Tiernahrungshersteller benötigt hochwertigen Fisch für eine neue Premium-Linie. Helfen Sie ihnen!"
		},
		['research_specimens'] = {
			['name'] = "Forschungsproben",
			['description'] = "Für wichtige Umweltstudien benötigen Meeresforscher bestimmte Fischarten."
		},
		['fish_market_supply'] = {
			['name'] = "Fischmarktversorgung",
			['description'] = "Ein lokaler Fischmarkt benötigt einen stetigen Nachschub an gewöhnlichem Fisch, um seine Regale gefüllt zu halten."
		},
		['bait_supply_order'] = {
			['name'] = "Auftrag zur Lieferung von Ködern",
			['description'] = "Ein Angelgeschäft benötigt verschiedene gängige Fische als Köder. Helfen Sie ihnen, ihr Inventar wieder aufzufüllen."
		},
		['cooking_class'] = {
			['name'] = "Gemeinschaftskochkurs",
			['description'] = "Ein Gemeindezentrum veranstaltet einen Kochkurs und benötigt einheimischen Fisch, um die richtigen Reinigungs- und Kochtechniken zu erlernen."
		},
		['restaurant_daily_special'] = {
			['name'] = "Lokales Restaurant-Special",
			['description'] = "Ein örtliches Restaurant bietet täglich ein Fischspezial an und benötigt täglich frischen, gewöhnlichen Fisch."
		},
		['science_project'] = {
			['name'] = "Schulwissenschaftliches Projekt",
			['description'] = "Eine örtliche Schule benötigt verschiedene gewöhnliche Fische für ein wissenschaftliches Projekt über lokale Ökosystemes."
		},
	},
	['dives'] = {
		['reef_explorer'] = {
			['name'] = "Riffforscher",
			['description'] = "Erkunden Sie die lebhaften Korallenriffe, um für Meeresbiologen seltene Meereslebewesen zu finden."
		},
		['sunken_armada'] = {
			['name'] = "Versunkene Armada",
			['description'] = "Tauchen Sie ein in die Überreste einer legendären Flotte, die während eines gewaltigen Sturms verloren gegangen ist. Holen Sie die Artefakte zurück!"
		},
		['merchant_lost'] = {
			['name'] = "Die verlorenen Waren des Händlers",
			['description'] = "Im 18. Jahrhundert sank hier ein Handelsschiff, das angeblich wertvolle Seide und Gewürze transportierte."
		},
		['underwater_city'] = {
			['name'] = "Antike Unterwasserstadt",
			['description'] = "Kürzlich unter dem Meer entdeckte antike Ruinen könnten Hinweise auf vergangene Zivilisationen enthalten."
		},
		['kraken_lair'] = {
			['name'] = "Kraken Versteck",
			['description'] = "Wagen Sie es, Schätze aus dem Versteck des mythischen Kraken zu bergen. Hüte dich vor seinem Zorn!"
		},
		['meteorite_crash'] = {
			['name'] = "Meteoriten Absturzstelle",
			['description'] = "Vor kurzem ist ein Meteorit in den Ozean eingeschlagen und hat ein reiches Bett seltener Mineralien geschaffen."
		},
		['ghost_ship'] = {
			['name'] = "Geisterschiff Expedition",
			['description'] = "Tauchen Sie ab, um ein Schiff zu untersuchen, das vor Jahrhunderten verschwunden ist und nun auf mysteriöse Weise wieder aufgetaucht ist."
		},
		['volcanic_vents'] = {
			['name'] = "Entdeckung vulkanischer Schlote",
			['description'] = "Erkunden Sie Vulkanschlote in der Tiefsee, in denen es von einzigartigen Lebensformen wimmelt, und sammeln Sie Proben für Studienzwecke."
		},
		['wreck_titan'] = {
			['name'] = "Wrack der Titan",
			['description'] = "Es wird angenommen, dass die Titan, eine Luxusyacht, die unter mysteriösen Umständen gesunken ist, voller Reichtümer steckt."
		},
		['bermuda_triangle'] = {
			['name'] = "Bermuda Dreieck Anomalie",
			['description'] = "Untersuchen Sie eine Anomalie in den Tiefen des Bermuda-Dreiecks. Erwarte das Unerwartete."
		},
		['pearl_diver'] = {
			['name'] = "Perlentaucher Aufgabe",
			['description'] = "Ein lukrativer Tauchgang zum Sammeln von Perlen aus einem dichten Austernbett, der nur den ältesten Tauchern bekannt ist."
		},
		['cold_war_relic'] = {
			['name'] = "Relikt des Kalten Krieges",
			['description'] = "Holen Sie verlorene Spionageausrüstung aus einem gesunkenen U-Boot aus der Zeit des Kalten Krieges zurück."
		},
		['deep_sea_salvage'] = {
			['name'] = "Bergungsaktion in der Tiefsee",
			['description'] = "Bergen Sie wertvolle Fracht aus einem tief im Meer versunkenen Frachter."
		},
		['lost_jewel_atlantis'] = {
			['name'] = "Verlorenes Juwel von Atlantis",
			['description'] = "Suchen Sie nach dem legendären verlorenen Juwel, das angeblich vor der Küste liegt und von den Geheimnissen des Meeres bewacht wird."
		},
		['sunken_plane'] = {
			['name'] = "Bergung versunkener Flugzeuge",
			['description'] = "Tauchen Sie zu einem kürzlich entdeckten Flugzeugwrack aus dem Zweiten Weltkrieg, um verlorene historische Artefakte zu bergen."
		},
		['sunken_yacht'] = {
			['name'] = "Die versunkene Yacht des Ölmanager",
			['description'] = "Die Yacht eines Milliardärs ist unter mysteriösen Umständen gesunken. Holen Sie alle Wertsachen zurück, die Sie finden."
		},
		['coral_reef_photography'] = {
			['name'] = "Korallenrifffotografie",
			['description'] = "Machen Sie atemberaubende Fotos vom Korallenriff für ein großes Magazin. Sie zahlen gut für Qualität!"
		},
		['arctic_shipwreck'] = {
			['name'] = "Arktische Schiffswrack Expedition",
			['description'] = "Trotzen Sie den kalten Gewässern und entdecken Sie ein Schiff, das beim Versuch, den Polarkreis zu überqueren, gesunken ist."
		},
	},
}
