if not Lang then Lang = {} end
Lang['hu'] = {
	['open'] = "Nyomj ~y~E~w~ a megnyitáshoz",
	['open_main_target'] = "Horgász panel megnyitása",
	['open_property_target'] = "Horgász tulajdon megnyitása",
	['open_store_target'] = "Horgászbolt megnyitása",
	['you_died'] = "Meghaltál ezért elvesztetted a járművedet",
	['insufficient_money'] = "Nem rendelkezel elegendő pénzel",
	['invalid_value'] = "Érvénytelen érték",
	['no_permission'] = "Nem rendelkezel a szükséges munkával ehhez a menü megnyitásához",
	['not_enough_level'] = "A szinted nem elegendő ennek a tárgynak a használatához",
	['fish_store_sold'] = "Eladtál %sx %s",
	['fish_store_all_sold'] = "Eladtad az összes haladat $%s-ért",
	['fish_store_nothing_sold'] = "Nem rendelkezel eladható hallal",
	['fish_store_not_enough'] = "Nincs %sx %s halad az eladáshoz",
	['exp'] = "XP",
	
	['anchor_boat_command'] = "Horgonyzás",
	['anchor_too_fast'] = "Lassíts a horgony használatához",
	['anchor_not_allowed'] = "Itt nem lehet horgonyozni",
	['anchor_lowered'] = "Horgony leengedve",
	['anchor_raised'] = "Horgony felhúzva",
	
	['contract_invalid'] = "Ez a szerződés már nem létezik",
	['contract_started'] = "Elfogadtad a szerződést, szállítsd le a szükséges termékeket a célállomásra",
	['contract_already_started'] = "Már van egy aktív szerződésed, fejezd be azt először hogy újat tudj kezdeni",
	['contract_someone_already_started'] = "Valaki már elfogadta ezt a szerződést, válassz egy másikat",
	['contract_waypoint_set'] = "A szerződés célállomása megjelölésre került a GPS-en",
	['contract_finish_delivery'] = "Nyomj ~y~E~w~ a szállítás befejezéséhez",
	['contract_received_money'] = "Kaptál $%s-t a szerződés teljesítéséért",
	['contract_received_item'] = "%sx %s tárgyat kaptál a szerződés teljesítéséért",
	['contract_received_item_error'] = "Nincs elég helyed a tárgyhoz %sx %s",
	['contract_destination_blip'] = "Célállomás",
	['contract_cancel'] = "Visszamondtad a szerződést",
	['contract_not_enough_items'] = "Nem rendelkezel a szükséges tárgyakkal: %s",

	['dive_invalid'] = "Ez a búvárkodás már nem létezik",
	['dive_started'] = "Elkezdtél egy búvárkodást, menj és keresd meg a kincset",
	['dive_already_started'] = "Már elkezdtél egy búvárkodást, fejezd azt először be hogy újat tudj kezdeni",
	['dive_someone_already_started'] = "Valaki már elkezdte ezt a búvárkodást, válassz egy másikat",
	['dive_waypoint_set'] = "A búvárkodás területe megjelölésre került a GPS-en",
	['dive_received_money'] = "Kaptál $%s-t a búvárkodás befejezéséért",
	['dive_received_item'] = "%sx %s tárgyat kaptál a búvárkodás befejezéséért",
	['dive_received_item_error'] = "Nincs elég helyed a tárgyhoz %sx %s",
	['dive_cancel'] = "Visszamondtad a búvárkodásodat",
	['dive_finish'] = "Nyomj ~y~E~w~ a búvárkodás befejezéséhez",

	['money_withdrawn'] = "Pénz kivéve",
	['money_deposited'] = "Pénz befizetve",
	['pay_loans'] = "Ki kell fizetned a kölcsöneidet, mielőtt pénzt vehetnél ki",
	['loan'] = "Kölcsön felvéve",
	['no_loan'] = "Nem veheted fel ezt a kölcsönt",
	['loan_paid'] = "Kölcsön visszafizetve",
	['no_loan_money'] = "Nincs pénzed, hogy kifizesd a horgászatból származó kölcsönödet. Mindent elvesztettél",
	
	['upgrade_purchased'] = "Fejlesztés megvásárolva",
	['equipment_purchased'] = "Felszerelés megvásárolva",
	['insufficient_skill_points'] = "Nincs elég képességpontod",
	
	['occupied_places'] = "A garázs foglalt, valami blokkolja a jármű parkolóhelyét",
	['vehicle_blip'] = "Jármű",
	['garage_blip'] = 'Garázs',
	['press_e_to_store_vehicle'] = '~w~Nyomj ~g~[E]~w~ a tárolásához.',
	['vehicle_already_spawned'] = 'Már van egy járműved',
	['vehicle_lost'] = 'Elvesztetted a járművedet valahol a világban',

	['garage_full'] = 'A garázsod tele van',
	['vehicle_purchased'] = "Megvásároltad a járművet",
	['vehicle_repaired'] = "Jármű megjavítva",
	['vehicle_refueled'] = "Jármű megtankolva",
	['vehicle_already_repaired'] = "Ez a jármű már meg van javítva",
	['vehicle_already_refueled'] = "Ez a jármű már meg van tankolva",
	['vehicle_not_found'] = "Jármű nem található",
	['vehicle_damaged'] = "A jármű túlzottan sérült",
	['vehicle_sold'] = "Jármű eladva $%s-ért",
	['vehicle_spawned'] = "A járműved a garázsodban van",
	['vehicle_capacity_full'] = "A járműved kapacitása tele van",
	['vehicle_owned_name'] = "Saját jármű",
	['vehicle_destroyed'] = "A járműved megsemmisült",

	['stock_item_deposited'] = "Tárgy elhelyezve",
	['dont_have_item'] = "Nincs %sx %s tárgyad a leltáradban",
	['stock_property_full'] = "A horgász ingatlan tárolója nem tudja eltárolni ezt a tárgyat",
	['stock_item_withdrawn'] = "Tárgy kivéve",
	['stock_cannot_withdraw'] = "Ezt a tárgyat nem lehet kivenni",
	['cant_carry_item'] = "Nem bírod el ezt a tárgyat",
	
	['property_waypoint_set'] = "Az ingatlanhoz vezető útvonalpontot megjelöltük a GPS-én",
	['property_needs_repair'] = "El fogod veszíteni a(z) '%s' horgász ingatlant hamarosan, ha nem javítod meg",
	['property_not_owned'] = "Ezzal a horgász tulajdonnal nem rendelkezel",
	['property_sold'] = "Eladtad a horgász ingatlant",
	['property_purchased'] = "Megvásároltad a horgász ingatlant",
	['property_max_amount'] = "Nem lehet több horgász ingatlanod",
	['property_not_found'] = "Ingatlan nem található",
	['property_already_repaired'] = "Ez az ingatlan már meg van javítva",
	['property_repaired'] = "Ingatlan megjavítva",

	['tournament_joined'] = "Sikeresen csatlakozott a versenyhez! A verseny helyszíne megjelöltetett a térképén. Ne feledje, legyen ott időben, és sok szerencsét!",
	['tournament_waypoint'] = "A verseny helyszíne megjelöltetett a térképén",
	['tournament_not_in'] = "Ön nem vesz részt ebben a versenyben",
	['tournament_not_found'] = "Jelenleg nincsenek versenyek itt",
	['tournament_already_in'] = "Már részt vesz ebben a versenyben",
	['tournament_not_available'] = "A csatlakozni kívánt verseny már nem elérhető",
	['tournament_started'] = "A horgászverseny elkezdődött! Fogja meg horgászbotját, és fogjon annyi halat, amennyit csak lehet, hogy nyerjen",
	['tournament_fish_caught'] = "%s pontot ért el ezzel a fogással!",
	['tournament_ended'] = "A verseny befejeződött",
	['tournament_cancelled'] = "A versenyt törölték, mert nem érte el a minimális résztvevői számot. A nevezési díjat visszatérítették",
	['tournament_prize_received'] = "Gratulálunk! A versenyen elért helyezése: %s. A díja: %s",
	['tournament_prize_not_received'] = "Ezúttal nem nyert díjat, de sok szerencsét a következő próbálkozáshoz",

	-- Logs
	['logs_date'] = "Dátum",
	['logs_hour'] = "Idő",
	['logs_withdraw'] = "```md\n[PÉNZ KIVÉVE]: %s \n[ID] %s \r```",
	['logs_deposit'] = "```md\n[PÉNZ BEHELYEZVE]: %s \n[ID] %s \r```",
	['logs_buy_vehicle'] = "```md\n[JÁTÉKOS]: %s\n[JÁRMŰ VÁSÁRLÁS]: %s \n[ÁR]: %s \n[ID]: %s \r```",
	['logs_buy_property'] = "```md\n[JÁTÉKOS]: %s\n[INGATLAN VÁSÁRLÁS]: %s \n[ÁR]: %s \n[ID]: %s \r```",
	['logs_fish_sold'] = "```md\n[HAL ELADÁS]: %s\n[MENNYISÉG]: %s \n[ÁR]: %s \n[ID]: %s \r```",
	['logs_exploit'] = "```md\n[LEHETSÉGES CSALÓ]: %s\n[JÁTÉKOS POZÍCIÓJA]: %s\n[ADAT]: %s\n[JÁTÉKOS]: %s \r```",

	-- Fishing Area
	["cannot_fish_in_vehicle"] = "Nem horgászhatsz, amíg járműben vagy",
	["water_not_found"] = "Nem található víz ezen a helyen! Győződj meg róla hogy van elég víz a horgászathoz",
	["area_not_found"] = "Nem tartózkodsz megfelelő helyen a horgászathoz",
	['new_level'] = "Szintet léptél: %s!",
	["fishing_lost"] = "A hal elúszott",
	
	["missing_equipments"] = {
		["rod"] = "Használnod kell egy horgászbotot",
		["hook"] = "Fel kell szerelned egy horgot",
		["reel"] = "Fel kell szerelned egy orsót",
		["bait"] = "Fel kell szerelned egy csalit",
		["line"] = "Fel kell szerelned egy damilt",
	},
	["equipment_equipped"] = "Felszerelted ezt az eszközt",

	-- Config contracts
	['contracts'] = {
		['chefs_special'] = {
			['name'] = "Séfek Különlegessége",
			['description'] = "A helyi séfeknek szüksége van ezekre a halakra egy ma esti gourmet vacsorához. Megoldható?"
		},
		['exotic_collection'] = {
			['name'] = "Egzotikus Gyűjtemény",
			['description'] = "Szállítsd le ezeket a ritka halakat, különleges felszerelésekért!"
		},
		['aquarium_exhibit'] = {
			['name'] = "Akváriumi Kiállítás",
			['description'] = "Egy akvárium szeretné bővíteni a kiállítását. Szállítsd le ezeket a halakat."
		},
		['rare_fish_trader'] = {
			['name'] = "Ritka Hal Kereskedő",
			['description'] = "Van egy halgyűjtő a városban, aki ritka halfajokat keres. Szállítsd le neki ezeket a halakat és sokat kereshetsz!"
		},
		['swamp_special'] = {
			['name'] = "Mocsári Érdekességek",
			['description'] = "Segíts egy kutatónak mintákat gyűjteni a mocsárból."
		},
		['maritime_donation'] = {
			['name'] = "Tengeri Múzeumi Adomány",
			['description'] = "A helyi tengeri múzeumnak szüksége van példányokra az új óceán kiállításukhoz. Segíts nekik!"
		},
		['gourmet_market'] = {
			['name'] = "Gourmet Halpiac",
			['description'] = "Egy felső kategóriás piac prémium halakat keres. Teljesítsd a rendelésüket bőséges kifizetésért."
		},
		['biological_research'] = {
			['name'] = "Biológiai Kutatás",
			['description'] = "Segíts a kutatóknak azzal, hogy példányokat biztosítasz nekik az élővilág tanulmányozásához."
		},
		['sport_fishing'] = {
			['name'] = "Sport Horgászat Kihívás",
			['description'] = "Fogd ki ezeket a kihívást jelentő fajokat, hogy nyereményt szerezz a helyi sport horgász versenyen."
		},
		['fish_fry'] = {
			['name'] = "Helyi Hal Sütés Esemény",
			['description'] = "Járulj hozzá egy közösségi hal sütés eseményéhez ezeknek a halaknak a leszállításával."
		},
		['seafood_festival'] = {
			['name'] = "Helyi Tenger Gyümölcsei Fesztivál",
			['description'] = "Az éves tenger gyümölcsei fesztiválnak szüksége van különféle halakra a bemutatóhoz. Segíts ellátni az igényeiket!"
		},
		['exotic_aquarium'] = {
			['name'] = "Egzotikus Akváriumi Készlet",
			['description'] = "Egy egzotikus akvárium ritka fajokat szeretne hozzáadni a gyűjteményéhez. Tudod biztosítani őket?"
		},
		['sushi_order'] = {
			['name'] = "Sushi Étterem Rendelés",
			['description'] = "Egy felső kategóriás sushi étterem friss, kiváló minőségű halakat keres. Szállítsd le a rendelésüket időben!"
		},
		['pet_food'] = {
			['name'] = "Gourmet Állateledel Készítő",
			['description'] = "Egy gourmet állateledel készítő kiváló minőségű halakat keres egy új prémium vonalhoz. Segíts nekik!"
		},
		['research_specimens'] = {
			['name'] = "Kutatási Minták",
			['description'] = "A tengeri kutatóknak specifikus halfajokra van szükségük fontos környezeti tanulmányokhoz."
		},
		['fish_market_supply'] = {
			['name'] = "Halpiaci Ellátás",
			['description'] = "Egy helyi halpiacnak folyamatos ellátásra van szüksége közönséges halakból."
		},
		['bait_supply_order'] = {
			['name'] = "Csalirendelés",
			['description'] = "Egy horgászbolt különféle közönséges halakat keres csalinak. Segíts nekik feltölteni a készletüket."
		},
		['cooking_class'] = {
			['name'] = "Közösségi Főzőtanfolyam",
			['description'] = "Egy közösségi központ főzőtanfolyamot tart, és helyi halakra van szükségük, hogy taníthassák a helyes tisztítási és főzési technikákat."
		},
		['restaurant_daily_special'] = {
			['name'] = "Helyi Étterem Napi Ajánlata",
			['description'] = "Egy helyi étterem napi halajánlattal rendelkezik, és friss halakra van szükségük."
		},
		['science_project'] = {
			['name'] = "Iskolai Tudományos Projekt",
			['description'] = "Egy helyi iskola különféle halakat keres egy tudományos projekthez a helyi ökoszisztémákról."
		},
	},
	['dives'] = {
		['reef_explorer'] = {
			['name'] = "Zátony Felfedező",
			['description'] = "Fedezd fel az élénk korallzátonyokat, hogy ritka tengeri életmintákat találj a tengeri biológusok számára."
		},
		['sunken_armada'] = {
			['name'] = "Elsüllyedt Flotta",
			['description'] = "Merülj el egy legendás flotta maradványaiba, amely egy hatalmas vihar során veszett el. Szerezd meg az értékes ereklyéket!"
		},
		['merchant_lost'] = {
			['name'] = "A Kereskedő Elveszett Áruk",
			['description'] = "Egy kereskedőhajó elsüllyedt itt a 18. században, amiről azt beszélik, hogy értékes selymeket és fűszereket szállíthatott."
		},
		['underwater_city'] = {
			['name'] = "Ősi Víz Alatti Város",
			['description'] = "A közelmúltban felfedezett ősi romok a tenger mélyén nyomokat rejthetnek a múlt civilizációiról."
		},
		['kraken_lair'] = {
			['name'] = "Kraken Barlangja",
			['description'] = "Bátor dolog kincseket gyűjteni a mitikus Kraken barlangjából. Óvakodj a haragjától!"
		},
		['meteorite_crash'] = {
			['name'] = "Meteorit Becsapódási Hely",
			['description'] = "Egy meteorit csapódott az óceánba a közelmúltban, ami ritka ásványokban gazdag réteget hozott létre."
		},
		['ghost_ship'] = {
			['name'] = "Kísértethajó Expedíció",
			['description'] = "Vizsgálj meg egy hajót, amely évszázadokkal ezelőtt eltűnt és most rejtélyesen újra megjelent."
		},
		['volcanic_vents'] = {
			['name'] = "Vulkáni Nyílások Felfedezése",
			['description'] = "Fedezd fel a mélytengeri vulkáni nyílásokat, amelyek egyedi életformákkal nyüzsögnek, és gyűjts mintákat tanulmányozásra."
		},
		['wreck_titan'] = {
			['name'] = "A Titan Roncsa",
			['description'] = "Titan egy luxusjacht titokzatos körülmények között süllyedt el, és azt beszélik, hogy tele van kincsekkel."
		},
		['bermuda_triangle'] = {
			['name'] = "Bermuda-háromszög Anomália",
			['description'] = "Vizsgálj meg egy anomáliát a Bermuda-háromszög mélyén. Legyél készen a váratlan helyzetekre."
		},
		['pearl_diver'] = {
			['name'] = "Gyöngyhalász Küldetés",
			['description'] = "Egy jövedelmező merülés gyöngyök gyűjtésére egy sűrű osztriga ágyból, amelyet csak a legidősebb búvárok ismernek."
		},
		['cold_war_relic'] = {
			['name'] = "Hidegháborús Relikvia",
			['description'] = "Keress elveszett kémfelszereléseket egy elsüllyedt hidegháborús tengeralattjárnál."
		},
		['deep_sea_salvage'] = {
			['name'] = "Mélytengeri Mentőakció",
			['description'] = "Szerezd vissza az értékes rakományt egy mélyen az óceánban elsüllyedt teherhajóról."
		},
		['lost_jewel_atlantis'] = {
			['name'] = "Atlantisz Elveszett Ékköve",
			['description'] = "Keresd meg az elveszett ékkövet, amelyről azt beszélik a partok közelében lelhető, és a tenger rejtélyei őrzik."
		},
		['sunken_plane'] = {
			['name'] = "Elsüllyedt Repülőgép Kiemelés",
			['description'] = "Merülj le egy nemrég felfedezett második világháborús repülőgép roncsához, hogy visszaszerezd az elveszett történelmi ereklyéket."
		},
		['sunken_yacht'] = {
			['name'] = "Olajmágnás Elsüllyedt Jachtja",
			['description'] = "Egy milliárdos jachtja titokzatos körülmények között süllyedt el. Szerezd vissza az értékes tárgyakat, amiket találsz."
		},
		['coral_reef_photography'] = {
			['name'] = "Korallzátony Fotózás",
			['description'] = "Készíts lenyűgöző fényképeket a korallzátonyról egy nagy magazin számára. Jól fizetnek a minőségi munkáért!"
		},
		['arctic_shipwreck'] = {
			['name'] = "Jegestengeri Hajóroncs Felfedezés",
			['description'] = "Merülj le a jéghideg vízbe és fedezz fel egy hajót, amely az Északi-sarkkör átkelése közben süllyedt el."
		},
	},
}
