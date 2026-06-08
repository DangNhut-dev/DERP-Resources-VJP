if not Lang then Lang = {} end
Lang['fr'] = {
	['open'] = "~y~E~w~ pour ouvrir",
	['open_main_target'] = "Ouvrir le tableau de bord de pêche",
	['open_property_target'] = "Ouvrir l'entreprise de pêche",
	['open_store_target'] = "Ouvrir la poissonnerie",
	['you_died'] = "Vous êtes décédé et avez perdu votre véhicule",
	['insufficient_money'] = "Argent insuffisant",
	['invalid_value'] = "Valeur invalide",
	['no_permission'] = "Vous n'avez pas le travail requis pour ouvrir ce menu",
	['not_enough_level'] = "Vous n'avez pas assez de niveau pour utiliser cet objet",
	['fish_store_sold'] = "vous avez vendu %sx %s",
	['fish_store_all_sold'] = "Vous avez vendu tous vos poissons pour$%s",
	['fish_store_nothing_sold'] = "Vous n'avez pas de poisson à vendre dans ce magasin",
	['fish_store_not_enough'] = "Vous n'avez pas %sx %s vendu",
	['exp'] = "EXP",

	['anchor_boat_command'] = "Bateau à ancre",
	['anchor_too_fast'] = "Ralentissez pour utiliser l'ancre",
	['anchor_not_allowed'] = "Vous ne pouvez pas jeter l'ancre ici",
	['anchor_lowered'] = "Ancre abaissée",
	['anchor_raised'] = "Ancre levée",

	['contract_invalid'] = "Ce contrat n'existe plus",
	['contract_started'] = "Vous avez commencé un contrat, livrer les produits requis à destination",
	['contract_already_started'] = "Vous avez déjà un contrat, veuillez d'abord le terminer",
	['contract_someone_already_started'] = "Quelqu'un d'autre a déjà commencé ce contrat, veuillez en choisir un autre",
	['contract_waypoint_set'] = "Le waypoint vers le contrat a été marqué sur votre GPS",
	['contract_finish_delivery'] = "~y~E~w~ pour terminer la livraison",
	['contract_received_money'] = "$%s reçu pour avoir terminer le contrat",
	['contract_received_item'] = "%sx %s reçu pour avoir terminer le contrat",
	['contract_received_item_error'] = "Vous n'avez pas assez d'espace pour recevoir l'article %sx %s",
	['contract_destination_blip'] = "Destination",
	['contract_cancel'] = "Vous avez résilié votre contrat",
	['contract_not_enough_items'] = "Vous n'avez pas les éléments requis: %s",

	['dive_invalid'] = "Cette plongée n'existe plus",
	['dive_started'] = "Tu as commencé une plongée, va chercher le trésor",
	['dive_already_started'] = "Vous avez déjà une plongée, veuillez la terminer d'abord",
	['dive_someone_already_started'] = "Quelqu'un d'autre a déjà commencé cette plongée, veuillez en choisir une autre",
	['dive_waypoint_set'] = "Le waypoint vers la zone de plongée a été marqué sur votre GPS",
	['dive_received_money'] = "$%s reçu pour terminer la plongée",
	['dive_received_item'] = "%sx %s reçu pour terminer la plongée",
	['dive_received_item_error'] = "Vous n'avez pas assez d'espace pour recevoir l'article %sx %s",
	['dive_cancel'] = "Vous avez annulé votre plongée",
	['dive_finish'] = "~y~E~w~ terminer la plongée",

	['money_withdrawn'] = "Argent retiré",
	['money_deposited'] = "Argent déposé",
	['pay_loans'] = "Vous devez rembourser vos prêts avant de retirer votre argent",
	['loan'] = "Prêt consenti",
	['no_loan'] = "Vous ne pouvez pas contracter ce prêt",
	['loan_paid'] = "Prêt payé",
	['no_loan_money'] = "Vous n avez pas d argent pour rembourser votre prêt lié au travail de pêcheur. Tu as tout perdu",

	['upgrade_purchased'] = "Mise à niveau achetée",
	['equipment_purchased'] = "Matériel acheté",
	['insufficient_skill_points'] = "Points de compétence insuffisants",

	['occupied_places'] = "Votre garage est occupé, pensez à retirer les obstacles qui bloquent l'espace de stationnement du véhicule",
	['vehicle_blip'] = "Véhicule",
	['garage_blip'] = 'Garage',
	['press_e_to_store_vehicle'] = '~w~Appuyez sur ~g~[E]~w~ pour stocker ~b~vehicle~w~.',
	['vehicle_already_spawned'] = 'Vous possédez déjà un véhicule',
	['vehicle_lost'] = 'Vous avez perdu votre véhicule quelque part dans le monde',

	['garage_full'] = 'Votre garage est plein',
	['vehicle_purchased'] = "Vous avez acheté le véhicule",
	['vehicle_repaired'] = "Véhicule réparé",
	['vehicle_refueled'] = "Véhicule ravitaillé",
	['vehicle_already_repaired'] = "Ce véhicule est déjà réparé",
	['vehicle_already_refueled'] = "Ce véhicule est déjà ravitaillé",
	['vehicle_not_found'] = "Véhicule introuvable",
	['vehicle_damaged'] = "Le véhicule est trop endommagé",
	['vehicle_sold'] = "Véhicule vendu pour$%s",
	['vehicle_spawned'] = "Votre véhicule est dans votre garage",
	['vehicle_capacity_full'] = "La capacité de vos véhicules est pleine",
	['vehicle_owned_name'] = "Véhicule possédé",
	['vehicle_destroyed'] = "Votre véhicule a été détruit",

	['stock_item_deposited'] = "Objet déposé",
	['dont_have_item'] = "Vous n'avez pas %sx %s articles dans votre inventaire",
	['stock_property_full'] = "Le stock immobilier ne peut pas contenir cet article",
	['stock_item_withdrawn'] = "Article retiré",
	['stock_cannot_withdraw'] = "Cet article ne peut pas être retiré",
	['cant_carry_item'] = "Vous ne pouvez pas transporter cet objet",

	['property_waypoint_set'] = "Le waypoint vers la propriété a été marqué sur votre GPS",
	['property_needs_repair'] = "Vous perdrez très bientôt la propriété '%s' si vous ne la réparez pas",
	['property_not_owned'] = "Vous n'êtes pas propriétaire de cette propriété",
	['property_sold'] = "Vous avez vendu la propriété",
	['property_purchased'] = "Vous avez acheté la propriété",
	['property_max_amount'] = 'Vous ne pouvez pas avoir plus de propriétés',
	['property_not_found'] = "Propriété introuvable",
	['property_already_repaired'] = "Cette propriété est déjà réparée",
	['property_repaired'] = "Propriété réparée",

	['tournament_joined'] = "Vous avez rejoint avec succès le tournoi ! L'emplacement du tournoi a été marqué sur votre carte. N'oubliez pas d'être à l'heure et bonne chance !",
	['tournament_waypoint'] = "L'emplacement du tournoi a été marqué sur votre carte",
	['tournament_not_in'] = "Vous n'êtes pas dans ce tournoi",
	['tournament_not_found'] = "Il n'y a actuellement aucun tournoi en cours ici",
	['tournament_already_in'] = "Vous êtes déjà dans ce tournoi",
	['tournament_not_available'] = "Le tournoi auquel vous tentez de participer n'est plus disponible",
	['tournament_started'] = "Le tournoi de pêche a commencé ! Prenez votre canne à pêche et attrapez autant de poissons que possible pour gagner",
	['tournament_fish_caught'] = "Vous avez marqué %s points avec cette prise !",
	['tournament_ended'] = "Le tournoi est terminé",
	['tournament_cancelled'] = "Le tournoi a été annulé car le nombre minimum de participants n'a pas été atteint. Les frais d'inscription ont été remboursés",
	['tournament_prize_received'] = "Félicitations ! Votre place dans le tournoi est : %s. Votre prix est : %s",
	['tournament_prize_not_received'] = "Vous n'avez pas gagné de prix cette fois, mais bonne chance pour votre prochaine tentative",

	-- Logs
	['logs_date'] = "Date",
	['logs_hour'] = "Temps",
	['logs_withdraw'] = "```prolog\n[MONEY WITHDRAW]: %s \n[ID] %s \r```",
	['logs_deposit'] = "```prolog\n[MONEY DEPOSITED]: %s \n[ID] %s \r```",
	['logs_buy_vehicle'] = "```prolog\n[USER]: %s\n[VEHICLE PURCHASED]: %s \n[PRICE]: %s \n[ID]: %s \r```",
	['logs_buy_property'] = "```prolog\n[USER]: %s\n[PROPERTY PURCHASED]: %s \n[PRICE]: %s \n[ID]: %s \r```",
	['logs_fish_sold'] = "```prolog\n[FISH SOLD]: %s\n[AMOUNT]: %s \n[PRICE]: %s \n[ID]: %s \r```",
	['logs_exploit'] = "```prolog\n[POTENTIAL EXPLOIT]: %s\n[PLAYER LOCATION]: %s\n[DATA]: %s\n[USER]: %s \r```",

	-- Fishing Area
	["cannot_fish_in_vehicle"] = "Vous ne pouvez pas pêcher lorsque vous êtes dans un véhicule",
	["water_not_found"] = "Aucune eau trouvée à l'endroit ciblé ! Assurez-vous qu'il y a suffisamment d'eau pour pêcher",
	["area_not_found"] = "Vous n'êtes pas dans une zone valide pour pêcher",
	['new_level'] = "Tu viens de passer au niveau: %s !",
	["fishing_lost"] = "Tu as perdu le poisson",

	["missing_equipments"] = {
		["rod"] = "Vous devez équiper une canne à pêche",
		["hook"] = "Vous devez équiper un hameçon",
		["reel"] = "Vous devez équiper un moulinet de pêche",
		["bait"] = "Vous devez équiper un appât de pêche",
		["line"] = "Vous devez équiper une ligne de pêche",
	},
	["equipment_equipped"] = "Vous avez équipé cet équipement",

	-- Config contracts
	['contracts'] = {
		['chefs_special'] = {
			['name'] = "Spécial du chef",
			['description'] = "Un chef local a besoin de ces poissons pour un repas gastronomique ce soir. Pouvez-vous livrer ?"
		},
		['exotic_collection'] = {
			['name'] = "Collection Exotique",
			['description'] = "Livrez ces poissons rares pour gagner un équipement spécial!"
		},
		['aquarium_exhibit'] = {
			['name'] = "Exposition d'aquariums",
			['description'] = "Un aquarium cherche à agrandir son exposition. Offrez ces poissons contre une récompense."
		},
		['rare_fish_trader'] = {
			['name'] = "Marchand de poissons rares",
			['description'] = "Un collectionneur est en ville à la recherche d'espèces rares. Livrez-les et gagnez gros !"
		},
		['swamp_special'] = {
			['name'] = "Spécialités des marais",
			['description'] = "Aidez un chercheur à collecter des échantillons dans le marais."
		},
		['maritime_donation'] = {
			['name'] = "Don au Musée maritime",
			['description'] = "Le musée maritime local a besoin de spécimens pour sa nouvelle exposition sur l'océan. Aidez-les !"
		},
		['gourmet_market'] = {
			['name'] = "Marché aux poissons gastronomique",
			['description'] = "Un marché haut de gamme recherche du poisson de première qualité. Exécutez leur commande pour un paiement généreux."
		},
		['biological_research'] = {
			['name'] = "Recherche biologique",
			['description'] = "Aider les chercheurs en leur fournissant des spécimens pour leur étude de la vie aquatique."
		},
		['sport_fishing'] = {
			['name'] = "Défi de pêche sportive",
			['description'] = "Attrapez ces espèces difficiles pour gagner un prix lors du concours de pêche sportive local.."
		},
		['fish_fry'] = {
			['name'] = "Événement de friture de poisson local",
			['description'] = "Contribuez à l'événement communautaire de friture de poisson en livrant ces poissons populaires."
		},
		['seafood_festival'] = {
			['name'] = "Festival des fruits de mer locaux",
			['description'] = "Le festival annuel des fruits de mer a besoin d’une variété de poissons à mettre en valeur. Aidez à répondre à leurs besoins !"
		},
		['exotic_aquarium'] = {
			['name'] = "Stock d'aquarium exotique",
			['description'] = "Un aquarium exotique cherche à ajouter des espèces rares à sa collection. Pouvez-vous les fournir ?"
		},
		['sushi_order'] = {
			['name'] = "Commande de restaurant de sushi",
			['description'] = "Un restaurant de sushi haut de gamme a besoin de poisson frais et de première qualité. Livrer leur commande à temps !"
		},
		['pet_food'] = {
			['name'] = "Fabricant d'aliments gastronomiques pour animaux de compagnie",
			['description'] = "Un fabricant d'aliments gastronomiques pour animaux de compagnie a besoin de poisson de haute qualité pour une nouvelle gamme haut de gamme. Aidez-les !"
		},
		['research_specimens'] = {
			['name'] = "Recherche de spécimens",
			['description'] = "Les chercheurs marins ont besoin d’espèces de poissons spécifiques pour des études environnementales importantes."
		},
		['fish_market_supply'] = {
			['name'] = "Approvisionnement du marché aux poissons",
			['description'] = "Un marché aux poissons local a besoin d'un approvisionnement constant en poissons communs pour maintenir ses étagères bien approvisionnées.."
		},
		['bait_supply_order'] = {
			['name'] = "Commande de fourniture d'appâts",
			['description'] = "Un magasin de pêche a besoin de divers poissons communs comme appât. Aidez-les à réapprovisionner leur inventaire."
		},
		['cooking_class'] = {
			['name'] = "Cours de cuisine communautaire",
			['description'] = "Un centre communautaire organise un cours de cuisine et a besoin de poissons locaux communs pour enseigner les techniques de nettoyage et de cuisson appropriées.."
		},
		['restaurant_daily_special'] = {
			['name'] = "Spécial restaurant local",
			['description'] = "Un restaurant local propose un plat de poisson du jour et a besoin de poisson commun frais livré quotidiennement.."
		},
		['science_project'] = {
			['name'] = "Projet scientifique scolaire",
			['description'] = "Une école locale a besoin de divers poissons communs pour un projet scientifique sur les écosystèmes locaux."
		},
	},
	['dives'] = {
		['reef_explorer'] = {
			['name'] = "Explorateur de récifs",
			['description'] = "Explorez les récifs coralliens vibrants pour trouver des échantillons rares de vie marine pour les biologistes marins."
		},
		['sunken_armada'] = {
			['name'] = "Armada engloutie",
			['description'] = "Plongez dans les vestiges d'une flotte légendaire perdue lors d'une énorme tempête. Récupérer les artefacts!"
		},
		['merchant_lost'] = {
			['name'] = "Les biens perdus du marchand",
			['description'] = "Un navire marchand coulé ici au XVIIIe siècle, censé transporter des soies et des épices précieuses.."
		},
		['underwater_city'] = {
			['name'] = "Ancienne ville sous-marine",
			['description'] = "Des ruines antiques récemment découvertes sous la mer pourraient contenir des indices sur des civilisations passées."
		},
		['kraken_lair'] = {
			['name'] = "Le repaire du Kraken",
			['description'] = "Osez récupérer les trésors de l'antre du mythique Kraken. Méfiez-vous de sa colère !"
		},
		['meteorite_crash'] = {
			['name'] = "Site d'accident de météorite",
			['description'] = "Une météorite s'est récemment écrasée dans l'océan, créant un riche lit de minéraux rares."
		},
		['ghost_ship'] = {
			['name'] = "Expédition en bateau fantôme",
			['description'] = "Plongez pour enquêter sur un navire qui a disparu il y a des siècles et qui est maintenant mystérieusement réapparu.."
		},
		['volcanic_vents'] = {
			['name'] = "Découverte des cheminées volcaniques",
			['description'] = "Explorez des cheminées volcaniques en haute mer regorgeant de formes de vie uniques et collectez des échantillons à étudier."
		},
		['wreck_titan'] = {
			['name'] = "Épave du Titan",
			['description'] = "Le Titan, un yacht de luxe coulé dans des circonstances mystérieuses, serait rempli de richesses."
		},
		['bermuda_triangle'] = {
			['name'] = "Anomalie du Triangle des Bermudes",
			['description'] = "Enquêtez sur une anomalie dans les profondeurs du Triangle des Bermudes. Attendez-vous à l'inattendu."
		},
		['pearl_diver'] = {
			['name'] = "La quête du plongeur de perles",
			['description'] = "Une plongée lucrative pour récolter les perles d'un parc à huîtres dense, connue uniquement des plongeurs les plus âgés.."
		},
		['cold_war_relic'] = {
			['name'] = "Relique de la guerre froide",
			['description'] = "Récupérer le matériel d'espionnage perdu dans un sous-marin coulé de la guerre froide."
		},
		['deep_sea_salvage'] = {
			['name'] = "Opération de sauvetage en haute mer",
			['description'] = "Récupérez une précieuse cargaison d'un cargo coulé au fond de l'océan."
		},
		['lost_jewel_atlantis'] = {
			['name'] = "Joyau perdu de l'Atlantide",
			['description'] = "À la recherche du légendaire joyau perdu qui se trouverait au large des côtes, gardé par les mystères de la mer."
		},
		['sunken_plane'] = {
			['name'] = "Récupération d'un avion coulé",
			['description'] = "Plongez dans une épave d'avion de la Seconde Guerre mondiale récemment découverte pour récupérer des objets historiques perdus."
		},
		['sunken_yacht'] = {
			['name'] = "Le yacht coulé du magnat du pétrole",
			['description'] = "Le yacht d'un milliardaire a coulé dans des circonstances mystérieuses. Récupérez tous les objets de valeur que vous trouvez."
		},
		['coral_reef_photography'] = {
			['name'] = "Photographie des récifs coralliens",
			['description'] = "Prenez de superbes photos du récif de corail pour un grand magazine. Ils paient bien pour la qualité !"
		},
		['arctic_shipwreck'] = {
			['name'] = "Expédition sur épaves dans l'Arctique",
			['description'] = "Bravez les eaux froides pour découvrir un navire qui a coulé alors qu'il tentait de traverser le cercle polaire arctique.."
		},
	},
}
