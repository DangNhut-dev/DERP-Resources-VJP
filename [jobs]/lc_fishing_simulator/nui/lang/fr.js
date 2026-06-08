if (Lang == undefined) {
	var Lang = [];
}
Lang["fr"] = {
	common: {
		confirm: "Confirmer",
		weight_unit: "kg",
		level_abbreviate: "Lvl.",
		skill_point: "Point de compétence",
		areas: {
			sea: "Mer",
			lake: "Lac",
			river: "Rivière",
			swamp: "Marais",
			all: "tout",
		},
	},
	sidebar: {
		profile: "Votre profil",
		bank: "Banque",
		deliveries: "Livraisons spéciales",
		dives: "Plongées",
		upgrades: "Mises à niveau",
		equipments: "Equipements",
		store: "Magasin",
		owned_vehicles: "Véhicules possédés",
		owned_property: "Propriétés possédées",
		guide: "Guide",
		close: "Fermer",
		property: "Propriété",
		fish_store: "Poissonnerie",
	},
	modals: {
		confirmation: {
			sell_vehicle: "Êtes-vous sûr de vouloir vendre ce véhicule ?",
			sell_propertty: "Etes-vous sûr de vouloir vendre cette propriété ? Tous les objets stockés seront perdus",
			loan_payoff: "Etes-vous sûr de vouloir payer la totalité du solde de{0}?",
			sell_all_fishes: "Cette action vendra tous les poissons de votre inventaire. Êtes-vous sûr de vouloir continuer ?",
		},
	},
	statistics_page: {
		title: "Statistiques",
		desc: "Statistiques pour suivre la progression de votre vie de pêcheur",
		money_earned: "Argent total gagné",
		money_spent: "Argent total dépensé",
		total_mythic_fish: "Total des poissons mythiques capturés",
		total_legendary_fish: "Total de poissons légendaires capturés",
		total_all_fish: "Total de poissons capturés",
		total_dives: "Total plongées terminées",
		total_deliveries: "Total des livraisons terminées",
		total_exp: "EXP totale gagnée",
		total_upgrades: "Total des mises à niveau achetées",
		top_users: {
			title: "Les meilleurs pêcheurs",
			desc: "Top 10 des pêcheurs de la ville",
			fishes_caught: "Poissons capturés: {0}",
			exp: "EXP: {0}",
		},
	},
	deliveries_page: {
		title: "Livraisons",
		desc: "Terminez les commandes pour recevoir des prix spéciaux pour le poisson. Sélectionnez un contrat pour démarrer et livrer les poissons demandés au client",
		contracts_time: "Nouveaux contrats toutes les {0} minutes",
		reward: "Récompense",
		required_items: "Éléments requis",
		start_button: "Démarrer le contrat",
		cancel_button: "Annuler le contrat",
		see_location: "Voir l'emplacement",
		missing_item: "Cela ne vous appartient pas",
	},
	dives_page: {
		start_button: "Commencer la plongée",
		cancel_button: "Annuler la plongée",
		title: "Plongées",
		desc: "Terminez des expéditions sous-marines pour trouver des trésors et des objets rares. Sélectionnez une mission de plongée pour commencer et gagnez des récompenses uniques, mais notez que les emplacements des coffres au trésor ne sont pas précis sur votre GPS, ce qui rend la tâche difficile, même pour les plus expérimentés.",
		time: "Nouvelles plongées toutes les {0} minutes",
	},
	bank_page: {
		title: "Banque",
		desc: "Consultez ici les informations du compte bancaire de votre entreprise",
		withdraw: "Retirer de l'argent",
		deposit: "Déposer de l'argent",
		balance: "Votre solde est de :",
		active_loans: "Prêts actifs",

		loan_title: "Prêts",
		loan_desc: "Souscrivez des prêts pour investir dans votre entreprise!<BR>(Prêt maximum: {0})",
		loan_button: "Prendre un prêt",
		loan_value_title: "Montant du prêt",
		loan_daily_title: "Coût quotidien",
		loan_remaining_title: "Montant restant",
		loan_date_title: "Prochain paiement (Auto-Debit)",
		loan_pay: "Remboursement de Prêt",

		loan_modal_desc: "Sélectionnez l'un des types de prêt:",
		loan_modal_item: "({0}% taux d'intérêt, remboursable en {1} jours)",
		loan_modal_submit: "Prendre un prêt",

		deposit_modal_title: "Déposer de l'argent",
		deposit_modal_desc: "Combien souhaitez-vous déposer ?",
		deposit_modal_submit: "Déposer de l'argent",

		withdraw_modal_title: "Retirer de l'argent",
		withdraw_modal_desc: "Combien souhaitez-vous retirer ?",
		withdraw_modal_submit: "Retirer de l'argent",

		modal_placeholder: "Montant",
		modal_money_available: "Argent disponible : {0}",
		modal_cancel: "Annuler",
	},
	upgrades_page: {
		title: "Compétences",
		desc: "Utilisez vos points de compétence accumulés pour débloquer de nouvelles capacités qui amélioreront votre expérience de pêche. Il existe un large éventail de compétences qui peuvent faire de vous un meilleur pêcheur.",
		vehicles: {
			title: "Vehicules",
			desc: "Améliorez la capacité de votre garage pour accueillir plus de véhicules pour transporter vos poissons.",
			level: "+{0} emplacements pour véhicules dans votre garage<BR>+ Débloque de nouveaux véhicules à acheter",
		},
		boats: {
			title: "Bateaux",
			desc: "Améliorez la capacité de votre quai pour accueillir plus de bateaux pour transporter votre poisson.",
			level: "+{0} emplacements pour véhicules dans votre garage<BR>+ Débloque de nouveaux bateaux à acheter",
		},
		properties: {
			title: "Propriétés",
			desc: "Débloquez de nouvelles propriétés pour les rendre achetables.",
			level: "Débloque de nouvelles propriétés à acheter",
		},
		lake: {
			title: "Lac",
			desc: "Améliorez vos compétences en lac pour attraper plus de types de poissons.",
			level: "Débloque de nouvelles espèces de poissons dans le lac",
		},
		river: {
			title: "Rivière",
			desc: "Améliorez vos compétences en rivière pour attraper plus de types de poissons.",
			level: "Débloque de nouvelles espèces de poissons dans la rivière",
		},
		swamp: {
			title: "Marais",
			desc: "Améliorez vos compétences dans les marais pour attraper plus de types de poissons.",
			level: "Débloque de nouvelles espèces de poissons dans le marais",
		},
		sea: {
			title: "Mer",
			desc: "Améliorez vos compétences en mer pour attraper plus de types de poissons.",
			level: "Débloque de nouvelles espèces de poissons dans la mer",
		},
	},
	equipments_page: {
		title: "Équipements",
		desc: "Achetez de nouveaux équipements de pêche pour améliorer vos techniques de pêche. Améliorez votre temps de réaction, augmentez les chances d'attraper des poissons rares et réduisez le temps d'attente pour les attraper. Investissez dans votre équipement pour augmenter l’efficacité et le succès de votre pêche",
		name: "Nom",
		price: "Prix",
		bonus: "Bonus",
		amount: "Montant",
		buy_button: "Acheter",
		unlock_text: "Atteignez le <b>niveau {0}</b> pour débloquer cet équipement.",
		rod: {
			title: "Canne",
			desc: "Améliorez votre canne à pêche pour augmenter les chances d'attraper des poissons plus rares",
		},
		reel: {
			title: "Bobine",
			desc: "Améliorez votre moulinet pour augmenter les performances de déroulement, ce qui rend la progression du déroulement plus rapide",
		},
		hook: {
			title: "hameçon",
			desc: "Améliorez votre hameçon pour augmenter le temps dont vous disposez pour réagir lorsque vous accrochez un poisson, le rendant ainsi plus facile à attraper",
		},
		line: {
			title: "Ligne",
			desc: "Cette mise à niveau rendra votre ligne plus solide, ce qui signifie qu'il sera plus facile de contrôler la tension et d'attraper le poisson plus rapidement.",
		},
		bait: {
			title: "Appât",
			desc: "Améliorez votre appât pour réduire le temps d'attente avant qu'un poisson morde et commencer votre pêche plus tôt.",
		},
		other : {
			title: "Autre",
			desc: "Autres équipements pour améliorer votre expérience de pêche",
		},
	},
	store_page: {
		title: "Magasin de flotte et de propriété",
		desc: "Achetez des véhicules, des bateaux et des propriétés pour améliorer vos capacités de livraison. Choisissez parmi une variété d’options pour améliorer votre efficacité et développer vos opérations",
		buy_button: "Acheter",
		tabs: {
			vehicle: "Vehicules",
			boat: "Bateaux",
			property: "Propriétés",
		},
		vehicle: {
			name: "Vehicule",
			price: "Prix",
			trunk: "Poids",
		},
		property: {
			name: "Propriété",
			capacity: "Capacité",
			owned: "Vous possédez déjà cette propriété",
		},
	},
	owned_vehicles_page: {
		title: "Véhicules possédés",
		desc: "Visualisez et gérez votre garage, où vous pouvez surveiller l'état et les niveaux de carburant de vos bateaux et véhicules.",
		vehicle_plate: "Plaque:",
		unregistered: "Vide",
		distance: "Km Total: {0} km",
		vehicle_condition: "État du véhicule",
		vehicle_fuel: "Essence",
		repair: "Réparation {0}",
		refuel: "Ravitailler {0}",
		spawn: "Spawn Vehicule",
		sell: "Vendre",
		unlock_text: {
			vehicle: "Améliorez le garage du véhicule au <b>niveau {0}</b> pour déverrouiller ce véhicule.",
			boat: "Améliorez le garage à bateaux au <b>niveau {0}</b> pour débloquer ce bateau.",
			property: "Améliorez la compétence Propriété au <b>niveau {0}</b> pour débloquer cette propriété.",
		},
		tabs: {
			vehicle: "Vehicules",
			boat: "Bateaux",
		},
	},
	owned_properties_page: {
		title: "Propriétés possédées",
		desc: "Gérez vos propriétés ici. Visualisez la capacité du stock, son état, définissez des points de cheminement, vendez des propriétés et réparez-les une fois qu'elles se dégradent pour continuer à fonctionner correctement.",
		see: "Voir le parc immobilier",
		repair: "Réparation {0}",
		sell: "Vendre une propriété",
		stock_percentage: "Capacité de stockage",
		stock_condition: "Etat des stocks",
		address: "Adresse: {0}",
		set_waypoint: "Définir un point de cheminement",
	},
	guide_page: {
		title: "Guide",
		desc: "Un guide conçu pour aider les pêcheurs à connaître les espèces de poissons trouvées dans chaque endroit",
		fish_weight: "Poids",
		fish_value: "Valeur",
		filter_label: "Filtrer par nom",
		filter_placeholder: "Nom du poisson",
	},
	stock_page: {
		title: "Propriété({0})",
		desc: "Ici, vous pouvez voir et interagir avec tous les éléments stockés par votre propriété.",
		property_stock_title: "Inventaire Propriété",
		player_inventory_title: "Votre inventaire",
		table_empty:"Stock vide",
		bar_title: "Capacité de stockage",
		inventory_table: {
			header_name: "Nom de l'article",
			header_amount: "Montant",
			header_weight: "Poids",
			header_value: "Valeur",
		},
		deposit_modal_title: "Deposit item",
		deposit_modal_item_available: "En inventaire: {0}",
		withdraw_modal_title: "Retirer l'article",
		withdraw_modal_item_available: "En stock: {0}",
		withdraw_modal_amount: "Montant",
		withdraw_modal_cancel: "Annuler",
	},
	tournaments: {
		join_tournament_alert: {
			title: "Tournoi de Pêche",
			body: "Participez à nos tournois de pêche pour une chance de gagner de grands prix ! Le prochain tournoi commence <b>{0}</b> à <b>{1}</b>. Pour participer, cliquez sur le bouton \"Rejoindre le tournoi\" avant le début de l'événement.",
			footer: "Préparez votre matériel et visez le grand prix en attrapant le poisson le plus gros et le plus rare. Ne ratez pas votre chance de gagner jusqu'à <b>{0}</b> !",
			button: "Rejoindre le Tournoi",
		},
		joined_tournament_alert: {
			title: "Inscription au Tournoi Confirmée",
			body: "Vous avez réussi à rejoindre le prochain tournoi de pêche ! Il commence <b>{0}</b> à <b>{1}</b>. N'oubliez pas d'être là à l'heure.",
			footer: "Tout est prêt ! Équipez-vous pour concourir pour le grand prix et la chance d'attraper le poisson le plus gros et le plus rare. Jusqu'à <b>{0}</b> en prix vous attendent !",
			button: "Marquer l'Emplacement sur le GPS",
		},
		scoreboard_dialog: {
			title: "Tableau des Scores du Tournoi",
			table_name: "Nom",
			table_points: "Points",
		},
		join_tournament_dialog: {
			title: "Rejoindre le Tournoi de Pêche",
			body: `
				<p>Vous êtes sur le point de participer au tournoi de pêche. Voici les détails du tournoi :</p>
		
				<ul>
					<li><strong>Heure de début du tournoi :</strong> {0} à {1}</li>
					<li><strong>Frais d'inscription :</strong> {2}</li>
					<li><strong>Durée :</strong> {3} minutes</li>
				</ul>
		
				<p><strong>Prix :</strong></p>
				<ul>
					<li><strong>1ère Place :</strong> {4}</li>
					<li><strong>2ème Place :</strong> {5}</li>
					<li><strong>3ème Place :</strong> {6}</li>
				</ul>
		
				<p><strong>Objectif :</strong> Attrapez autant de poissons que possible pour augmenter votre score total, les poissons rares augmentant plus votre score que les communs ! 🏆</p>
		
				<p>Êtes-vous prêt ?</p>`,
		},
		today_text: "Aujourd'hui",
		week_days: new Array("Dimanche", "Lundi", "Mardi", "Mercredi", "Jeudi", "Vendredi", "Samedi"),
	},
	fish_store_page: {
		desc: "Ici, vous pouvez vendre vos prises à des prix désignés. Utilisez les options de filtrage pour trouver rapidement un poisson spécifique par son nom ou ajuster les fourchettes de prix. Obtenez la meilleure valeur pour vos efforts et gardez votre inventaire à jour",
		amount: "Montant",
		sell_button: "Vendre du poisson",
		sell_all_button: "Vendre tous les poissons",
		filters: {
			title: "Filtres",
			name_placeholder: "Filtrer par nom",
			name: "Nom :",
			price: "Prix :",
			min: "Min:",
			max: "Max:",
			only_owned: "Possédé uniquement:",
			filter_btn: "Filtre",
		},
		others_tab: "Autres",
	},
	fishing_game: {
		get_ready: "Préparez-vous à ferrer le poisson !",
		hook_fish: "<strong>LMB</strong> ferrer le poisson!",
		instructions: {
			title: "INSTRUCTIONS",
			hook_command: "Action (ferrer/rembobiner)",
			exit_fishing: "Arreter de pêcher",
		},
		progress_bar_labels: {
			tension: {
				low: "Tension basse",
				avg: "Tension optimale",
				max: "Tension haute",
			},
			progress: {
				low: "Départ",
				avg: "En progression",
				max: "Presque attrapé",
			},
		},
		fish_details: {
			rarity: {
				common: "Commun",
				uncommon: "Peu common",
				rare: "Rare",
				legendary: "Légendaire",
				mythic: "Mythique",
			},
			weight: "Poids",
			exp: "EXP",
			price: "Prix",
			keep: "Garder",
			release: "Libérer",
			illegal: "Illégal",
		},
	},
};