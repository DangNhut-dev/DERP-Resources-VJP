let config = {};

window.addEventListener("message", async function (event) {
	const item = event.data;
	if (item.utils) {
		if (typeof Lang === "undefined") {
			await Utils.loadLanguageModules(item.utils);
		}
	}
	if (item.resourceName) {
		Utils.setResourceName(item.resourceName);
	}
	if (item.openOwnerUI) {
		config = item.data.config;
		const player_inventory = item.data.player_inventory;
		const fishing_simulator_user = item.data.fishing_simulator_users;
		const fishing_simulator_fishes_caught = item.data.fishing_simulator_fishes_caught;
		const fishing_simulator_loans = item.data.fishing_simulator_loans;
		const fishing_simulator_available_contracts = item.data.fishing_simulator_available_contracts;
		const fishing_simulator_available_dives = item.data.fishing_simulator_available_dives;
		const fishing_simulator_vehicles = item.data.fishing_simulator_vehicles;
		const fishing_simulator_properties = item.data.fishing_simulator_properties;

		/*
		 * PLAYER INFO HEADER
		 */
		$("#player-info-level").text(Utils.numberFormat(config.player_level, 0));
		$("#player-info-skill").text(Utils.numberFormat(fishing_simulator_user.skill_points, 0));
		$("#player-info-money").text(Utils.currencyFormat(fishing_simulator_user.money, 2));

		renderStatisticsPage(fishing_simulator_user, fishing_simulator_fishes_caught, item.data.top_users, item.data.next_tournament);
		renderDeliveriesPage(fishing_simulator_available_contracts, fishing_simulator_user, getTableTotalFishesUserHas(player_inventory, fishing_simulator_properties));
		renderDivesPage(fishing_simulator_available_dives, fishing_simulator_user);
		renderStorePage(config.available_items_store, fishing_simulator_properties, fishing_simulator_user);
		renderOwnedVehiclesPage(fishing_simulator_vehicles, config.available_items_store, item.data.max_garage_slots);
		renderOwnedPropertiesPage(fishing_simulator_properties, config.available_items_store, config.fishes_available);
		renderBankPage(fishing_simulator_user, item.data.available_money, fishing_simulator_loans);
		renderUpgradesPage(config.upgrades, fishing_simulator_user);
		renderEquipmentsPage(config.equipments_upgrades, config.player_level);
		renderGuidePage(config.fishes_available);

		if (item.isUpdate !== true) {
			// Open on first time
			$(".main").fadeIn(200);
			renderStaticTexts();

			$(".css-toggle").prop("checked", fishing_simulator_user.dark_theme).change();
			setTimeout(() => {
				openPage("profile");
			}, 100);
		}
	} else if (item.openPropertyUI) {
		config = item.data.config;
		const fishing_simulator_users = item.data.fishing_simulator_users;
		const player_inventory = item.data.player_inventory;

		renderStaticTextsProperty();

		/*
		 * PLAYER INFO HEADER
		 */
		$("#player-info-level-stock").text(Utils.numberFormat(config.player_level, 0));
		$("#player-info-skill-stock").text(Utils.numberFormat(fishing_simulator_users.skill_points, 0));
		$("#player-info-money-stock").text(Utils.currencyFormat(fishing_simulator_users.money, 2));

		renderStockPage(item.property, config.available_items_store, player_inventory, config.fishes_available);

		$(".main-stock").fadeIn(200);
		$(".stock-page").css("display", "block");
		$(".css-toggle").prop("checked", fishing_simulator_users.dark_theme).change();
		openPage("stock");
	} else if (item.openFishStoreUI) {
		const fishing_simulator_users = item.data.fishing_simulator_users;
		const store_data = item.data.store_data;
		const fishes_available = item.data.fishes_available;
		const items_in_inventory = item.data.items_in_inventory;

		renderStaticTextsFishStore();

		/*
		 * PLAYER INFO HEADER
		 */
		$("#player-info-level-fish-store").text(Utils.numberFormat(item.data.player_level, 0));
		$("#player-info-skill-fish-store").text(Utils.numberFormat(fishing_simulator_users.skill_points, 0));
		$("#player-info-money-fish-store").text(Utils.currencyFormat(item.data.available_money, 2));

		renderFishStorePage(fishes_available, store_data, items_in_inventory);

		$(".main-fish-store").fadeIn(200);
		$(".fish-store-page").css("display", "block");
		$(".css-toggle").prop("checked", fishing_simulator_users.dark_theme).change();
		openPage("fish-store", "fish-store-sea");
	} else if (item.openTournamentUI) {
		let c = 1;
		let icon;
		let tableBodyHtml = ``;
		let sorted_tournament_list = Utils.sortElement(item.fishing_simulator_tournaments_users, "catches", false);
		for (const tournament_user of sorted_tournament_list) {
			if (c == 1) {
				icon = `<i class="fas fa-medal amber accent-4 font-medium-5"></i>`;
			} else if (c == 2) {
				icon = `<i class="fas fa-medal blue-grey lighten-3 font-medium-4"></i>`;
			} else if (c == 3) {
				icon = `<i class="fas fa-medal bronze font-medium-3"></i>`;
			} else {
				icon = c.toString();
			}
			tableBodyHtml += `
				<tr>
					<td>${icon}</td>
					<td>${tournament_user.user_name}</td>
					<td class="text-end">${tournament_user.catches}</td>
				</tr>`;
			c++;
		}
		let bodyHtml = `
			<div style="max-height: 50vh; overflow: auto;">
				<table class="table table-striped">
					<thead>
						<tr>
							<th scope="col">#</th>
							<th scope="col">${Utils.translate("tournaments.scoreboard_dialog.table_name")}</th>
							<th scope="col">${Utils.translate("tournaments.scoreboard_dialog.table_points")}</th>
						</tr>
					</thead>
					<tbody>
						${tableBodyHtml}
					</tbody>
				</table>
			</div>
		`;
		const tournamentScoreboardModalConfig = {
			title: Utils.translate("tournaments.scoreboard_dialog.title"),
			bodyHtml: bodyHtml,
			buttons: [
				{ text: Utils.translate("confirmation_modal_cancel_button"), class: "btn btn-outline-primary", dismiss: true },
			],
		};
		Utils.showCustomModal(tournamentScoreboardModalConfig);

		$("#confirmation-modal").on("hidden.bs.modal", function () {
			closeUI();
		});
	}
	if (item.hidemenu) {
		$(".main").fadeOut(200);
		$(".main-stock").fadeOut(200);
		$(".main-fish-store").fadeOut(200);
	}
	createListeners();

	//FISHING AREA
	if (item.startFishing) {
		fishingGame.startFishing(item.fishing_difficulties, item.fishing_simulator_user, item.equipments_upgrades, item.selected_equipments, item.time_bait, item.time_hook);
	}
	if (item.updateFishingCoords) {
		fishingGame.updateFishingCoords(item.x, item.y);
	}
});

function createListeners() {
	$(".sidebar-navigation ul li").on("click", function () {
		$("li").removeClass("active");
		$(this).addClass("active");
	});

	$(".navigation-tabs-container .navigation-tab").on("click", function () {
		$(".navigation-tab").removeClass("selected");
		$(this).addClass("selected");
	});
}

function renderStaticTextsProperty() {
	// Properties UI
	$("#stock-page-desc").text(Utils.translate("stock_page.desc"));
	$("#stock-page-th-name").text(Utils.translate("stock_page.inventory_table.header_name"));
	$("#stock-page-th-weight").text(Utils.translate("stock_page.inventory_table.header_weight"));
	$("#stock-page-th-amount").text(Utils.translate("stock_page.inventory_table.header_amount"));
	$("#stock-page-th-value").text(Utils.translate("stock_page.inventory_table.header_value"));
	$("#stock-player-page-th-name").text(Utils.translate("stock_page.inventory_table.header_name"));
	$("#stock-player-page-th-weight").text(Utils.translate("stock_page.inventory_table.header_weight"));
	$("#stock-player-page-th-amount").text(Utils.translate("stock_page.inventory_table.header_amount"));
	$("#withdraw-item-modal-cancel").text(Utils.translate("stock_page.withdraw_modal_cancel"));
	$("#withdraw-item-modal-submit").text(Utils.translate("common.confirm"));
	$("#withdraw-item-modal-amount").text(Utils.translate("stock_page.withdraw_modal_amount"));
	$("#deposit-item-modal-cancel").text(Utils.translate("stock_page.withdraw_modal_cancel"));
	$("#deposit-item-modal-submit").text(Utils.translate("common.confirm"));
	$("#deposit-item-modal-amount").text(Utils.translate("stock_page.withdraw_modal_amount"));
	$("#stock-title").text(Utils.translate("stock_page.bar_title"));
	$("#stock-table-factory-title").text(Utils.translate("stock_page.property_stock_title"));
	$("#stock-table-player-title").text(Utils.translate("stock_page.player_inventory_title"));

	$("#nav-bar-stock").html(`
		<li class="active">
			<i class="fas fa-warehouse"></i>
			<span class="tooltip">${Utils.translate("sidebar.property")}</span>
		</li>
		<li onclick="closeUI()">
			<i class="fas fa-times"></i>
			<span class="tooltip">${Utils.translate("sidebar.close")}</span>
		</li>
	`);
	$("#player-info-level-stock-label").text(Utils.translate("common.level_abbreviate"));
}

function renderStaticTextsFishStore() {
	$("#fish-store-page-desc").text(Utils.translate("fish_store_page.desc"));
	$("#fish-store-sell-all-button").text(Utils.translate("fish_store_page.sell_all_button"));

	$("#nav-bar-fish-store").html(`
		<li onclick="openPage('store')" class="active">
			<i class="fas fa-store"></i>
			<span class="tooltip">${Utils.translate("sidebar.fish_store")}</span>
		</li>
		<li onclick="closeUI()">
			<i class="fas fa-times"></i>
			<span class="tooltip">${Utils.translate("sidebar.close")}</span>
		</li>
	`);

	$(".navigation-tabs-container").empty();
	$("#navigation-tab-fish-store").append(getFishStoreTabHTML());

	$("#player-info-level-fish-store-label").text(Utils.translate("common.level_abbreviate"));
}

function renderStaticTexts() {
	$(".pages").css("display", "none");
	$(".main").css("display", "");

	// Statistics page
	$("#profile-page-title").text(Utils.translate("statistics_page.title"));
	$("#profile-page-desc").text(Utils.translate("statistics_page.desc"));
	$("#profile-money-earned-text").text(Utils.translate("statistics_page.money_earned"));
	$("#profile-money-spent-text").text(Utils.translate("statistics_page.money_spent"));
	$("#profile-total-xp").text(Utils.translate("statistics_page.total_exp"));
	$("#profile-total-upgrades").text(Utils.translate("statistics_page.total_upgrades"));
	$("#profile-total-dives").text(Utils.translate("statistics_page.total_dives"));
	$("#profile-total-deliveries").text(Utils.translate("statistics_page.total_deliveries"));
	$("#profile-total-mythic-fish").text(Utils.translate("statistics_page.total_mythic_fish"));
	$("#profile-total-legendary-fish").text(Utils.translate("statistics_page.total_legendary_fish"));
	$("#profile-total-all-fish").text(Utils.translate("statistics_page.total_all_fish"));

	$("#top-users-title-div").html(`
		<h4 class="text-uppercase">${Utils.translate("statistics_page.top_users.title")}</h4>
		<p>${Utils.translate("statistics_page.top_users.desc")}</p>
	`);

	// Deliveries page
	$("#deliveries-title-div").html(`
		<h4 class="text-uppercase">${Utils.translate("deliveries_page.title")}</h4>
		<p>${Utils.translate("deliveries_page.desc")}</p>
	`);
	$("#new-contracts-text").text(Utils.translate("deliveries_page.contracts_time").format(config.contracts.time_to_new_contracts));

	// Dives page
	$("#dives-title-div").html(`
		<h4 class="text-uppercase">${Utils.translate("dives_page.title")}</h4>
		<p>${Utils.translate("dives_page.desc")}</p>
	`);
	$("#new-dives-text").text(Utils.translate("dives_page.time").format(config.dives.time_to_new_dives));

	// Upgrades page
	$("#upgrades-page-title").text(Utils.translate("upgrades_page.title"));
	$("#upgrades-page-desc").text(Utils.translate("upgrades_page.desc"));

	// $("#vehicles-upgrade-desc").text(Utils.translate("upgrades_page.vehicles.desc"));
	// $("#boats-upgrade-desc").text(Utils.translate("upgrades_page.boats.desc"));
	// $("#properties-upgrade-desc").text(Utils.translate("upgrades_page.properties.desc"));
	$("#lake-upgrade-desc").text(Utils.translate("upgrades_page.lake.desc"));
	$("#river-upgrade-desc").text(Utils.translate("upgrades_page.river.desc"));
	$("#swamp-upgrade-desc").text(Utils.translate("upgrades_page.swamp.desc"));
	$("#sea-upgrade-desc").text(Utils.translate("upgrades_page.sea.desc"));

	// Equipments page
	$("#equipments-page-title").text(Utils.translate("equipments_page.title"));
	$("#equipments-page-desc").text(Utils.translate("equipments_page.desc"));
	$("#reel-equipments-desc").text(Utils.translate("equipments_page.reel.desc"));
	$("#hook-equipments-desc").text(Utils.translate("equipments_page.hook.desc"));
	$("#line-equipments-desc").text(Utils.translate("equipments_page.line.desc"));
	$("#rod-equipments-desc").text(Utils.translate("equipments_page.rod.desc"));
	$("#bait-equipments-desc").text(Utils.translate("equipments_page.bait.desc"));
	$("#other-equipments-desc").text(Utils.translate("equipments_page.other.desc"));

	// Store page
	$("#store-page-title").text(Utils.translate("store_page.title"));
	$("#store-page-desc").text(Utils.translate("store_page.desc"));

	// Owned vehicle page
	$("#owned-vehicle-page-desc").text(Utils.translate("owned_vehicles_page.desc"));

	// Owned property page
	$("#owned-property-page-title").text(Utils.translate("owned_properties_page.title"));
	$("#owned-property-page-desc").text(Utils.translate("owned_properties_page.desc"));

	$("#stock-modal-title").text(Utils.translate("stock_page.property_stock_title"));
	$("#stock-page-th-name-modal").text(Utils.translate("stock_page.inventory_table.header_name"));
	$("#stock-page-th-weight-modal").text(Utils.translate("stock_page.inventory_table.header_weight"));
	$("#stock-page-th-amount-modal").text(Utils.translate("stock_page.inventory_table.header_amount"));
	$("#stock-page-th-value-modal").text(Utils.translate("stock_page.inventory_table.header_value"));

	// Guide page
	$("#guide-page-title").text(Utils.translate("guide_page.title"));
	$("#guide-page-desc").text(Utils.translate("guide_page.desc"));

	// Bank page
	$("#bank-title-div").html(`
		<h4 class="text-uppercase">${Utils.translate("bank_page.title")}</h4>
		<p>${Utils.translate("bank_page.desc")}</p>
	`);
	$("#withdraw-money-btn").text(Utils.translate("bank_page.withdraw"));
	$("#deposit-money-btn").text(Utils.translate("bank_page.deposit"));
	$("#active-loans-title").text(`${Utils.translate("bank_page.active_loans")}`);
	$("#bank-balance-text").text(`${Utils.translate("bank_page.balance")}`);
	$("#bank-loans-title").text(`${Utils.translate("bank_page.loan_title")}`);
	$("#bank-loans-desc").html(`${Utils.translate("bank_page.loan_desc").format(Utils.currencyFormat(config.max_loan))}`);
	$("#bank-loans-btn").text(`${Utils.translate("bank_page.loan_button")}`);
	$("#loan-value-title").text(`${Utils.translate("bank_page.loan_value_title")}`);
	$("#loan-daily-title").text(`${Utils.translate("bank_page.loan_daily_title")}`);
	$("#loan-remaining-title").text(`${Utils.translate("bank_page.loan_remaining_title")}`);
	$("#loan-date-title").text(`${Utils.translate("bank_page.loan_date_title")}`);

	$("#loan-modal-title").text(`${Utils.translate("bank_page.loan_title")}`);
	$("#loan-modal-desc").text(`${Utils.translate("bank_page.loan_modal_desc")}`);

	let loan_list = ``;
	for (const loan_id in config.loans.plans) {
		const checkedAttribute = loan_id == 0 ? "checked" : "";
		const loan = config.loans.plans[loan_id];
		loan_list += `
			<div class="form-check mb-2">
				<input class="form-check-input" type="radio" name="loan-radio" id="loan-${loan_id}" value="${loan_id}" ${checkedAttribute}>
				<label class="form-check-label" for="loan-${loan_id}">
					<span style="font-weight: 600;">${Utils.currencyFormat(loan.loan_amount)}</span> ${Utils.translate("bank_page.loan_modal_item").format(Utils.numberFormat(loan.interest_rate), Utils.numberFormat(loan.repayment_days))}
				</label>
			</div>
		`;
	}
	$("#loan-list-container").html(loan_list);
	$("#loan-modal-cancel").text(`${Utils.translate("bank_page.modal_cancel")}`);
	$("#loan-modal-submit").text(`${Utils.translate("bank_page.loan_modal_submit")}`);

	$("#deposit-modal-title").text(`${Utils.translate("bank_page.deposit_modal_title")}`);
	$("#deposit-modal-desc").text(`${Utils.translate("bank_page.deposit_modal_desc")}`);
	$("#deposit-modal-money-amount").attr("placeholder", Utils.translate("bank_page.modal_placeholder"));
	$("#deposit-modal-cancel").text(`${Utils.translate("bank_page.modal_cancel")}`);
	$("#deposit-modal-submit").text(`${Utils.translate("bank_page.deposit_modal_submit")}`);

	$("#withdraw-modal-title").text(`${Utils.translate("bank_page.withdraw_modal_title")}`);
	$("#withdraw-modal-desc").text(`${Utils.translate("bank_page.withdraw_modal_desc")}`);
	$("#withdraw-modal-money-amount").attr("placeholder", Utils.translate("bank_page.modal_placeholder"));
	$("#withdraw-modal-cancel").text(`${Utils.translate("bank_page.modal_cancel")}`);
	$("#withdraw-modal-submit").text(`${Utils.translate("bank_page.withdraw_modal_submit")}`);

	$("#nav-bar").html(`
		<li id="sidebar-profile" onclick="openPage('profile')" class="active">
			<i class="fas fa-user-circle"></i>
			<span class="tooltip">${Utils.translate("sidebar.profile")}</span>
		</li>
		<li onclick="openPage('deliveries')">
			<i class="fas fa-fish"></i>
			<span class="tooltip">${Utils.translate("sidebar.deliveries")}</span>
		</li>
		<li onclick="openPage('upgrades','lake-upgrades')">
			<i class="fas fa-trophy"></i>
			<span class="tooltip">${Utils.translate("sidebar.upgrades")}</span>
		</li>
		<li onclick="openPage('equipments','rod-equipments')">
			<i class="fas fa-cog"></i>
			<span class="tooltip">${Utils.translate("sidebar.equipments")}</span>
		</li>
		<li onclick="openPage('guide','guide-all')">
			<i class="far fa-map"></i>
			<span class="tooltip">${Utils.translate("sidebar.guide")}</span>
		</li>
		<li onclick="closeUI()">
			<i class="fas fa-times"></i>
			<span class="tooltip">${Utils.translate("sidebar.close")}</span>
		</li>
	`);

	$("#player-info-level-label").text(Utils.translate("common.level_abbreviate"));
	$(".navigation-tabs-container").empty();
	$("#navigation-tab-store").append(getStoreTabHTML());
	$("#navigation-tab-guide").append(getGuideTabHTML());
	$("#navigation-tab-upgrades").append(getUpgradesTabHTML());
	$("#navigation-tab-equipments").append(getEquipmentsTabHTML());
	$("#navigation-tab-owned-vehicle").append(getOwnedVehicleTabHTML());

	if (config.disable_loans) {
		$("#loans-card-container").removeClass("d-flex");
		$("#loans-card-container").css("display", "none");
	}
}

function renderStatisticsPage(fishing_simulator_user, fishing_simulator_fishes_caught, top_users, next_tournament) {
	$("#profile-money-earned2").text(Utils.currencyFormat(fishing_simulator_user.total_money_earned, 2));
	$("#profile-money-spent2").text(Utils.currencyFormat(fishing_simulator_user.total_money_spent, 2));

	let totalMythic = 0;
	let totalLegendary = 0;
	let totalAllFish = 0;
	fishing_simulator_fishes_caught.forEach((fish) => {
		if (fish.fish_rarity === "mythic") {
			totalMythic += fish.amount;
		} else if (fish.fish_rarity === "legendary") {
			totalLegendary += fish.amount;
		}
		totalAllFish += fish.amount;
	});
	$("#profile-total-mythic-fish-2").text(totalMythic);
	$("#profile-total-legendary-fish-2").text(totalLegendary);
	$("#profile-total-all-fish-2").text(totalAllFish);
	$("#profile-total-dives-2").text(fishing_simulator_user.total_dives);
	$("#profile-total-xp-2").text(Utils.numberFormat(fishing_simulator_user.exp));
	let upgrades_sum = Object.keys(fishing_simulator_user)
		.filter((key) => key.includes("upgrade"))
		.reduce((sum, key) => sum + fishing_simulator_user[key], 0);
	$("#profile-total-upgrades-2").text(Utils.numberFormat(upgrades_sum));
	$("#profile-total-deliveries-2").text(fishing_simulator_user.total_deliveries);
	$("#profile-total-xp-bar").empty();
	let exp_r = 0;
	if (fishing_simulator_user.exp >= config.required_xp_to_levelup[config.required_xp_to_levelup.length - 1]) {
		exp_r = 100;
	} else if (config.player_level == 0) {
		let max = config.required_xp_to_levelup[config.player_level];
		let exp = fishing_simulator_user.exp;
		exp_r = Math.round((exp * 100) / max);
	} else {
		for (const key in config.required_xp_to_levelup) {
			if (fishing_simulator_user.exp < config.required_xp_to_levelup[key]) {
				let max = config.required_xp_to_levelup[key] - config.required_xp_to_levelup[key - 1];
				let exp = fishing_simulator_user.exp - config.required_xp_to_levelup[key - 1];
				exp_r = Math.round((exp * 100) / max);
				if (exp_r >= 0) {
					break;
				}
			}
		}
	}
	$("#profile-total-xp-bar").append(`<div class="progress-bar bg-amber accent-4" role="progressbar" style="width: ${exp_r}%" aria-valuenow="${exp_r}" aria-valuemin="0" aria-valuemax="100"></div>`);

	$("#top-users-list").empty();
	let c = 1;
	let icon;
	for (const top_user of top_users) {
		if (c == 1) {
			icon = "fa-medal amber accent-4 font-large-2";
		} else if (c == 2) {
			icon = "fa-medal blue-grey lighten-3 font-large-1";
		} else if (c == 3) {
			icon = "fa-medal bronze font-large-0";
		} else {
			icon = "fa-check-circle checkicon font-small-3";
		}
		$("#top-users-list").append(`
		<li class="d-flex justify-content-between card-theme">
			<div class="d-flex flex-row align-items-center"><i class="fas ${icon}"></i>
				<div class="ml-2">
					<h6 class="mb-0">${top_user.name} ${top_user.firstname ?? ""}</h6>
					<div class="d-flex flex-row mt-1 text-black-50 small">
						<div><i class="fas fa-chart-line"></i></i><span class="ml-2">${Utils.translate("statistics_page.top_users.exp").format(Utils.numberFormat(top_user.exp))}</span></div>
						<div class="ml-3"><i class="fas fa-fish"></i></i><span class="ml-2">${Utils.translate("statistics_page.top_users.fishes_caught").format(Utils.numberFormat(top_user.fishes_caught ?? 0))}</span></div>
					</div>
				</div>
			</div>
		</li>`);
		c++;
	}
	if (c == 1) {
		$("#top-users-title-div").css("display","none");
		$("#top-users-body-div").css("display","none");
	} else {
		$("#top-users-title-div").css("display","");
		$("#top-users-body-div").css("display","");
	}

	if (next_tournament) {
		$("#fishing-tournament-info").css("display","");
		let prize_text = getPrizeText(next_tournament.prizes[0]);
		if (next_tournament.joined) {
			$("#fishing-tournament-title").text(Utils.translate("tournaments.joined_tournament_alert.title"));
			$("#fishing-tournament-body").html(Utils.translate("tournaments.joined_tournament_alert.body").format(next_tournament.isToday ? Utils.translate("tournaments.today_text") : getWeekdayFromTimestamp(next_tournament.startTimeUnix), getTimeOfTheDayFromTimestamp(next_tournament.startTimeUnix)));
			$("#fishing-tournament-footer").html(Utils.translate("tournaments.joined_tournament_alert.footer").format(prize_text));
			$("#fishing-tournament-button").text(Utils.translate("tournaments.joined_tournament_alert.button"));
			$("#fishing-tournament-button").off("click").click(function() {
				Utils.post("seeTournamentLocation", {startTimeUnix: next_tournament.startTimeUnix});
			});
		} else {
			$("#fishing-tournament-title").text(Utils.translate("tournaments.join_tournament_alert.title"));
			$("#fishing-tournament-body").html(Utils.translate("tournaments.join_tournament_alert.body").format(next_tournament.isToday ? Utils.translate("tournaments.today_text") : getWeekdayFromTimestamp(next_tournament.startTimeUnix), getTimeOfTheDayFromTimestamp(next_tournament.startTimeUnix)));
			$("#fishing-tournament-footer").html(Utils.translate("tournaments.join_tournament_alert.footer").format(prize_text));
			$("#fishing-tournament-button").text(Utils.translate("tournaments.join_tournament_alert.button"));
			$("#fishing-tournament-button").off("click").click({next_tournament}, openJoinTournamentModal);
		}
	} else {
		$("#fishing-tournament-info").css("display","none");
	}
}

function getPrizeText(current_prizes) {
	let prize_text = "";

	if (current_prizes.money) {
		prize_text += `${Utils.currencyFormat(current_prizes.money, 0)}`;
	}

	if (current_prizes.item && current_prizes.item.label && current_prizes.item.display_name && current_prizes.item.amount) {
		if (prize_text) prize_text += " + ";
		prize_text += `${current_prizes.item.amount}x ${current_prizes.item.display_name}`;
	}

	if (current_prizes.exp) {
		if (prize_text) prize_text += " + ";
		prize_text += `${Utils.numberFormat(current_prizes.exp, 0)} ${Utils.translate("fishing_game.fish_details.exp")}`;
	}
	return prize_text;
}

function getWeekdayFromTimestamp(unixTimestamp) {
	const date = new Date(unixTimestamp * 1000); // Convert to milliseconds
	const days = Utils.translate("tournaments.week_days");
	return days[date.getDay()];
}

function getTimeOfTheDayFromTimestamp(unixTimestamp) {
	const date = new Date(unixTimestamp * 1000); // Convert to milliseconds
	let hours = date.getHours();
	let minutes = date.getMinutes();

	// Pad with zeros if necessary to ensure 2-digit formatting
	hours = hours.toString().padStart(2, "0");
	minutes = minutes.toString().padStart(2, "0");

	return `${hours}:${minutes}`;
}

function renderDeliveriesPage(fishing_simulator_available_contracts, fishing_simulator_user, total_fishes_table) {
	$("#list-available-contracts").empty();
	for (const contract of fishing_simulator_available_contracts) {
		let reward_html;
		let reward_icon;
		if (contract.money_reward) {
			reward_icon = "coins";
			reward_html = Utils.currencyFormat(contract.money_reward, 0);
		} else {
			const items = JSON.parse(contract.item_reward);
			reward_icon = "box";
			reward_html = `${items.amount}x ${items.display_name}`;
		}
		let start_button = `<button onclick="startContract(${contract.id})" type="button" class="btn btn-primary btn-block"><small>${Utils.translate("deliveries_page.start_button")}</small></button>`;
		if (fishing_simulator_user.user_id === contract.progress) {
			start_button = `<button onclick="cancelContract()" type="button" class="btn btn-outline-danger btn-block"><small>${Utils.translate("deliveries_page.cancel_button")}</small></button>`;
		}

		const required_items = JSON.parse(contract.required_items);

		const required_items_html = required_items
			.map((item) => {
				const userHasEnough = total_fishes_table[item.name] >= item.amount;
				const itemStyle = userHasEnough ? "" : "text-danger";
				const tooltip = userHasEnough ? "" : `data-tooltip-location="top" data-tooltip="${Utils.translate("deliveries_page.missing_item")}"`;
				return `<span class="${itemStyle}" ${tooltip}>${item.amount}x ${item.display_name}</span>`;
			})
			.join(", ");

		$("#list-available-contracts").append(`
			<div class="col-3 mb-3">
				<div class="card h-100">
					<div>
						<img src="${contract.image}" class="card-img-top w-100">
						<div class="mx-3 mt-2">
							<h6 style="font-size: 17px; font-weight: 600;">${contract.name}</h6>
						</div>
						<div class="mx-3">
							<h6>${contract.description}</h6>
						</div>
					</div>
					<div class="card-body px-0 pt-0">
						<div class="my-2 card-line"></div>
						<div class="mx-3 d-flex align-items-center">
							<i class="fa-solid fa-fish text-primary"></i>
							<div class="d-flex flex-column ml-2">
								<span class="small text-muted">${Utils.translate("deliveries_page.required_items")}</span>
								<span style="font-weight: 600;">${required_items_html}</span>
							</div>
						</div>
						<div class="my-2 card-line"></div>
						<div class="mx-3 d-flex align-items-center">
							<i class="fa-solid fa-${reward_icon} text-primary"></i>
							<div class="d-flex flex-column ml-2">
								<span class="small text-muted">${Utils.translate("deliveries_page.reward")}</span>
								<span style="font-weight: 600;">${reward_html}</span>
							</div>
						</div>
						<div class="my-2 card-line"></div>
						<div onclick="viewLocation(${contract.id})" class="view-location-container mx-3">
							<a class="text-primary" style="font-weight: 600;"><i class="fa-solid fa-map-pin mr-2"></i>${Utils.translate("deliveries_page.see_location")}</a>
						</div>
						<div class="my-2 card-line"></div>
						<div class="mx-4">
							${start_button}
						</div>
					</div>
				</div>
			</div>
		`);
	}
}

function renderDivesPage(fishing_simulator_available_dives, fishing_simulator_user) {
	$("#list-available-dives").empty();
	for (const dive of fishing_simulator_available_dives) {
		let reward_html;
		let reward_icon;
		if (dive.money_reward) {
			reward_icon = "coins";
			reward_html = Utils.currencyFormat(dive.money_reward, 0);
		} else {
			const items = JSON.parse(dive.item_reward);
			reward_icon = "box";
			reward_html = `${items.amount}x ${items.display_name}`;
		}
		let start_button = `<button onclick="startDive(${dive.id})" type="button" class="btn btn-primary btn-block"><small>${Utils.translate("dives_page.start_button")}</small></button>`;
		if (fishing_simulator_user.user_id === dive.progress) {
			start_button = `<button onclick="cancelDive()" type="button" class="btn btn-outline-danger btn-block"><small>${Utils.translate("dives_page.cancel_button")}</small></button>`;
		}

		$("#list-available-dives").append(`
			<div class="col-3 mb-3">
				<div class="card h-100">
					<div>
						<img src="${dive.image}" class="card-img-top w-100">
						<div class="mx-3 mt-2">
							<h6 style="font-size: 17px; font-weight: 600;">${dive.name}</h6>
						</div>
						<div class="mx-3">
							<h6>${dive.description}</h6>
						</div>
					</div>
					<div class="card-body px-0 pt-0">
						<div class="my-2 card-line"></div>
						<div class="mx-3 d-flex align-items-center">
							<i class="fa-solid fa-${reward_icon} text-primary"></i>
							<div class="d-flex flex-column ml-2">
								<span class="small text-muted">${Utils.translate("deliveries_page.reward")}</span>
								<span style="font-weight: 600;">${reward_html}</span>
							</div>
						</div>
						<div class="my-2 card-line"></div>
						<div class="mx-4">
							${start_button}
						</div>
					</div>
				</div>
			</div>
		`);
	}
}

function renderStorePage(available_items_store, fishing_simulator_properties, fishing_simulator_user) {
	const upgrade_level = {
		vehicle: fishing_simulator_user.vehicles_upgrade,
		boat: fishing_simulator_user.boats_upgrade,
		property: fishing_simulator_user.properties_upgrade,
	};

	$("#store-property-page-list").empty();
	$("#store-boat-page-list").empty();
	$("#store-vehicle-page-list").empty();
	for (const type in available_items_store) {
		const items = Utils.sortElement(available_items_store[type], ["level", "price"]);
		for (const item of items) {
			let button_html = `<button onclick="buyVehicle('${item.id}','${type}')" type="button" class="btn btn-primary btn-block"><small>${Utils.translate("store_page.buy_button")}</small></button>`;
			let dealership_locked_background = "";
			let property_html = "";
			let name_label = Utils.translate("store_page.vehicle.name");
			if (type === "property") {
				name_label = Utils.translate("store_page.property.name");
				button_html = `<button onclick="buyProperty('${item.id}','${type}')" type="button" class="btn btn-primary btn-block"><small>${Utils.translate("store_page.buy_button")}</small></button>`;
				if (fishing_simulator_properties.filter((p) => p.property == item.id).length > 0) {
					button_html = `<div class="d-flex align-items-center" style="min-height: 35px;"><i class="fa-solid fa-lock text-muted"></i><span class=" ml-2 small">${Utils.translate("store_page.property.owned")}</span></div>`;
					dealership_locked_background = "dealership-locked-background";
				}
				property_html = `
					<hr class="mt-2 mx-3">
						<div class="d-flex flex-row justify-content-between px-3">
							<div class="d-flex flex-column"><span class="small text-muted">${Utils.translate("store_page.property.capacity")}</span></div>
							<div class="d-flex flex-column">
								<h5 class="mb-0">${item.capacity}</h5>
							</div>
						</div>
						<hr class="mt-2 mx-3">
						<div class="d-flex flex-row justify-content-between m-auto">
							<div onclick="viewPropertyLocation('${item.id}')" class="view-location-container mx-3">
							<a class="text-primary" style="font-weight: 600;"><i class="fa-solid fa-map-pin mr-2"></i>${Utils.translate("deliveries_page.see_location")}</a>
						</div>
					</div>`;
			}
			if (upgrade_level[type] < item.level) {
				button_html = `<div class="d-flex align-items-center" style="min-height: 35px;"><i class="fa-solid fa-lock text-muted"></i><span class=" ml-2 small">${Utils.translate(`owned_vehicles_page.unlock_text.${type}`).format(item.level)}</span></div>`;
				dealership_locked_background = "dealership-locked-background";
			}
			$(`#store-${type}-page-list`).append(`
				<div class="card ${dealership_locked_background}">
					<img src="${item.image}" class="card-img-top" width="100%">
					<div class="card-body pt-0 px-0 pb-2 d-flex flex-column justify-content-between">
						<div>
							<div class="d-flex flex-row justify-content-between mt-3 px-3"> <span class="small text-muted">${name_label}</span>
								<h6 class="text-right">${item.name}</h6>
							</div>
							<hr class="mt-2 mx-3">
							<div class="d-flex flex-row justify-content-between px-3">
								<div class="d-flex flex-column"><span class="small text-muted">${Utils.translate("store_page.vehicle.price")}</span></div>
								<div class="d-flex flex-column">
									<h5 class="mb-0">${Utils.currencyFormat(item.price)}</h5>
								</div>
							</div>
							${property_html}
						</div>
						<div class="mx-3 mt-3 mb-2">
							${button_html}
						</div>
					</div>
				</div>
			`);
		}
	}
}

function renderGuidePage(fishes_available) {
	$("#guide-all-page-list").empty();
	$("#guide-sea-page-list").empty();
	$("#guide-lake-page-list").empty();
	$("#guide-river-page-list").empty();
	$("#guide-swamp-page-list").empty();

	const htmlContent = {
		all: "",
		sea: "",
		lake: "",
		river: "",
		swamp: "",
	};

	const fishes = Utils.sortElement(fishes_available, ["level", "name"]);
	for (const fish_config of fishes) {
		for (const area of fish_config.areas) {
			const fish_html = `
				<div data-name="${fish_config.name}" class="card py-2 guide-item-card">
					<h5 class="align-self-center">${Utils.translate("common.areas." + area)} ${fish_config.illegal ? `<small class="text-muted">[${Utils.translate("fishing_game.fish_details.illegal")}]</small>` : ""}</h5>
					<img src="${fish_config.image}" class="card-img-top align-self-center w-75">
					<div class="card-body pt-0 px-0 pb-2">
						<div>
							<div class="d-flex flex-row justify-content-between mt-3 px-3"> <span class="text-muted">${Utils.translate("common.level_abbreviate")} ${fish_config.level}</span>
								<h6>${fish_config.name}</h6>
							</div>
							<hr class="mt-2 mx-3">
							<div class="d-flex flex-row justify-content-between px-3">
								<div class="d-flex flex-column"><span class="text-muted">${Utils.translate("guide_page.fish_value")}</span></div>
								<div class="d-flex flex-column">
									<h5 class="mb-0">${Utils.currencyFormat(fish_config.sale_value)}</h5>
								</div>
							</div>
							<hr class="mt-2 mx-3">
							<div class="d-flex flex-row justify-content-between px-3">
								<div class="d-flex flex-column"><span class="text-muted">${Utils.translate("guide_page.fish_weight")}</span></div>
								<div class="d-flex flex-column">
									<h5 class="mb-0">${Utils.numberFormat(fish_config.weight)} ${Utils.translate("common.weight_unit")}</h5>
								</div>
							</div>
						</div>
					</div>
				</div>
			`;
			htmlContent[area] += fish_html;
			htmlContent.all += fish_html;
		}
	}
	for (const area in htmlContent) {
		$(`#guide-${area}-page-list`).append(htmlContent[area]);
	}

	$("#guide-page-filter-container").html(`
		<label class="label-input-filter-trademarket mb-0 mr-2 text-nowrap" for="input-filter-trademarket">${Utils.translate("guide_page.filter_label")}</label>
		<input id="input-filter-trademarket" type="text" name="name" class="form-control" placeholder="${Utils.translate("guide_page.filter_placeholder")}" oninput="filterGuidePage(this);">
	`);
}

function renderOwnedVehiclesPage(fishing_simulator_vehicles, available_items_store, max_garage_slots) {
	$("#owned-vehicle-page-title").html(`${Utils.translate("owned_vehicles_page.title")} <small>(${fishing_simulator_vehicles.length}/${max_garage_slots})</small>`);
	$("#owned-vehicle-page-list").empty();
	$("#owned-boat-page-list").empty();
	for (const vehicle_data of fishing_simulator_vehicles) {
		if (!available_items_store[vehicle_data.type]) continue;
		const vehicle = available_items_store[vehicle_data.type][vehicle_data.vehicle];
		if (vehicle) {
			let vehicle_health_str = "";
			let vehicle_fuel_str = "";
			let health_color = "success";
			let fuel_color = "amber";
			if (vehicle_data.health < 900) {
				const remaining_health = Math.floor((1000 - vehicle_data.health) / 10);
				const total_repair_price = vehicle.repair_price * remaining_health;
				vehicle_health_str = `<a class="dropdown-item text-black-50" onclick="repairVehicle('${vehicle_data.id}')">${Utils.translate("owned_vehicles_page.repair").format(Utils.currencyFormat(total_repair_price, 0))}</a>`;

				if (vehicle_data.health < 200) {
					health_color = "danger";
				}
			}
			if (vehicle_data.fuel < 90) {
				const remaining_fuel = Math.floor(100 - vehicle_data.fuel);
				const total_refuel_price = vehicle.refuel_price * remaining_fuel;
				vehicle_fuel_str = `<a class="dropdown-item text-black-50" onclick="refuelVehicle('${vehicle_data.id}')">${Utils.translate("owned_vehicles_page.refuel").format(Utils.currencyFormat(total_refuel_price, 0))}</a>`;

				if (vehicle_data.fuel < 20) {
					fuel_color = "danger";
				}
			}
			let css_shadow = "";
			if (vehicle_data.type == "boat") {
				css_shadow = " img-shadow";
			}
			$(`#owned-${vehicle_data.type}-page-list`).append(`
				<li class="d-flex card-theme justify-content-between">
					<div style="width: 300px;" class="d-flex flex-row align-items-center">
						<img src="${vehicle.image}" class="img-width${css_shadow}">
						<div class="ml-2">
							<h6 class="mb-0">${vehicle.name}</h6>
							<div class="d-flex flex-row mt-1 text-black-50 text-nowrap small">
								<div style="min-width: 110px;" ><i class="fas fa-tag"></i><span class="small ml-2">${Utils.translate("owned_vehicles_page.vehicle_plate")} ${JSON.parse(vehicle_data.properties).plate ?? Utils.translate("owned_vehicles_page.unregistered")}</span></div>
								<div class="ml-3"><i class="fas fa-route"></i><span class="small ml-2">${Utils.translate("owned_vehicles_page.distance").format(Utils.numberFormat(vehicle_data.traveled_distance / 1000, 2))}</span></div>
							</div>
						</div>
					</div>
					<div class="d-flex flex-row text-black-50 small">
						<div class="d-flex align-items-center">
							<img src="images/car-engine.png" width="35px">
							<div class="ml-1">
								<span>${Utils.translate("owned_vehicles_page.vehicle_condition")}</span>
								<div id="vehicle-health" class="progress mt-0 mb-0" style="height: 10px; width: 200px;"><div class="progress-bar bg-${health_color}" role="progressbar" style="width: ${vehicle_data.health / 10}%" aria-valuenow="0.0" aria-valuemin="0" aria-valuemax="100"></div></div>
							</div>
						</div>
						<div class="d-flex align-items-center ml-3">
							<img src="images/fuel.png" width="35px">
							<div class="ml-1">
								<span>${Utils.translate("owned_vehicles_page.vehicle_fuel")}</span>
								<div id="vehicle-health" class="progress mt-0 mb-0" style="height: 10px; width: 200px;"><div class="progress-bar bg-${fuel_color}" role="progressbar" style="width: ${vehicle_data.fuel}%" aria-valuenow="0.0" aria-valuemin="0" aria-valuemax="100"></div></div>
							</div>
						</div>
					</div>
					<div class="d-flex flex-row align-items-center mr-2">
						<div class="dropdown">
							<svg data-toggle="dropdown" class="dropdown-options-svg" xmlns="http://www.w3.org/2000/svg" version="1.1" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:svgjs="http://svgjs.com/svgjs" width="512" height="512" x="0" y="0" viewBox="0 0 515.555 515.555" style="enable-background:new 0 0 512 512" xml:space="preserve"><g><path xmlns="http://www.w3.org/2000/svg" d="m496.679 212.208c25.167 25.167 25.167 65.971 0 91.138s-65.971 25.167-91.138 0-25.167-65.971 0-91.138 65.971-25.167 91.138 0" data-original="#000000" style="" class=""></path><path xmlns="http://www.w3.org/2000/svg" d="m303.347 212.208c25.167 25.167 25.167 65.971 0 91.138s-65.971 25.167-91.138 0-25.167-65.971 0-91.138 65.971-25.167 91.138 0" data-original="#000000" style="" class=""></path><path xmlns="http://www.w3.org/2000/svg" d="m110.014 212.208c25.167 25.167 25.167 65.971 0 91.138s-65.971 25.167-91.138 0-25.167-65.971 0-91.138 65.971-25.167 91.138 0" data-original="#000000" style="" class=""></path></g></svg>
							<div class="dropdown-menu">
								${vehicle_health_str}
								${vehicle_fuel_str}
								<a class="dropdown-item text-black-50" onclick="spawnVehicle('${vehicle_data.id}')">${Utils.translate("owned_vehicles_page.spawn")}</a>
								<a class="dropdown-item" onclick="sellVehicle('${vehicle_data.id}')" style="color:#ff0000c2;">${Utils.translate("owned_vehicles_page.sell")}</a>
							</div>
						</div>
					</div>
				</li>
			`);
		}
	}
}

function renderOwnedPropertiesPage(fishing_simulator_properties, available_items_store, fishes_available) {
	$("#owned-property-page-list").empty();
	for (const property_data of fishing_simulator_properties) {
		const property_config = available_items_store.property[property_data.property];
		if (property_config) {
			let property_stock_str = "";
			let health_color = "success";
			if (property_data.property_condition < 90) {
				const remaining_health = 100 - property_data.property_condition;
				const total_repair_price = property_config.repair_price * remaining_health;
				property_stock_str = `<a class="dropdown-item text-black-50" onclick="repairProperty('${property_data.id}')">${Utils.translate("owned_properties_page.repair").format(Utils.currencyFormat(total_repair_price, 0))}</a>`;

				if (property_data.property_condition < 30) {
					health_color = "danger";
				}
			}
			const max_stock = property_config.capacity;
			const stock_capacity_percent = Utils.numberFormat((property_data.stock_weight * 100) / max_stock, 1);
			$("#owned-property-page-list").append(`
				<li class="d-flex card-theme justify-content-between">
					<div style="width: 600px;" class="d-flex flex-row align-items-center">
						<img src="${property_config.image}" class="img-shadow" style="max-width: 160px; border-radius: 15px;">
						<div class="ml-3">
							<h5 class="mb-0">${property_config.name}</h5>
							<div class="d-flex flex-row mt-1 text-black-50 text-nowrap small">
								<div style="min-width: 110px;" ><i class="fas fa-map-location-dot"></i><span class="small ml-2">${Utils.translate("owned_properties_page.address").format(property_config.address)}</span></div>
								<div class="ml-3"><i class="fas fa-weight-hanging"></i><span class="small ml-2">${Utils.translate("store_page.property.capacity")} ${Utils.numberFormat(property_config.capacity)} ${Utils.translate("common.weight_unit")}</span></div>
							</div>
						</div>
					</div>
					<div class="d-flex">
						<div class="d-flex justify-content-between flex-column text-black-50 small my-1 mr-5" style="gap: 7px;">
							<div class="d-flex align-items-center">
								<img src="images/stock.png" width="35px">
								<div class="ml-1">
									<span>${Utils.translate("owned_properties_page.stock_percentage")}</span>
									<div class="progress mt-0 mb-0" style="height: 10px; width: 200px;"><div class="progress-bar bg-warning" role="progressbar" style="width: ${stock_capacity_percent}%" aria-valuenow="0.0" aria-valuemin="0" aria-valuemax="100"></div></div>
								</div>
							</div>
							<div class="d-flex align-items-center">
								<img src="images/maintenance.png" width="35px">
								<div class="ml-1">
									<span>${Utils.translate("owned_properties_page.stock_condition")}</span>
									<div class="progress mt-0 mb-0" style="height: 10px; width: 200px;"><div class="progress-bar bg-${health_color}" role="progressbar" style="width: ${property_data.property_condition}%" aria-valuenow="0.0" aria-valuemin="0" aria-valuemax="100"></div></div>
								</div>
							</div>
						</div>
						<div class="d-flex flex-row align-items-center mr-2">
							<div class="dropdown">
								<svg data-toggle="dropdown" class="dropdown-options-svg" xmlns="http://www.w3.org/2000/svg" version="1.1" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:svgjs="http://svgjs.com/svgjs" width="512" height="512" x="0" y="0" viewBox="0 0 515.555 515.555" style="enable-background:new 0 0 512 512" xml:space="preserve"><g><path xmlns="http://www.w3.org/2000/svg" d="m496.679 212.208c25.167 25.167 25.167 65.971 0 91.138s-65.971 25.167-91.138 0-25.167-65.971 0-91.138 65.971-25.167 91.138 0" data-original="#000000" style="" class=""></path><path xmlns="http://www.w3.org/2000/svg" d="m303.347 212.208c25.167 25.167 25.167 65.971 0 91.138s-65.971 25.167-91.138 0-25.167-65.971 0-91.138 65.971-25.167 91.138 0" data-original="#000000" style="" class=""></path><path xmlns="http://www.w3.org/2000/svg" d="m110.014 212.208c25.167 25.167 25.167 65.971 0 91.138s-65.971 25.167-91.138 0-25.167-65.971 0-91.138 65.971-25.167 91.138 0" data-original="#000000" style="" class=""></path></g></svg>
								<div class="dropdown-menu">
									${property_stock_str}
									<a class="dropdown-item text-black-50" id="seePropertyButton-${property_data.property}">${Utils.translate("owned_properties_page.see")}</a>
									<a class="dropdown-item text-black-50" onclick="viewPropertyLocation('${property_data.property}')">${Utils.translate("owned_properties_page.set_waypoint")}</a>
									<a class="dropdown-item" onclick="sellProperty(${property_data.id})" style="color:#ff0000c2;">${Utils.translate("owned_properties_page.sell")}</a>
								</div>
							</div>
						</div>
					</div>
				</li>
			`);
			$(`#seePropertyButton-${property_data.property}`).bind("click", { property_data, fishes_available }, seePropertyStock);
		}
	}
}

function renderStockPage(property, properties, player_inventory, fishes_available) {
	// Stock property page UI
	let arr_stock = property.stock;
	const max_stock = properties.property[property.property].capacity;
	const stock_capacity_percent = Utils.numberFormat((property.stock_weight * 100) / max_stock, 1);

	$("#stock-page-title").text(Utils.translate("stock_page.title").format(property.name));
	$("#stock-values").text(`${Utils.numberFormat(property.stock_weight)}/${Utils.numberFormat(max_stock)} ${Utils.translate("common.weight_unit")}`);
	$("#stock-progress-bar").html(`<div class="progress-bar bg-primary" role="progressbar" style="width: ${stock_capacity_percent}%" aria-valuenow="${stock_capacity_percent}" aria-valuemin="0" aria-valuemax="100">${stock_capacity_percent}%</div>`);

	$("#stock-table-body").empty();
	if (arr_stock && Object.keys(arr_stock).length > 0) {
		arr_stock = Utils.sortElement(arr_stock, "id");
		for (const stock_item of arr_stock) {
			const item = fishes_available[stock_item.id];
			if (item) {
				$("#stock-table-body").append(`
					<tr data-toggle="modal" data-target="#withdraw-item-modal" data-item="${stock_item.id}" data-amount="${stock_item.value}" class="border-right border-left border-bottom">
						<td class="d-flex align-items-center text-left"><img src="${item.image}" class="mr-2" style="width: 40px;">${item.name}</td>
						<td class="align-middle">${Utils.numberFormat(item.weight)} ${Utils.translate("common.weight_unit")}</td>
						<td class="align-middle">${Utils.currencyFormat(item.sale_value)}</td>
						<td class="align-middle">${Utils.numberFormat(stock_item.value)}</td>
					</tr>
				`);
			} else {
				console.log(`Item '${stock_item.id}' from your stock does not exist in config, contact the server owner to remove that item from your database`);
			}
		}
	} else {
		$("#stock-table-body").append(`
			<tr class="border-right border-left border-bottom">
				<td colspan="4">${Utils.translate("stock_page.table_empty")}</td>
			</tr>
		`);
	}

	let has_readable_inventory_item = false;
	$("#stock-player-table-body").empty();
	player_inventory = Utils.sortElement(player_inventory, "name");
	for (const inventory_item of player_inventory) {
		if (inventory_item && fishes_available[inventory_item.name]) {
			const item = fishes_available[inventory_item.name];
			has_readable_inventory_item = true;
			$("#stock-player-table-body").append(`
				<tr data-toggle="modal" data-target="#deposit-item-modal" data-item="${inventory_item.name}" data-amount="${inventory_item.amount}" class="border-right border-left border-bottom">
					<td class="d-flex align-items-center text-left"><img src="${item.image}" class="mr-2" style="width: 40px;">${inventory_item.label}</td>
					<td class="align-middle">${item.weight} ${Utils.translate("common.weight_unit")}</td>
					<td class="align-middle">${inventory_item.amount}</td>
				</tr>
			`);
		}
	}
	if (!has_readable_inventory_item) {
		$("#stock-player-table-body").append(`
			<tr class="border-right border-left border-bottom">
				<td colspan="3">${Utils.translate("stock_page.table_empty")}</td>
			</tr>
		`);
	}

	$("#deposit-item-modal").attr("value", `${property.property}`);
	$("#withdraw-item-modal").attr("value", `${property.property}`);
}

function renderFishStorePage(fishes_available, store_data, items_in_inventory) {
	$("#fish-store-page-title").text(store_data.blips.name);


	$("#fish-store-page-container .tabs").empty();
	let { min_price, max_price } = appendFishStoreList(store_data, fishes_available, items_in_inventory);
	$("#filter-form").html(getFilterHTML(min_price, max_price));
}

function appendFishStoreList(store_data, fishes_available, items_in_inventory) {
	let min_price = Infinity;
	let max_price = -Infinity;
	const sorted_fishes = store_data.fishes_to_sell.sort();
	const htmlContent = {
		sea: "",
		lake: "",
		river: "",
		swamp: "",
		others: "",
	};

	for (const fish_id of sorted_fishes) {
		let fish_data = fishes_available[fish_id];
		if (!fish_data) continue;

		for (const area of fish_data.areas) {
			htmlContent[area] += getFishStoreCardItemHtml(fish_data, fish_id, area, items_in_inventory[fish_id] ?? 0);
		}

		const price = parseInt(fish_data.sale_value);
		min_price = Math.min(min_price, price);
		max_price = Math.max(max_price, price);
	}

	let sorted_items = Utils.sortElement(store_data.items_to_sell, ["name"]);
	for (const item_data of sorted_items) {
		htmlContent.others += getFishStoreCardItemHtml(item_data, item_data.id, "others", items_in_inventory[item_data.id] ?? 0);

		const price = parseInt(item_data.sale_value);
		min_price = Math.min(min_price, price);
		max_price = Math.max(max_price, price);
	}

	// Append all content at once per area.
	for (const area in htmlContent) {
		$(`.fish-store-${area}-tab`).append(htmlContent[area]);
	}

	if (min_price === max_price) {
		max_price++;
	}
	return { min_price, max_price };
}

function getFishStoreCardItemHtml(fish_data, fish_id, area, amount) {
	return `
		<div class="item-card col-6 mb-2" data-inventory="${amount}" data-price="${fish_data.sale_value}" data-name="${fish_data.name}">
			<div class="card overflow-hidden w-auto">
				<div class="card-content">
					<div class="card-body cleartfix pl-2">
						<div class="media align-items-stretch">
							<div class="align-self-center">
								<img class="font-large-2 mr-2 " src="${fish_data.image}" width="80">
							</div>
							<div class="media-body">
								<div>
									<h4 style="margin: 0;" ${amount == 0 ? `class="text-danger" data-tooltip-location="bottom" data-tooltip="${Utils.translate("deliveries_page.missing_item")}"` : ""}><small class="text-muted">${amount}x</small> ${fish_data.name}</h4>
								</div>
								<div class="fish-store-item-content my-1">
									<input class="form-control h-50" id="input-${fish_id}-${area}" type="number" min="1" placeholder="${Utils.translate("fish_store_page.amount")}" name="amount" required="required">
									<h4 class="m-0">${Utils.currencyFormat(fish_data.sale_value)}</h1>
								</div>
								<div>
									<button onclick="sellFish('${fish_id}','${area}')" class="btn btn-primary btn-block deposit-money-btn">${Utils.translate("fish_store_page.sell_button")}</button>
								</div>
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
	`;
}

function getFilterHTML(min_price, max_price) {
	return `
		<div id="filter-items" class="filters-container">
			<h2 style="border-bottom: 2px solid #00000033;font-weight: 600;">${Utils.translate("fish_store_page.filters.title")}</h2>
			<div style="margin: 20px 0px;">
				<h4 style="margin-bottom: 5px;font-weight: 600;">${Utils.translate("fish_store_page.filters.name")}</h4> 
				<input id="filter-name" class="form-control" type="text" placeholder="${Utils.translate("fish_store_page.filters.name_placeholder")}">
			</div>
			<label style="margin: 0px 0px 10px;" for="filter-inventory">
				<div>
					<h4 for="filter-inventory" style="margin-bottom: 5px;font-weight: 600;">${Utils.translate("fish_store_page.filters.only_owned")}</h4> 
					<input id="filter-inventory" class="filter-name-input" type="checkbox">
				</div>
			</label>
			<div>
				<h4 style="border-top: 2px solid #00000033;margin-top: 10px;padding-top: 15px;font-weight: 600;">${Utils.translate("fish_store_page.filters.price")}</h4> 
				<h4 style="margin: 17px 0px;">${Utils.translate("fish_store_page.filters.min")}</h4> 
				<div class="range-slider" style='--min:${min_price}; --max:${max_price}; --step:1; --value:${min_price}; --text-value:"${min_price}"; --prefix:"${Utils.getCurrencySymbol()} ";'>
					<input id="filter-min" type="range" min="${min_price}" max="${max_price}" step="1" value="${min_price}" oninput="this.parentNode.style.setProperty('--value',this.value); this.parentNode.style.setProperty('--text-value', JSON.stringify(this.value))">
					<output></output>
					<div class='range-slider__progress'></div>
				</div>
				<h4 style="margin: 17px 0px;margin-top: 0;">${Utils.translate("fish_store_page.filters.max")}</h4> 
				<div class="range-slider" style='--min:${min_price}; --max:${max_price}; --step:1; --value:${max_price}; --text-value:"${max_price}"; --prefix:"${Utils.getCurrencySymbol()} ";'>
					<input id="filter-max" type="range" min="${min_price}" max="${max_price}" step="1" value="${max_price}" oninput="this.parentNode.style.setProperty('--value',this.value); this.parentNode.style.setProperty('--text-value', JSON.stringify(this.value))">
					<output></output>
					<div class='range-slider__progress'></div>
				</div>
			</div>
		</div>
		<div id="button-filter-items" class="filters-container pt-2" style="align-self: end;">
			<button type="submit" class="btn btn-primary btn-block">${Utils.translate("fish_store_page.filters.filter_btn")}</button>
		</div>
	`;
}

function renderUpgradesPage(upgrades, fishing_simulator_user) {
	$(".upgrade-list").empty();
	for (const upgrade_type in upgrades) {
		let level = 1;
		for (const upgrade of upgrades[upgrade_type]) {
			const current_level = fishing_simulator_user[upgrade_type + "_upgrade"];
			$("#" + upgrade_type + "-upgrades-list").append(getUpgradeItemHTML(upgrade, upgrade_type, level, current_level));
			level++;
		}
	}
}

function renderEquipmentsPage(equipments, player_level) {
	$(".equipment-list").empty();
	for (const equipment_type in equipments) {
		const sorted_equipments = Utils.sortElement(equipments[equipment_type], ["required_level", "price", "name"]);
		for (const equipment of sorted_equipments) {
			$("#" + equipment_type + "-equipments-list").append(getEquipmentItemHTML(equipment, equipment_type, player_level));
		}
	}
}

function renderBankPage(fishing_simulator_user, available_money, fishing_simulator_loans) {
	$("#bank-money").text(Utils.currencyFormat(fishing_simulator_user.money, 2));

	$("#withdraw-modal-money-available").text(`${Utils.translate("bank_page.modal_money_available").format(Utils.currencyFormat(fishing_simulator_user.money, 2))}`);
	$("#deposit-modal-money-available").text(`${Utils.translate("bank_page.modal_money_available").format(Utils.currencyFormat(available_money, 2))}`);

	$("#loan-table-body").empty();
	$("#loan-table-container").css("display", "none");
	for (const loan of fishing_simulator_loans) {
		$("#loan-table-body").append(`
				<tr>
					<td>${Utils.currencyFormat(loan.loan)}</td>
					<td>${Utils.currencyFormat(loan.day_cost)}</td>
					<td class="text-danger">${Utils.currencyFormat(loan.remaining_amount)}</td>
					<td>${Utils.timeConverter(loan.timer + config.loans.payment_interval_hours * 3600)}</td>
					<td><button class="btn btn-outline-primary" style="min-width: 200px;" onclick="payLoan(${loan.id},${loan.remaining_amount})" >${Utils.translate("bank_page.loan_pay")}</button></td>
				</tr>
			`);
		$("#loan-table-container").css("display", "");
	}
}

/*=================
	FUNCTIONS
=================*/

function openPage(page, tab) {
	$(".pages").css("display", "none");
	$(`.${page}-page`).css("display", "block");
	if (tab) {
		$(".tabs").css("display", "none");
		$(`.${tab}-tab`).css("display", "");
		$("#fish-store-page-container").scrollTop(0);

		$(".navigation-tab").removeClass("selected");
		$(".navigation-tab-available").addClass("selected");
	}

	const titleHeight = $(`#${page}-title-div`).outerHeight(true) ?? 0;
	const footerHeight = $(`#${page}-footer-div`).outerHeight(true) ?? 0;
	$(":root").css(`--${page}-title-height`, titleHeight + footerHeight + "px");
}

function getStoreTabHTML() {
	return getTabHTML("store", "store-vehicle", Utils.translate("store_page.tabs.vehicle"), true)
		+ getTabHTML("store", "store-boat", Utils.translate("store_page.tabs.boat"))
		+ getTabHTML("store", "store-property", Utils.translate("store_page.tabs.property"));
}

function getGuideTabHTML() {
	return getTabHTML("guide", "guide-all", Utils.translate("common.areas.all"), true)
		+ getTabHTML("guide", "guide-sea", Utils.translate("common.areas.sea"))
		+ getTabHTML("guide", "guide-lake", Utils.translate("common.areas.lake"))
		+ getTabHTML("guide", "guide-river", Utils.translate("common.areas.river"))
		+ getTabHTML("guide", "guide-swamp", Utils.translate("common.areas.swamp"));
}

function getUpgradesTabHTML() {
	return getTabHTML("upgrades", "lake-upgrades", Utils.translate("upgrades_page.lake.title"), true)
		+ getTabHTML("upgrades", "river-upgrades", Utils.translate("upgrades_page.river.title"))
		+ getTabHTML("upgrades", "swamp-upgrades", Utils.translate("upgrades_page.swamp.title"))
		+ getTabHTML("upgrades", "sea-upgrades", Utils.translate("upgrades_page.sea.title"));
}

function getEquipmentsTabHTML() {
	return getTabHTML("equipments", "rod-equipments", Utils.translate("equipments_page.rod.title"), true)
		+ getTabHTML("equipments", "reel-equipments", Utils.translate("equipments_page.reel.title"))
		+ getTabHTML("equipments", "hook-equipments", Utils.translate("equipments_page.hook.title"))
		+ getTabHTML("equipments", "bait-equipments", Utils.translate("equipments_page.bait.title"))
		+ getTabHTML("equipments", "line-equipments", Utils.translate("equipments_page.line.title"))
		+ getTabHTML("equipments", "other-equipments", Utils.translate("equipments_page.other.title"));
}

function getFishStoreTabHTML() {
	return getTabHTML("fish-store", "fish-store-sea", Utils.translate("common.areas.sea"), true)
		+ getTabHTML("fish-store", "fish-store-swamp", Utils.translate("common.areas.swamp"))
		+ getTabHTML("fish-store", "fish-store-river", Utils.translate("common.areas.river"))
		+ getTabHTML("fish-store", "fish-store-lake", Utils.translate("common.areas.lake"))
		+ getTabHTML("fish-store", "fish-store-others", Utils.translate("fish_store_page.others_tab"));
}

function getOwnedVehicleTabHTML() {
	return getTabHTML("owned-vehicle", "owned-vehicle", Utils.translate("owned_vehicles_page.tabs.vehicle"), true)
		+ getTabHTML("owned-vehicle", "owned-boat", Utils.translate("owned_vehicles_page.tabs.boat"));
}

function getTabHTML(page, tab, tab_title, selected) {
	let selectedHTML = "";
	if (selected) {
		selectedHTML = "navigation-tab-available selected";
	}
	return `<div class="navigation-tab ${selectedHTML}" onclick="openPage('${page}','${tab}')">
		<h5>${tab_title}</h5>
		<div class="d-flex">
			<div class="border-default"></div>
			<div class="border-selected"></div>
			<div class="border-default"></div>
		</div>
	</div>`;
}

function getUpgradeItemHTML(upgrade, upgrade_type, level, current_level) {
	current_level++;
	let upgrade_button = `<button style="height:38px;" class="btn btn-primary btn-block" onclick="buyUpgrade('${upgrade_type}')">${upgrade.points_required} ${Utils.translate("common.skill_point")}</button>`;
	if (level > current_level) {
		upgrade_button = `<button style="height:38px;" class="btn btn-secondary btn-block"><i class="fa-solid fa-lock" disabled></i></button>`;
	} else if (level < current_level) {
		upgrade_button = `<button style="height:38px;" class="btn btn-outline-success btn-block"><i class="fa-solid fa-check"></i></button>`;
	}
	const upgrade_description = Utils.translate("upgrades_page." + upgrade_type + ".level").format(upgrade.level_reward);
	return `
		<li class="d-flex card-theme align-items-center">
			<img style="width: 8%;" src="${upgrade.icon}">
			<div style="width: 20%;" class="ml-2">
				<small class="text-black-50">${Utils.translate("upgrades_page." + upgrade_type + ".title")}</small>
				<h4 class="font-weight-semi-bold">${Utils.translate("common.level_abbreviate")}${level}</h4>
			</div>
			<div style="width: 55%;">
				<span class="text-success">${upgrade_description}</span>
			</div>
			<div style="width: 15%;">
				${upgrade_button}
			</div>
		</li>
	`;
}

function getEquipmentItemHTML(equipment, equipment_type, player_level) {
	let button_html = `<button onclick="buyEquipment('${equipment.id}','${equipment_type}')" type="button" class="btn btn-primary btn-block"><small>${Utils.translate("equipments_page.buy_button")}</small></button>`;
	if (equipment_type == "bait") {
		button_html = `
			<input type="number" style="border-top-right-radius: 0; border-bottom-right-radius: 0;" min="1" class="form-control" id="equipment-amount-${equipment.id}-${equipment_type}" placeholder="${Utils.translate("equipments_page.amount")}" name="amount" required>
			<button onclick="buyEquipment('${equipment.id}','${equipment_type}')" type="button" class="btn btn-primary btn-block"><small>${Utils.translate("equipments_page.buy_button")}</small></button>
		`;
	}
	let dealership_locked_background = "";
	if (equipment.required_level > player_level) {
		button_html = `<div class="d-flex align-items-center" style="min-height: 35px;"><i class="fa-solid fa-lock text-muted"></i><span class=" ml-2 small">${Utils.translate(`equipments_page.unlock_text`).format(equipment.required_level)}</span></div>`;
		dealership_locked_background = "dealership-locked-background";
	}
	let bonus_html = "";
	if (equipment.bonus != undefined) {
		bonus_html = `
			<hr class="mt-2 mx-3">
			<div class="d-flex flex-row justify-content-between px-3">
				<div class="d-flex flex-column"><span class="small text-muted">${Utils.translate("equipments_page.bonus")}</span></div>
				<div class="d-flex flex-column">
					<h5 class="mb-0">+${Utils.numberFormat(equipment.bonus)}%</h5>
				</div>
			</div>
		`;
	}
	return `
		<div class="card ${dealership_locked_background}">
			<img src="${equipment.icon}" class="card-img-top my-1" style="width: 60%; align-self: center;">
			<div class="card-body pt-0 px-0 pb-2 d-flex flex-column justify-content-between">
				<div>
					<div class="mt-3 px-3">
						<h6 class="text-right">${equipment.name}</h6>
					</div>
					${bonus_html}
					<hr class="mt-2 mx-3">
					<div class="d-flex flex-row justify-content-between px-3">
						<div class="d-flex flex-column"><span class="small text-muted">${Utils.translate("equipments_page.price")}</span></div>
						<div class="d-flex flex-column">
							<h5 class="mb-0">${Utils.currencyFormat(equipment.price)}</h5>
						</div>
					</div>
				</div>
				<div class="btn-group mx-3 mt-3 mb-2" style="width: -webkit-fill-available;">
					${button_html}
				</div>
			</div>
		</div>
	`;
}

function getTableTotalFishesUserHas(player_inventory, fishing_simulator_properties) {
	let total_fishes = {};
	for (const property of fishing_simulator_properties) {
		for (const stock_item in property.stock) {
			if (total_fishes[stock_item]) {
				total_fishes[stock_item] += property.stock[stock_item];
			} else {
				total_fishes[stock_item] = property.stock[stock_item];
			}
		}
	}
	for (const item of player_inventory) {
		if (total_fishes[item.name]) {
			total_fishes[item.name] += item.amount;
		} else {
			total_fishes[item.name] = item.amount;
		}
	}
	return total_fishes;
}

function openJoinTournamentModal(event) {
	const next_tournament = event.data.next_tournament;
	const joinTournamentModalConfig = {
		title: Utils.translate("tournaments.join_tournament_dialog.title"),
		bodyHtml: Utils.translate("tournaments.join_tournament_dialog.body").format(next_tournament.isToday ? Utils.translate("tournaments.today_text") : getWeekdayFromTimestamp(next_tournament.startTimeUnix), getTimeOfTheDayFromTimestamp(next_tournament.startTimeUnix), Utils.currencyFormat(next_tournament.entryFee,0), next_tournament.duration, getPrizeText(next_tournament.prizes[0]), getPrizeText(next_tournament.prizes[1]), getPrizeText(next_tournament.prizes[2])),
		buttons: [
			{ text: Utils.translate("confirmation_modal_cancel_button"), class: "btn btn-outline-primary", dismiss: true },
			{ text: Utils.translate("confirmation_modal_confirm_button"), class: "btn btn-primary", dismiss: true, action: () => Utils.post("joinTournament", {startTimeUnix: next_tournament.startTimeUnix}) },
		],
	};
	Utils.showCustomModal(joinTournamentModalConfig);
}

/*=================
	CALLBACKS
=================*/

function closeUI() {
	Utils.post("close", "");
}
function startContract(contract_id) {
	Utils.post("startContract", { contract_id: contract_id });
}
function cancelContract() {
	Utils.post("cancelContract", {});
}
function startDive(dive_id) {
	Utils.post("startDive", { dive_id: dive_id });
}
function cancelDive() {
	Utils.post("cancelDive", {});
}
function viewLocation(contract_id) {
	Utils.post("viewLocation", { contract_id: contract_id });
}
function viewPropertyLocation(property_id) {
	Utils.post("viewPropertyLocation", { property_id: property_id });
}
function repairProperty(property_id) {
	Utils.post("repairProperty", { property_id: property_id });
}
function sellProperty(property_id) {
	Utils.showDefaultDangerModal(() => Utils.post("sellProperty", { property_id }), Utils.translate("modals.confirmation.sell_propertty"));
}
function payLoan(loan_id, remaining_amount) {
	Utils.showDefaultDangerModal(() => Utils.post("payLoan", { loan_id }), Utils.translate("modals.confirmation.loan_payoff").format(Utils.currencyFormat(remaining_amount)));
}
function changeTheme(dark_theme) {
	Utils.post("changeTheme", { dark_theme });
}
function buyVehicle(vehicle_id, type) {
	Utils.post("buyVehicle", { vehicle_id, type });
}
function buyUpgrade(upgrade_type) {
	Utils.post("buyUpgrade", { upgrade_type });
}
function buyEquipment(equipment_id, equipment_type) {
	let amount_input = $(`#equipment-amount-${equipment_id}-${equipment_type}`);
	let amount = 1;
	if (amount_input.length > 0) {
		amount = amount_input.val();
		amount_input.val("");
	}
	Utils.post("buyEquipment", { equipment_id, equipment_type, amount });
}
function repairVehicle(vehicle_id) {
	Utils.post("repairVehicle", { vehicle_id });
}
function refuelVehicle(vehicle_id) {
	Utils.post("refuelVehicle", { vehicle_id });
}
function spawnVehicle(vehicle_id) {
	Utils.post("spawnVehicle", { vehicle_id });
}
function sellVehicle(vehicle_id) {
	Utils.showDefaultDangerModal(() => Utils.post("sellVehicle", { vehicle_id }), Utils.translate("modals.confirmation.sell_vehicle"));
}
function buyProperty(property_id, type) {
	Utils.post("buyProperty", { property_id, type });
}
function sellFish(fish_id, area) {
	let amount = $(`#input-${fish_id}-${area}`).val();
	$(`#input-${fish_id}-${area}`).val("");
	Utils.post("sellFish",{fish_id:fish_id,amount:amount,area:area});
}
function sellAllFishes() {
	Utils.showDefaultDangerModal(() => {
		Utils.post("sellAllFishes");
		setTimeout(() => {
			closeUI();
		}, 100);
	}, Utils.translate("modals.confirmation.sell_all_fishes"));
}
function endFishingGamePost(success, released) {
	Utils.post("endFishingGame", { success, released });
}
function closeFishingUi() {
	Utils.post("closeFishingUI");
}
function closeFishDetaisUi() {
	$("#fishing-fish-details-container").css("display", "none");
	closeFishingUi();
}
function keepFish() {
	endFishingGamePost(true, false);
	closeFishDetaisUi();
}
function releaseFish() {
	endFishingGamePost(true, true);
	closeFishDetaisUi();
}

function seePropertyStock(event) {
	// stock property page modal
	const property = event.data.property_data;
	const fishes_available = event.data.fishes_available;
	let arr_stock = property.stock;
	$("#stock-table-body-modal").empty();
	if (Object.keys(arr_stock).length > 0) {
		arr_stock = Utils.sortElement(arr_stock, "id");
		for (const stock_item of arr_stock) {
			const item = fishes_available[stock_item.id];
			if (item) {
				$("#stock-table-body-modal").append(`
					<tr class="border-right border-left border-bottom">
						<td class="d-flex align-items-center text-left"><img src="${item.image}" class="mr-2" style="width: 40px;">${item.name}</td>
						<td class="align-middle">${Utils.numberFormat(item.weight)} ${Utils.translate("common.weight_unit")}</td>
						<td class="align-middle">${Utils.numberFormat(stock_item.value)}</td>
						<td class="align-middle">${Utils.currencyFormat(item.sale_value)}</td>
					</tr>
				`);
			} else {
				console.log(`Item '${stock_item.id}' from your stock does not exist in config, contact the server owner to remove that item from your database`);
			}
		}
	} else {
		$("#stock-table-body-modal").append(`
			<tr class="border-right border-left border-bottom">
				<td colspan="4">${Utils.translate("stock_page.table_empty")}</td>
			</tr>
		`);
	}
	$("#stock-modal").modal();
}

function filterGuidePage(element) {
	let list = document.getElementsByClassName("guide-item-card");
	if (list && list.length > 0) {
		for (const cards of list) {
			cards.style.display = "";
			if (element.value != "" && (!cards.dataset.name.toLowerCase().includes(element.value.toLowerCase()))) {
				cards.style.display = "none";
			}
		}
	}
}

$(document).ready(function () {
	$(".css-toggle").on("change", function () {
		if ($(this).prop("checked") == false) {
			// Light theme
			$("#css-bs-light").prop("disabled", false);
			$("#css-light").prop("disabled", false);
			$("#css-bs-dark").prop("disabled", true);
			$("#css-dark").prop("disabled", true);
			$(".dark-theme-icon").css("display", "");
			$(".light-theme-icon").css("display", "none");
			changeTheme(0);
		} else if ($(this).prop("checked") == true) {
			// Dark theme
			$("#css-bs-dark").prop("disabled", false);
			$("#css-dark").prop("disabled", false);
			$("#css-bs-light").prop("disabled", true);
			$("#css-light").prop("disabled", true);
			$(".dark-theme-icon").css("display", "none");
			$(".light-theme-icon").css("display", "");
			changeTheme(1);
		}
	});

	$("#form-deposit-money").on("submit", function (e) {
		e.preventDefault();
		let form = $("#form-deposit-money").serializeArray();
		$("#deposit-modal-money-amount").val(null);
		$("#deposit-modal").modal("hide");
		Utils.post("depositMoney", { amount: form[0].value });
	});

	$("#form-withdraw-money").on("submit", function (e) {
		e.preventDefault();
		let form = $("#form-withdraw-money").serializeArray();
		$("#withdraw-modal-money-amount").val(null);
		$("#withdraw-modal").modal("hide");
		Utils.post("withdrawMoney", { amount: form[0].value });
	});

	$("#form-withdraw-item").on("submit", function (e) {
		e.preventDefault();
		let form = $("#form-withdraw-item").serializeArray();
		let item = $("#withdraw-modal-item-amount").data("item");
		let property = $("#withdraw-item-modal").attr("value");
		$("#withdraw-modal-item-amount").val(0);
		$("#add-button-withdraw").prop("disabled", false);
		$("#subtract-button-withdraw").prop("disabled", true);
		$("#withdraw-item-modal").modal("hide");
		Utils.post("withdrawItem", { amount: form[0].value, item, property });
	});

	$("#form-deposit-item").on("submit", function (e) {
		e.preventDefault();
		let form = $("#form-deposit-item").serializeArray();
		let item = $("#deposit-modal-item-amount").data("item");
		let property = $("#deposit-item-modal").attr("value");
		$("#deposit-modal-item-amount").val(0);
		$("#add-button-deposit").prop("disabled", false);
		$("#subtract-button-deposit").prop("disabled", true);
		$("#deposit-item-modal").modal("hide");
		Utils.post("depositItem", { amount: form[0].value, item, property });
	});

	$("#form-loan").on("submit", function (e) {
		e.preventDefault();
		let form = $("#form-loan").serializeArray();
		$("#loans-modal").modal("hide");
		Utils.post("loan", { loan_id: form[0].value });
	});

	$("#withdraw-item-modal").on("show.bs.modal", function (event) {
		let button = $(event.relatedTarget);
		let item = button.data("item");
		let amount = button.data("amount");
		let itemModal = config.fishes_available[item];
		$("#withdraw-item-modal-item-name").text(itemModal.name);
		$("#withdraw-item-modal-img").attr("src", itemModal.image);
		$("#withdraw-item-modal-item-available").text(`${Utils.translate("stock_page.withdraw_modal_item_available").format(amount)}`);
		$("#withdraw-modal-item-amount").val(0);
		$("#form-withdraw-item-input-container").css("display", "flex");
		$("#withdraw-modal-item-amount").data("max", amount);
		$("#withdraw-item-modal-title").text(`${Utils.translate("stock_page.withdraw_modal_title")}`);
		$("#withdraw-item-modal-img").css("width", "80px");
		$("#withdraw-modal-item-amount").attr("max", amount);
		$("#withdraw-modal-item-amount").attr("oninvalid", "Utils.onInvalidInput(this);");
		$("#add-button-withdraw").prop("disabled", false);
		$("#subtract-button-withdraw").prop("disabled", true);
		$("#withdraw-modal-item-amount").data("item", item);
	});

	$("#deposit-item-modal").on("show.bs.modal", function (event) {
		let button = $(event.relatedTarget);
		let item = button.data("item");
		let amount = button.data("amount");
		let itemModal = config.fishes_available[item];
		$("#deposit-item-modal-item-name").text(itemModal.name);
		$("#deposit-item-modal-img").attr("src", itemModal.image);
		$("#deposit-item-modal-item-available").text(`${Utils.translate("stock_page.deposit_modal_item_available").format(amount)}`);
		$("#deposit-modal-item-amount").val(0);
		$("#form-deposit-item-input-container").css("display", "flex");
		$("#deposit-modal-item-amount").data("max", amount);
		$("#deposit-item-modal-title").text(`${Utils.translate("stock_page.deposit_modal_title")}`);
		$("#deposit-item-modal-img").css("width", "80px");
		$("#add-button-deposit").prop("disabled", false);
		$("#subtract-button-deposit").prop("disabled", true);
		$("#deposit-modal-item-amount").data("item", item);
		$("#deposit-modal-item-amount").attr("max", amount);
		$("#deposit-modal-item-amount").attr("oninvalid", "Utils.onInvalidInput(this);");
	});

	$("#subtract-button-deposit").on("click", function () {
		$("#add-button-deposit").prop("disabled", false);
		let max_amount = $("#deposit-modal-item-amount").data("max");
		let amount = $("#deposit-modal-item-amount").val();
		if (--amount <= 0) {
			amount = 0;
			$(this).prop("disabled", true);
		}
		if (amount >= max_amount) {
			amount = max_amount;
			$("#add-button-deposit").prop("disabled", true);
		}
		$("#deposit-modal-item-amount").val(amount);
	});

	$("#add-button-deposit").on("click", function () {
		$("#subtract-button-deposit").prop("disabled", false);
		let max_amount = $("#deposit-modal-item-amount").data("max");
		let amount = $("#deposit-modal-item-amount").val();
		if (++amount >= max_amount) {
			amount = max_amount;
			$(this).prop("disabled", true);
		}
		if (amount <= 0) {
			amount = 0;
			$("#subtract-button-deposit").prop("disabled", true);
		}
		$("#deposit-modal-item-amount").val(amount);
	});

	$("#subtract-button-withdraw").on("click", function () {
		$("#add-button-withdraw").prop("disabled", false);
		let max_amount = $("#withdraw-modal-item-amount").data("max");
		let amount = $("#withdraw-modal-item-amount").val();
		if (--amount <= 0) {
			amount = 0;
			$(this).prop("disabled", true);
		}
		if (amount >= max_amount) {
			amount = max_amount;
			$("#add-button-withdraw").prop("disabled", true);
		}
		$("#withdraw-modal-item-amount").val(amount);
	});

	$("#add-button-withdraw").on("click", function () {
		$("#subtract-button-withdraw").prop("disabled", false);
		let max_amount = $("#withdraw-modal-item-amount").data("max");
		let amount = $("#withdraw-modal-item-amount").val();
		if (++amount >= max_amount) {
			amount = max_amount;
			$(this).prop("disabled", true);
		}
		if (amount <= 0) {
			amount = 0;
			$("#subtract-button-withdraw").prop("disabled", true);
		}
		$("#withdraw-modal-item-amount").val(amount);
	});

	$("#filter-form").on("submit", function (e) {
		e.preventDefault();

		let name = document.getElementById("filter-name").value;
		let min = document.getElementById("filter-min").value;
		let max = document.getElementById("filter-max").value;
		let inventory = document.getElementById("filter-inventory").checked;
		let list = document.getElementById("fish-store-page-container").getElementsByClassName("item-card");
		if (list && list.length > 0) {
			for (const cards of list) {
				cards.style.display = "";
				if (name != "" && !cards.dataset.name.toLowerCase().includes(name.toLowerCase())) {
					cards.style.display = "none";
				}
				if (parseInt(cards.dataset.price) < parseInt(min) || parseInt(cards.dataset.price) > parseInt(max)) {
					cards.style.display = "none";
				}
				if (inventory && cards.dataset.inventory == 0) {
					cards.style.display = "none";
				}
			}
		}
	});

	document.onkeyup = function (data) {
		if (data.which == 27) {
			if ($(".main-stock").is(":visible") || $(".main-fish-store").is(":visible") || $(".main").is(":visible")) {
				Utils.post("close", "");
			}
			if (typeof $(".modal").modal == "function") {
				$(".modal").modal("hide");
			}
		}
	};
});

// -----------------------------------------------------------------------------------------------------------------------------------------
// -- Fishing Area
// -----------------------------------------------------------------------------------------------------------------------------------------
let fishingGame = {
	playerFishing: null,
	selectedEquipments: null,
	config: {
		fishingDifficulties: null,
		equipmentsUpgrades: null,
	},

	values: {
		fishData: null,
		isFishing: false,
		canHook: false,
		tensionLevel: 0,
		reelingProgress: 20,
		fishTiredness: 0,
		timeBait: 0,
		timeHook: 0,

		tension: {
			baseValue: null,
			isMouseClicked: false,
		},
	},

	elements: {
		containers: {
			fishingContainer: null,
			fishingControlsContainer: null,
			fishingHookingContainer: null,
			fishingReelingContainer: null,
			fishingHookingBarContainer: null,
			fishingFishDetailsContainer: null,
		},
		progressBar: {
			fishingHookingBar: null,
			fishingReelingBar: null,
			fishingTensionBar: null,
		},
		fishingHookingText: null,
		fishingHookingImg: null,
	},

	bound: {
		attemptHook: null,
		mouseDown: null,
		mouseUp: null,
	},
	hookTimerInterval: null,
	reelingInterval: null,

	startFishing: function (fishing_difficulties, fishing_simulator_user, equipments_upgrades, selected_equipments, time_bait, time_hook) {
		this.resetVariables();

		this.elements.containers.fishingContainer = $("#fishing-ui-container");
		this.elements.containers.fishingControlsContainer = $("#fishing-controls-container");
		this.elements.containers.fishingHookingContainer = $("#fishing-hooking-container");
		this.elements.containers.fishingReelingContainer = $("#fishing-reeling-container");
		this.elements.containers.fishingHookingBarContainer = $("#fishing-hooking-bar-container");
		this.elements.containers.fishingFishDetailsContainer = $("#fishing-fish-details-container");
		this.elements.progressBar.fishingTensionBar = $("#fishing-tension-shrinker-bar");
		this.elements.progressBar.fishingHookingBar = $("#fishing-hooking-shrinker-bar");
		this.elements.progressBar.fishingReelingBar = $("#fishing-reeling-bar");
		this.elements.fishingHookingText = $("#fishing-hooking-text");
		this.elements.fishingHookingImg = $("#fishing-hooking-img");

		this.setFishingStaticTexts();
		this.elements.containers.fishingHookingBarContainer.css("display", "none");

		this.elements.progressBar.fishingTensionBar.css("height", "100%");
		this.elements.progressBar.fishingReelingBar.css("height", "0%");
		this.elements.progressBar.fishingHookingBar.css("width", "100%");

		this.bound.mouseDown = this.handleMouseDown.bind(this);
		this.bound.mouseUp = this.handleMouseUp.bind(this);
		this.bound.attemptHook = this.attemptHook.bind(this);

		this.config.equipmentsUpgrades = equipments_upgrades;
		this.config.fishingDifficulties = fishing_difficulties;
		this.playerFishing = fishing_simulator_user;
		this.selectedEquipments = selected_equipments;
		this.timeBait = time_bait;
		this.timeHook = time_hook;
		this.updateFishingCoords(this.playerFishing.x, this.playerFishing.y);

		this.values.tension.baseValue = this.getTensionBaseValue(this.config.fishingDifficulties.tension.base_value, this.config.fishingDifficulties.tension.randomness);

		this.values.isFishing = true;
		this.openStartFishingUI();
	},

	setFishingStaticTexts: function () {
		$("#fishing-controls-title").text(Utils.translate("fishing_game.instructions.title"));
		$("#fishing-controls-mouse-text").text(Utils.translate("fishing_game.instructions.hook_command"));
		$("#fishing-controls-mouse-esc").text(Utils.translate("fishing_game.instructions.exit_fishing"));
		$("#fishing-tension-1").text(Utils.translate("fishing_game.progress_bar_labels.tension.low"));
		$("#fishing-tension-2").text(Utils.translate("fishing_game.progress_bar_labels.tension.avg"));
		$("#fishing-tension-3").text(Utils.translate("fishing_game.progress_bar_labels.tension.max"));
		$("#fishing-progress-1").text(Utils.translate("fishing_game.progress_bar_labels.progress.low"));
		$("#fishing-progress-2").text(Utils.translate("fishing_game.progress_bar_labels.progress.avg"));
		$("#fishing-progress-3").text(Utils.translate("fishing_game.progress_bar_labels.progress.max"));

		$("#fishing-fish-weight-text").text(Utils.translate("fishing_game.fish_details.weight"));
		$("#fishing-fish-xp-text").text(Utils.translate("fishing_game.fish_details.exp"));
		$("#fishing-fish-price-text").text(Utils.translate("fishing_game.fish_details.price"));
		$("#fishing-fish-keep-button").text(Utils.translate("fishing_game.fish_details.keep"));
		$("#fishing-fish-release-button").text(Utils.translate("fishing_game.fish_details.release"));
		$("#fishing-fish-illegal-label").text(Utils.translate("fishing_game.fish_details.illegal"));
	},

	openStartFishingUI: function () {
		this.elements.containers.fishingControlsContainer.css("display", "");
		this.elements.containers.fishingContainer.css("display", "");
		this.elements.containers.fishingHookingContainer.css("display", "");

		this.startHookTimer();
	},

	startHookTimer: function () {
		this.elements.fishingHookingText.html(Utils.translate("fishing_game.get_ready"));
		this.elements.fishingHookingImg.attr("src", "./images/fishing/checkIcon.png");
		this.elements.progressBar.fishingHookingBar.css("width", "100%");

		$(document).one("mousedown", this.bound.attemptHook);

		let timeLeft = this.timeBait + this.timeHook;
		const startTime = Date.now();

		this.elements.containers.fishingHookingContainer.animate({ top: "+=10px" }, 500).animate({ top: "-=10px" }, 500);
		this.hookTimerInterval = setInterval(() => {
			let elapsedTime = (Date.now() - startTime) / 1000;
			timeLeft = this.timeBait + this.timeHook - elapsedTime;
			this.elements.containers.fishingHookingContainer.animate({ top: "+=10px" }, 500).animate({ top: "-=10px" }, 500);
			if (timeLeft <= this.timeHook) {
				if (timeLeft <= 0) {
					clearInterval(this.hookTimerInterval);
					this.endFishingGame(false);
					return;
				}

				this.values.canHook = true;
				this.elements.containers.fishingHookingBarContainer.css("display", "");
				this.elements.progressBar.fishingHookingBar.css("width", ((timeLeft / this.timeHook) * 100) + "%");
				this.elements.fishingHookingText.html(Utils.translate("fishing_game.hook_fish"));
				this.elements.fishingHookingImg.attr("src", "./images/fishing/mouseIcon.png");
			}
		}, 100);
	},

	attemptHook: function () {
		if (this.values.canHook) {
			this.hookFish();
		} else {
			this.endFishingGame(false);
		}
	},

	hookFish: function () {
		clearInterval(this.hookTimerInterval);
		this.values.canHook = false;

		this.elements.containers.fishingHookingContainer.css("display", "none");
		this.elements.containers.fishingHookingBarContainer.css("display", "none");

		Utils.post("generateFish", {}, "generateFish", (data) => {
			this.values.fishData = data.fish_data;
			this.startReeling();
		});
	},

	startReeling: function () {
		this.elements.containers.fishingReelingContainer.css("display", "");

		$(document).on("mousedown", this.bound.mouseDown);
		$(document).on("mouseup", this.bound.mouseUp);

		this.reelingInterval = setInterval(() => {
			if (this.values.reelingProgress >= 100) {
				this.endFishingGame(true);
				return;
			}
			if (this.values.tensionLevel >= 100 || this.values.reelingProgress <= 0) {
				this.endFishingGame(false);
				return;
			}
			if (this.values.tension.isMouseClicked) {
				this.values.fishTiredness += this.getFishTirednessIncreaseRate();

				const reelingIncreaseRate = this.getReelingIncreaseRate();
				this.values.reelingProgress = Math.min(this.values.reelingProgress + reelingIncreaseRate + this.values.fishTiredness, 100);

				const tensionIncreaseRate = this.getTensionIncreaseRate();
				this.values.tensionLevel = Math.min(this.values.tensionLevel + tensionIncreaseRate, 100);
			} else {
				const reelingDecreaseRate = this.getReelingDecreaseRate();
				this.values.reelingProgress = Math.max(this.values.reelingProgress - reelingDecreaseRate, 0);

				const tensionDecreaseRate = this.getTensionDecreaseRate();
				this.values.tensionLevel = Math.max(this.values.tensionLevel - tensionDecreaseRate, 0);
			}
			this.elements.containers.fishingReelingContainer.css("zoom", this.getZoomValue() + "%");
			this.elements.progressBar.fishingReelingBar.css("height", this.values.reelingProgress + "%");
			this.elements.progressBar.fishingTensionBar.css("height", (100 - this.values.tensionLevel) + "%");
		}, 100);
	},

	handleMouseDown: function () {
		this.values.tension.isMouseClicked = true;
	},

	handleMouseUp: function () {
		this.values.tension.isMouseClicked = false;
	},

	updateFishingCoords: function (x, y) {
		if (this.elements.containers.fishingContainer != null) {
			this.elements.containers.fishingContainer.css("left", (x * 100) + "%");
			this.elements.containers.fishingContainer.css("top", (y * 100) + "%");
		}
	},

	endFishingGame: function (success) {
		if (!this.values.isFishing) return;

		this.values.isFishing = false;
		this.elements.containers.fishingReelingContainer.css("zoom", "100%");
		this.elements.containers.fishingReelingContainer.css("display", "none");
		this.elements.containers.fishingHookingContainer.css("display", "none");
		this.elements.containers.fishingHookingBarContainer.css("display", "none");
		this.elements.containers.fishingControlsContainer.css("display", "none");
		this.elements.containers.fishingContainer.css("display", "none");

		if (success) {
			this.showFishDetails(this.values.fishData);
		} else {
			endFishingGamePost(success);
		}

		this.resetVariables();
	},

	showFishDetails: function (fishData) {
		Utils.post("focusFishingUI");
		function removeClasses($elements, classesToRemove) {
			classesToRemove.forEach((classToRemove) => {
				$elements.removeClass(`fish-rarity-color-${classToRemove}-image`);
				$elements.removeClass(`fish-rarity-color-${classToRemove}-containers`);
			});
		}

		// Assuming $(".fish-details-fish-img") and others return jQuery objects
		const classesToRemove = ["common", "uncommon", "rare", "legendary", "mythic"];

		removeClasses($(".fish-details-fish-img"), classesToRemove);
		removeClasses($(".fish-rarity-title-container"), classesToRemove);
		removeClasses($(".fish-details-items-container"), classesToRemove);

		$(".fish-details-fish-img").addClass(`fish-rarity-color-${fishData.rarity}-image`);
		$(".fish-rarity-title-container").addClass(`fish-rarity-color-${fishData.rarity}-containers`);
		$(".fish-details-items-container").addClass(`fish-rarity-color-${fishData.rarity}-containers`);
		$("#fishing-fish-name-text").text(fishData.name);
		$("#fishing-fish-image").attr("src", fishData.image);
		$("#fishing-fish-rarity-text").text(Utils.translate(`fishing_game.fish_details.rarity.${fishData.rarity}`));
		$("#fishing-fish-weight-value").text(`${Utils.numberFormat(fishData.weight)} ${Utils.translate("common.weight_unit")}`);
		$("#fishing-fish-xp-value").text(`+${Utils.numberFormat(fishData.exp)}`);
		$("#fishing-fish-price-value").text(Utils.currencyFormat(fishData.sale_value));

		if (fishData.illegal) {
			$("#fishing-fish-illegal-label").css("display", "");
		} else {
			$("#fishing-fish-illegal-label").css("display", "none");
		}
		this.elements.containers.fishingFishDetailsContainer.css("display", "");
	},

	resetVariables: function () {
		$(document).off("mousedown", this.bound.mouseDown);
		$(document).off("mouseup", this.bound.mouseUp);
		clearInterval(this.hookTimerInterval);
		clearInterval(this.reelingInterval);

		this.values = {
			fishData: null,
			isFishing: false,
			canHook: false,
			tensionLevel: 0,
			reelingProgress: 20,
			fishTiredness: 0,

			tension: {
				baseValue: null,
				isMouseClicked: false,
			},
		};

		this.elements = {
			containers: {
				fishingContainer: null,
				fishingControlsContainer: null,
				fishingHookingContainer: null,
				fishingReelingContainer: null,
				fishingHookingBarContainer: null,
				fishingFishDetailsContainer: null,
			},
			progressBar: {
				fishingHookingBar: null,
				fishingReelingBar: null,
				fishingTensionBar: null,
			},
			fishingHookingText: null,
			fishingHookingImg: null,
		};

		this.bound = {
			attemptHook: null,
			mouseDown: null,
			mouseUp: null,
		};

		this.hookTimerInterval = null;
		this.reelingInterval = null;
		this.playerFishing = null;
		this.selectedEquipments = null;
	},

	getTensionBaseValue: function (base, randomness) {
		if (randomness < 0 || randomness > 100) {
			return base;
		}

		const randomFactor = randomness / 100;
		const randomVariation = base * randomFactor * (Math.random() * 2 - 1);
		return base + randomVariation;
	},

	getTensionIncreaseRate: function () {
		const fishingLineFactor = Math.max(((100 - this.config.equipmentsUpgrades.line[this.selectedEquipments.line.item].bonus)) / 100, 0);
		const fishPenaltyFactor = this.config.fishingDifficulties.tension.fish_difficult[this.values.fishData.level - 1] / 100;
		const penaltyFactor = this.config.fishingDifficulties.tension.penalty / 100;
		const tensionLevel = this.values.tensionLevel / 100;

		const deviation = 8 * (tensionLevel - 0.5) ** 2;
		const adjustmentFactor = 1 + (deviation * penaltyFactor);

		return this.values.tension.baseValue * adjustmentFactor * (1 + fishPenaltyFactor) * fishingLineFactor;
	},

	getTensionDecreaseRate: function () {
		if (this.values.reelingProgress <= 20) {
			return this.config.fishingDifficulties.tension.decrease_rate / 2;
		}
		return this.config.fishingDifficulties.tension.decrease_rate;
	},

	getReelingIncreaseRate: function () {
		const fishingReelFactor = Math.max(((100 + this.config.equipmentsUpgrades.reel[this.selectedEquipments.reel.item].bonus)) / 100, 0);
		const penaltyFactor = this.config.fishingDifficulties.reeling.penalty / 100;
		const tensionLevel = this.values.tensionLevel / 100;

		const deviation = 1 - 8 * (tensionLevel - 0.5) ** 2;
		const adjustmentFactor = 1 + (deviation * penaltyFactor);

		return this.config.fishingDifficulties.reeling.base_value * adjustmentFactor * fishingReelFactor;
	},

	getReelingDecreaseRate: function () {
		return this.config.fishingDifficulties.reeling.decrease_rate;
	},

	getFishTirednessIncreaseRate: function () {
		if (this.values.fishTiredness >= 1.0) {
			return 0; // No increase if already fully tired
		}

		const baseRate = 0.002; // Base increase rate for level 5, 1 kg fish
		let fishWeight = this.values.fishData.weight;
		fishWeight = Math.max(fishWeight, 1.0); // Ensure weight is at least 1 kg

		// Using linear scaling for weight factor
		const a = 0.06; // Slope of the linear function
		const b = 0.6; // Intercept of the linear function
		const weightFactor = 1 / (a * fishWeight + b);

		// Level adjustment (example: making higher levels have less increase rate)
		const level = this.values.fishData.level;
		const levelAdjustment = 1 / (0.4 * level);

		// Calculate the tiredness increase rate
		return baseRate * weightFactor * levelAdjustment;
	},

	getZoomValue: function () {
		return 100 + (this.values.tensionLevel * 0.15);
	},
};

$(document).bind("keyup", function (data) {
	data.preventDefault();
	data.stopPropagation();
	if (data.key == "Escape") {
		fishingGame.endFishingGame(false);
	}
});
