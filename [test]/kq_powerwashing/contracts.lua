
-------------------------------------
--- CONTRACTS
-------------------------------------

-- To create your own contracts, simply copy one of the existing ones, modify the coordinates, reward, and labels
-- To easily retrieve the spot "corners" use the /selectarea command when in-game. (This is only available when the debug mode is enabled in config.lua)
-- The command will automatically copy the correct format and coordinates to your clipboard

Config.contracts = {
    {
        name = "Schoonmaakbedrijf",
        description = "Reinig de oprit en de garagewand",
        reward = 3250,
        minPlayers = 1,
        maxPlayers = 3,
        locations = {
            {
                name = "Huis",
                coords = vector3(-1079.99, 459.24, 77.49),
                radius = 100.0,
                spots = {
                    {
                        name = "Oprit",
                        areas = {
                            {
                                corners = {
                                    vec3(-1083.96, 462.99, 76.55),
                                    vec3(-1075.60, 457.43, 76.54),
                                    vec3(-1069.91, 466.03, 76.83),
                                    vec3(-1078.32, 471.57, 76.83),
                                },
                                edgeFadeout = 0.6,
                            },
                        },
                    },
                    {
                        name = "Muur",
                        areas = {
                            {
                                corners = {
                                    vec3(-1074.49, 459.03, 76.57),
                                    vec3(-1074.48, 459.04, 78.60),
                                    vec3(-1069.92, 465.95, 78.59),
                                    vec3(-1069.89, 465.99, 76.85),
                                },
                                edgeFadeout = 0.12,
                            },
                            {
                                corners = {
                                    vec3(-1071.33, 463.82, 78.44),
                                    vec3(-1071.31, 463.84, 79.97),
                                    vec3(-1069.9, 465.98, 79.96),
                                    vec3(-1069.9, 465.98, 78.44),
                                },
                                edgeFadeout = 0.15,
                            },
                        },
                    },
                }
            },
        }
    },
    {
        name = "Terras",
        description = "Maak het terras in de achtertuin schoon.",
        reward = 3500,
        minPlayers = 1,
        maxPlayers = 3,
        locations = {
            {
                name = "Terras",
                coords = vec3(-1306.53, 517.23, 96.67),
                spots = {
                    {
                        name = "Terras",
                        areas = {
                            {
                                corners = {
                                    vec3(-1306.53, 517.23, 96.67),
                                    vec3(-1299.83, 517.18, 96.67),
                                    vec3(-1299.78, 519.84, 96.67),
                                    vec3(-1306.44, 520.01, 96.67),
                                },
                                edgeFadeout = 0.05,
                            },
                            {
                                corners = {
                                    vec3(-1308.24, 507.02, 96.67),
                                    vec3(-1299.99, 506.93, 96.67),
                                    vec3(-1299.83, 517.38, 96.67),
                                    vec3(-1308.06, 517.27, 96.67),
                                },
                                edgeFadeout = 0.05,
                            },
                            {
                                corners = {
                                    vec3(-1302.53, 519.79, 96.67),
                                    vec3(-1299.77, 519.75, 96.67),
                                    vec3(-1299.75, 521.59, 96.67),
                                    vec3(-1302.47, 521.62, 96.67),
                                },
                                edgeFadeout = 0.05,
                            },
                        },
                    },
                }
            },
        }
    },
    {
        name = "Strand tattooshop",
        description = "Maak de zijkant van de tattooshop aan het strand schoon.",
        reward = 2000,
        minPlayers = 1,
        maxPlayers = 2,
        locations = {
            {
                name = "Tattooshop",
                coords = vector3(-1214.77, -1434.91, 6.38),
                radius = 100.0,
                spots = {
                    {
                        name = "Muur",
                        areas = {
                            {
                                corners = {
                                    vec3(-1214.77, -1434.91, 6.38),
                                    vec3(-1214.75, -1434.93, 3.67),
                                    vec3(-1223.55, -1422.37, 3.67),
                                    vec3(-1223.54, -1422.38, 6.38),
                                },
                                edgeFadeout = 0.12,
                                completionThreshold = 97,
                            },
                        },
                    },
                }
            },
        }
    },
    {
        name = "Koele bonen",
        description = "Schoon, koel, bonen, terras en achtergang",
        reward = 3500,
        minPlayers = 1,
        maxPlayers = 4,
        locations = {
            {
                name = "Koele bonen",
                coords = vector3(-1274.46, -887.98, 10.93),
                radius = 100.0,
                spots = {
                    {
                        name = "Terras",
                        areas = {
                            {
                                corners = {
                                    vec3(-1274.46, -887.98, 10.94),
                                    vec3(-1271.53, -885.84, 10.94),
                                    vec3(-1283.02, -870.23, 10.94),
                                    vec3(-1285.73, -873.12, 10.94),
                                },
                                edgeFadeout = 0.16,
                                dirtColor = {23, 31, 22},
                                cleaningMultiplier = 1.25,
                                completionThreshold = 90,
                            },
                            {
                                corners = {
                                    vec3(-1274.71, -882.05, 10.94),
                                    vec3(-1271.59, -885.9, 10.94),
                                    vec3(-1265.12, -881.1, 10.94),
                                    vec3(-1268.18, -876.54, 10.94),
                                },
                                edgeFadeout = 0.2,
                                dirtColor = {23, 31, 22},
                                cleaningMultiplier = 1.25,
                                completionThreshold = 90,
                            },
                        },
                    },
                    {
                        name = "Achterste gang",
                        areas = {
                            {
                                corners = {
                                    vec3(-1280.3, -862.19, 11.25),
                                    vec3(-1277.19, -866.36, 11.22),
                                    vec3(-1268.99, -860.09, 11.24),
                                    vec3(-1272.17, -855.99, 11.25),
                                },
                                edgeFadeout = 0.2,
                                dirtColor = {23, 31, 22},
                                cleaningMultiplier = 1.25,
                            },
                        },
                    },
                }
            },
        }
    },
    {
        name = "Oprit Grovestraat",
        description = "Maak de oprit schoon.",
        reward = 1500,
        minPlayers = 1,
        maxPlayers = 2,
        locations = {
            {
                name = "Huis",
                coords = vector3(-59.50, -1785.41, 26.98),
                radius = 50.0,
                spots = {
                    {
                        name = "Oprit",
                        areas = {
                            {
                                corners = {
                                    vec3(-59.50, -1785.41, 26.98),
                                    vec3(-55.06, -1789.4, 26.87),
                                    vec3(-51.14, -1785.25, 26.86),
                                    vec3(-55.64, -1780.99, 26.95),
                                },
                            },
                        },
                    },
                }
            },
        }
    },
    {
        name = "Basketbalveld",
        description = "Maak het basketbalveld schoon.",
        reward = 5750,
        minPlayers = 1,
        maxPlayers = 4,
        locations = {
            {
                name = "Basketbalveld",
                coords = vector3(-942.13, -743.37, 22.87),
                radius = 50.0,
                spots = {
                    {
                        name = "Veld",
                        areas = {
                            {
                                corners = {
                                    vec3(-939.91, -737.79, 18.95),
                                    vec3(-923.49, -737.88, 18.95),
                                    vec3(-923.54, -711.08, 18.95),
                                    vec3(-939.92, -711.07, 18.95),
                                },
                                dirtColor = {43, 46, 43},
                                cleaningMultiplier = 1.6,
                            },
                        },
                    },
                }
            },
        }
    },
    {
        name = "Fleeca Bank",
        description = "Maak de buitenkant van Fleeca Bank aan de westkust schoon.",
        reward = 5500,
        minPlayers = 1,
        maxPlayers = 4,
        locations = {
            {
                name = "Fleeca Bank",
                coords = vector3(-2966.64, 472.04, 17.65),
                radius = 50.0,
                spots = {
                    {
                        name = "Voormuren",
                        areas = {
                            {
                                corners = {
                                    vec3(-2966.54, 472.04, 15.4),
                                    vec3(-2966.54, 472.04, 17.65),
                                    vec3(-2966.18, 480.49, 17.68),
                                    vec3(-2966.17, 480.68, 15.37),
                                },
                                dirtColor = {14, 18, 13},
                                edgeFadeout = 0.1,
                            },
                            {
                                corners = {
                                    vec3(-2965.93, 485.48, 15.1),
                                    vec3(-2965.93, 485.38, 17.79),
                                    vec3(-2965.84, 487.44, 17.77),
                                    vec3(-2965.84, 487.43, 15.1),
                                },
                                dirtColor = {14, 18, 13},
                                edgeFadeout = 0.15,
                            },
                        },
                    },
                    {
                        name = "ATM muur",
                        areas = {
                            {
                                corners = {
                                    vec3(-2955.69, 487.05, 17.80),
                                    vec3(-2955.69, 487.05, 14.61),
                                    vec3(-2960.2, 487.24, 14.58),
                                    vec3(-2960.2, 487.24, 17.81),
                                },
                                dirtColor = {14, 18, 13},
                                edgeFadeout = 0.06,
                            },
                        },
                    },
                    {
                        name = "Achterdeurwand",
                        areas = {
                            {
                                corners = {
                                    vec3(-2948.27, 480.0, 17.76),
                                    vec3(-2948.27, 480.03, 14.54),
                                    vec3(-2947.99, 486.56, 14.49),
                                    vec3(-2947.99, 486.57, 17.78),
                                },
                                dirtColor = {14, 18, 13},
                                edgeFadeout = 0.06,
                            },
                        },
                    },
                }
            },
        }
    },
    {
        name = "Pacific basketbalveld",
        description = "Maak het basketbalveld bij de Pacific schoon.",
        reward = 7500,
        minPlayers = 1,
        maxPlayers = 4,
        locations = {
            {
                name = "Basketbalveld",
                coords = vector3(-2956.89, 30.72, 10.62),
                radius = 50.0,
                spots = {
                    {
                        name = "Veld",
                        areas = {
                            {
                                corners = {
                                    vec3(-2939.49, 22.58, 10.62),
                                    vec3(-2935.83, 30.65, 10.62),
                                    vec3(-2953.16, 38.71, 10.62),
                                    vec3(-2956.89, 30.72, 10.62),
                                },
                                edgeFadeout = 0.1,
                                cleaningMultiplier = 1.1,
                            },
                        },
                    },
                    {
                        name = "Muur",
                        areas = {
                            {
                                corners = {
                                    vec3(-2956.90, 31.21, 14.57),
                                    vec3(-2956.87, 31.26, 10.75),
                                    vec3(-2953.55, 38.39, 10.78),
                                    vec3(-2953.5, 38.49, 14.59),
                                },
                                edgeFadeout = 0.5,
                                cleaningMultiplier = 0.9,
                            },
                        },
                    },
                    {
                        name = "Hoepels",
                        areas = {
                            {
                                corners = {
                                    vec3(-2938.42, 27.68, 14.52),
                                    vec3(-2938.96, 26.52, 14.50),
                                    vec3(-2938.96, 26.53, 13.61),
                                    vec3(-2938.42, 27.71, 13.59),
                                },
                                edgeFadeout = 0.06,
                                flipped = true,
                                cleaningMultiplier = 0.75,
                            },
                            {
                                corners = {
                                    vec3(-2954.28, 33.67, 14.53),
                                    vec3(-2953.74, 34.85, 14.52),
                                    vec3(-2953.73, 34.85, 13.60),
                                    vec3(-2954.29, 33.67, 13.61),
                                },
                                edgeFadeout = 0.06,
                                flipped = true,
                                cleaningMultiplier = 0.75,
                            },
                        },
                    },
                }
            },
        }
    },
    {
        name = "Oprit",
        description = "Reinig meerdere opritten in de omgeving.",
        reward = 6250,
        minPlayers = 1,
        maxPlayers = 3,
        locations = {
            {
                name = "Vinewood",
                coords = vector3(-982.03, 583.32, 101.44),
                spots = {
                    {
                        name = "Oprit",
                        areas = {
                            {
                                corners = {
                                    vec3(-982.03, 583.31, 101.46),
                                    vec3(-980.71, 588.42, 100.99),
                                    vec3(-990.11, 590.10, 101.32),
                                    vec3(-991.02, 584.93, 101.46),
                                },
                                edgeFadeout = 0.25,
                                cleaningMultiplier = 1.1,
                            },
                        },
                    },
                }
            },
            {
                name = "Vinewood",
                coords = vector3(-1033.19, 588.27, 102.43),
                spots = {
                    {
                        name = "Oprit",
                        areas = {
                            {
                                corners = {
                                    vec3(-1033.19, 588.27, 102.43),
                                    vec3(-1033.26, 592.88, 102.04),
                                    vec3(-1040.50, 592.46, 102.08),
                                    vec3(-1040.35, 588.15, 102.44),
                                },
                                edgeFadeout = 0.25,
                                cleaningMultiplier = 1.1,
                            },
                        },
                    },
                }
            },
            {
                name = "Vinewood",
                coords = vector3(-598.50, 750.98, 182.74),
                spots = {
                    {
                        name = "Oprit",
                        areas = {
                            {
                                corners = {
                                    vec3(-598.50, 750.98, 182.74),
                                    vec3(-592.00, 748.94, 182.73),
                                    vec3(-589.42, 756.32, 182.76),
                                    vec3(-596.63, 758.12, 182.74),
                                },
                                edgeFadeout = 0.25,
                                cleaningMultiplier = 1.4,
                            },
                        },
                    },
                }
            },
        }
    },
    {
        name = "Villa oprit",
        description = "Een enorme oprit van een enorme villa schoonmaken",
        reward = 8000,
        minPlayers = 1,
        maxPlayers = 4,
        locations = {
            {
                name = "Villa",
                coords = vector3(-134.52, 1007.51, 234.77),
                spots = {
                    {
                        name = "Oprit",
                        areas = {
                            {
                                corners = {
                                    vec3(-134.52, 1007.51, 234.77),
                                    vec3(-126.08, 983.89, 234.75),
                                    vec3(-113.71, 988.61, 234.78),
                                    vec3(-122.24, 1011.95, 234.76),
                                },
                                edgeFadeout = 0.6,
                                cleaningMultiplier = 1.25,
                            },
                            {
                                corners = {
                                    vec3(-105.84, 1013.57, 234.79),
                                    vec3(-121.35, 1008.12, 234.79),
                                    vec3(-117.74, 997.43, 234.79),
                                    vec3(-102.06, 1003.20, 234.79),
                                },
                                edgeFadeout = 0.4,
                                cleaningMultiplier = 1.25,
                            },
                        },
                    },
                }
            },

        }
    },
    {
        name = "Liquor Winkel",
        description = "Zoek een manier om naar boven te klimmen en het uithangbord van de slijterij op het dak schoon te maken. ",
        reward = 3500,
        minPlayers = 1,
        maxPlayers = 2,
        locations = {
            {
                name = "Dak van de Liquor Jr.winkel",
                coords = vector3(583.32, 2671.70, 48.46),
                spots = {
                    {
                        name = "Reclamenbord",
                        areas = {
                            {
                                corners = {
                                    vec3(583.32, 2671.70, 48.46),
                                    vec3(578.89, 2671.13, 48.44),
                                    vec3(578.89, 2671.13, 46.11),
                                    vec3(583.33, 2671.7, 46.11),
                                },
                                edgeFadeout = 0.1,
                                cleaningMultiplier = 0.8,
                                opacityMultiplier = 1.4,
                                flipped = true,
                            },
                        },
                    },
                }
            },

        }
    },
    {
        name = "Sandy Reclamebord",
        description = "Maak reclamebord schoon bij Sandy Shores",
        reward = 3500,
        minPlayers = 1,
        maxPlayers = 2,
        locations = {
            {
                name = "Reclamebord",
                coords = vector3(447.81, 3452.69, 56.86),
                spots = {
                    {
                        name = "Reclamebord",
                        areas = {
                            {
                                corners = {
                                    vec3(447.81, 3452.69, 56.86),
                                    vec3(447.78, 3452.66, 51.13),
                                    vec3(438.71, 3440.90, 51.03),
                                    vec3(438.76, 3440.97, 56.74),
                                },
                                edgeFadeout = 0.2,
                                cleaningMultiplier = 1.8,
                                opacityMultiplier = 1.4,
                                completionThreshold = 90,
                            },
                        },
                    },
                }
            },

        }
    },
    {
        name = "Reclamebord stad",
        description = "Een reclamebord in de stad schoonmaken.",
        reward = 2000,
        minPlayers = 1,
        maxPlayers = 2,
        locations = {
            {
                name = "Reclamebord",
                coords = vector3(754.65, -1719.97, 44.24),
                spots = {
                    {
                        name = "Reclamebord",
                        areas = {
                            {
                                corners = {
                                    vec3(752.23, -1706.27, 44.30),
                                    vec3(754.65, -1719.97, 44.24),
                                    vec3(754.65, -1719.98, 38.26),
                                    vec3(752.23, -1706.23, 38.22),
                                },
                                edgeFadeout = 0.2,
                                flipped = true,
                                cleaningMultiplier = 1.5,
                                opacityMultiplier = 1.4,
                                completionThreshold = 90,
                            },
                        },
                    },
                }
            },

        }
    },
    {
        name = "Kip Reclamebord",
        description = "Was het kip reclamebord in de stad.",
        reward = 4000,
        minPlayers = 1,
        maxPlayers = 2,
        locations = {
            {
                name = "Reclamebord",
                coords = vector3(798.72, -802.24, 41.33),
                spots = {
                    {
                        name = "Reclamebord",
                        areas = {
                            {
                                corners = {
                                    vec3(798.72, -802.24, 41.33),
                                    vec3(784.69, -801.01, 41.76),
                                    vec3(784.74, -801.02, 36.96),
                                    vec3(798.80, -802.25, 36.97),
                                },
                                edgeFadeout = 0.2,
                                flipped = true,
                                cleaningMultiplier = 1.5,
                                opacityMultiplier = 1.4,
                                completionThreshold = 90,
                            },
                        },
                    },
                }
            },

        }
    },
    {
        name = "Schoonmaken taxi",
        description = "Maak het taxi gebouw schoon.",
        reward = 3750,
        minPlayers = 1,
        maxPlayers = 3,
        locations = {
            {
                name = "Taxi",
                coords = vector3(912.12, -152.39, 81.63),
                spots = {
                    {
                        name = "Muur",
                        areas = {
                            {
                                corners = {
                                    vec3(912.12, -152.39, 81.63),
                                    vec3(904.87, -147.85, 81.69),
                                    vec3(904.92, -147.89, 75.94),
                                    vec3(912.13, -152.40, 75.89),
                                },
                                edgeFadeout = 0.25,
                                flipped = true,
                                cleaningMultiplier = 1.15,
                                completionThreshold = 96,
                                opacityMultiplier = 1.4,
                            },
                        },
                    },
                    {
                        name = "Garage deur",
                        areas = {
                            {
                                corners = {
                                    vec3(901.64, -149.02, 78.89),
                                    vec3(897.74, -146.67, 78.87),
                                    vec3(897.80, -146.71, 75.84),
                                    vec3(901.67, -149.04, 75.68),
                                },
                                edgeFadeout = 0.2,
                                flipped = true,
                                dirtColor = {10, 15, 15},
                                completionThreshold = 95,
                                opacityMultiplier = 1.2,
                            },
                        },
                    },
                    {
                        name = "Muur",
                        areas = {
                            {
                                corners = {
                                    vec3(895.87, -177.11, 79.55),
                                    vec3(901.15, -168.54, 79.53),
                                    vec3(901.13, -168.57, 77.86),
                                    vec3(895.90, -177.06, 77.85),
                                },
                                edgeFadeout = 0.25,
                                dirtColor = {10, 15, 15},
                                cleaningMultiplier = 1.15,
                                opacityMultiplier = 1.2,
                                flipped = true,
                            },
                        },
                    },
                }
            },

        }
    },
    {
        name = "Schaduw aan het strand",
        description = "Maak schoon bij een restaurant aan het strand",
        reward = 3000,
        minPlayers = 1,
        maxPlayers = 2,
        locations = {
            {
                name = "Restaurant",
                coords = vector3(-1313.56, -1337.73, 8.36),
                spots = {
                    {
                        name = "Zonnescherm",
                        areas = {
                            {
                                corners = {
                                    vec3(-1313.56, -1337.73, 8.36),
                                    vec3(-1317.24, -1339.06, 6.79),
                                    vec3(-1309.10, -1361.41, 6.77),
                                    vec3(-1305.55, -1359.95, 8.35),
                                },
                                edgeFadeout = 0.2,
                                cleaningMultiplier = 1.1,
                                completionThreshold = 95,
                                opacityMultiplier = 1.2,
                            },
                        },
                    },
                }
            },

        }
    },
    {
        name = "Het afstoffen van de Nutbuster",
        description = "Maak het restaurant schoon",
        reward = 4250,
        minPlayers = 1,
        maxPlayers = 4,
        locations = {
            {
                name = "Restaurant",
                coords = vector3(-1265.52, -1219.15, 7.06),
                spots = {
                    {
                        name = "Voorwand",
                        areas = {
                            {
                                corners = {
                                    vec3(-1267.64, -1208.39, 7.07),
                                    vec3(-1264.00, -1218.48, 6.86),
                                    vec3(-1264.00, -1218.48, 4.15),
                                    vec3(-1267.63, -1208.39, 4.30),
                                },
                                edgeFadeout = 0.2,
                                flipped = true,
                                cleaningMultiplier = 1.1,
                            },
                            {
                                corners = {
                                    vec3(-1264.03, -1218.51, 6.86),
                                    vec3(-1263.99, -1218.54, 4.15),
                                    vec3(-1265.36, -1219.04, 4.13),
                                    vec3(-1265.32, -1219.02, 6.83),
                                },
                                edgeFadeout = 0.2,
                                cleaningMultiplier = 1.1,
                                completionThreshold = 90,
                            },
                            {
                                corners = {
                                    vec3(-1265.52, -1219.15, 7.06),
                                    vec3(-1264.54, -1221.42, 7.14),
                                    vec3(-1264.58, -1221.36, 4.00),
                                    vec3(-1265.52, -1219.14, 4.00),
                                },
                                edgeFadeout = 0.2,
                                flipped = true,
                                cleaningMultiplier = 1.1,
                                completionThreshold = 90,
                            },
                        },
                    },
                    {
                        name = "Terras",
                        areas = {
                            {
                                corners = {
                                    vec3(-1264.71, -1191.52, 4.46),
                                    vec3(-1274.44, -1196.21, 4.37),
                                    vec3(-1272.09, -1200.52, 4.38),
                                    vec3(-1263.12, -1196.02, 4.38),
                                },
                                edgeFadeout = 0.4,
                                opacityMultiplier = 0.9,
                                cleaningMultiplier = 1.4,
                                completionThreshold = 85,
                            },
                        },
                    },
                    {
                        name = "parkeerterrein",
                        areas = {
                            {
                                corners = {
                                    vec3(-1267.76, -1209.17, 4.13),
                                    vec3(-1273.29, -1212.61, 3.77),
                                    vec3(-1270.11, -1220.54, 3.66),
                                    vec3(-1265.25, -1218.26, 4.04),
                                },
                                edgeFadeout = 0.45,
                                cleaningMultiplier = 1.5,
                            },
                        },
                    },
                }
            },

        }
    },
    {
        name = "Kledingwinkel",
        description = "Maak het bord van de kledingwinkel schoon.",
        reward = 2000,
        minPlayers = 1,
        maxPlayers = 2,
        locations = {
            {
                name = "Binco",
                coords = vector3(-824.81, -1081.27, 18.30),
                spots = {
                    {
                        name = "Reclamebord (op het dak)",
                        areas = {
                            {
                                corners = {
                                    vec3(-824.81, -1081.27, 18.30),
                                    vec3(-821.78, -1079.79, 17.93),
                                    vec3(-821.92, -1079.87, 15.73),
                                    vec3(-825.10, -1081.36, 16.00),
                                },
                                edgeFadeout = 0.2,
                                flipped = true,
                                opacityMultiplier = 1.4,
                                cleaningMultiplier = 0.8,
                            },
                        },
                    },
                    {
                        name = "Reclamebord (boven de deur)",
                        areas = {
                            {
                                corners = {
                                    vec3(-816.78, -1078.66, 15.07),
                                    vec3(-815.01, -1077.64, 14.80),
                                    vec3(-815.16, -1077.73, 13.39),
                                    vec3(-817.02, -1078.80, 13.81),
                                },
                                edgeFadeout = 0.2,
                                flipped = true,
                                opacityMultiplier = 1.4,
                                cleaningMultiplier = 0.8,
                            },
                        },
                    },
                }
            },

        }
    },
    {
        name = "Wigwam ramen",
        description = "Maak alle ramen van het Wigwam restaurant schoon.",
        reward = 2500,
        minPlayers = 1,
        maxPlayers = 2,
        locations = {
            {
                name = "Wigwam",
                coords = vector3(-859.24, -1140.44, 8.89),
                spots = {
                    {
                        name = "Voorramen",
                        areas = {
                            {
                                corners = {
                                    vec3(-859.24, -1140.44, 8.89),
                                    vec3(-854.04, -1137.44, 8.91),
                                    vec3(-854.05, -1137.45, 6.49),
                                    vec3(-859.27, -1140.46, 6.54),
                                },
                                edgeFadeout = 0.2,
                                flipped = true,
                                opacityMultiplier = 1.2,
                            },
                        },
                    },
                    {
                        name = "Zijramen",
                        areas = {
                            {
                                corners = {
                                    vec3(-864.72, -1135.77, 8.86),
                                    vec3(-862.58, -1139.48, 8.83),
                                    vec3(-862.52, -1139.58, 6.54),
                                    vec3(-864.69, -1135.82, 6.61),
                                },
                                edgeFadeout = 0.2,
                                flipped = true,
                                opacityMultiplier = 1.2,
                            },
                        },
                    },
                    {
                        name = "Deuren",
                        areas = {
                            {
                                corners = {
                                    vec3(-862.26, -1139.75, 8.90),
                                    vec3(-859.55, -1140.48, 8.87),
                                    vec3(-859.53, -1140.48, 6.51),
                                    vec3(-862.28, -1139.75, 6.49),
                                },
                                edgeFadeout = 0.2,
                                flipped = true,
                                opacityMultiplier = 1.2,
                            },
                        },
                    },
                }
            },

        }
    },
    {
        name = "Zwembad pier",
        description = "Was alle tegels bij het zwembad",
        reward = 5250,
        minPlayers = 1,
        maxPlayers = 4,
        locations = {
            {
                name = "Zwembad",
                coords = vector3(-977.92, -1496.30, 4.59),
                spots = {
                    {
                        name = "Tegels",
                        areas = {
                            {
                                corners = {
                                    vec3(-988.88, -1506.00, 4.59),
                                    vec3(-986.72, -1508.41, 4.59),
                                    vec3(-976.61, -1500.36, 4.59),
                                    vec3(-979.05, -1497.26, 4.59),
                                },
                                edgeFadeout = 0.3,
                                dirtColor = {87, 85, 68},
                                cleaningMultiplier = 1.25,
                                completionThreshold = 90,

                            },
                            {
                                corners = {
                                    vec3(-979.54, -1497.78, 4.59),
                                    vec3(-977.78, -1496.62, 4.59),
                                    vec3(-984.82, -1486.16, 4.59),
                                    vec3(-986.60, -1487.88, 4.59),
                                },
                                edgeFadeout = 0.3,
                                dirtColor = {87, 85, 68},
                                cleaningMultiplier = 1.25,
                                completionThreshold = 90,
                            },
                            {
                                corners = {
                                    vec3(-985.29, -1486.38, 4.59),
                                    vec3(-987.51, -1482.80, 4.59),
                                    vec3(-998.78, -1490.23, 4.59),
                                    vec3(-996.96, -1493.30, 4.59),
                                },
                                edgeFadeout = 0.3,
                                dirtColor = {87, 85, 68},
                                cleaningMultiplier = 1.25,
                                completionThreshold = 90,
                            },
                            {
                                corners = {
                                    vec3(-1004.45, -1496.84, 4.59),
                                    vec3(-1007.23, -1498.16, 4.59),
                                    vec3(-997.03, -1513.35, 4.59),
                                    vec3(-994.40, -1511.15, 4.59),
                                },
                                edgeFadeout = 0.3,
                                dirtColor = {87, 85, 68},
                                cleaningMultiplier = 1.25,
                                completionThreshold = 90,
                            },
                        },
                    },
                }
            },

        }
    },
    {
        name = "Coconut Cafe schoonmaken",
        description = "Maak het terras van het wereldberoemde Coconut Cafe schoon",
        reward = 3250,
        minPlayers = 1,
        maxPlayers = 3,
        locations = {
            {
                name = "Coconut Cafe",
                coords = vec3(-1112.15, -1453.25, 4.15),
                spots = {
                    {
                        name = "Terras",
                        areas = {
                            {
                                corners = {
                                    vec3(-1112.15, -1453.25, 4.15),
                                    vec3(-1109.51, -1451.29, 4.12),
                                    vec3(-1114.57, -1444.20, 4.15),
                                    vec3(-1117.21, -1446.06, 4.12),
                                },
                                edgeFadeout = 0.25,
                                dirtColor = {29, 38, 31},
                            },
                            {
                                corners = {
                                    vec3(-1118.59, -1448.42, 4.12),
                                    vec3(-1116.62, -1447.01, 4.12),
                                    vec3(-1117.19, -1446.03, 4.23),
                                    vec3(-1119.29, -1447.35, 4.11),
                                },
                                edgeFadeout = 0.2,
                                dirtColor = {29, 38, 31},
                            },
                        },
                    },
                }
            },

        }
    },
    {
        name = "Visbord",
        description = "Maak het bord op het dak van het La Spada restaurant schoon",
        reward = 2250,
        minPlayers = 1,
        maxPlayers = 2,
        locations = {
            {
                name = "La Spada restaurant",
                coords = vector3(-1040.12, -1396.64, 12.46),
                spots = {
                    {
                        name = "Reclamebord",
                        areas = {
                            {
                                corners = {
                                    vec3(-1040.15, -1396.64, 12.46),
                                    vec3(-1042.15, -1404.21, 12.49),
                                    vec3(-1042.15, -1404.13, 9.15),
                                    vec3(-1040.15, -1396.67, 9.15),
                                },
                                flipped = true,
                                edgeFadeout = 0.35,
                            },
                        },
                    },
                }
            },

        }
    },
    {
        name = "Drankproblemen",
        description = "Maak het vieze reclamebord van de Sandy Shores bar schoon",
        reward = 4000,
        minPlayers = 1,
        maxPlayers = 2,
        locations = {
            {
                name = "Bar",
                coords = vector3(1968.13, 3856.27, 36.43),
                spots = {
                    {
                        name = "Reclamebord",
                        areas = {
                            {
                                corners = {
                                    vec3(1968.13, 3856.27, 36.43),
                                    vec3(1972.71, 3859.13, 36.42),
                                    vec3(1972.68, 3859.11, 34.75),
                                    vec3(1968.13, 3856.27, 34.71),
                                },
                                flipped = true,
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.3,
                                cleaningMultiplier = 0.9,
                                completionThreshold = 97,
                            },
                        },
                    },
                }
            },

        }
    },
    {
        name = "advertentieproblemen",
        description = "Maak het reclamebord van de 24/7 supermarkt in Sandy Shores schoon",
        reward = 4500,
        minPlayers = 1,
        maxPlayers = 2,
        locations = {
            {
                name = "24/7 Reclamebord",
                coords = vector3(941.64, 3544.19, 38.26),
                spots = {
                    {
                        name = "24/7 Reclamebord",
                        areas = {
                            {
                                corners = {
                                    vec3(941.64, 3544.19, 38.26),
                                    vec3(951.00, 3544.31, 38.24),
                                    vec3(950.99, 3544.31, 34.87),
                                    vec3(941.74, 3544.19, 34.88),
                                },
                                flipped = true,
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.3,
                                cleaningMultiplier = 0.9,
                                completionThreshold = 97,
                            },
                        },
                    },
                }
            },

        }
    },
    {
        name = "Dierenwinkel",
        description = "Schoonmaakklus voor Animal Ark in Harmony, maak hun reclameborden en de voorkant van hun winkel schoon",
        reward = 6250,
        minPlayers = 1,
        maxPlayers = 3,
        locations = {
            {
                name = "Animal Ark Reclamebord",
                coords = vector3(1951.50, 2989.27, 50.51),
                spots = {
                    {
                        name = "Reclamebord",
                        areas = {
                            {
                                corners = {
                                    vec3(1951.52, 2989.27, 50.51),
                                    vec3(1951.04, 2996.04, 50.33),
                                    vec3(1951.04, 2996.00, 47.78),
                                    vec3(1951.51, 2989.21, 47.96),
                                },
                                flipped = true,
                                edgeFadeout = 0.25,
                                opacityMultiplier = 1.3,
                            },
                        },
                    },
                }
            },
            {
                name = "Animal Ark Winkel",
                coords = vector3(560.92, 2741.13, 41.81),
                spots = {
                    {
                        name = "Deurhelling",
                        areas = {
                            {
                                corners = {
                                    vec3(560.92, 2741.13, 41.87),
                                    vec3(561.12, 2737.79, 41.27),
                                    vec3(564.01, 2738.00, 41.27),
                                    vec3(563.77, 2741.33, 41.86),
                                },
                                edgeFadeout = 0.25,
                                dirtColor = {92, 94, 75},
                            },
                        },
                    },
                    {
                        name = "Advertisement reclamebord",
                        areas = {
                            {
                                corners = {
                                    vec3(600.15, 2722.99, 45.02),
                                    vec3(600.33, 2719.73, 44.96),
                                    vec3(600.33, 2719.70, 42.97),
                                    vec3(600.15, 2723.01, 42.94),
                                },
                                edgeFadeout = 0.25,
                                flipped = true,
                                opacityMultiplier = 1.6,
                                dirtColor = {92, 94, 75},
                            },
                        },
                    },
                }
            },

        }
    },
    {
        name = "Chiliad Mysterie",
        description = "Voer kleine schoonmaakklussen uit op de top van Mount Chiliad.",
        reward = 10000,
        minPlayers = 1,
        maxPlayers = 3,
        locations = {
            {
                name = "Mount Chiliad",
                coords = vector3(457.51, 5574.00, 783.45),
                spots = {
                    {
                        name = "Binnendeur",
                        areas = {
                            {
                                corners = {
                                    vec3(457.51, 5574.00, 783.45),
                                    vec3(457.51, 5569.69, 783.44),
                                    vec3(457.51, 5569.74, 780.28),
                                    vec3(457.51, 5574.07, 780.24),
                                },
                                flipped = true,
                                edgeFadeout = 0.25,
                                dirtColor = {23, 20, 19},
                                opacityMultiplier = 1.25,
                            },
                        },
                    },
                    {
                        name = "Muurschildering",
                        areas = {
                            {
                                corners = {
                                    vec3(456.76, 5568.91, 783.58),
                                    vec3(456.76, 5564.29, 783.54),
                                    vec3(456.75, 5564.31, 780.31),
                                    vec3(456.75, 5568.82, 780.27),
                                },
                                flipped = true,
                                edgeFadeout = 0.15,
                                dirtColor = {23, 20, 19},
                                opacityMultiplier = 1.25,
                            },
                        },
                    },
                    {
                        name = "Observatie Reclamebord",
                        areas = {
                            {
                                corners = {
                                    vec3(502.47, 5602.29, 798.15),
                                    vec3(502.57, 5603.31, 797.91),
                                    vec3(500.71, 5603.49, 797.91),
                                    vec3(500.61, 5602.44, 798.15),
                                },
                                edgeFadeout = 0.1,
                            },
                        },
                    },
                    {
                        name = "Rode vlek",
                        areas = {
                            {
                                corners = {
                                    vec3(452.33, 5577.00, 780.19),
                                    vec3(453.15, 5576.60, 780.19),
                                    vec3(453.90, 5576.87, 780.19),
                                    vec3(452.86, 5577.68, 780.19),
                                },
                                edgeFadeout = 0.4,
                                dirtColor = {31, 5, 3},
                                opacityMultiplier = 1.5,
                            },
                        },
                    },
                }
            },

        }
    },
    {
        name = "Bayview uitje",
        description = "Help Bayview Lodges hun reclameborden schoonmaken, evenals andere vuile plekken rondom de lodges",
        reward = 9000,
        minPlayers = 1,
        maxPlayers = 4,
        locations = {
            {
                name = "Bayview Lodges Vakantiepark",
                coords = vector3(-694.99, 5796.21, 19.75),
                spots = {
                    {
                        name = "Reclamebord A",
                        areas = {
                            {
                                corners = {
                                    vec3(-694.99, 5796.21, 19.75),
                                    vec3(-696.79, 5792.34, 19.74),
                                    vec3(-696.80, 5792.31, 18.84),
                                    vec3(-694.97, 5796.24, 18.83),
                                },
                                flipped = true,
                                edgeFadeout = 0.15,
                                dirtColor = {23, 20, 19},
                                opacityMultiplier = 1.4,
                            },
                        },
                    },
                    {
                        name = "Reclamebord B",
                        areas = {
                            {
                                corners = {
                                    vec3(-701.18, 5804.73, 22.05),
                                    vec3(-697.27, 5802.90, 22.04),
                                    vec3(-697.29, 5802.92, 21.13),
                                    vec3(-701.16, 5804.72, 21.10),
                                },
                                flipped = true,
                                edgeFadeout = 0.15,
                                dirtColor = {23, 20, 19},
                                opacityMultiplier = 1.4,
                            },
                        },
                    },
                    {
                        name = "Reclamebord C",
                        areas = {
                            {
                                corners = {
                                    vec3(-676.85, 5837.60, 22.48),
                                    vec3(-673.87, 5834.62, 22.49),
                                    vec3(-673.90, 5834.65, 21.56),
                                    vec3(-676.85, 5837.59, 21.56),
                                },
                                flipped = true,
                                edgeFadeout = 0.15,
                                dirtColor = {23, 20, 19},
                                opacityMultiplier = 1.4,
                            },
                        },
                    },
                }
            },
            {
                name = "Vakantiehuisjes",
                coords = vec3(-694.81, 5768.65, 16.33),
                spots = {
                    {
                        name = "Vakantiehuisjes terras A",
                        areas = {
                            {
                                corners = {
                                    vec3(-698.40, 5765.49, 16.52),
                                    vec3(-702.08, 5767.31, 16.52),
                                    vec3(-703.07, 5765.22, 16.52),
                                    vec3(-699.37, 5763.60, 16.52),
                                },
                                edgeFadeout = 0.25,
                                dirtColor = {23, 20, 19},
                                opacityMultiplier = 1.4,
                            },
                        },
                    },
                    {
                        name = "Vakantiehuisjes terras B",
                        areas = {
                            {
                                corners = {
                                    vec3(-686.07, 5766.56, 16.52),
                                    vec3(-687.82, 5762.98, 16.52),
                                    vec3(-685.77, 5761.94, 16.52),
                                    vec3(-684.09, 5765.62, 16.52),
                                },
                                edgeFadeout = 0.25,
                                dirtColor = {23, 20, 19},
                                opacityMultiplier = 1.4,
                            },
                        },
                    },
                    {
                        name = "Gemorste verf",
                        areas = {
                            {
                                corners = {
                                    vec3(-687.59, 5760.97, 16.52),
                                    vec3(-688.76, 5760.96, 16.52),
                                    vec3(-688.91, 5759.70, 16.52),
                                    vec3(-687.61, 5759.57, 16.52),
                                },
                                edgeFadeout = 0.45,
                                dirtColor = {77, 73, 18},
                                opacityMultiplier = 1.5,
                                cleaningMultiplier = 0.6,
                            },
                        },
                    },
                }
            },

        }
    },
    {
        name = "Tegels noord",
        description = "Maak tegels schoon voor een huiseigenaar helemaal in Paleto Bay",
        reward = 9000,
        minPlayers = 1,
        maxPlayers = 4,
        locations = {
            {
                name = "Huis in Paleto Bay",
                coords = vec3(-435.98, 6263.64, 29.11),
                spots = {
                    {
                        name = "Bovenste verdieping terras",
                        areas = {
                            {
                                corners = {
                                    vec3(-454.72, 6263.01, 32.35),
                                    vec3(-450.71, 6261.66, 32.35),
                                    vec3(-445.66, 6276.32, 32.35),
                                    vec3(-449.73, 6277.61, 32.35),
                                },
                                edgeFadeout = 0.2,
                                dirtColor = {28, 33, 27},
                                opacityMultiplier = 1.2,
                                cleaningMultiplier = 1.25,
                            },
                        },
                    },
                    {
                        name = "Benedenverdieping terras",
                        areas = {
                            {
                                corners = {
                                    vec3(-453.28, 6268.01, 29.06),
                                    vec3(-454.98, 6263.06, 29.06),
                                    vec3(-449.88, 6261.20, 29.06),
                                    vec3(-448.12, 6266.16, 29.09),
                                },
                                edgeFadeout = 0.15,
                                dirtColor = {28, 33, 27},
                                opacityMultiplier = 1.2,
                                cleaningMultiplier = 1.1,
                            },
                            {
                                corners = {
                                    vec3(-450.61, 6275.72, 29.06),
                                    vec3(-453.39, 6267.63, 29.06),
                                    vec3(-451.64, 6267.09, 29.06),
                                    vec3(-448.95, 6275.10, 29.06),
                                },
                                edgeFadeout = 0.2,
                                dirtColor = {28, 33, 27},
                                opacityMultiplier = 1.2,
                                cleaningMultiplier = 1.1,
                            },
                            {
                                corners = {
                                    vec3(-439.52, 6257.55, 29.07),
                                    vec3(-452.99, 6262.54, 29.07),
                                    vec3(-453.71, 6260.52, 29.07),
                                    vec3(-440.12, 6255.87, 29.07),
                                },
                                edgeFadeout = 0.15,
                                dirtColor = {28, 33, 27},
                                opacityMultiplier = 1.2,
                                cleaningMultiplier = 1.1,
                            },
                        },
                    },
                }
            },

        }
    },
    {
        name = "Vergeten zwembad",
        description = "Maak het zwembad van een hotel in Paleto Bay schoon. Ze willen het weer in gebruik nemen",
        reward = 8000,
        minPlayers = 1,
        maxPlayers = 3,
        locations = {
            {
                name = "Zwembad",
                coords = vec3(-183.71, 6424.70, 29.72),
                spots = {
                    {
                        name = "Zwembad",
                        areas = {
                            {
                                corners = {
                                    vec3(-183.65, 6424.96, 29.71),
                                    vec3(-176.47, 6417.56, 29.47),
                                    vec3(-170.33, 6423.61, 29.47),
                                    vec3(-177.63, 6430.88, 29.70),
                                },
                                edgeFadeout = 0.4,
                                dirtColor = {28, 33, 27},
                                opacityMultiplier = 1.1,
                                cleaningMultiplier = 1.2,
                            },
                            {
                                corners = {
                                    vec3(-169.10, 6422.40, 29.43),
                                    vec3(-171.07, 6424.04, 29.49),
                                    vec3(-172.44, 6422.48, 29.48),
                                    vec3(-170.47, 6420.90, 29.43),
                                },
                                edgeFadeout = 0.35,
                                dirtColor = {28, 33, 27},
                                opacityMultiplier = 1.1,
                                cleaningMultiplier = 1.3,
                            },
                            {
                                corners = {
                                    vec3(-173.67, 6417.81, 29.43),
                                    vec3(-175.28, 6419.71, 29.48),
                                    vec3(-176.81, 6418.00, 29.48),
                                    vec3(-175.28, 6416.36, 29.43),
                                },
                                edgeFadeout = 0.35,
                                dirtColor = {28, 33, 27},
                                opacityMultiplier = 1.1,
                                cleaningMultiplier = 1.3,
                            },
                        },
                    },
                    {
                        name = "Bubbelbad",
                        areas = {
                            {
                                corners = {
                                    vec3(-170.74, 6419.03, 29.97),
                                    vec3(-171.85, 6419.80, 29.97),
                                    vec3(-172.69, 6418.69, 29.97),
                                    vec3(-171.83, 6417.84, 29.97),
                                },
                                edgeFadeout = 0.4,
                                dirtColor = {28, 33, 27},
                                opacityMultiplier = 1.1,
                            },
                        },
                    },
                }
            },

        }
    },
    {
        name = "Paleto terras",
        description = "Maak een voorterras schoon voor een gezin in Paleto Bay.",
        reward = 7500,
        minPlayers = 1,
        maxPlayers = 3,
        locations = {
            {
                name = "Huis in Paleto Bay",
                coords = vec3(32.46, 6654.73, 30.72),
                spots = {
                    {
                        name = "Voorterras",
                        areas = {
                            {
                                corners = {
                                    vec3(40.35, 6665.69, 30.73),
                                    vec3(36.92, 6653.91, 30.71),
                                    vec3(41.63, 6652.05, 30.71),
                                    vec3(45.78, 6663.95, 30.73),
                                },
                                edgeFadeout = 0.25,
                                dirtColor = {28, 33, 27},
                            },
                            {
                                corners = {
                                    vec3(33.64, 6661.12, 30.74),
                                    vec3(32.46, 6654.73, 30.72),
                                    vec3(37.18, 6653.73, 30.71),
                                    vec3(39.24, 6659.58, 30.71),
                                },
                                edgeFadeout = 0.25,
                                dirtColor = {28, 33, 27},
                            },
                            {
                                corners = {
                                    vec3(33.29, 6658.16, 30.73),
                                    vec3(29.53, 6658.34, 30.74),
                                    vec3(29.51, 6654.89, 30.71),
                                    vec3(32.71, 6654.77, 30.71),
                                },
                                edgeFadeout = 0.25,
                                dirtColor = {28, 33, 27},
                            },
                        },
                    },
                }
            },

        }
    },
    {
        name = "Overheidsverspilling",
        description = "Maak de top van de brandweertoren van Paleto Bay schoon",
        reward = 6500,
        minPlayers = 1,
        maxPlayers = 2,
        locations = {
            {
                name = "Brandweertoren Paleto Bay",
                coords = vec3(-380.95, 6084.34, 43.27),
                spots = {
                    {
                        name = "Toren dak",
                        areas = {
                            {
                                corners = {
                                    vec3(-380.95, 6084.34, 43.27),
                                    vec3(-376.81, 6086.69, 43.33),
                                    vec3(-378.85, 6090.36, 43.27),
                                    vec3(-383.03, 6087.99, 43.27),
                                },
                                edgeFadeout = 0.25,
                            },
                        },
                    },
                }
            },

        }
    },
    {
        name = "Lange opritten",
        description = "Maak twee lange opritten schoon voor bewoners van Paleto Bay",
        reward = 10500,
        minPlayers = 1,
        maxPlayers = 3,
        locations = {
            {
                name = "Huis in Paleto Bay",
                coords = vec3(-342.24, 6212.74, 30.51),
                spots = {
                    {
                        name = "Oprit",
                        areas = {
                            {
                                corners = {
                                    vec3(-361.07, 6225.53, 30.51),
                                    vec3(-345.23, 6209.88, 30.51),
                                    vec3(-342.24, 6212.74, 30.51),
                                    vec3(-357.96, 6228.86, 30.51),
                                },
                                edgeFadeout = 0.3,
                                cleaningMultiplier = 1.25,
                            },
                        },
                    },
                }
            },
            {
                name = "Nog een huis in Paleto Bay",
                coords = vec3(-216.93, 6433.25, 30.22),
                spots = {
                    {
                        name = "Oprit",
                        areas = {
                            {
                                corners = {
                                    vec3(-238.27, 6444.23, 30.22),
                                    vec3(-221.15, 6428.16, 30.24),
                                    vec3(-216.93, 6433.25, 30.22),
                                    vec3(-234.08, 6448.85, 30.22),
                                },
                                edgeFadeout = 0.3,
                                cleaningMultiplier = 1.25,
                            },
                        },
                    },
                }
            },

        }
    },
    {
        name = "Bishops parkeerplaats",
        description = "Maak de parkeerplaats van het Bishops Chicken restaurant schoon",
        reward = 5500,
        minPlayers = 1,
        maxPlayers = 4,
        locations = {
            {
                name = "Bishops Chicken",
                coords = vec3(2591.30, 452.39, 107.47),
                spots = {
                    {
                        name = "Vak 1",
                        areas = {
                            {
                                corners = {
                                    vec3(2591.30, 452.39, 107.47),
                                    vec3(2581.58, 452.33, 107.47),
                                    vec3(2581.29, 441.52, 107.47),
                                    vec3(2591.47, 441.54, 107.50),
                                },
                                edgeFadeout = 0.4,
                                cleaningMultiplier = 1.2,
                            },
                            {
                                corners = {
                                    vec3(2581.00, 452.31, 107.46),
                                    vec3(2579.47, 449.72, 107.47),
                                    vec3(2581.84, 446.74, 107.47),
                                    vec3(2583.54, 450.88, 107.47),
                                },
                                edgeFadeout = 0.6,
                                cleaningMultiplier = 1.4,
                                completionThreshold = 85,
                            },
                        },
                    },
                    {
                        name = "Vak 2",
                        areas = {
                            {
                                corners = {
                                    vec3(2585.31, 435.73, 107.47),
                                    vec3(2585.32, 442.34, 107.47),
                                    vec3(2573.73, 442.40, 107.47),
                                    vec3(2573.68, 435.64, 107.47),
                                },
                                edgeFadeout = 0.4,
                                cleaningMultiplier = 1.2,
                            },
                            {
                                corners = {
                                    vec3(2576.93, 444.79, 107.47),
                                    vec3(2579.93, 447.18, 107.47),
                                    vec3(2578.12, 449.21, 107.47),
                                    vec3(2575.63, 446.91, 107.47),
                                },
                                edgeFadeout = 0.6,
                                cleaningMultiplier = 1.3,
                                completionThreshold = 85,
                            },
                        },
                    },
                }
            },
        }
    },
    {
        name = "Spectaculair reclamebord",
        description = "Maak een reclamebord langs de snelweg schoon. Val er bij voorkeur niet vanaf",
        reward = 5000,
        minPlayers = 1,
        maxPlayers = 2,
        locations = {
            {
                name = "Reclamebord",
                coords = vec3(2550.13, 90.47, 114.17),
                spots = {
                    {
                        name = "Reclamebord",
                        areas = {
                            {
                                corners = {
                                    vec3(2550.13, 90.47, 113.7),
                                    vec3(2564.16, 87.29, 113.5),
                                    vec3(2564.33, 87.25, 108.48),
                                    vec3(2550.27, 90.44, 108.55),
                                },
                                edgeFadeout = 0.35,
                                flipped = true,
                                cleaningMultiplier = 1.8,
                                opacityMultiplier = 1.4,
                                completionThreshold = 92,
                            },
                        },
                    },
                }
            },
        }
    },
    {
        name = "Skatepark schoonmaak",
        description = "Maak een vergeten skatepark onder de snelweg schoon.",
        reward = 2000,
        minPlayers = 1,
        maxPlayers = 2,
        locations = {
            {
                name = "Skatepark",
                coords = vec3(710.80, -1203.53, 25.72),
                spots = {
                    {
                        name = "Vuile plekken",
                        areas = {
                            {
                                corners = {
                                    vec3(710.80, -1203.53, 25.72),
                                    vec3(709.05, -1203.58, 25.84),
                                    vec3(709.12, -1202.40, 24.29),
                                    vec3(710.67, -1202.51, 24.39),
                                },
                                edgeFadeout = 0.3,
                                cleaningMultiplier = 1.2,
                                opacityMultiplier = 1.2,
                                completionThreshold = 90,
                                flipped = true,
                            },
                            {
                                corners = {
                                    vec3(696.28, -1198.71, 23.49),
                                    vec3(699.59, -1198.70, 23.37),
                                    vec3(699.74, -1196.80, 23.36),
                                    vec3(696.11, -1196.60, 23.50),
                                },
                                edgeFadeout = 0.3,
                                cleaningMultiplier = 1.2,
                                opacityMultiplier = 1.2,
                                completionThreshold = 90,
                            },
                            {
                                corners = {
                                    vec3(694.09, -1208.43, 25.13),
                                    vec3(692.83, -1207.99, 25.14),
                                    vec3(693.39, -1206.49, 23.99),
                                    vec3(694.62, -1207.09, 24.08),
                                },
                                edgeFadeout = 0.3,
                                cleaningMultiplier = 1.2,
                                opacityMultiplier = 1.2,
                                flipped = true,
                                completionThreshold = 90,
                            },
                            {
                                corners = {
                                    vec3(693.45, -1196.10, 23.60),
                                    vec3(696.23, -1195.67, 23.55),
                                    vec3(695.69, -1193.56, 23.44),
                                    vec3(693.04, -1194.51, 23.62),
                                },
                                edgeFadeout = 0.3,
                                cleaningMultiplier = 1.2,
                                opacityMultiplier = 1.2,
                                completionThreshold = 90,
                            },
                        },
                    },
                    {
                        name = "Helling",
                        areas = {
                            {
                                corners = {
                                    vec3(712.51, -1232.53, 25.50),
                                    vec3(716.76, -1232.52, 23.71),
                                    vec3(716.78, -1229.53, 23.71),
                                    vec3(712.54, -1229.60, 25.49),
                                },
                                edgeFadeout = 0.3,
                                cleaningMultiplier = 1.2,
                                opacityMultiplier = 1.2,
                            },
                            {
                                corners = {
                                    vec3(710.15, -1232.34, 25.57),
                                    vec3(712.21, -1232.23, 25.56),
                                    vec3(712.16, -1229.86, 25.57),
                                    vec3(710.23, -1229.78, 25.57),
                                },
                                edgeFadeout = 0.4,
                                cleaningMultiplier = 1.1,
                                opacityMultiplier = 1.2,
                            },
                        },
                    },
                    {
                        name = "Drop-in",
                        areas = {
                            {
                                corners = {
                                    vec3(718.47, -1204.29, 26.62),
                                    vec3(718.46, -1202.55, 26.60),
                                    vec3(712.83, -1202.03, 26.61),
                                    vec3(712.79, -1204.25, 26.62),
                                },
                                edgeFadeout = 0.3,
                                cleaningMultiplier = 1.2,
                                opacityMultiplier = 1.2,
                            },
                        },
                    },
                }
            },
        }
    },
    {
        name = "Onbekende beller",
        description = "Stel geen vragen. Ga er gewoon heen en maak het schoon.",
        reward = 2000,
        minPlayers = 1,
        maxPlayers = 1,
        locations = {
            {
                name = "Locatie",
                coords = vec3(-408.61, -2300.97, 2.68),
                spots = {
                    {
                        name = "Rode vlek",
                        areas = {
                            {
                                corners = {
                                    vec3(-408.61, -2300.97, 2.68),
                                    vec3(-407.80, -2298.59, 2.67),
                                    vec3(-409.04, -2298.07, 2.68),
                                    vec3(-409.91, -2300.54, 2.68),
                                },
                                edgeFadeout = 0.35,
                                cleaningMultiplier = 0.7,
                                opacityMultiplier = 1.4,
                                dirtColor = {31, 5, 3},
                                completionThreshold = 90,
                            },
                        },
                    },
                }
            },
        }
    },
    {
        name = "Onbekende beller",
        description = "Stel geen vragen. Ga er gewoon heen en maak het schoon.",
        reward = 2000,
        minPlayers = 1,
        maxPlayers = 1,
        locations = {
            {
                name = "Locatie",
                coords = vec3(-502.07, -1647.41, 16.82),
                spots = {
                    {
                        name = "Rode vlek",
                        areas = {
                            {
                                corners = {
                                    vec3(-502.07, -1647.41, 16.82),
                                    vec3(-500.29, -1647.01, 16.82),
                                    vec3(-500.63, -1645.75, 16.82),
                                    vec3(-502.44, -1646.33, 16.82),
                                },
                                edgeFadeout = 0.35,
                                cleaningMultiplier = 0.7,
                                opacityMultiplier = 1.4,
                                dirtColor = {31, 5, 3},
                                completionThreshold = 90,
                            },
                        },
                    },
                }
            },
        }
    },
    {
        name = "Onbekende beller",
        description = "Don't ask any questions. Just go and clean it.",
        reward = 2000,
        minPlayers = 1,
        maxPlayers = 1,
        locations = {
            {
                name = "Locatie",
                coords = vec3(-52.95, -1494.69, 30.62),
                spots = {
                    {
                        name = "Rode vlek",
                        areas = {
                            {
                                corners = {
                                    vec3(-52.95, -1494.69, 30.62),
                                    vec3(-54.37, -1493.65, 30.68),
                                    vec3(-55.16, -1494.57, 30.68),
                                    vec3(-53.57, -1495.63, 30.61),
                                },
                                edgeFadeout = 0.35,
                                cleaningMultiplier = 0.7,
                                opacityMultiplier = 1.4,
                                dirtColor = {31, 5, 3},
                                completionThreshold = 90,
                            },
                        },
                    },
                }
            },
        }
    },
    {
        name = "Dubbele oprit",
        description = "Maak 2 opritten schoon in de Los Santos Hills.",
        reward = 3750,
        minPlayers = 1,
        maxPlayers = 3,
        locations = {
            {
                name = "Oprit",
                coords = vec3(-760.60, 664.59, 142.53),
                spots = {
                    {
                        name = "Oprit",
                        areas = {
                            {
                                corners = {
                                    vec3(-769.07, 660.85, 144.67),
                                    vec3(-760.60, 664.59, 142.53),
                                    vec3(-761.44, 670.03, 142.51),
                                    vec3(-771.64, 666.54, 144.59),
                                },
                                edgeFadeout = 0.3,
                                opacityMultiplier = 0.9,
                            },
                        },
                    },
                }
            },
            {
                name = "Tweede oprit",
                coords = vec3(-347.09, 667.47, 168.10),
                spots = {
                    {
                        name = "Oprit",
                        areas = {
                            {
                                corners = {
                                    vec3(-347.09, 667.47, 168.10),
                                    vec3(-348.07, 660.59, 168.73),
                                    vec3(-343.44, 658.54, 169.08),
                                    vec3(-342.09, 666.35, 168.12),
                                },
                                edgeFadeout = 0.3,
                                opacityMultiplier = 0.9,
                            },
                        },
                    },
                }
            },
        }
    },
    {
        name = "Opritten bij het meer",
        description = "Maak meerdere opritten schoon bij het meer.",
        reward = 4500,
        minPlayers = 1,
        maxPlayers = 2,
        locations = {
            {
                name = "Oprit",
                coords = vec3(834.94, -542.61, 56.35),
                spots = {
                    {
                        name = "Oprit",
                        areas = {
                            {
                                corners = {
                                    vec3(834.94, -542.61, 56.35),
                                    vec3(856.45, -544.08, 56.34),
                                    vec3(856.74, -540.60, 56.33),
                                    vec3(835.12, -539.23, 56.34),
                                },
                                edgeFadeout = 0.3,
                                opacityMultiplier = 0.9,
                                cleaningMultiplier = 1.25,
                            },
                        },
                    },
                }
            },
            {
                name = "Tweede oprit",
                coords = vec3(925.44, -628.17, 56.88),
                spots = {
                    {
                        name = "Oprit",
                        areas = {
                            {
                                corners = {
                                    vec3(914.38, -646.23, 56.88),
                                    vec3(927.93, -630.41, 56.88),
                                    vec3(925.44, -628.17, 56.88),
                                    vec3(911.60, -643.81, 56.88),
                                },
                                edgeFadeout = 0.3,
                                opacityMultiplier = 0.9,
                                cleaningMultiplier = 1.25,
                            },
                        },
                    },
                }
            },
            {
                name = "Derde oprit",
                coords = vec3(1005.80, -735.89, 56.47),
                spots = {
                    {
                        name = "Oprit",
                        areas = {
                            {
                                corners = {
                                    vec3(1005.80, -735.89, 56.47),
                                    vec3(1008.41, -733.79, 56.67),
                                    vec3(1005.44, -730.07, 56.62),
                                    vec3(1002.69, -732.39, 56.47),
                                },
                                edgeFadeout = 0.3,
                                opacityMultiplier = 0.9,
                            },
                        },
                    },
                }
            },
        }
    },
    {
        name = "Opritten bij het meer",
        description = "Maak twee opritten schoon bij het Los Santos-meer.",
        reward = 4750,
        minPlayers = 1,
        maxPlayers = 2,
        locations = {
            {
                name = "Oprit",
                coords = vec3(1010.40, -523.37, 59.54),
                spots = {
                    {
                        name = "Opritv",
                        areas = {
                            {
                                corners = {
                                    vec3(999.06, -511.56, 59.70),
                                    vec3(1004.24, -522.44, 59.70),
                                    vec3(1008.82, -520.10, 59.73),
                                    vec3(1003.39, -509.50, 59.71),
                                },
                                edgeFadeout = 0.3,
                                opacityMultiplier = 0.9,
                                cleaningMultiplier = 1.25,
                            },
                            {
                                corners = {
                                    vec3(1003.79, -521.84, 59.73),
                                    vec3(1005.63, -525.62, 59.43),
                                    vec3(1010.40, -523.37, 59.54),
                                    vec3(1008.57, -519.33, 59.70),
                                },
                                edgeFadeout = 0.3,
                                opacityMultiplier = 0.9,
                                cleaningMultiplier = 1.25,
                            },
                        },
                    },
                }
            },
            {
                name = "Tweede oprit",
                coords = vec3(1096.10, -422.72, 66.17),
                spots = {
                    {
                        name = "Oprit",
                        areas = {
                            {
                                corners = {
                                    vec3(1114.25, -417.56, 66.19),
                                    vec3(1097.77, -416.22, 66.18),
                                    vec3(1096.10, -422.72, 66.17),
                                    vec3(1113.37, -424.78, 66.17),
                                },
                                edgeFadeout = 0.3,
                                opacityMultiplier = 0.9,
                                completionThreshold = 85,
                            },
                        },
                    },
                }
            },
        }
    },
    {
        name = "Executieverkoop woning",
        description = "Maak het pand schoon zodat de makelaar het met meer winst kan verkopen.",
        reward = 5250,
        minPlayers = 1,
        maxPlayers = 3,
        locations = {
            {
                name = "Pand",
                coords = vec3(1384.94, -581.84, 73.35),
                spots = {
                    {
                        name = "Oprit",
                        areas = {
                            {
                                corners = {
                                    vec3(1403.51, -568.34, 73.35),
                                    vec3(1384.45, -576.78, 73.36),
                                    vec3(1385.67, -581.46, 73.36),
                                    vec3(1405.62, -572.92, 73.37),
                                },
                                edgeFadeout = 0.3,
                                opacityMultiplier = 0.9,
                                cleaningMultiplier = 1.25,
                            },
                        },
                    },
                    {
                        name = "Pad naar voordeur",
                        areas = {
                            {
                                corners = {
                                    vec3(1386.58, -569.22, 73.35),
                                    vec3(1382.55, -570.88, 73.35),
                                    vec3(1383.59, -573.19, 73.35),
                                    vec3(1387.50, -571.36, 73.35),
                                },
                                edgeFadeout = 0.3,
                                opacityMultiplier = 0.9,
                            },
                        },
                    },
                    {
                        name = "Garagepoort",
                        areas = {
                            {
                                corners = {
                                    vec3(1404.21, -568.57, 75.11),
                                    vec3(1406.04, -572.56, 75.11),
                                    vec3(1406.02, -572.51, 73.48),
                                    vec3(1404.20, -568.54, 73.40),
                                },
                                edgeFadeout = 0.3,
                                flipped = true,
                                opacityMultiplier = 0.9,
                            },
                        },
                    },
                }
            },
        }
    },
    {
        name = "Executiewoning",
        description = "Maak het pand schoon zodat de makelaar het met meer winst kan verkopen.",
        reward = 5250,
        minPlayers = 1,
        maxPlayers = 3,
        locations = {
            {
                name = "Pand",
                coords = vec3(1357.36, -596.46, 73.35),
                spots = {
                    {
                        name = "Oprit",
                        areas = {
                            {
                                corners = {
                                    vec3(1362.48, -620.21, 73.36),
                                    vec3(1362.24, -597.86, 73.35),
                                    vec3(1357.36, -596.46, 73.35),
                                    vec3(1357.27, -620.39, 73.35),
                                },
                                edgeFadeout = 0.3,
                                opacityMultiplier = 0.9,
                                cleaningMultiplier = 1.25,
                            },
                        },
                    },
                    {
                        name = "Pad naar voordeur",
                        areas = {
                            {
                                corners = {
                                    vec3(1368.68, -604.25, 73.35),
                                    vec3(1368.70, -597.75, 73.35),
                                    vec3(1366.00, -597.91, 73.35),
                                    vec3(1365.97, -604.25, 73.35),
                                },
                                edgeFadeout = 0.3,
                                opacityMultiplier = 0.9,
                            },
                        },
                    },
                    {
                        name = "Garagepoort",
                        areas = {
                            {
                                corners = {
                                    vec3(1362.08, -620.80, 75.12),
                                    vec3(1357.53, -620.87, 75.11),
                                    vec3(1357.53, -620.86, 73.49),
                                    vec3(1362.06, -620.78, 73.47),
                                },
                                edgeFadeout = 0.3,
                                flipped = true,
                                opacityMultiplier = 0.9,
                            },
                        },
                    },
                }
            },
        }
    },
    {
        name = "Executiewoning",
        description = "Maak het pand schoon zodat de makelaar het met meer winst kan verkopen.",
        reward = 4500,
        minPlayers = 1,
        maxPlayers = 2,
        locations = {
            {
                name = "Pand",
                coords = vec3(1327.24, -593.56, 72.14),
                spots = {
                    {
                        name = "Achtertuin",
                        areas = {
                            {
                                corners = {
                                    vec3(1317.15, -599.56, 71.91),
                                    vec3(1315.45, -602.94, 71.93),
                                    vec3(1321.59, -605.97, 71.93),
                                    vec3(1323.35, -602.12, 71.92),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 0.9,
                                cleaningMultiplier = 1.1,
                            },
                            {
                                corners = {
                                    vec3(1313.51, -599.37, 71.92),
                                    vec3(1312.51, -601.65, 71.91),
                                    vec3(1315.88, -603.19, 71.92),
                                    vec3(1316.81, -600.82, 71.92),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 0.9,
                                cleaningMultiplier = 1.1,
                            },
                            {
                                corners = {
                                    vec3(1325.31, -592.74, 72.05),
                                    vec3(1321.19, -601.64, 71.92),
                                    vec3(1323.15, -602.70, 71.93),
                                    vec3(1327.24, -593.56, 72.14),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 0.9,
                                cleaningMultiplier = 1.1,
                            },
                        },
                    },
                    {
                        name = "Achtertuinmuur",
                        areas = {
                            {
                                corners = {
                                    vec3(1320.49, -610.14, 73.33),
                                    vec3(1310.96, -603.59, 73.37),
                                    vec3(1310.74, -603.44, 72.17),
                                    vec3(1320.53, -610.18, 72.23),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.2,
                                flipped = true,
                            },
                        },
                    },
                }
            },
        }
    },
    {
        name = "Schitterende juwelen",
        description = "Maak het Discount Jewels winkelpand en de reclameborden schoon.",
        reward = 2250,
        minPlayers = 1,
        maxPlayers = 2,
        locations = {
            {
                name = "Discount Jewels",
                coords = vec3(129.86, -1771.45, 28.76),
                spots = {
                    {
                        name = "Gold & Silver reclamebord",
                        areas = {
                            {
                                corners = {
                                    vec3(128.85, -1770.14, 31.11),
                                    vec3(125.48, -1767.29, 31.14),
                                    vec3(125.49, -1767.29, 29.03),
                                    vec3(128.87, -1770.15, 29.05),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.2,
                                flipped = true,
                            },
                        },
                    },
                    {
                        name = "Ingang",
                        areas = {
                            {
                                corners = {
                                    vec3(131.90, -1773.27, 28.76),
                                    vec3(135.07, -1769.51, 28.29),
                                    vec3(133.03, -1767.64, 28.29),
                                    vec3(129.86, -1771.45, 28.76),
                                },
                                edgeFadeout = 0.2,
                            },
                        },
                    },
                    {
                        name = "Zijmuur",
                        areas = {
                            {
                                corners = {
                                    vec3(136.59, -1794.63, 32.02),
                                    vec3(145.09, -1784.51, 32.04),
                                    vec3(145.14, -1784.46, 28.47),
                                    vec3(136.63, -1794.60, 27.70),
                                },
                                edgeFadeout = 0.2,
                                cleaningMultiplier = 1.2,
                                flipped = true,
                                completionThreshold = 97,
                            },
                        },
                    },
                }
            },
        }
    },
    {
        name = "Vieze trailer",
        description = "Maak een vrachtwagentrailer schoon, hij moet weer glimmen.",
        reward = 2500,
        minPlayers = 1,
        maxPlayers = 3,
        locations = {
            {
                name = "Aanhanger",
                coords = vec3(171.01, -3264.76, 8.83),
                spots = {
                    {
                        name = "Linkerkant",
                        areas = {
                            {
                                corners = {
                                    vec3(171.01, -3264.76, 8.83),
                                    vec3(159.29, -3264.76, 9.05),
                                    vec3(159.27, -3264.74, 6.75),
                                    vec3(171.00, -3264.76, 6.48),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.1,
                                dirtColor = {25, 31, 23},
                                flipped = true,
                            },
                        },
                    },
                    {
                        name = "Rechterkant",
                        areas = {
                            {
                                corners = {
                                    vec3(159.33, -3267.59, 9.05),
                                    vec3(170.95, -3267.59, 8.79),
                                    vec3(170.88, -3267.59, 6.49),
                                    vec3(159.31, -3267.61, 6.70),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.1,
                                dirtColor = {25, 31, 23},
                                flipped = true,
                            },
                        },
                    },
                    {
                        name = "Achterkant",
                        areas = {
                            {
                                corners = {
                                    vec3(159.05, -3264.93, 9.10),
                                    vec3(159.06, -3267.40, 9.10),
                                    vec3(158.92, -3267.47, 6.96),
                                    vec3(158.92, -3265.01, 6.97),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.1,
                                dirtColor = {25, 31, 23},
                                flipped = true,
                            },
                        },
                    },
                    {
                        name = "Dak",
                        areas = {
                            {
                                corners = {
                                    vec3(171.07, -3264.93, 9.03),
                                    vec3(159.18, -3264.89, 9.26),
                                    vec3(159.24, -3267.44, 9.26),
                                    vec3(171.01, -3267.38, 9.04),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.1,
                                dirtColor = {25, 31, 23},
                            },
                        },
                    },
                }
            },
        }
    },
    {
        name = "Vieze trailer",
        description = "Maak een vrachtwagentrailer schoon, hij moet weer glimmen.",
        reward = 2750,
        minPlayers = 1,
        maxPlayers = 3,
        locations = {
            {
                name = "Aanhanger",
                coords = vec3(196.39, 2766.20, 46.63),
                spots = {
                    {
                        name = "Linkerkant",
                        areas = {
                            {
                                corners = {
                                    vec3(200.42, 2754.86, 46.48),
                                    vec3(199.03, 2766.54, 46.46),
                                    vec3(199.04, 2766.56, 44.09),
                                    vec3(200.42, 2754.91, 44.09),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.1,
                                dirtColor = {25, 31, 23},
                                flipped = true,
                            },
                        },
                    },
                    {
                        name = "Rechterkant",
                        areas = {
                            {
                                corners = {
                                    vec3(196.21, 2766.23, 46.47),
                                    vec3(197.61, 2754.52, 46.44),
                                    vec3(197.61, 2754.57, 44.07),
                                    vec3(196.20, 2766.16, 44.08),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.1,
                                dirtColor = {25, 31, 23},
                                flipped = true,
                            },
                        },
                    },
                    {
                        name = "Achterkant",
                        areas = {
                            {
                                corners = {
                                    vec3(198.81, 2766.74, 46.47),
                                    vec3(196.36, 2766.44, 46.44),
                                    vec3(196.38, 2766.54, 44.19),
                                    vec3(198.77, 2766.82, 44.23),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.1,
                                dirtColor = {25, 31, 23},
                                flipped = true,
                            },
                        },
                    },
                    {
                        name = "Dak",
                        areas = {
                            {
                                corners = {
                                    vec3(200.23, 2754.91, 46.63),
                                    vec3(198.87, 2766.50, 46.63),
                                    vec3(196.39, 2766.20, 46.63),
                                    vec3(197.78, 2754.62, 46.63),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.1,
                                dirtColor = {25, 31, 23},
                            },
                        },
                    },
                }
            },
        }
    },
    {
        name = "Vieze trailer",
        description = "Maak een vrachtwagentrailer schoon, hij moet weer glimmen.",
        reward = 2500,
        minPlayers = 1,
        maxPlayers = 3,
        locations = {
            {
                name = "Aanhanger",
                coords = vec3(-522.83, -2858.80, 9.07),
                spots = {
                    {
                        name = "Linkerkant",
                        areas = {
                            {
                                corners = {
                                    vec3(-522.83, -2858.80, 9.07),
                                    vec3(-522.81, -2858.81, 6.66),
                                    vec3(-514.49, -2867.16, 6.66),
                                    vec3(-514.50, -2867.13, 9.04),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.1,
                                dirtColor = {25, 31, 23},
                            },
                        },
                    },
                    {
                        name = "Rechterkant",
                        areas = {
                            {
                                corners = {
                                    vec3(-512.49, -2865.13, 9.09),
                                    vec3(-512.53, -2865.07, 6.74),
                                    vec3(-520.80, -2856.83, 6.73),
                                    vec3(-520.80, -2856.83, 9.12),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.1,
                                dirtColor = {25, 31, 23},
                            },
                        },
                    },
                    {
                        name = "Achterkant",
                        areas = {
                            {
                                corners = {
                                    vec3(-514.20, -2867.17, 9.10),
                                    vec3(-514.06, -2867.16, 6.66),
                                    vec3(-512.38, -2865.48, 6.69),
                                    vec3(-512.43, -2865.40, 9.07),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.1,
                                dirtColor = {25, 31, 23},
                            },
                        },
                    },
                }
            },
        }
    },
    {
        name = "Zonder brandstof",
        description = "Maak een verlaten tankstation schoon. De eigenaar wil het verkopen en denkt dat dit hem een betere prijs oplevert",
        reward = 6500,
        minPlayers = 1,
        maxPlayers = 4,
        locations = {
            {
                name = "Tankstation",
                coords = vec3(2530.39, 4196.08, 39.02),
                spots = {
                    {
                        name = "Tankstation bestrating",
                        areas = {
                            {
                                corners = {
                                    vec3(2530.39, 4196.08, 39.02),
                                    vec3(2519.07, 4202.92, 38.95),
                                    vec3(2514.84, 4195.79, 38.97),
                                    vec3(2526.03, 4188.82, 38.92),
                                },
                                edgeFadeout = 0.35,
                            },
                        },
                    },
                }
            },
        }
    },
    {
        name = "Sandy bewegwijzering",
        description = "De verkeersborden in Blaine County zijn extreem stoffig geworden. Ze zijn al tientallen jaren niet schoongemaakt. Ga ze schoonmaken",
        reward = 7250,
        minPlayers = 1,
        maxPlayers = 2,
        locations = {
            {
                name = "Verkeersreclamebord",
                coords = vec3(2790.26, 4392.63, 50.99),
                spots = {
                    {
                        name = "Verkeersreclamebord",
                        areas = {
                            {
                                corners = {
                                    vec3(2790.26, 4392.63, 50.99),
                                    vec3(2790.55, 4389.33, 50.98),
                                    vec3(2790.55, 4389.35, 50.01),
                                    vec3(2790.26, 4392.65, 50.01),
                                },
                                edgeFadeout = 0.15,
                                opacityMultiplier = 1.4,
                                dirtColor = {74, 72, 65},
                                flipped = true,
                            },
                        },
                    },
                }
            },
            {
                name = "Verkeersreclamebord",
                coords = vec3(2793.91, 4423.47, 50.42),
                spots = {
                    {
                        name = "Verkeersreclamebord",
                        areas = {
                            {
                                corners = {
                                    vec3(2793.91, 4423.47, 50.42),
                                    vec3(2793.63, 4426.70, 50.42),
                                    vec3(2793.63, 4426.66, 49.53),
                                    vec3(2793.91, 4423.47, 49.49),
                                },
                                edgeFadeout = 0.15,
                                opacityMultiplier = 1.4,
                                dirtColor = {74, 72, 65},
                                flipped = true,
                            },
                        },
                    },
                }
            },
            {
                name = "Verkeersreclamebord",
                coords = vec3(2748.94, 4388.08, 50.97),
                spots = {
                    {
                        name = "Verkeersreclamebord",
                        areas = {
                            {
                                corners = {
                                    vec3(2748.94, 4388.08, 50.97),
                                    vec3(2749.67, 4385.34, 50.97),
                                    vec3(2749.66, 4385.36, 49.91),
                                    vec3(2748.93, 4388.09, 49.89),
                                },
                                edgeFadeout = 0.15,
                                opacityMultiplier = 1.4,
                                dirtColor = {74, 72, 65},
                                flipped = true,
                            },
                        },
                    },
                }
            },
            {
                name = "Verkeersreclamebord",
                coords = vec3(2519.13, 4163.39, 41.09),
                spots = {
                    {
                        name = "Verkeersreclamebord",
                        areas = {
                            {
                                corners = {
                                    vec3(2519.13, 4163.39, 41.09),
                                    vec3(2516.95, 4165.22, 41.07),
                                    vec3(2516.95, 4165.22, 40.04),
                                    vec3(2519.14, 4163.39, 40.02),
                                },
                                edgeFadeout = 0.15,
                                opacityMultiplier = 1.4,
                                dirtColor = {74, 72, 65},
                                flipped = true,
                            },
                        },
                    },
                }
            },
            {
                name = "Verkeersreclamebord",
                coords = vec3(2492.07, 4077.11, 39.81),
                spots = {
                    {
                        name = "Verkeersreclamebord",
                        areas = {
                            {
                                corners = {
                                    vec3(2492.03, 4077.11, 39.81),
                                    vec3(2494.46, 4075.69, 39.80),
                                    vec3(2494.45, 4075.69, 38.70),
                                    vec3(2492.02, 4077.13, 38.72),
                                },
                                edgeFadeout = 0.15,
                                opacityMultiplier = 1.4,
                                dirtColor = {74, 72, 65},
                                flipped = true,
                            },
                        },
                    },
                }
            },
            {
                name = "Verkeersreclamebord",
                coords = vec3(1629.40, 3475.15, 39.24),
                spots = {
                    {
                        name = "Verkeersreclamebord",
                        areas = {
                            {
                                corners = {
                                    vec3(1629.37, 3475.15, 39.24),
                                    vec3(1629.64, 3471.87, 39.20),
                                    vec3(1629.64, 3471.90, 37.56),
                                    vec3(1629.37, 3475.13, 37.56),
                                },
                                edgeFadeout = 0.15,
                                opacityMultiplier = 1.4,
                                dirtColor = {74, 72, 65},
                                flipped = true,
                            },
                        },
                    },
                }
            },
            {
                name = "Verkeersreclamebord",
                coords = vec3(1213.84, 3530.05, 36.30),
                spots = {
                    {
                        name = "Verkeersreclamebord",
                        areas = {
                            {
                                corners = {
                                    vec3(1213.84, 3530.05, 36.30),
                                    vec3(1213.84, 3527.24, 36.29),
                                    vec3(1213.84, 3527.26, 35.86),
                                    vec3(1213.84, 3530.11, 35.86),
                                },
                                edgeFadeout = 0.05,
                                opacityMultiplier = 1.6,
                                dirtColor = {74, 72, 65},
                                flipped = true,
                            },
                        },
                    },
                }
            },
            {
                name = "Verkeersreclamebord",
                coords = vec3(295.07, 3425.68, 39.02),
                spots = {
                    {
                        name = "Verkeersreclamebord",
                        areas = {
                            {
                                corners = {
                                    vec3(295.07, 3425.68, 39.02),
                                    vec3(293.56, 3428.09, 39.01),
                                    vec3(293.55, 3428.09, 37.93),
                                    vec3(295.06, 3425.69, 37.91),
                                },
                                edgeFadeout = 0.15,
                                opacityMultiplier = 1.4,
                                dirtColor = {74, 72, 65},
                                flipped = true,
                            },
                        },
                    },
                }
            },
        }
    },
    {
        name = "Vuile trailer",
        description = "Was een vrachttrailer, hij moet weer glanzen.",
        reward = 2500,
        minPlayers = 1,
        maxPlayers = 3,
        locations = {
            {
                name = "Trailer",
                coords = vec3(-445.53, -2719.54, 9.09),
                spots = {
                    {
                        name = "Linkerkant",
                        areas = {
                            {
                                corners = {
                                    vec3(-434.90, -2725.39, 9.11),
                                    vec3(-443.64, -2717.44, 9.10),
                                    vec3(-443.58, -2717.46, 6.70),
                                    vec3(-434.93, -2725.36, 6.71),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.1,
                                dirtColor = {25, 31, 23},
                                flipped = true,
                            },
                        },
                    },
                    {
                        name = "Rechterkant",
                        areas = {
                            {
                                corners = {
                                    vec3(-445.53, -2719.54, 9.09),
                                    vec3(-436.80, -2727.48, 9.11),
                                    vec3(-436.75, -2727.53, 6.64),
                                    vec3(-445.49, -2719.60, 6.72),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.1,
                                dirtColor = {25, 31, 23},
                                flipped = true,
                            },
                        },
                    },
                    {
                        name = "Achterkant",
                        areas = {
                            {
                                corners = {
                                    vec3(-443.87, -2717.45, 9.11),
                                    vec3(-445.56, -2719.30, 9.10),
                                    vec3(-445.62, -2719.23, 6.69),
                                    vec3(-443.97, -2717.43, 6.64),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.1,
                                dirtColor = {25, 31, 23},
                                flipped = true,
                            },
                        },
                    },
                }
            },
        }
    },
    {
        name = "Naar de ranch",
        description = "Maak de ranch schoon, begin bij de oprit, ga via het zwembad en eindig bij de stallen.",
        reward = 8250,
        minPlayers = 1,
        maxPlayers = 4,
        locations = {
            {
                name = "Ranch",
                coords = vec3(1415.22, 1121.82, 113.85),
                spots = {
                    {
                        name = "Oprit",
                        areas = {
                            {
                                corners = {
                                    vec3(1415.22, 1121.82, 113.85),
                                    vec3(1398.58, 1122.33, 113.85),
                                    vec3(1397.42, 1114.57, 113.85),
                                    vec3(1415.92, 1114.85, 113.85),
                                },
                                edgeFadeout = 0.35,
                                opacityMultiplier = 1.1,
                                cleaningMultiplier = 1.4,
                            },
                        },
                    },
                }
            },
            {
                name = "Zwembad",
                coords = vec3(1417.13, 1158.25, 113.67),
                spots = {
                    {
                        name = "Zwembadterras",
                        areas = {
                            {
                                corners = {
                                    vec3(1417.13, 1158.25, 113.68),
                                    vec3(1417.19, 1150.35, 113.68),
                                    vec3(1420.34, 1150.63, 113.68),
                                    vec3(1420.35, 1158.28, 113.68),
                                },
                                edgeFadeout = 0.2,
                            },
                        },
                    },
                }
            },
            {
                name = "Stallen",
                coords = vec3(1467.39, 1138.88, 113.32),
                spots = {
                    {
                        name = "Stal 1",
                        areas = {
                            {
                                corners = {
                                    vec3(1467.39, 1138.88, 113.34),
                                    vec3(1467.50, 1136.91, 113.34),
                                    vec3(1470.09, 1136.74, 113.34),
                                    vec3(1470.09, 1138.89, 113.34),
                                },
                                edgeFadeout = 0.3,
                                dirtColor = {33, 28, 21},
                                opacityMultiplier = 1.4,
                                cleaningMultiplier = 0.8,
                                completionThreshold = 90,
                            },
                        },
                    },
                    {
                        name = "Stal 2",
                        areas = {
                            {
                                corners = {
                                    vec3(1461.28, 1138.86, 113.35),
                                    vec3(1458.74, 1138.47, 113.35),
                                    vec3(1459.52, 1136.42, 113.35),
                                    vec3(1461.79, 1137.49, 113.35),
                                },
                                edgeFadeout = 0.3,
                                dirtColor = {33, 28, 21},
                                opacityMultiplier = 1.4,
                                cleaningMultiplier = 0.8,
                                completionThreshold = 90,
                            },
                        },
                    },
                    {
                        name = "Stal 3",
                        areas = {
                            {
                                corners = {
                                    vec3(1467.29, 1153.55, 113.33),
                                    vec3(1467.26, 1150.55, 113.36),
                                    vec3(1469.41, 1150.69, 113.36),
                                    vec3(1469.37, 1153.60, 113.33),
                                },
                                edgeFadeout = 0.3,
                                dirtColor = {33, 28, 21},
                                opacityMultiplier = 1.4,
                                cleaningMultiplier = 0.8,
                                completionThreshold = 90,
                            },
                        },
                    },
                    {
                        name = "Stal 4",
                        areas = {
                            {
                                corners = {
                                    vec3(1443.30, 1169.97, 113.36),
                                    vec3(1443.10, 1172.57, 113.36),
                                    vec3(1441.25, 1172.62, 113.36),
                                    vec3(1441.43, 1169.71, 113.36),
                                },
                                edgeFadeout = 0.3,
                                dirtColor = {33, 28, 21},
                                opacityMultiplier = 1.4,
                                cleaningMultiplier = 0.8,
                                completionThreshold = 90,
                            },
                        },
                    },
                    {
                        name = "Opslagschuur",
                        areas = {
                            {
                                corners = {
                                    vec3(1488.74, 1129.14, 113.37),
                                    vec3(1485.01, 1129.27, 113.37),
                                    vec3(1484.97, 1127.44, 113.37),
                                    vec3(1488.63, 1127.26, 113.37),
                                },
                                edgeFadeout = 0.3,
                                dirtColor = {33, 28, 21},
                                opacityMultiplier = 1.2,
                                cleaningMultiplier = 0.8,
                                completionThreshold = 90,
                            },
                        },
                    },
                    {
                        name = "Dixi",
                        areas = {
                            {
                                corners = {
                                    vec3(1472.03, 1144.40, 113.35),
                                    vec3(1471.95, 1145.91, 113.35),
                                    vec3(1471.36, 1146.05, 113.35),
                                    vec3(1471.39, 1144.45, 113.35),
                                },
                                edgeFadeout = 0.4,
                                dirtColor = {33, 28, 21},
                                opacityMultiplier = 1.5,
                                completionThreshold = 90,
                            },
                        },
                    },
                }
            },
        }
    },
    {
        name = "Bushalte advertentie",
        description = "Maak de advertenties bij lokale bushaltes schoon om de consumptie op peil te houden.",
        reward = 2750,
        minPlayers = 1,
        maxPlayers = 2,
        locations = {
            {
                name = "Bushalte",
                coords = vec3(810.77, -1350.18, 27.20),
                spots = {
                    {
                        name = "Bushalte advertentie",
                        areas = {
                            {
                                corners = {
                                    vec3(810.77, -1350.18, 27.20),
                                    vec3(810.80, -1350.19, 25.74),
                                    vec3(809.87, -1350.19, 25.76),
                                    vec3(809.90, -1350.18, 27.20),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.7,
                                cleaningMultiplier = 0.6,
                            },
                        },
                    },
                }
            },
            {
                name = "Bushalte",
                coords = vec3(789.09, -774.13, 27.37),
                spots = {
                    {
                        name = "Bushalte advertentie",
                        areas = {
                            {
                                corners = {
                                    vec3(789.09, -774.13, 27.37),
                                    vec3(788.02, -774.13, 27.39),
                                    vec3(788.03, -774.13, 25.78),
                                    vec3(789.13, -774.13, 25.81),
                                },
                                edgeFadeout = 0.2,
                                flipped = true,
                                opacityMultiplier = 1.7,
                                cleaningMultiplier = 0.6,
                            },
                        },
                    },
                }
            },
            {
                name = "Bushalte",
                coords = vec3(767.62, -943.82, 26.67),
                spots = {
                    {
                        name = "Bushalte advertentie",
                        areas = {
                            {
                                corners = {
                                    vec3(767.62, -943.82, 26.67),
                                    vec3(768.59, -943.74, 26.67),
                                    vec3(768.58, -943.76, 25.15),
                                    vec3(767.59, -943.85, 25.13),
                                },
                                edgeFadeout = 0.2,
                                flipped = true,
                                opacityMultiplier = 1.7,
                                cleaningMultiplier = 0.6,
                            },
                        },
                    },
                }
            },
            {
                name = "Bushalte",
                coords = vec3(358.40, -1068.14, 30.56),
                spots = {
                    {
                        name = "Bushalte advertentie",
                        areas = {
                            {
                                corners = {
                                    vec3(358.40, -1068.14, 30.56),
                                    vec3(358.40, -1067.00, 30.55),
                                    vec3(358.40, -1067.02, 28.91),
                                    vec3(358.40, -1068.13, 28.94),
                                },
                                edgeFadeout = 0.2,
                                flipped = true,
                                opacityMultiplier = 1.7,
                                cleaningMultiplier = 0.6,
                            },
                        },
                    },
                }
            },
            {
                name = "Bushalte",
                coords = vec3(59.26, -1539.01, 30.30),
                spots = {
                    {
                        name = "Bushalte advertentie",
                        areas = {
                            {
                                corners = {
                                    vec3(59.26, -1539.01, 30.30),
                                    vec3(58.42, -1538.31, 30.31),
                                    vec3(58.45, -1538.33, 28.69),
                                    vec3(59.30, -1539.04, 28.68),
                                },
                                edgeFadeout = 0.2,
                                flipped = true,
                                opacityMultiplier = 1.7,
                                cleaningMultiplier = 0.6,
                            },
                        },
                    },
                }
            },
            {
                name = "Bushalte",
                coords = vec3(-112.23, -1687.05, 28.74),
                spots = {
                    {
                        name = "Bushalte advertentie",
                        areas = {
                            {
                                corners = {
                                    vec3(-112.22, -1687.06, 30.21),
                                    vec3(-112.23, -1687.05, 28.74),
                                    vec3(-111.50, -1687.67, 28.72),
                                    vec3(-111.50, -1687.67, 30.21),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.7,
                                cleaningMultiplier = 0.6,
                            },
                        },
                    },
                }
            },
        }
    },
    {
        name = "Een handvol garagedeuren",
        description = "Maak een aantal garagedeuren schoon in de omgeving van Davis",
        reward = 2500,
        minPlayers = 1,
        maxPlayers = 2,
        locations = {
            {
                name = "Garage",
                coords = vec3(166.53, -1853.10, 25.47),
                spots = {
                    {
                        name = "Garage deur",
                        areas = {
                            {
                                corners = {
                                    vec3(166.53, -1853.10, 25.47),
                                    vec3(169.21, -1854.31, 25.44),
                                    vec3(169.22, -1854.31, 23.41),
                                    vec3(166.51, -1853.09, 23.42),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.2,
                                cleaningMultiplier = 0.9,
                                flipped = true,
                            },
                        },
                    },
                }
            },
            {
                name = "Garage",
                coords = vec3(158.66, -1902.05, 24.20),
                spots = {
                    {
                        name = "Garage deur",
                        areas = {
                            {
                                corners = {
                                    vec3(158.66, -1902.05, 24.20),
                                    vec3(156.09, -1900.85, 24.19),
                                    vec3(156.08, -1900.84, 22.19),
                                    vec3(158.63, -1902.04, 22.16),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.2,
                                cleaningMultiplier = 0.9,
                                flipped = true,
                            },
                        },
                    },
                }
            },
            {
                name = "Garage",
                coords = vec3(248.18, -1995.49, 21.48),
                spots = {
                    {
                        name = "Red door",
                        areas = {
                            {
                                corners = {
                                    vec3(248.18, -1995.49, 21.48),
                                    vec3(246.57, -1997.88, 21.47),
                                    vec3(246.60, -1997.83, 19.33),
                                    vec3(248.16, -1995.51, 19.35),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.2,
                                cleaningMultiplier = 0.9,
                                flipped = true,
                            },
                        },
                    },
                    {
                        name = "Witte deur",
                        areas = {
                            {
                                corners = {
                                    vec3(245.94, -1998.81, 21.39),
                                    vec3(244.42, -2001.06, 21.45),
                                    vec3(244.45, -2001.02, 19.37),
                                    vec3(245.97, -1998.76, 19.37),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.2,
                                cleaningMultiplier = 0.9,
                                flipped = true,
                            },
                        },
                    },
                }
            },

            {
                name = "Garage",
                coords = vec3(279.43, -2003.70, 21.26),
                spots = {
                    {
                        name = "Garage deur",
                        areas = {
                            {
                                corners = {
                                    vec3(279.43, -2003.70, 21.26),
                                    vec3(281.30, -2000.83, 21.24),
                                    vec3(281.28, -2000.85, 19.35),
                                    vec3(279.38, -2003.78, 19.36),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.2,
                                cleaningMultiplier = 0.9,
                                flipped = true,
                            },
                        },
                    },
                }
            },
            {
                name = "Garage",
                coords = vec3(245.66, -2044.35, 19.17),
                spots = {
                    {
                        name = "Garage deur",
                        areas = {
                            {
                                corners = {
                                    vec3(245.66, -2044.35, 19.17),
                                    vec3(247.90, -2041.65, 19.22),
                                    vec3(247.88, -2041.67, 17.16),
                                    vec3(245.65, -2044.37, 17.26),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.2,
                                cleaningMultiplier = 0.9,
                                flipped = true,
                            },
                        },
                    },
                }
            },
        }
    },
    {
        name = "Modderig Galileo",
        description = "Maak de bovenste uitkijkplatforms van het Galileo Observatorium schoon",
        reward = 11500,
        minPlayers = 1,
        maxPlayers = 4,
        locations = {
            {
                name = "Galileo Observatorium",
                coords = vec3(-424.21, 1128.03, 324.86),
                spots = {
                    {
                        name = "Uitkijkplatform (links)",
                        areas = {
                            {
                                corners = {
                                    vec3(-404.38, 1101.08, 331.54),
                                    vec3(-420.92, 1105.69, 331.54),
                                    vec3(-424.66, 1092.61, 331.54),
                                    vec3(-407.46, 1088.39, 331.54),
                                },
                                edgeFadeout = 0.35,
                                opacityMultiplier = 1.1,
                                cleaningMultiplier = 1.25,
                            },
                        },
                    },
                    {
                        name = "Uitkijkplatform (links)",
                        areas = {
                            {
                                corners = {
                                    vec3(-459.08, 1102.69, 331.54),
                                    vec3(-442.53, 1097.28, 331.56),
                                    vec3(-438.56, 1111.21, 331.54),
                                    vec3(-455.74, 1115.62, 331.56),
                                },
                                edgeFadeout = 0.35,
                                opacityMultiplier = 1.1,
                                cleaningMultiplier = 1.25,
                            },
                        },
                    },
                    {
                        name = "Uitkijkplatform (verbinding)",
                        areas = {
                            {
                                corners = {
                                    vec3(-421.35, 1089.91, 331.54),
                                    vec3(-445.89, 1096.89, 331.55),
                                    vec3(-446.90, 1093.29, 331.54),
                                    vec3(-422.87, 1086.54, 331.54),
                                },
                                edgeFadeout = 0.35,
                                opacityMultiplier = 1.1,
                                cleaningMultiplier = 1.25,
                            },
                        },
                    },
                }
            },

        }
    },
    {
        name = "Toiletpauze",
        description = "Maak de openbare toiletten bij het Galileo Observatorium schoon",
        reward = 4750,
        minPlayers = 1,
        maxPlayers = 3,
        locations = {
            {
                name = "Galileo Observatorium",
                coords = vec3(-415.07, 1207.58, 324.64),
                spots = {
                    {
                        name = "Toiletten A",
                        areas = {
                            {
                                corners = {
                                    vec3(-425.29, 1211.07, 327.37),
                                    vec3(-429.49, 1212.19, 327.47),
                                    vec3(-429.45, 1212.18, 324.89),
                                    vec3(-425.25, 1211.06, 324.84),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.1,
                                flipped = true,
                            },
                            {
                                corners = {
                                    vec3(-425.82, 1208.74, 327.82),
                                    vec3(-425.21, 1211.07, 327.85),
                                    vec3(-425.21, 1211.08, 324.84),
                                    vec3(-425.82, 1208.79, 324.84),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.1,
                                flipped = true,
                            },
                            {
                                corners = {
                                    vec3(-424.57, 1212.60, 324.77),
                                    vec3(-429.36, 1213.92, 324.77),
                                    vec3(-429.82, 1212.40, 324.77),
                                    vec3(-425.07, 1211.17, 324.77),
                                },
                                edgeFadeout = 0.25,
                                opacityMultiplier = 1.1,
                            },
                        },
                    },
                    {
                        name = "Toiletten B",
                        areas = {
                            {
                                corners = {
                                    vec3(-427.79, 1218.01, 327.27),
                                    vec3(-423.81, 1216.96, 327.24),
                                    vec3(-423.83, 1216.96, 324.83),
                                    vec3(-427.84, 1218.02, 324.82),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.1,
                                flipped = true,
                            },
                            {
                                corners = {
                                    vec3(-423.14, 1219.52, 328.12),
                                    vec3(-422.84, 1220.64, 327.99),
                                    vec3(-422.83, 1220.68, 324.92),
                                    vec3(-423.15, 1219.49, 324.92),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.1,
                                flipped = true,
                            },
                            {
                                corners = {
                                    vec3(-423.80, 1223.66, 326.97),
                                    vec3(-426.28, 1224.31, 327.02),
                                    vec3(-426.27, 1224.31, 324.89),
                                    vec3(-423.75, 1223.64, 324.91),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.1,
                                flipped = true,
                            },
                        },
                    },
                }
            },

        }
    },
    {
        name = "De Gentry Manor klus",
        description = "Voer een premium opdracht uit voor Gentry Manor. Nog nooit van gehoord? Ik ook niet. Ze zijn veeleisend, maar betalen erg goed.",
        reward = 10000,
        minPlayers = 1,
        maxPlayers = 4,
        locations = {
            {
                name = "Gentry Manor",
                coords = vec3(-33.73, 337.27, 112.94),
                spots = {
                    {
                        name = "Terras",
                        areas = {
                            {
                                corners = {
                                    vec3(-33.73, 337.27, 112.94),
                                    vec3(-30.84, 344.94, 112.93),
                                    vec3(-38.62, 345.70, 112.96),
                                    vec3(-41.01, 340.43, 112.90),
                                },
                                edgeFadeout = 0.25,
                                opacityMultiplier = 1.1,
                                cleaningMultiplier = 1.1,
                            },
                            {
                                corners = {
                                    vec3(-40.81, 346.91, 112.92),
                                    vec3(-37.90, 345.42, 112.94),
                                    vec3(-35.39, 347.35, 112.93),
                                    vec3(-39.27, 349.29, 112.92),
                                },
                                edgeFadeout = 0.35,
                                opacityMultiplier = 1.1,
                            },
                        },
                    },
                    {
                        name = "Zwembadgedeelte",
                        areas = {
                            {
                                corners = {
                                    vec3(-10.31, 322.84, 112.18),
                                    vec3(-12.75, 330.07, 112.17),
                                    vec3(-22.34, 327.13, 112.17),
                                    vec3(-19.95, 319.52, 112.18),
                                },
                                edgeFadeout = 0.35,
                                opacityMultiplier = 1.1,
                                cleaningMultiplier = 1.15,
                            },
                            {
                                corners = {
                                    vec3(-0.74, 344.85, 112.17),
                                    vec3(-6.04, 347.50, 112.17),
                                    vec3(-13.23, 332.38, 112.17),
                                    vec3(-8.03, 329.10, 112.17),
                                },
                                edgeFadeout = 0.45,
                                cleaningMultiplier = 1.15,
                            },
                            {
                                corners = {
                                    vec3(-23.93, 323.18, 112.17),
                                    vec3(-21.88, 326.86, 112.17),
                                    vec3(-28.71, 330.83, 112.17),
                                    vec3(-31.22, 326.63, 112.17),
                                },
                                edgeFadeout = 0.35,
                                cleaningMultiplier = 1.15,
                            },
                        },
                    },
                }
            },

            {
                name = "Appartementen",
                coords = vec3(9.92, 309.63, 112.17),
                spots = {
                    {
                        name = "Appartemententuin",
                        areas = {
                            {
                                corners = {
                                    vec3(9.89, 309.63, 112.44),
                                    vec3(9.94, 309.62, 110.15),
                                    vec3(7.07, 310.96, 110.17),
                                    vec3(7.13, 310.93, 112.25),
                                },
                                edgeFadeout = 0.25,
                                cleaningMultiplier = 1.1,
                                dirtColor = {23, 31, 22},
                            },
                            {
                                corners = {
                                    vec3(14.65, 320.11, 109.93),
                                    vec3(11.01, 312.66, 109.93),
                                    vec3(13.53, 311.78, 109.93),
                                    vec3(16.86, 319.14, 109.93),
                                },
                                edgeFadeout = 0.25,
                                cleaningMultiplier = 1.1,
                                dirtColor = {23, 31, 22},
                                completionThreshold = 89,
                            },
                            {
                                corners = {
                                    vec3(2.78, 301.69, 109.93),
                                    vec3(5.09, 306.69, 109.93),
                                    vec3(3.35, 307.27, 109.93),
                                    vec3(0.82, 302.21, 109.93),
                                },
                                edgeFadeout = 0.25,
                                cleaningMultiplier = 1.1,
                                dirtColor = {23, 31, 22},
                                completionThreshold = 89,
                            },
                            {
                                corners = {
                                    vec3(13.67, 329.61, 109.93),
                                    vec3(13.77, 328.63, 109.93),
                                    vec3(14.55, 327.88, 109.93),
                                    vec3(14.99, 329.85, 109.93),
                                },
                                edgeFadeout = 0.45,
                                dirtColor = {33, 25, 18},
                                completionThreshold = 89,
                            },
                        },
                    },
                    {
                        name = "Appartementen",
                        areas = {
                            {
                                corners = {
                                    vec3(7.90, 321.39, 113.80),
                                    vec3(12.69, 331.64, 113.72),
                                    vec3(12.73, 331.73, 110.12),
                                    vec3(7.92, 321.45, 111.12),
                                },
                                edgeFadeout = 0.25,
                                dirtColor = {23, 31, 22},
                                flipped = true,
                                completionThreshold = 89,
                            },
                            {
                                corners = {
                                    vec3(19.76, 321.21, 113.40),
                                    vec3(15.94, 313.01, 113.71),
                                    vec3(15.94, 313.02, 111.13),
                                    vec3(19.82, 321.33, 111.25),
                                },
                                edgeFadeout = 0.25,
                                dirtColor = {23, 31, 22},
                                flipped = true,
                                completionThreshold = 89,
                            },
                            {
                                corners = {
                                    vec3(7.87, 295.80, 113.95),
                                    vec3(7.26, 294.50, 114.08),
                                    vec3(7.26, 294.51, 111.05),
                                    vec3(7.87, 295.79, 111.03),
                                },
                                edgeFadeout = 0.25,
                                dirtColor = {23, 31, 22},
                                flipped = true,
                                completionThreshold = 89,
                            },
                        },
                    },
                }
            },

        }
    },
    {
        name = "Rijke mensen garageproblemen",
        description = "Was meerdere garagedeuren in de Vinewood Hills omgeving.",
        reward = 5750,
        minPlayers = 1,
        maxPlayers = 2,
        locations = {
            {
                name = "Huis",
                coords = vec3(68.73, 455.04, 148.22),
                spots = {
                    {
                        name = "Garagedeur",
                        areas = {
                            {
                                corners = {
                                    vec3(68.73, 455.04, 148.22),
                                    vec3(68.76, 455.07, 146.07),
                                    vec3(64.31, 451.51, 145.90),
                                    vec3(64.33, 451.52, 148.20),
                                },
                                edgeFadeout = 0.25,
                                opacityMultiplier = 1.3,
                                dirtColor = {21, 23, 20},
                            },
                        },
                    },
                }
            },
            {
                name = "Huis",
                coords = vec3(3.35, 464.63, 147.64),
                spots = {
                    {
                        name = "Garagedeur",
                        areas = {
                            {
                                corners = {
                                    vec3(3.35, 464.63, 147.64),
                                    vec3(3.35, 464.63, 145.21),
                                    vec3(-3.82, 467.00, 145.19),
                                    vec3(-3.75, 466.97, 147.53),
                                },
                                edgeFadeout = 0.25,
                                opacityMultiplier = 1.3,
                                dirtColor = {21, 23, 20},
                            },
                        },
                    },
                }
            },
            {
                name = "Huis",
                coords = vec3(-126.74, 506.68, 142.64),
                spots = {
                    {
                        name = "Garagedeur",
                        areas = {
                            {
                                corners = {
                                    vec3(-120.51, 505.47, 145.24),
                                    vec3(-120.50, 505.47, 142.64),
                                    vec3(-126.74, 506.68, 142.64),
                                    vec3(-126.82, 506.70, 145.27),
                                },
                                edgeFadeout = 0.25,
                                opacityMultiplier = 1.3,
                                dirtColor = {21, 23, 20},
                            },
                        },
                    },
                }
            },
            {
                name = "Huis",
                coords = vec3(-241.25, 491.57, 125.65),
                spots = {
                    {
                        name = "Garagedeur",
                        areas = {
                            {
                                corners = {
                                    vec3(-241.27, 491.56, 128.42),
                                    vec3(-241.25, 491.57, 125.65),
                                    vec3(-249.04, 488.15, 125.64),
                                    vec3(-249.10, 488.13, 128.45),
                                },
                                edgeFadeout = 0.25,
                                opacityMultiplier = 1.3,
                                dirtColor = {21, 23, 20},
                            },
                        },
                    },
                }
            },
            {
                name = "Huis",
                coords = vec3(-437.47, 539.43, 124.11),
                spots = {
                    {
                        name = "Garagedeur",
                        areas = {
                            {
                                corners = {
                                    vec3(-437.47, 539.43, 124.11),
                                    vec3(-437.56, 539.46, 121.36),
                                    vec3(-443.65, 541.70, 121.31),
                                    vec3(-443.65, 541.70, 124.02),
                                },
                                edgeFadeout = 0.25,
                                opacityMultiplier = 1.3,
                                dirtColor = {21, 23, 20},
                            },
                        },
                    },
                }
            },
            {
                name = "Huis",
                coords = vec3(-473.79, 602.57, 129.55),
                spots = {
                    {
                        name = "Garagedeur",
                        areas = {
                            {
                                corners = {
                                    vec3(-473.79, 602.57, 129.55),
                                    vec3(-473.79, 602.57, 126.93),
                                    vec3(-473.73, 595.90, 126.95),
                                    vec3(-473.73, 595.76, 129.63),
                                },
                                edgeFadeout = 0.25,
                                opacityMultiplier = 1.3,
                                dirtColor = {21, 23, 20},
                            },
                        },
                    },
                }
            },
        }
    },
    {
        name = "Kronkelende garages",
        description = "Was een paar garagedeuren in de Vinewood Hills omgeving.",
        reward = 5500,
        minPlayers = 1,
        maxPlayers = 2,
        locations = {
            {
                name = "Huis",
                coords = vec3(-341.98, 666.65, 168.33),
                spots = {
                    {
                        name = "Garagedeur",
                        areas = {
                            {
                                corners = {
                                    vec3(-347.09, 667.59, 170.43),
                                    vec3(-347.07, 667.59, 168.26),
                                    vec3(-341.98, 666.65, 168.33),
                                    vec3(-342.00, 666.65, 170.37),
                                },
                                edgeFadeout = 0.25,
                                opacityMultiplier = 1.3,
                                dirtColor = {21, 23, 20},
                            },
                        },
                    },
                }
            },
            {
                name = "Huis",
                coords = vec3(-242.71, 616.84, 190.01),
                spots = {
                    {
                        name = "Garagedeur",
                        areas = {
                            {
                                corners = {
                                    vec3(-242.71, 616.84, 190.01),
                                    vec3(-242.73, 616.87, 186.87),
                                    vec3(-237.91, 609.37, 186.89),
                                    vec3(-237.88, 609.33, 189.98),
                                },
                                edgeFadeout = 0.25,
                                opacityMultiplier = 1.3,
                                dirtColor = {21, 23, 20},
                            },
                        },
                    },
                }
            },
            {
                name = "Huis",
                coords = vec3(222.40, 757.58, 203.93),
                spots = {
                    {
                        name = "Garagedeur",
                        areas = {
                            {
                                corners = {
                                    vec3(222.39, 757.55, 206.49),
                                    vec3(222.40, 757.58, 203.93),
                                    vec3(219.66, 752.96, 203.96),
                                    vec3(219.65, 752.94, 206.46),
                                },
                                edgeFadeout = 0.25,
                                opacityMultiplier = 1.3,
                                dirtColor = {21, 23, 20},
                            },
                        },
                    },
                }
            },
            {
                name = "Huis",
                coords = vec3(-550.01, 825.77, 196.57),
                spots = {
                    {
                        name = "Garagedeur",
                        areas = {
                            {
                                corners = {
                                    vec3(-550.01, 825.77, 199.25),
                                    vec3(-550.01, 825.77, 196.57),
                                    vec3(-556.07, 827.70, 196.61),
                                    vec3(-556.13, 827.72, 199.22),
                                },
                                edgeFadeout = 0.25,
                                opacityMultiplier = 1.3,
                                dirtColor = {21, 23, 20},
                            },
                        },
                    },
                }
            },
            {
                name = "Huis",
                coords = vec3(-515.91, 692.02, 150.38),
                spots = {
                    {
                        name = "Garagedeur",
                        areas = {
                            {
                                corners = {
                                    vec3(-516.31, 697.25, 152.53),
                                    vec3(-516.31, 697.29, 150.61),
                                    vec3(-515.81, 692.16, 150.55),
                                    vec3(-515.81, 692.17, 152.60),
                                },
                                edgeFadeout = 0.25,
                                opacityMultiplier = 1.3,
                                dirtColor = {21, 23, 20},
                            },
                        },
                    },
                }
            },
        }
    },
    {
        name = "Driedubbele garage",
        description = "Was 3 garages voor een rijke huisbaas die 3 panden in dezelfde straat bezit.",
        reward = 4250,
        minPlayers = 1,
        maxPlayers = 2,
        locations = {
            {
                name = "Huis",
                coords = vec3(-570.59, 395.70, 102.54),
                spots = {
                    {
                        name = "Garagedeur",
                        areas = {
                            {
                                corners = {
                                    vec3(-570.59, 395.70, 102.54),
                                    vec3(-570.54, 395.72, 99.76),
                                    vec3(-577.40, 393.13, 99.78),
                                    vec3(-577.43, 393.12, 102.54),
                                },
                                edgeFadeout = 0.25,
                                opacityMultiplier = 1.3,
                                dirtColor = {21, 23, 20},
                            },
                        },
                    },
                }
            },
            {
                name = "Huis",
                coords = vec3(-600.72, 393.44, 101.00),
                spots = {
                    {
                        name = "Garagedeur",
                        areas = {
                            {
                                corners = {
                                    vec3(-600.69, 393.44, 103.23),
                                    vec3(-600.72, 393.44, 101.00),
                                    vec3(-607.15, 392.94, 101.01),
                                    vec3(-607.13, 392.95, 103.21),
                                },
                                edgeFadeout = 0.25,
                                opacityMultiplier = 1.3,
                                dirtColor = {21, 23, 20},
                            },
                        },
                    },
                }
            },
            {
                name = "Huis",
                coords = vec3(-570.59, 395.70, 102.54),
                spots = {
                    {
                        name = "Garagedeur",
                        areas = {
                            {
                                corners = {
                                    vec3(-624.75, 397.23, 103.98),
                                    vec3(-624.77, 397.23, 100.35),
                                    vec3(-631.44, 396.99, 100.37),
                                    vec3(-631.51, 396.99, 103.93),
                                },
                                edgeFadeout = 0.25,
                                opacityMultiplier = 1.3,
                                dirtColor = {21, 23, 20},
                            },
                        },
                    },
                }
            },
        }
    },
    {
        name = "Nieuw in de stad",
        description = "Maak een pand schoon van een nieuwe miljardair die zojuist een nieuw huis in Vinewood heeft gekocht.",
        reward = 8000,
        minPlayers = 1,
        maxPlayers = 4,
        locations = {
            {
                name = "Villa",
                coords = vec3(-729.86, 442.27, 108.63),
                spots = {
                    {
                        name = "Garagedeur",
                        areas = {
                            {
                                corners = {
                                    vec3(-729.86, 442.30, 108.63),
                                    vec3(-729.89, 442.28, 106.00),
                                    vec3(-738.13, 438.45, 106.01),
                                    vec3(-738.17, 438.43, 108.60),
                                },
                                edgeFadeout = 0.25,
                                opacityMultiplier = 1.3,
                                dirtColor = {21, 23, 20},
                            },
                        },
                    },
                    {
                        name = "Voormuren",
                        areas = {
                            {
                                corners = {
                                    vec3(-721.93, 448.79, 110.92),
                                    vec3(-721.82, 448.83, 105.98),
                                    vec3(-725.15, 447.28, 106.03),
                                    vec3(-725.18, 447.26, 111.32),
                                },
                                edgeFadeout = 0.25,
                                dirtColor = {21, 23, 20},
                            },
                            {
                                corners = {
                                    vec3(-712.15, 453.35, 110.96),
                                    vec3(-712.15, 453.35, 106.09),
                                    vec3(-715.27, 451.89, 106.11),
                                    vec3(-715.27, 451.89, 111.17),
                                },
                                edgeFadeout = 0.25,
                                dirtColor = {21, 23, 20},
                            },
                        },
                    },
                    {
                        name = "Looppad",
                        areas = {
                            {
                                corners = {
                                    vec3(-696.65, 463.76, 105.92),
                                    vec3(-726.22, 449.96, 105.92),
                                    vec3(-725.31, 447.63, 105.92),
                                    vec3(-695.39, 461.61, 105.92),
                                },
                                edgeFadeout = 0.25,
                                dirtColor = {21, 23, 20},
                                cleaningMultiplier = 1.25,
                            },
                            {
                                corners = {
                                    vec3(-716.78, 449.26, 105.92),
                                    vec3(-717.77, 451.51, 105.92),
                                    vec3(-719.83, 450.66, 105.92),
                                    vec3(-718.92, 448.31, 105.92),
                                },
                                edgeFadeout = 0.35,
                                dirtColor = {21, 23, 20},
                                cleaningMultiplier = 1.4,
                            },
                        },
                    },
                }
            },
            {
                name = "Zwembadgedeelte",
                coords = vec3(-693.23, 421.47, 105.91),
                spots = {
                    {
                        name = "Betonnen terras",
                        areas = {
                            {
                                corners = {
                                    vec3(-693.23, 421.47, 105.91),
                                    vec3(-695.49, 426.88, 105.91),
                                    vec3(-709.78, 420.44, 105.91),
                                    vec3(-707.21, 414.84, 105.91),
                                },
                                edgeFadeout = 0.25,
                                opacityMultiplier = 1,
                                dirtColor = {21, 23, 20},
                            },
                        },
                    },
                    {
                        name = "Achtermuren",
                        areas = {
                            {
                                corners = {
                                    vec3(-707.87, 441.79, 108.91),
                                    vec3(-707.82, 441.82, 106.07),
                                    vec3(-702.91, 444.11, 106.11),
                                    vec3(-702.86, 444.13, 108.88),
                                },
                                edgeFadeout = 0.25,
                                dirtColor = {21, 23, 20},
                            },
                            {
                                corners = {
                                    vec3(-718.15, 436.99, 108.86),
                                    vec3(-718.15, 437.00, 106.04),
                                    vec3(-713.26, 439.28, 106.04),
                                    vec3(-713.27, 439.27, 108.82),
                                },
                                edgeFadeout = 0.25,
                                dirtColor = {21, 23, 20},
                            },
                        },
                    },
                }
            },
        }
    },
    {
        name = "Zwembadklus A",
        description = "Standaard klus voor het reinigen van zwembadtegels.",
        reward = 5000,
        minPlayers = 1,
        maxPlayers = 4,
        locations = {
            {
                name = "Villa",
                coords = vec3(-914.52, 510.67, 91.34),
                spots = {
                    {
                        name = "zwembadtegels",
                        areas = {
                            {
                                corners = {
                                    vec3(-914.52, 510.67, 91.34),
                                    vec3(-903.53, 513.46, 91.34),
                                    vec3(-904.37, 516.50, 91.34),
                                    vec3(-915.21, 513.53, 91.34),
                                },
                                edgeFadeout = 0.25,
                                opacityMultiplier = 1.1,
                                dirtColor = {21, 23, 20},
                            },
                            {
                                corners = {
                                    vec3(-911.60, 499.19, 91.34),
                                    vec3(-900.54, 502.21, 91.34),
                                    vec3(-901.29, 504.93, 91.34),
                                    vec3(-912.29, 502.04, 91.34),
                                },
                                edgeFadeout = 0.25,
                                opacityMultiplier = 1.1,
                                dirtColor = {21, 23, 20},
                            },
                            {
                                corners = {
                                    vec3(-901.23, 504.65, 91.34),
                                    vec3(-903.63, 513.66, 91.34),
                                    vec3(-905.61, 513.18, 91.34),
                                    vec3(-903.09, 504.14, 91.34),
                                },
                                edgeFadeout = 0.25,
                                opacityMultiplier = 1.1,
                                dirtColor = {21, 23, 20},
                            },
                            {
                                corners = {
                                    vec3(-909.47, 502.53, 91.34),
                                    vec3(-912.06, 511.83, 91.34),
                                    vec3(-914.74, 510.80, 91.34),
                                    vec3(-912.27, 501.85, 91.34),
                                },
                                edgeFadeout = 0.25,
                                opacityMultiplier = 1.1,
                                dirtColor = {21, 23, 20},
                            },
                        },
                    },
                }
            },
        }
    },
    {
        name = "Zwembadklus B",
        description = "Standaard klus voor het reinigen van zwembadtegels.",
        reward = 5000,
        minPlayers = 1,
        maxPlayers = 4,
        locations = {
            {
                name = "Villa",
                coords = vec3(-757.79, 477.71, 106.49),
                spots = {
                    {
                        name = "Zwembadterras",
                        areas = {
                            {
                                corners = {
                                    vec3(-757.79, 477.71, 106.49),
                                    vec3(-746.00, 483.14, 106.50),
                                    vec3(-746.93, 485.21, 106.49),
                                    vec3(-758.81, 479.73, 106.50),
                                },
                                edgeFadeout = 0.25,
                                opacityMultiplier = 1.1,
                                dirtColor = {21, 23, 20},
                            },
                            {
                                corners = {
                                    vec3(-766.11, 495.99, 106.49),
                                    vec3(-754.58, 501.54, 106.49),
                                    vec3(-755.58, 503.51, 106.49),
                                    vec3(-767.32, 498.12, 106.49),
                                },
                                edgeFadeout = 0.25,
                                opacityMultiplier = 1.1,
                                dirtColor = {21, 23, 20},
                            },
                            {
                                corners = {
                                    vec3(-756.69, 500.91, 106.49),
                                    vec3(-748.70, 484.52, 106.49),
                                    vec3(-746.60, 485.53, 106.50),
                                    vec3(-754.32, 501.79, 106.49),
                                },
                                edgeFadeout = 0.25,
                                opacityMultiplier = 1.1,
                                dirtColor = {21, 23, 20},
                            },
                            {
                                corners = {
                                    vec3(-756.58, 480.57, 106.49),
                                    vec3(-764.45, 497.12, 106.48),
                                    vec3(-766.44, 496.35, 106.49),
                                    vec3(-758.76, 479.73, 106.49),
                                },
                                edgeFadeout = 0.25,
                                opacityMultiplier = 1.1,
                                dirtColor = {21, 23, 20},
                            },
                        },
                    },
                }
            },
        }
    },
    {
        name = "Zwembadklus C",
        description = "Standaard klus voor het reinigen van zwembadtegels.",
        reward = 5000,
        minPlayers = 1,
        maxPlayers = 4,
        locations = {
            {
                name = "Villa",
                coords = vec3(-408.53, 631.76, 157.76),
                spots = {
                    {
                        name = "Zwembadterras",
                        areas = {
                            {
                                corners = {
                                    vec3(-408.53, 631.76, 157.76),
                                    vec3(-396.81, 631.85, 157.76),
                                    vec3(-396.74, 636.77, 157.82),
                                    vec3(-408.76, 635.98, 158.04),
                                },
                                edgeFadeout = 0.25,
                                opacityMultiplier = 1.1,
                                dirtColor = {21, 23, 20},
                            },
                            {
                                corners = {
                                    vec3(-399.95, 632.00, 157.76),
                                    vec3(-399.87, 624.51, 157.76),
                                    vec3(-396.47, 624.64, 157.76),
                                    vec3(-396.67, 632.26, 157.76),
                                },
                                edgeFadeout = 0.25,
                                opacityMultiplier = 1.1,
                                dirtColor = {21, 23, 20},
                            },
                            {
                                corners = {
                                    vec3(-396.49, 636.98, 158.09),
                                    vec3(-396.24, 624.51, 158.07),
                                    vec3(-391.79, 624.59, 158.06),
                                    vec3(-392.14, 637.02, 158.09),
                                },
                                edgeFadeout = 0.25,
                                opacityMultiplier = 1.1,
                                dirtColor = {21, 23, 20},
                            },
                        },
                    },
                }
            },
        }
    },
    {
        name = "Zwembadklus D",
        description = "Standaard klus voor het reinigen van zwembadtegels.",
        reward = 5000,
        minPlayers = 1,
        maxPlayers = 4,
        locations = {
            {
                name = "Villa",
                coords = vec3(-223.50, 571.46, 184.69),
                spots = {
                    {
                        name = "Zwembadterras",
                        areas = {
                            {
                                corners = {
                                    vec3(-223.50, 571.46, 184.69),
                                    vec3(-227.71, 571.55, 184.68),
                                    vec3(-227.97, 560.25, 184.69),
                                    vec3(-223.82, 560.00, 184.69),
                                },
                                edgeFadeout = 0.25,
                                opacityMultiplier = 1.1,
                                dirtColor = {21, 23, 20},
                            },
                            {
                                corners = {
                                    vec3(-249.06, 572.72, 184.67),
                                    vec3(-227.78, 571.65, 184.73),
                                    vec3(-227.74, 574.86, 184.67),
                                    vec3(-248.98, 575.41, 184.75),
                                },
                                edgeFadeout = 0.25,
                                opacityMultiplier = 1.1,
                                dirtColor = {21, 23, 20},
                            },
                            {
                                corners = {
                                    vec3(-228.35, 571.53, 184.37),
                                    vec3(-239.07, 572.00, 184.37),
                                    vec3(-239.63, 570.53, 184.37),
                                    vec3(-229.06, 570.11, 184.37),
                                },
                                edgeFadeout = 0.25,
                                opacityMultiplier = 1.1,
                                dirtColor = {21, 23, 20},
                            },
                        },
                    },
                }
            },
        }
    },
    {
        name = "Zwembadklus E",
        description = "Standaard klus voor het reinigen van zwembadtegels.",
        reward = 5000,
        minPlayers = 1,
        maxPlayers = 4,
        locations = {
            {
                name = "Villa",
                coords = vec3(110.27, 436.44, 141.22),
                spots = {
                    {
                        name = "Zwembadterras",
                        areas = {
                            {
                                corners = {
                                    vec3(110.27, 436.44, 141.22),
                                    vec3(110.61, 446.05, 141.23),
                                    vec3(106.35, 445.85, 141.23),
                                    vec3(106.54, 436.59, 141.23),
                                },
                                edgeFadeout = 0.25,
                                opacityMultiplier = 1.1,
                                dirtColor = {21, 23, 20},
                            },
                            {
                                corners = {
                                    vec3(107.17, 445.33, 141.23),
                                    vec3(87.44, 444.70, 141.23),
                                    vec3(86.90, 442.13, 141.22),
                                    vec3(107.02, 441.99, 141.22),
                                },
                                edgeFadeout = 0.25,
                                opacityMultiplier = 1.1,
                                dirtColor = {21, 23, 20},
                            },
                            {
                                corners = {
                                    vec3(86.86, 442.66, 141.23),
                                    vec3(86.79, 436.28, 141.22),
                                    vec3(91.12, 436.31, 141.23),
                                    vec3(90.97, 442.58, 141.23),
                                },
                                edgeFadeout = 0.25,
                                opacityMultiplier = 1.1,
                                dirtColor = {21, 23, 20},
                            },
                        },
                    },
                }
            },
        }
    },
    {
        name = "Zwembadklus F",
        description = "Standaard klus voor het reinigen van zwembadtegels.",
        reward = 5000,
        minPlayers = 1,
        maxPlayers = 4,
        locations = {
            {
                name = "Villa",
                coords = vec3(232.41, 632.49, 184.83),
                spots = {
                    {
                        name = "Zwembadterras",
                        areas = {
                            {
                                corners = {
                                    vec3(232.41, 632.49, 184.84),
                                    vec3(243.41, 645.51, 184.84),
                                    vec3(242.02, 647.04, 184.84),
                                    vec3(231.10, 633.78, 184.84),
                                },
                                edgeFadeout = 0.25,
                                opacityMultiplier = 1.1,
                                dirtColor = {21, 23, 20},
                            },
                            {
                                corners = {
                                    vec3(249.35, 646.97, 184.83),
                                    vec3(246.23, 650.22, 184.83),
                                    vec3(241.92, 646.32, 184.83),
                                    vec3(245.93, 643.00, 184.83),
                                },
                                edgeFadeout = 0.25,
                                opacityMultiplier = 1.1,
                                dirtColor = {21, 23, 20},
                            },
                            {
                                corners = {
                                    vec3(246.95, 639.20, 184.83),
                                    vec3(236.37, 626.83, 184.84),
                                    vec3(237.93, 625.56, 184.84),
                                    vec3(248.34, 638.09, 184.83),
                                },
                                edgeFadeout = 0.25,
                                opacityMultiplier = 1.1,
                                dirtColor = {21, 23, 20},
                            },
                            {
                                corners = {
                                    vec3(237.91, 628.13, 184.84),
                                    vec3(232.26, 632.67, 184.83),
                                    vec3(231.13, 631.32, 184.84),
                                    vec3(236.61, 626.61, 184.84),
                                },
                                edgeFadeout = 0.25,
                                opacityMultiplier = 1.1,
                                dirtColor = {21, 23, 20},
                            },
                        },
                    },
                }
            },
        }
    },
    {
        name = "Zwembadklus G",
        description = "Standaard klus voor het reinigen van zwembadtegels.",
        reward = 5000,
        minPlayers = 1,
        maxPlayers = 4,
        locations = {
            {
                name = "Villa",
                coords = vec3(-820.45, 788.57, 201.20),
                spots = {
                    {
                        name = "Zwembadterras",
                        areas = {
                            {
                                corners = {
                                    vec3(-820.45, 788.57, 201.20),
                                    vec3(-811.96, 792.31, 201.21),
                                    vec3(-813.80, 795.25, 201.20),
                                    vec3(-821.15, 792.65, 201.20),
                                },
                                edgeFadeout = 0.25,
                                opacityMultiplier = 1.1,
                                dirtColor = {21, 23, 20},
                            },
                            {
                                corners = {
                                    vec3(-813.60, 791.90, 201.20),
                                    vec3(-808.04, 777.82, 201.20),
                                    vec3(-806.64, 778.43, 201.22),
                                    vec3(-811.96, 792.51, 201.20),
                                },
                                edgeFadeout = 0.25,
                                opacityMultiplier = 1.1,
                                dirtColor = {21, 23, 20},
                            },
                            {
                                corners = {
                                    vec3(-809.39, 781.45, 201.20),
                                    vec3(-815.74, 779.14, 201.20),
                                    vec3(-814.48, 775.36, 201.20),
                                    vec3(-808.17, 777.73, 201.20),
                                },
                                edgeFadeout = 0.25,
                                opacityMultiplier = 1.1,
                                dirtColor = {21, 23, 20},
                            },
                            {
                                corners = {
                                    vec3(-820.84, 789.25, 201.20),
                                    vec3(-815.94, 776.49, 201.20),
                                    vec3(-814.33, 776.88, 201.20),
                                    vec3(-819.20, 789.76, 201.20),
                                },
                                edgeFadeout = 0.25,
                                opacityMultiplier = 1.1,
                                dirtColor = {21, 23, 20},
                            },
                        },
                    },
                }
            },
        }
    },
    {
        name = "Zwembadklus H",
        description = "Standaard klus voor het reinigen van zwembadtegels.",
        reward = 5000,
        minPlayers = 1,
        maxPlayers = 4,
        locations = {
            {
                name = "Villa",
                coords = vec3(-1912.00, 436.88, 101.60),
                spots = {
                    {
                        name = "Zwembadterras",
                        areas = {
                            {
                                corners = {
                                    vec3(-1912.00, 436.88, 101.60),
                                    vec3(-1926.25, 434.98, 101.59),
                                    vec3(-1924.91, 426.07, 101.71),
                                    vec3(-1910.73, 428.21, 101.60),
                                },
                                edgeFadeout = 0.25,
                                opacityMultiplier = 1.1,
                                dirtColor = {21, 23, 20},
                            },
                            {
                                corners = {
                                    vec3(-1924.10, 435.90, 101.39),
                                    vec3(-1927.44, 458.38, 101.39),
                                    vec3(-1929.45, 458.04, 101.39),
                                    vec3(-1926.18, 435.63, 101.39),
                                },
                                edgeFadeout = 0.25,
                                opacityMultiplier = 1.1,
                                dirtColor = {21, 23, 20},
                            },
                            {
                                corners = {
                                    vec3(-1929.44, 449.50, 101.39),
                                    vec3(-1927.81, 449.54, 101.39),
                                    vec3(-1928.91, 457.44, 101.39),
                                    vec3(-1930.57, 457.03, 101.39),
                                },
                                edgeFadeout = 0.25,
                                opacityMultiplier = 1.1,
                                dirtColor = {21, 23, 20},
                            },
                            {
                                corners = {
                                    vec3(-1927.31, 455.73, 101.39),
                                    vec3(-1922.08, 458.89, 101.39),
                                    vec3(-1922.93, 460.11, 101.41),
                                    vec3(-1927.93, 458.00, 101.39),
                                },
                                edgeFadeout = 0.25,
                                opacityMultiplier = 1.1,
                                dirtColor = {21, 23, 20},
                            },
                        },
                    },
                }
            },
        }
    },
    {
        name = "Opulentie",
        description = "We hebben een contract binnengehaald bij een van de grootste Vinewood-villa's. Deze moet perfect worden uitgevoerd. Vooral de tennisbaan.",
        reward = 13000,
        minPlayers = 1,
        maxPlayers = 4,
        locations = {
            {
                name = "Villa",
                coords = vec3(-111.31, 973.84, 234.76),
                spots = {
                    {
                        name = "Ontspanningsruimte",
                        areas = {
                            {
                                corners = {
                                    vec3(-63.91, 976.01, 231.89),
                                    vec3(-61.09, 964.15, 231.89),
                                    vec3(-50.90, 965.22, 231.88),
                                    vec3(-53.99, 979.10, 231.89),
                                },
                                edgeFadeout = 0.25,
                                opacityMultiplier = 1.1,
                                cleaningMultiplier = 1.1,
                                dirtColor = {21, 23, 20},
                            },
                        },
                    },
                    {
                        name = "Bargedeelte",
                        areas = {
                            {
                                corners = {
                                    vec3(-80.96, 933.30, 232.04),
                                    vec3(-72.92, 931.81, 232.04),
                                    vec3(-72.02, 937.37, 232.03),
                                    vec3(-79.99, 938.92, 232.04),
                                },
                                edgeFadeout = 0.25,
                                opacityMultiplier = 1.1,
                                dirtColor = {21, 23, 20},
                                cleaningMultiplier = 1.2,
                            },
                        },
                    },
                    {
                        name = "Tennisbaan",
                        areas = {
                            {
                                corners = {
                                    vec3(-55.56, 937.66, 231.18),
                                    vec3(-31.79, 935.53, 231.18),
                                    vec3(-30.75, 946.51, 231.18),
                                    vec3(-54.59, 948.64, 231.18),
                                },
                                edgeFadeout = 0.25,
                                opacityMultiplier = 1.1,
                                cleaningMultiplier = 1.2,
                                dirtColor = {21, 23, 20},
                            },
                        },
                    },
                    {
                        name = "Overwoekerde muren",
                        areas = {
                            {
                                corners = {
                                    vec3(-57.37, 919.39, 232.71),
                                    vec3(-57.44, 919.37, 229.46),
                                    vec3(-63.12, 918.15, 230.36),
                                    vec3(-62.69, 918.25, 233.17),
                                },
                                edgeFadeout = 0.35,
                                opacityMultiplier = 1.1,
                                cleaningMultiplier = 1.1,
                                dirtColor = {25, 31, 22},
                            },
                            {
                                corners = {
                                    vec3(-48.60, 921.28, 230.31),
                                    vec3(-48.61, 921.28, 226.85),
                                    vec3(-57.86, 919.28, 228.61),
                                    vec3(-57.53, 919.35, 230.79),
                                },
                                edgeFadeout = 0.35,
                                opacityMultiplier = 1.1,
                                cleaningMultiplier = 1.1,
                                dirtColor = {25, 31, 22},
                            },
                        },
                    },
                }
            },
        }
    },
    {
        name = "Laden in de vuiligheid",
        description = "Was een laadperron voor vrachtwagens bij een nabijgelegen magazijn.",
        reward = 2000,
        minPlayers = 1,
        maxPlayers = 2,
        locations = {
            {
                name = "Laadperron",
                coords = vec3(1004.05, -1531.34, 28.48),
                spots = {
                    {
                        name = "Laadperron",
                        areas = {
                            {
                                corners = {
                                    vec3(1004.05, -1531.34, 28.48),
                                    vec3(991.79, -1531.23, 29.84),
                                    vec3(991.84, -1535.26, 29.83),
                                    vec3(1004.13, -1535.26, 28.47),
                                },
                                edgeFadeout = 0.25,
                                opacityMultiplier = 1.1,
                                dirtColor = {21, 23, 20},
                            },
                        },
                    },
                }
            },
        }
    },
    {
        name = "Giftige lekkages",
        description = "Help een megabedrijf hun giftige lekkages op te ruimen. De autoriteiten hoeven niet te weten dat dit is gebeurd.",
        reward = 2000,
        minPlayers = 1,
        maxPlayers = 2,
        locations = {
            {
                name = "Giftige lekkage",
                coords = vec3(446.94, -2183.51, 4.93),
                spots = {
                    {
                        name = "Giftige lekkage",
                        areas = {
                            {
                                corners = {
                                    vec3(446.94, -2183.51, 4.93),
                                    vec3(445.79, -2186.08, 4.93),
                                    vec3(447.85, -2187.61, 4.93),
                                    vec3(449.86, -2184.85, 4.93),
                                },
                                edgeFadeout = 0.4,
                                opacityMultiplier = 1.2,
                                dirtColor = {44, 99, 40},
                            },
                            {
                                corners = {
                                    vec3(447.10, -2187.68, 4.93),
                                    vec3(445.95, -2187.74, 4.93),
                                    vec3(446.10, -2188.86, 4.93),
                                    vec3(447.33, -2188.71, 4.93),
                                },
                                edgeFadeout = 0.25,
                                opacityMultiplier = 1.1,
                                dirtColor = {44, 99, 40},
                            },
                            {
                                corners = {
                                    vec3(445.46, -2185.80, 4.93),
                                    vec3(444.48, -2186.11, 4.93),
                                    vec3(444.44, -2186.91, 4.93),
                                    vec3(445.64, -2186.70, 4.93),
                                },
                                edgeFadeout = 0.25,
                                opacityMultiplier = 1.1,
                                dirtColor = {44, 99, 40},
                            },
                        },
                    },
                }
            },
        }
    },
    {
        name = "Helikopteropslag",
        description = "Maak de hangardeur schoon voor Higgins Helitours.",
        reward = 2500,
        minPlayers = 1,
        maxPlayers = 2,
        locations = {
            {
                name = "Higgins Helitours Hangar",
                coords = vec3(-737.69, -1506.54, 7.97),
                spots = {
                    {
                        name = "Hangardeur",
                        areas = {
                            {
                                corners = {
                                    vec3(-737.69, -1506.54, 7.97),
                                    vec3(-737.83, -1506.59, 4.22),
                                    vec3(-746.52, -1510.26, 4.22),
                                    vec3(-746.54, -1510.27, 8.01),
                                },
                                edgeFadeout = 0.25,
                            },
                        },
                    },
                }
            },
        }
    },
    {
        name = "Vies marina",
        description = "Maak al het vuil weg bij de lokale marina. Probeer niet in het water te vallen.",
        reward = 7500,
        minPlayers = 1,
        maxPlayers = 4,
        locations = {
            {
                name = "Marina",
                coords = vec3(-869.36, -1492.38, 4.17),
                spots = {
                    {
                        name = "Marina",
                        areas = {
                            {
                                corners = {
                                    vec3(-872.02, -1474.10, 0.65),
                                    vec3(-861.15, -1503.93, 0.65),
                                    vec3(-859.09, -1503.16, 0.65),
                                    vec3(-869.86, -1473.35, 0.64),
                                },
                                edgeFadeout = 0.2,
                                dirtColor = {27, 33, 29},
                            },
                            {
                                corners = {
                                    vec3(-868.94, -1476.34, 0.65),
                                    vec3(-854.80, -1471.23, 0.65),
                                    vec3(-855.88, -1468.21, 0.65),
                                    vec3(-869.91, -1473.45, 0.64),
                                },
                                edgeFadeout = 0.2,
                                dirtColor = {27, 33, 29},
                            },
                            {
                                corners = {
                                    vec3(-865.85, -1484.91, 0.61),
                                    vec3(-851.64, -1479.69, 0.61),
                                    vec3(-852.26, -1478.04, 0.61),
                                    vec3(-866.38, -1483.22, 0.61),
                                },
                                edgeFadeout = 0.2,
                                dirtColor = {27, 33, 29},
                            },
                            {
                                corners = {
                                    vec3(-862.70, -1493.34, 0.61),
                                    vec3(-848.58, -1488.15, 0.61),
                                    vec3(-849.19, -1486.50, 0.61),
                                    vec3(-863.30, -1491.73, 0.61),
                                },
                                edgeFadeout = 0.2,
                                dirtColor = {27, 33, 29},
                            },
                            {
                                corners = {
                                    vec3(-859.20, -1503.09, 0.65),
                                    vec3(-845.12, -1497.95, 0.65),
                                    vec3(-846.20, -1495.06, 0.65),
                                    vec3(-860.28, -1500.19, 0.65),
                                },
                                edgeFadeout = 0.2,
                                dirtColor = {27, 33, 29},
                            },
                        },
                    },
                }
            },
        }
    },
    {
        name = "Smerige marina",
        description = "Maak al het vuil weg bij de lokale marina. Hopelijk val je er niet in.",
        reward = 8250,
        minPlayers = 1,
        maxPlayers = 4,
        locations = {
            {
                name = "Marina",
                coords = vec3(-894.96, -1425.20, 4.16),
                spots = {
                    {
                        name = "Marina",
                        areas = {
                            {
                                corners = {
                                    vec3(-888.72, -1424.28, 0.61),
                                    vec3(-902.67, -1385.95, 0.65),
                                    vec3(-904.80, -1386.74, 0.65),
                                    vec3(-890.85, -1425.07, 0.61),
                                },
                                edgeFadeout = 0.2,
                                dirtColor = {27, 33, 29},
                            },
                            {
                                corners = {
                                    vec3(-901.61, -1389.15, 0.65),
                                    vec3(-887.51, -1383.90, 0.65),
                                    vec3(-888.63, -1380.86, 0.65),
                                    vec3(-902.73, -1385.99, 0.65),
                                },
                                edgeFadeout = 0.2,
                                dirtColor = {27, 33, 29},
                            },
                            {
                                corners = {
                                    vec3(-898.48, -1397.65, 0.61),
                                    vec3(-884.36, -1392.39, 0.61),
                                    vec3(-885.00, -1390.61, 0.61),
                                    vec3(-899.20, -1395.73, 0.61),
                                },
                                edgeFadeout = 0.2,
                                dirtColor = {27, 33, 29},
                            },
                            {
                                corners = {
                                    vec3(-895.53, -1406.26, 0.61),
                                    vec3(-881.33, -1400.84, 0.61),
                                    vec3(-881.93, -1399.11, 0.61),
                                    vec3(-896.25, -1404.34, 0.61),
                                },
                                edgeFadeout = 0.2,
                                dirtColor = {27, 33, 29},
                            },
                            {
                                corners = {
                                    vec3(-892.37, -1414.56, 0.61),
                                    vec3(-878.28, -1409.28, 0.61),
                                    vec3(-878.88, -1407.59, 0.61),
                                    vec3(-893.06, -1412.69, 0.61),
                                },
                                edgeFadeout = 0.2,
                                dirtColor = {27, 33, 29},
                            },
                            {
                                corners = {
                                    vec3(-888.82, -1424.31, 0.61),
                                    vec3(-874.68, -1419.13, 0.61),
                                    vec3(-875.81, -1416.08, 0.61),
                                    vec3(-889.98, -1421.22, 0.61),
                                },
                                edgeFadeout = 0.2,
                                dirtColor = {27, 33, 29},
                            },
                        },
                    },
                }
            },
        }
    },
    {
        name = "Vuile oprit",
        description = "Maak een oprit schoon voor een maat van de baas van Dirty Hose.",
        reward = 3500,
        minPlayers = 1,
        maxPlayers = 2,
        locations = {
            {
                name = "Oprit",
                coords = vec3(331.98, -1752.74, 28.29),
                spots = {
                    {
                        name = "Oprit",
                        areas = {
                            {
                                corners = {
                                    vec3(309.87, -1736.77, 28.56),
                                    vec3(330.70, -1753.91, 28.24),
                                    vec3(333.05, -1751.26, 28.36),
                                    vec3(312.29, -1734.05, 28.56),
                                },
                                edgeFadeout = 0.2,
                            },
                        },
                    },
                }
            },
        }
    },
    {
        name = "Vies raftingsteiger",
        description = "Voer een grondige schoonmaak uit van een wildwater-raftingsteiger.",
        reward = 6500,
        minPlayers = 1,
        maxPlayers = 3,
        locations = {
            {
                name = "Steiger",
                coords = vec3(-1520.01, 1489.41, 110.66),
                spots = {
                    {
                        name = "Steiger",
                        areas = {
                            {
                                corners = {
                                    vec3(-1520.01, 1489.41, 110.66),
                                    vec3(-1518.47, 1496.82, 110.65),
                                    vec3(-1523.50, 1497.91, 110.63),
                                    vec3(-1525.33, 1490.84, 110.64),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.1,
                                dirtColor = {27, 33, 29},
                            },
                            {
                                corners = {
                                    vec3(-1514.85, 1524.71, 110.64),
                                    vec3(-1522.47, 1497.51, 110.66),
                                    vec3(-1519.74, 1496.76, 110.65),
                                    vec3(-1512.03, 1523.85, 110.64),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.1,
                                dirtColor = {27, 33, 29},
                            },
                        },
                    },
                }
            },
        }
    },
    {
        name = "Vissteiger",
        description = "Was een steiger voor een visser uit Blaine County.",
        reward = 9250,
        minPlayers = 1,
        maxPlayers = 3,
        locations = {
            {
                name = "Steiger",
                coords = vec3(714.67, 4157.04, 37.31),
                spots = {
                    {
                        name = "Steiger",
                        areas = {
                            {
                                corners = {
                                    vec3(712.75, 4153.45, 34.80),
                                    vec3(712.74, 4107.03, 34.80),
                                    vec3(715.62, 4107.04, 34.80),
                                    vec3(715.59, 4153.50, 34.80),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.1,
                                dirtColor = {27, 33, 29},
                            },
                            {
                                corners = {
                                    vec3(715.14, 4107.14, 34.80),
                                    vec3(712.80, 4106.95, 34.80),
                                    vec3(711.55, 4096.92, 34.81),
                                    vec3(715.08, 4096.94, 34.81),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.1,
                                dirtColor = {27, 33, 29},
                            },
                            {
                                corners = {
                                    vec3(715.39, 4092.15, 33.74),
                                    vec3(715.36, 4096.09, 33.74),
                                    vec3(711.55, 4096.26, 33.74),
                                    vec3(711.61, 4092.19, 33.74),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.1,
                                dirtColor = {27, 33, 29},
                            },
                        },
                    },
                }
            },
        }
    },
    {
        name = "Brug met uitzicht",
        description = "Maak een brug schoon bij de vuurtoren.",
        reward = 6750,
        minPlayers = 1,
        maxPlayers = 3,
        locations = {
            {
                name = "Brug",
                coords = vec3(3055.21, 5053.58, 24.65),
                spots = {
                    {
                        name = "Brug",
                        areas = {
                            {
                                corners = {
                                    vec3(3055.21, 5053.58, 24.65),
                                    vec3(3062.31, 5053.61, 24.65),
                                    vec3(3062.03, 5077.92, 23.98),
                                    vec3(3055.14, 5077.66, 23.92),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.1,
                                dirtColor = {27, 33, 29},
                            },
                        },
                    },
                }
            },
        }
    },
    {
        name = "Hookies poepies",
        description = "Maak de openbare toiletten bij de Hookies Bar schoon",
        reward = 6250,
        minPlayers = 1,
        maxPlayers = 3,
        locations = {
            {
                name = "Hookies",
                coords = vec3(-2184.75, 4250.11, 47.95),
                spots = {
                    {
                        name = "Vloer",
                        areas = {
                            {
                                corners = {
                                    vec3(-2184.75, 4250.11, 47.95),
                                    vec3(-2188.34, 4254.72, 47.95),
                                    vec3(-2191.16, 4252.53, 47.95),
                                    vec3(-2187.65, 4247.95, 47.95),
                                },
                                edgeFadeout = 0.2,
                            },
                            {
                                corners = {
                                    vec3(-2187.63, 4249.78, 47.96),
                                    vec3(-2187.68, 4250.21, 47.96),
                                    vec3(-2188.10, 4250.28, 47.96),
                                    vec3(-2188.09, 4249.84, 47.96),
                                },
                                edgeFadeout = 0.1,
                                opacityMultiplier = 1.7,
                                dirtColor = {61, 47, 28},
                            },
                        },
                    },
                    {
                        name = "Zijmuur",
                        areas = {
                            {
                                corners = {
                                    vec3(-2193.07, 4251.24, 50.41),
                                    vec3(-2193.08, 4251.27, 47.94),
                                    vec3(-2189.40, 4246.43, 47.95),
                                    vec3(-2189.42, 4246.46, 50.42),
                                },
                                edgeFadeout = 0.2,
                            },
                        },
                    },
                    {
                        name = "Voormuur",
                        areas = {
                            {
                                corners = {
                                    vec3(-2186.68, 4256.31, 50.58),
                                    vec3(-2186.69, 4256.28, 47.96),
                                    vec3(-2189.03, 4254.49, 47.97),
                                    vec3(-2189.04, 4254.52, 50.52),
                                },
                                edgeFadeout = 0.2,
                            },
                            {
                                corners = {
                                    vec3(-2190.76, 4253.21, 50.49),
                                    vec3(-2190.73, 4253.20, 47.98),
                                    vec3(-2193.03, 4251.45, 47.96),
                                    vec3(-2193.05, 4251.46, 50.52),
                                },
                                edgeFadeout = 0.2,
                            },
                            {
                                corners = {
                                    vec3(-2188.93, 4254.57, 50.41),
                                    vec3(-2188.93, 4254.57, 50.22),
                                    vec3(-2190.80, 4253.14, 50.18),
                                    vec3(-2190.80, 4253.15, 50.40),
                                },
                                edgeFadeout = 0.2,
                                completionThreshold = 70,
                            },
                        },
                    },
                }
            },
        }
    },
    {
        name = "Vespucci garage",
        description = "Was meerdere garagedeuren voor de gemeenschap",
        reward = 4000,
        minPlayers = 1,
        maxPlayers = 2,
        locations = {
            {
                name = "Garage",
                coords = vec3(-983.75, -1113.75, 3.73),
                spots = {
                    {
                        name = "Garagedeur",
                        areas = {
                            {
                                corners = {
                                    vec3(-983.75, -1113.75, 3.73),
                                    vec3(-983.76, -1113.75, 1.27),
                                    vec3(-988.11, -1116.26, 1.25),
                                    vec3(-988.11, -1116.26, 3.70),
                                },
                                edgeFadeout = 0.2,
                            },
                        },
                    },
                }
            },
            {
                name = "Garage",
                coords = vec3(-969.06, -1090.91, 3.66),
                spots = {
                    {
                        name = "Garagedeur",
                        areas = {
                            {
                                corners = {
                                    vec3(-969.06, -1090.91, 3.66),
                                    vec3(-969.07, -1090.91, 1.30),
                                    vec3(-964.83, -1088.47, 1.29),
                                    vec3(-964.84, -1088.48, 3.65),
                                },
                                edgeFadeout = 0.2,
                            },
                        },
                    },
                }
            },
            {
                name = "Garage",
                coords = vec3(-941.79, -1075.61, 3.64),
                spots = {
                    {
                        name = "Garagedeur",
                        areas = {
                            {
                                corners = {
                                    vec3(-941.79, -1075.61, 3.64),
                                    vec3(-941.78, -1075.61, 1.23),
                                    vec3(-935.26, -1071.85, 1.23),
                                    vec3(-935.22, -1071.82, 3.64),
                                },
                                edgeFadeout = 0.2,
                            },
                        },
                    },
                }
            },
            {
                name = "Garage",
                coords = vec3(-1124.53, -1071.21, 3.33),
                spots = {
                    {
                        name = "Linker garagedeur",
                        areas = {
                            {
                                corners = {
                                    vec3(-1124.53, -1071.21, 3.33),
                                    vec3(-1124.49, -1071.19, 1.27),
                                    vec3(-1127.10, -1072.69, 1.29),
                                    vec3(-1127.10, -1072.69, 3.28),
                                },
                                edgeFadeout = 0.2,
                            },
                        },
                    },
                    {
                        name = "Rechte garagedeur",
                        areas = {
                            {
                                corners = {
                                    vec3(-1127.70, -1073.04, 3.32),
                                    vec3(-1127.69, -1073.03, 1.26),
                                    vec3(-1130.30, -1074.54, 1.29),
                                    vec3(-1130.32, -1074.55, 3.29),
                                },
                                edgeFadeout = 0.2,
                            },
                        },
                    },
                }
            },
        }
    },
    {
        name = "Vespucci balkon",
        description = "Was meerdere garagedeuren voor de Vespucci Canals-gemeenschap.",
        reward = 3500,
        minPlayers = 1,
        maxPlayers = 2,
        locations = {
            {
                name = "Balkon",
                coords = vec3(-1243.83, -1238.62, 9.64),
                spots = {
                    {
                        name = "Balkon",
                        areas = {
                            {
                                corners = {
                                    vec3(-1243.83, -1238.62, 9.64),
                                    vec3(-1222.95, -1231.03, 9.64),
                                    vec3(-1224.46, -1227.15, 9.64),
                                    vec3(-1245.37, -1234.61, 9.64),
                                },
                                edgeFadeout = 0.2,
                            },
                        },
                    },
                }
            },
        }
    },
    {
        name = "Heilige parkeerplaats",
        description = "Was de VIP-parkeerplaats voor de Los Santos kerk.",
        reward = 4000,
        minPlayers = 1,
        maxPlayers = 2,
        locations = {
            {
                name = "Kerk",
                coords = vec3(-1679.69, -293.53, 50.83),
                spots = {
                    {
                        name = "Parkeerplaats",
                        areas = {
                            {
                                corners = {
                                    vec3(-1679.69, -293.53, 50.83),
                                    vec3(-1683.82, -298.40, 50.82),
                                    vec3(-1673.11, -306.29, 50.83),
                                    vec3(-1669.10, -301.08, 50.82),
                                },
                                edgeFadeout = 0.2,
                            },
                        },
                    },
                }
            },
        }
    },
    {
        name = "Onhygiënische universiteit",
        description = "Maak meerdere locaties bij de ULSA schoon.",
        reward = 7250,
        minPlayers = 1,
        maxPlayers = 4,
        locations = {
            {
                name = "Universiteit",
                coords = vec3(-1633.56, 175.47, 60.77),
                spots = {
                    {
                        name = "Trap",
                        areas = {
                            {
                                corners = {
                                    vec3(-1633.56, 175.47, 60.77),
                                    vec3(-1631.19, 176.68, 60.77),
                                    vec3(-1636.28, 187.59, 60.77),
                                    vec3(-1638.70, 186.34, 60.77),
                                },
                                edgeFadeout = 0.2,
                            },
                            {
                                corners = {
                                    vec3(-1629.74, 176.10, 60.31),
                                    vec3(-1628.30, 176.73, 60.31),
                                    vec3(-1634.34, 189.68, 60.31),
                                    vec3(-1635.81, 188.99, 60.32),
                                },
                                edgeFadeout = 0.2,
                            },
                        },
                    },
                }
            },
            {
                name = "Baan",
                coords = vec3(-1716.29, 141.13, 64.06),
                spots = {
                    {
                        name = "Landing pit",
                        areas = {
                            {
                                corners = {
                                    vec3(-1716.29, 141.13, 64.06),
                                    vec3(-1714.40, 138.43, 64.06),
                                    vec3(-1710.55, 141.19, 64.05),
                                    vec3(-1712.41, 143.81, 64.06),
                                },
                                edgeFadeout = 0.2,
                                cleaningMultiplier = 1.3,
                            },
                        },
                    },
                    {
                        name = "Landing pit",
                        areas = {
                            {
                                corners = {
                                    vec3(-1739.90, 205.30, 64.06),
                                    vec3(-1737.42, 201.75, 64.05),
                                    vec3(-1733.55, 204.46, 64.05),
                                    vec3(-1736.03, 208.04, 64.06),
                                },
                                edgeFadeout = 0.2,
                                cleaningMultiplier = 1.3,
                            },
                        },
                    },
                    {
                        name = "Landing pit",
                        areas = {
                            {
                                corners = {
                                    vec3(-1767.88, 165.12, 64.05),
                                    vec3(-1765.36, 161.54, 64.05),
                                    vec3(-1761.54, 164.23, 64.05),
                                    vec3(-1764.02, 167.77, 64.05),
                                },
                                edgeFadeout = 0.2,
                                cleaningMultiplier = 1.3,
                            },
                        },
                    },
                }
            },
            {
                name = "ULSA Reclamebord",
                coords = vec3(-1586.64, 259.88, 60.12),
                spots = {
                    {
                        name = "Reclamebord",
                        areas = {
                            {
                                corners = {
                                    vec3(-1586.64, 259.88, 60.12),
                                    vec3(-1586.64, 259.88, 58.22),
                                    vec3(-1585.44, 263.20, 58.22),
                                    vec3(-1585.42, 263.23, 60.13),
                                },
                                edgeFadeout = 0.2,
                            },
                        },
                    },
                }
            },
        }
    },
    {
        name = "Golfen",
        description = "Maak het terras van de golfbaan lobby schoon.",
        reward = 5500,
        minPlayers = 1,
        maxPlayers = 3,
        locations = {
            {
                name = "Golfbaan",
                coords = vec3(-1347.45, 71.71, 54.27),
                spots = {
                    {
                        name = "Terras",
                        areas = {
                            {
                                corners = {
                                    vec3(-1347.45, 71.71, 54.27),
                                    vec3(-1345.12, 45.04, 54.26),
                                    vec3(-1334.66, 46.15, 54.27),
                                    vec3(-1337.08, 72.71, 54.27),
                                },
                                edgeFadeout = 0.3,
                                cleaningMultiplier = 1.3,
                            },
                        },
                    },
                }
            },
        }
    },
    {
        name = "We spelen tennis",
        description = "Maak twee tennisbanen schoon.",
        reward = 7500,
        minPlayers = 1,
        maxPlayers = 4,
        locations = {
            {
                name = "Tennisbanen",
                coords = vec3(-1378.68, -90.52, 49.71),
                spots = {
                    {
                        name = "Tennisbanen 1",
                        areas = {
                            {
                                corners = {
                                    vec3(-1378.68, -90.52, 49.71),
                                    vec3(-1376.00, -114.13, 49.71),
                                    vec3(-1365.23, -112.90, 49.71),
                                    vec3(-1367.92, -89.32, 49.71),
                                },
                                edgeFadeout = 0.35,
                                cleaningMultiplier = 1.3,
                            },
                        },
                    },
                    {
                        name = "Tennisbaan 2",
                        areas = {
                            {
                                corners = {
                                    vec3(-1352.89, -87.58, 49.71),
                                    vec3(-1350.25, -111.19, 49.71),
                                    vec3(-1339.44, -109.97, 49.71),
                                    vec3(-1342.10, -86.33, 49.71),
                                },
                                edgeFadeout = 0.35,
                                cleaningMultiplier = 1.3,
                            },
                        },
                    },
                }
            },
        }
    },
    {
        name = "Schone redneck",
        description = "Maak de terrassen van een woonwagen in Sandy Shores schoon.",
        reward = 7000,
        minPlayers = 1,
        maxPlayers = 3,
        locations = {
            {
                name = "Woonwagen",
                coords = vec3(1650.94, 3801.03, 37.67),
                spots = {
                    {
                        name = "Dakterras",
                        areas = {
                            {
                                corners = {
                                    vec3(1642.96, 3811.49, 37.68),
                                    vec3(1650.94, 3801.03, 37.67),
                                    vec3(1655.88, 3804.97, 37.74),
                                    vec3(1647.95, 3815.30, 37.68),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.2,
                                cleaningMultiplier = 1.1,
                            },
                        },
                    },
                    {
                        name = "Voorterras",
                        areas = {
                            {
                                corners = {
                                    vec3(1661.93, 3818.66, 34.48),
                                    vec3(1663.82, 3819.93, 34.48),
                                    vec3(1660.74, 3824.15, 34.48),
                                    vec3(1658.94, 3822.76, 34.48),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.2,
                            },
                        },
                    },
                }
            },
        }
    },
    {
        name = "Industriële magazijnen",
        description = "Maak de magazijndeuren van meerdere bedrijven in de omgeving van La Mesa schoon.",
        reward = 3750,
        minPlayers = 1,
        maxPlayers = 3,
        locations = {
            {
                name = "Magazijn",
                coords = vec3(681.93, -716.03, 28.41),
                spots = {
                    {
                        name = "Linkerdeur",
                        areas = {
                            {
                                corners = {
                                    vec3(681.93, -716.05, 28.41),
                                    vec3(681.91, -716.05, 25.11),
                                    vec3(686.93, -716.05, 25.19),
                                    vec3(686.94, -716.05, 28.35),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.1,
                            },
                        },
                    },
                    {
                        name = "Rechtedeur",
                        areas = {
                            {
                                corners = {
                                    vec3(687.84, -716.05, 28.39),
                                    vec3(687.80, -716.05, 25.16),
                                    vec3(692.76, -716.05, 25.19),
                                    vec3(692.76, -716.05, 28.43),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.1,
                            },
                        },
                    },
                }
            },
            {
                name = "Magazijn",
                coords = vec3(727.31, -818.74, 28.89),
                spots = {
                    {
                        name = "Magazijndeur",
                        areas = {
                            {
                                corners = {
                                    vec3(727.31, -818.74, 28.89),
                                    vec3(727.31, -818.68, 24.00),
                                    vec3(727.31, -826.49, 24.04),
                                    vec3(727.31, -826.45, 28.79),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.1,
                            },
                        },
                    },
                }
            },
            {
                name = "Magazijn",
                coords = vec3(716.34, -659.90, 30.29),
                spots = {
                    {
                        name = "Magazijndeur",
                        areas = {
                            {
                                corners = {
                                    vec3(716.34, -659.90, 30.29),
                                    vec3(716.34, -659.91, 26.76),
                                    vec3(716.34, -655.85, 26.86),
                                    vec3(716.34, -655.80, 30.30),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.1,
                            },
                        },
                    },
                }
            },
        }
    },
    {
        name = "Meer deuren, meer water",
        description = "Maak 4 garagedeuren van een magazijn in La Mesa schoon.",
        reward = 2750,
        minPlayers = 1,
        maxPlayers = 4,
        locations = {
            {
                name = "Magazijn",
                coords = vec3(962.68, -1033.46, 43.52),
                spots = {
                    {
                        name = "Deur 1",
                        areas = {
                            {
                                corners = {
                                    vec3(962.71, -1033.46, 43.52),
                                    vec3(962.71, -1033.48, 39.93),
                                    vec3(962.71, -1028.72, 39.96),
                                    vec3(962.71, -1028.69, 43.46),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.1,
                            },
                        },
                    },
                    {
                        name = "Deur 2",
                        areas = {
                            {
                                corners = {
                                    vec3(962.69, -1027.80, 43.52),
                                    vec3(962.69, -1027.83, 39.91),
                                    vec3(962.69, -1023.04, 39.93),
                                    vec3(962.69, -1023.03, 43.45),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.1,
                            },
                        },
                    },
                    {
                        name = "Deur 3",
                        areas = {
                            {
                                corners = {
                                    vec3(962.71, -1022.13, 43.55),
                                    vec3(962.71, -1022.08, 39.95),
                                    vec3(962.71, -1017.43, 39.93),
                                    vec3(962.71, -1017.41, 43.47),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.1,
                            },
                        },
                    },
                    {
                        name = "Deur 4",
                        areas = {
                            {
                                corners = {
                                    vec3(962.69, -1016.44, 43.50),
                                    vec3(962.69, -1016.46, 39.96),
                                    vec3(962.69, -1011.77, 39.95),
                                    vec3(962.69, -1011.72, 43.51),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.1,
                            },
                        },
                    },
                }
            },
        }
    },
    {
        name = "Terminal loopbrug",
        description = "Maak de loopbrug bij de haven terminal schoon.",
        reward = 5500,
        minPlayers = 1,
        maxPlayers = 4,
        locations = {
            {
                name = "Loopbrug",
                coords = vec3(771.46, -3057.89, 13.73),
                spots = {
                    {
                        name = "Loopbrug",
                        areas = {
                            {
                                corners = {
                                    vec3(757.44, -3054.32, 13.73),
                                    vec3(757.47, -3047.47, 13.76),
                                    vec3(754.97, -3047.49, 13.76),
                                    vec3(754.95, -3054.29, 13.73),
                                },
                                edgeFadeout = 0.2,
                                cleaningMultiplier = 1.1,
                            },
                            {
                                corners = {
                                    vec3(757.29, -3052.62, 13.75),
                                    vec3(773.09, -3052.65, 13.75),
                                    vec3(773.04, -3049.37, 13.75),
                                    vec3(757.24, -3049.39, 13.73),
                                },
                                edgeFadeout = 0.2,
                                cleaningMultiplier = 1.1,
                            },
                            {
                                corners = {
                                    vec3(769.83, -3052.56, 13.73),
                                    vec3(769.86, -3064.78, 13.73),
                                    vec3(773.14, -3064.64, 13.71),
                                    vec3(773.07, -3052.58, 13.75),
                                },
                                edgeFadeout = 0.2,
                                cleaningMultiplier = 1.1,
                            },
                            {
                                corners = {
                                    vec3(772.89, -3064.67, 13.72),
                                    vec3(786.02, -3064.80, 13.72),
                                    vec3(785.96, -3061.51, 13.73),
                                    vec3(773.04, -3061.57, 13.76),
                                },
                                edgeFadeout = 0.2,
                                cleaningMultiplier = 1.1,
                            },
                            {
                                corners = {
                                    vec3(785.98, -3059.82, 13.71),
                                    vec3(786.00, -3066.65, 13.73),
                                    vec3(788.51, -3066.65, 13.73),
                                    vec3(788.53, -3059.80, 13.71),
                                },
                                edgeFadeout = 0.2,
                                cleaningMultiplier = 1.1,
                            },
                        },
                    },
                }
            },
        }
    },
    {
        name = "Opslagruimte strandwacht",
        description = "Maak de garagedeuren van de opslagruimte van de strandwacht op het strand van Vespucci schoon.",
        reward = 4500,
        minPlayers = 1,
        maxPlayers = 4,
        locations = {
            {
                name = "Opslagruimte strandwacht",
                coords = vec3(-1191.06, -1770.24, 5.74),
                spots = {
                    {
                        name = "Opslagdeur",
                        areas = {
                            {
                                corners = {
                                    vec3(-1191.06, -1770.24, 5.74),
                                    vec3(-1191.09, -1770.24, 3.15),
                                    vec3(-1196.43, -1770.72, 3.13),
                                    vec3(-1196.45, -1770.72, 5.70),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.1,
                            },
                        },
                    },
                    {
                        name = "Opslagdeur",
                        areas = {
                            {
                                corners = {
                                    vec3(-1197.61, -1770.82, 5.75),
                                    vec3(-1197.64, -1770.83, 3.11),
                                    vec3(-1202.93, -1771.30, 3.09),
                                    vec3(-1203.04, -1771.31, 5.78),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.1,
                            },
                        },
                    },
                    {
                        name = "Opslagdeur",
                        areas = {
                            {
                                corners = {
                                    vec3(-1208.86, -1775.33, 5.76),
                                    vec3(-1208.88, -1775.39, 3.15),
                                    vec3(-1211.12, -1780.22, 3.09),
                                    vec3(-1211.14, -1780.25, 5.79),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.1,
                            },
                        },
                    },
                    {
                        name = "Opslagdeur",
                        areas = {
                            {
                                corners = {
                                    vec3(-1211.62, -1781.30, 5.78),
                                    vec3(-1211.64, -1781.35, 3.21),
                                    vec3(-1213.88, -1786.18, 3.12),
                                    vec3(-1213.93, -1786.28, 5.79),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.1,
                            },
                        },
                    },
                    {
                        name = "Opslagdeur",
                        areas = {
                            {
                                corners = {
                                    vec3(-1200.67, -1799.28, 4.99),
                                    vec3(-1200.66, -1799.25, 3.01),
                                    vec3(-1201.88, -1801.87, 3.04),
                                    vec3(-1201.89, -1801.90, 4.96),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.1,
                            },
                        },
                    },
                    {
                        name = "Opslagdeur",
                        areas = {
                            {
                                corners = {
                                    vec3(-1200.01, -1805.96, 5.78),
                                    vec3(-1199.98, -1805.96, 3.12),
                                    vec3(-1194.47, -1805.47, 3.04),
                                    vec3(-1194.39, -1805.47, 5.78),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.1,
                            },
                        },
                    },
                    {
                        name = "Opslagdeur",
                        areas = {
                            {
                                corners = {
                                    vec3(-1193.46, -1805.39, 5.78),
                                    vec3(-1193.40, -1805.38, 3.18),
                                    vec3(-1188.01, -1804.91, 3.16),
                                    vec3(-1187.92, -1804.91, 5.77),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.1,
                            },
                        },
                    },
                }
            },
        }
    },
    {
        name = "Kleurrijke garages",
        description = "Maak een aantal zeer kleurrijke garagedeuren schoon op het strand van Vespucci.",
        reward = 4250,
        minPlayers = 1,
        maxPlayers = 3,
        locations = {
            {
                name = "Witte garage",
                coords = vec3(-1952.65, -520.72, 11.05),
                spots = {
                    {
                        name = "Deur 1",
                        areas = {
                            {
                                corners = {
                                    vec3(-1952.65, -520.72, 13.07),
                                    vec3(-1952.65, -520.72, 11.05),
                                    vec3(-1954.30, -519.34, 11.10),
                                    vec3(-1954.35, -519.30, 13.03),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.1,
                            },
                        },
                    },
                    {
                        name = "Deur 2",
                        areas = {
                            {
                                corners = {
                                    vec3(-1954.90, -518.83, 13.07),
                                    vec3(-1954.91, -518.82, 11.09),
                                    vec3(-1956.54, -517.45, 11.10),
                                    vec3(-1956.54, -517.45, 13.07),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.1,
                            },
                        },
                    },
                    {
                        name = "Deur 3",
                        areas = {
                            {
                                corners = {
                                    vec3(-1957.18, -516.91, 13.05),
                                    vec3(-1957.18, -516.92, 11.10),
                                    vec3(-1958.80, -515.56, 11.09),
                                    vec3(-1958.83, -515.53, 13.05),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.1,
                            },
                        },
                    },
                }
            },
            {
                name = "Roze garage",
                coords = vec3(-1888.53, -574.93, 13.10),
                spots = {
                    {
                        name = "Roze deur",
                        areas = {
                            {
                                corners = {
                                    vec3(-1888.53, -574.93, 13.10),
                                    vec3(-1888.55, -574.92, 10.93),
                                    vec3(-1892.42, -571.67, 10.91),
                                    vec3(-1892.46, -571.64, 13.12),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.1,
                            },
                        },
                    },
                }
            },
            {
                name = "Groene garages",
                coords = vec3(-1776.17, -672.14, 11.53),
                spots = {
                    {
                        name = "Deur 1",
                        areas = {
                            {
                                corners = {
                                    vec3(-1776.17, -672.14, 11.53),
                                    vec3(-1776.16, -672.14, 9.60),
                                    vec3(-1777.85, -670.73, 9.61),
                                    vec3(-1777.87, -670.71, 11.52),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.1,
                            },
                        },
                    },
                    {
                        name = "Deur 2",
                        areas = {
                            {
                                corners = {
                                    vec3(-1778.42, -670.25, 11.52),
                                    vec3(-1778.43, -670.24, 9.62),
                                    vec3(-1780.07, -668.87, 9.64),
                                    vec3(-1780.08, -668.85, 11.48),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.1,
                            },
                        },
                    },
                    {
                        name = "Deur 3",
                        areas = {
                            {
                                corners = {
                                    vec3(-1780.70, -668.33, 11.52),
                                    vec3(-1780.72, -668.32, 9.64),
                                    vec3(-1782.34, -666.96, 9.63),
                                    vec3(-1782.37, -666.93, 11.52),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.1,
                            },
                        },
                    },
                }
            },
        }
    },
    {
        name = "Morningwood Plaza",
        description = "Maak het Morningwood plein schoon.",
        reward = 10500,
        minPlayers = 1,
        maxPlayers = 4,
        locations = {
            {
                name = "Plein",
                coords = vec3(-1492.65, -167.74, 47.85),
                spots = {
                    {
                        name = "Plein",
                        areas = {
                            {
                                corners = {
                                    vec3(-1454.98, -172.54, 47.84),
                                    vec3(-1463.16, -162.27, 47.84),
                                    vec3(-1473.64, -170.65, 47.84),
                                    vec3(-1465.34, -180.81, 47.84),
                                },
                                edgeFadeout = 0.35,
                                opacityMultiplier = 1.2,
                                cleaningMultiplier = 1.4,
                            },
                            {
                                corners = {
                                    vec3(-1462.79, -162.94, 47.84),
                                    vec3(-1472.24, -150.95, 47.85),
                                    vec3(-1482.73, -159.75, 47.85),
                                    vec3(-1472.90, -172.01, 47.84),
                                },
                                edgeFadeout = 0.35,
                                opacityMultiplier = 1.2,
                                cleaningMultiplier = 1.4,
                            },
                            {
                                corners = {
                                    vec3(-1464.77, -180.63, 47.84),
                                    vec3(-1472.33, -170.42, 47.84),
                                    vec3(-1483.26, -179.34, 47.84),
                                    vec3(-1475.33, -189.45, 47.84),
                                },
                                edgeFadeout = 0.35,
                                opacityMultiplier = 1.2,
                                cleaningMultiplier = 1.4,
                            },
                            {
                                corners = {
                                    vec3(-1472.78, -170.95, 47.84),
                                    vec3(-1482.18, -159.44, 47.85),
                                    vec3(-1492.56, -167.74, 47.85),
                                    vec3(-1482.77, -179.80, 47.84),
                                },
                                edgeFadeout = 0.35,
                                opacityMultiplier = 1.2,
                                cleaningMultiplier = 1.4,
                            },
                        },
                    },
                }
            },
        }
    },
    {
        name = "Villa schoonmaak",
        description = "Maak meerdere plekken schoon bij een huis in Vinewood.",
        reward = 6500,
        minPlayers = 1,
        maxPlayers = 3,
        locations = {
            {
                name = "Huis",
                coords = vec3(-1478.29, 526.03, 116.99),
                spots = {
                    {
                        name = "Oprit",
                        areas = {
                            {
                                corners = {
                                    vec3(-1492.16, 529.28, 117.29),
                                    vec3(-1488.99, 524.90, 117.28),
                                    vec3(-1480.12, 529.96, 117.28),
                                    vec3(-1482.98, 534.52, 117.29),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.1,
                                cleaningMultiplier = 1.1,
                            },
                            {
                                corners = {
                                    vec3(-1478.29, 526.03, 116.99),
                                    vec3(-1480.09, 530.42, 117.29),
                                    vec3(-1489.36, 525.04, 117.29),
                                    vec3(-1487.54, 521.53, 116.78),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.1,
                                cleaningMultiplier = 1.1,
                            },
                        },
                    },
                    {
                        name = "Grote garagedeur",
                        areas = {
                            {
                                corners = {
                                    vec3(-1491.87, 529.52, 120.10),
                                    vec3(-1491.93, 529.49, 117.39),
                                    vec3(-1486.92, 532.38, 117.40),
                                    vec3(-1486.88, 532.40, 120.09),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.2,
                                dirtColor = {22, 28, 20},
                            },
                        },
                    },
                    {
                        name = "Kleine garagedeur",
                        areas = {
                            {
                                corners = {
                                    vec3(-1486.02, 532.90, 120.11),
                                    vec3(-1486.00, 532.91, 117.38),
                                    vec3(-1483.29, 534.48, 117.39),
                                    vec3(-1483.21, 534.52, 120.10),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.2,
                                dirtColor = {22, 28, 20},
                            },
                        },
                    },
                    {
                        name = "Achterterras",
                        areas = {
                            {
                                corners = {
                                    vec3(-1500.28, 536.50, 117.28),
                                    vec3(-1492.42, 541.04, 117.28),
                                    vec3(-1496.01, 547.16, 117.28),
                                    vec3(-1503.77, 542.62, 117.28),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.1,
                                cleaningMultiplier = 1.1,
                                dirtColor = {22, 28, 20},
                            },
                            {
                                corners = {
                                    vec3(-1501.72, 543.69, 117.28),
                                    vec3(-1504.79, 549.13, 117.28),
                                    vec3(-1506.83, 547.93, 117.28),
                                    vec3(-1503.68, 542.47, 117.28),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.1,
                                cleaningMultiplier = 1.1,
                                dirtColor = {22, 28, 20},
                            },
                        },
                    },
                    {
                        name = "Zijmuur",
                        areas = {
                            {
                                corners = {
                                    vec3(-1510.14, 514.76, 119.81),
                                    vec3(-1510.14, 514.78, 117.40),
                                    vec3(-1515.77, 524.57, 117.48),
                                    vec3(-1515.81, 524.62, 119.66),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.1,
                                cleaningMultiplier = 1.1,
                                dirtColor = {22, 28, 20},
                            },
                        },
                    },
                }
            },
        }
    },
    {
        name = "Metroperron",
        description = "Maak een metroperron in het centrum van Los Santos schoon.",
        reward = 4750,
        minPlayers = 1,
        maxPlayers = 2,
        locations = {
            {
                name = "Metroperron",
                coords = vec3(-547.52, -1270.74, 24.93),
                spots = {
                    {
                        name = "Perron",
                        areas = {
                            {
                                corners = {
                                    vec3(-533.62, -1260.32, 25.93),
                                    vec3(-552.93, -1303.24, 25.93),
                                    vec3(-551.16, -1303.93, 25.93),
                                    vec3(-531.76, -1261.14, 25.93),
                                },
                                edgeFadeout = 0.15,
                                opacityMultiplier = 1.2,
                            },
                            {
                                corners = {
                                    vec3(-547.94, -1305.50, 25.93),
                                    vec3(-528.60, -1262.51, 25.93),
                                    vec3(-530.48, -1261.78, 25.93),
                                    vec3(-549.73, -1304.66, 25.92),
                                },
                                edgeFadeout = 0.15,
                                opacityMultiplier = 1.2,
                            },
                            {
                                corners = {
                                    vec3(-533.58, -1269.32, 25.92),
                                    vec3(-530.23, -1261.84, 25.92),
                                    vec3(-532.00, -1261.08, 25.91),
                                    vec3(-535.32, -1268.57, 25.92),
                                },
                                edgeFadeout = 0.15,
                                opacityMultiplier = 1.2,
                            },
                            {
                                corners = {
                                    vec3(-547.95, -1296.27, 25.92),
                                    vec3(-551.48, -1303.78, 25.92),
                                    vec3(-549.49, -1304.73, 25.92),
                                    vec3(-546.17, -1297.11, 25.92),
                                },
                                edgeFadeout = 0.15,
                                opacityMultiplier = 1.2,
                            },
                        },
                    },
                }
            },
        }
    },
    {
        name = "Roestige watertoren",
        description = "Klim helemaal naar de top van de watertoren en maak de roest bovenop schoon.",
        reward = 2500,
        minPlayers = 1,
        maxPlayers = 2,
        locations = {
            {
                name = "Watertoren",
                coords = vec3(1250.60, -1574.24, 77.99),
                spots = {
                    {
                        name = "Dak van de watertoren",
                        areas = {
                            {
                                corners = {
                                    vec3(1250.60, -1574.24, 77.99),
                                    vec3(1261.76, -1574.86, 77.99),
                                    vec3(1262.05, -1569.10, 77.99),
                                    vec3(1250.83, -1568.49, 77.99),
                                },
                                edgeFadeout = 0.15,
                                opacityMultiplier = 1.2,
                                dirtColor = {41, 15, 4},
                            },
                        },
                    },
                }
            },
        }
    },
    {
        name = "Laadperrons post",
        description = "Maak de deuren van meerdere laadperrons schoon.",
        reward = 3250,
        minPlayers = 1,
        maxPlayers = 2,
        locations = {
            {
                name = "Postmagazijn",
                coords = vec3(1187.88, -3325.28, 9.32),
                spots = {
                    {
                        name = "Deur 1",
                        areas = {
                            {
                                corners = {
                                    vec3(1187.88, -3325.28, 9.32),
                                    vec3(1187.90, -3325.28, 4.63),
                                    vec3(1193.05, -3325.28, 4.69),
                                    vec3(1193.07, -3325.28, 9.31),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.1,
                            },
                        },
                    },
                    {
                        name = "Deur 2",
                        areas = {
                            {
                                corners = {
                                    vec3(1202.88, -3325.28, 9.27),
                                    vec3(1202.87, -3325.28, 4.69),
                                    vec3(1208.06, -3325.28, 4.73),
                                    vec3(1208.07, -3325.28, 9.29),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.1,
                            },
                        },
                    },
                    {
                        name = "Deur 3",
                        areas = {
                            {
                                corners = {
                                    vec3(1215.90, -3325.28, 9.28),
                                    vec3(1215.91, -3325.28, 4.72),
                                    vec3(1221.04, -3325.28, 4.71),
                                    vec3(1221.01, -3325.28, 9.26),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.1,
                            },
                        },
                    },
                    {
                        name = "Deur 4",
                        areas = {
                            {
                                corners = {
                                    vec3(1230.93, -3325.28, 9.26),
                                    vec3(1230.89, -3325.28, 4.68),
                                    vec3(1236.07, -3325.28, 4.68),
                                    vec3(1236.09, -3325.28, 9.30),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.1,
                            },
                        },
                    },
                }
            },
        }
    },
    {
        name = "Reservoir schoonmaken",
        description = "Maak de steiger bij het waterreservoir van Los Santos schoon.",
        reward = 4500,
        minPlayers = 1,
        maxPlayers = 3,
        locations = {
            {
                name = "Reservoir",
                coords = vec3(-184.95, 804.73, 197.13),
                spots = {
                    {
                        name = "Steiger",
                        areas = {
                            {
                                corners = {
                                    vec3(-184.95, 804.73, 197.13),
                                    vec3(-193.67, 792.32, 197.13),
                                    vec3(-190.94, 790.28, 197.13),
                                    vec3(-182.20, 802.81, 197.13),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.1,
                                dirtColor = {27, 33, 29},
                            },
                            {
                                corners = {
                                    vec3(-199.39, 793.75, 197.13),
                                    vec3(-187.59, 785.46, 197.13),
                                    vec3(-186.27, 787.35, 197.13),
                                    vec3(-198.09, 795.60, 197.13),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.1,
                                dirtColor = {27, 33, 29},
                            },
                        },
                    },
                    {
                        name = "Helling",
                        areas = {
                            {
                                corners = {
                                    vec3(-176.01, 816.46, 202.03),
                                    vec3(-184.33, 804.59, 197.18),
                                    vec3(-182.44, 803.26, 197.18),
                                    vec3(-174.12, 815.13, 202.04),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.1,
                                dirtColor = {27, 33, 29},
                            },
                        },
                    },
                }
            },
        }
    },
    {
        name = "Moeras Altruïsten",
        description = "Maak meerdere plekken schoon bij het altruïstenkamp in de bergen.",
        reward = 11000,
        minPlayers = 1,
        maxPlayers = 4,
        locations = {
            {
                name = "Altruïstenkamp",
                coords = vec3(-1064.68, 4905.72, 211.14),
                spots = {
                    {
                        name = "Terras van de hut",
                        areas = {
                            {
                                corners = {
                                    vec3(-1092.46, 4893.17, 215.08),
                                    vec3(-1098.80, 4896.19, 215.08),
                                    vec3(-1099.70, 4893.57, 215.30),
                                    vec3(-1093.66, 4891.00, 215.08),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.1,
                                dirtColor = {27, 33, 29},
                            },
                        },
                    },
                    {
                        name = "Terras van de hut",
                        areas = {
                            {
                                corners = {
                                    vec3(-1136.52, 4933.43, 221.28),
                                    vec3(-1129.38, 4952.86, 221.28),
                                    vec3(-1133.11, 4954.23, 221.38),
                                    vec3(-1140.03, 4934.75, 221.28),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.1,
                                dirtColor = {27, 33, 29},
                            },
                        },
                    },
                    {
                        name = "Wachttoren",
                        areas = {
                            {
                                corners = {
                                    vec3(-1061.55, 4968.73, 212.23),
                                    vec3(-1063.88, 4968.07, 212.23),
                                    vec3(-1063.34, 4966.02, 212.23),
                                    vec3(-1060.98, 4966.60, 212.23),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.1,
                                dirtColor = {27, 33, 29},
                            },
                        },
                    },
                    {
                        name = "Wachttoren",
                        areas = {
                            {
                                corners = {
                                    vec3(-1044.33, 4918.97, 211.55),
                                    vec3(-1046.81, 4919.20, 211.55),
                                    vec3(-1047.06, 4917.13, 211.55),
                                    vec3(-1044.59, 4916.82, 211.55),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.1,
                                dirtColor = {27, 33, 29},
                            },
                        },
                    },
                    {
                        name = "Wachttoren",
                        areas = {
                            {
                                corners = {
                                    vec3(-1136.97, 4871.99, 214.18),
                                    vec3(-1136.18, 4874.18, 214.18),
                                    vec3(-1138.11, 4874.99, 214.18),
                                    vec3(-1139.03, 4872.76, 214.18),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.1,
                                dirtColor = {27, 33, 29},
                            },
                        },
                    },
                }
            },
        }
    },
    {
        name = "Hotdogs",
        description = "Maak een Chihuahua hotdogkraam schoon.",
        reward = 4250,
        minPlayers = 1,
        maxPlayers = 3,
        locations = {
            {
                name = "Chihuahua trailer",
                coords = vec3(1968.60, 3262.40, 46.83),
                spots = {
                    {
                        name = "Zijkanten van de kraam",
                        areas = {
                            {
                                corners = {
                                    vec3(1968.60, 3262.40, 46.83),
                                    vec3(1968.60, 3262.37, 45.20),
                                    vec3(1966.52, 3259.87, 45.31),
                                    vec3(1966.53, 3259.92, 46.91),
                                },
                                edgeFadeout = 0.1,
                                opacityMultiplier = 1.5,
                                cleaningMultiplier = 0.8,
                                dirtColor = {51, 47, 37},
                            },
                            {
                                corners = {
                                    vec3(1966.56, 3259.82, 47.04),
                                    vec3(1966.52, 3259.80, 45.06),
                                    vec3(1968.06, 3258.52, 45.09),
                                    vec3(1968.06, 3258.59, 47.07),
                                },
                                edgeFadeout = 0.1,
                                opacityMultiplier = 1.5,
                                cleaningMultiplier = 0.8,
                                dirtColor = {51, 47, 37},
                            },
                            {
                                corners = {
                                    vec3(1969.25, 3259.88, 46.85),
                                    vec3(1969.31, 3259.91, 45.27),
                                    vec3(1970.20, 3260.93, 44.95),
                                    vec3(1970.19, 3260.99, 46.82),
                                },
                                edgeFadeout = 0.1,
                                opacityMultiplier = 1.5,
                                cleaningMultiplier = 0.8,
                                dirtColor = {51, 47, 37},
                            },
                            {
                                corners = {
                                    vec3(1970.20, 3261.10, 45.50),
                                    vec3(1970.19, 3261.07, 44.98),
                                    vec3(1968.67, 3262.36, 44.98),
                                    vec3(1968.68, 3262.37, 45.42),
                                },
                                edgeFadeout = 0.1,
                                opacityMultiplier = 1.5,
                                cleaningMultiplier = 0.8,
                                dirtColor = {51, 47, 37},
                            },
                        },
                    },
                    {
                        name = "Dak van de kraam",
                        areas = {
                            {
                                corners = {
                                    vec3(1968.04, 3258.75, 47.16),
                                    vec3(1970.05, 3261.16, 47.09),
                                    vec3(1968.72, 3262.28, 47.07),
                                    vec3(1966.71, 3259.81, 47.14),
                                },
                                edgeFadeout = 0.15,
                                opacityMultiplier = 1.1,
                                dirtColor = {51, 47, 37},
                            },
                        },
                    },
                }
            },
        }
    },
    {
        name = "East Alamo Uitzicht",
        description = "Maak een uitkijkplatform met uitzicht op het East Alamo-meer schoon.",
        reward = 4750,
        minPlayers = 1,
        maxPlayers = 2,
        locations = {
            {
                name = "Uitkijkplatform",
                coords = vec3(-520.19, 4196.99, 192.86),
                spots = {
                    {
                        name = "Platform",
                        areas = {
                            {
                                corners = {
                                    vec3(-520.19, 4196.99, 192.86),
                                    vec3(-523.22, 4198.62, 192.75),
                                    vec3(-526.72, 4191.44, 192.75),
                                    vec3(-523.55, 4189.93, 192.75),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.2,
                            },
                        },
                    },
                    {
                        name = "Reclamebord",
                        areas = {
                            {
                                corners = {
                                    vec3(-521.37, 4194.36, 193.93),
                                    vec3(-522.34, 4194.83, 193.68),
                                    vec3(-523.15, 4193.09, 193.69),
                                    vec3(-522.19, 4192.65, 193.93),
                                },
                                edgeFadeout = 0.1,
                                opacityMultiplier = 1.4,
                                cleaningMultiplier = 0.8,
                                dirtColor = {51, 47, 37},
                            },
                        },
                    },
                }
            },
        }
    },
    {
        name = "Raton Canyon",
        description = "Maak een uitkijkplatform met uitzicht op Raton Canyon schoon.",
        reward = 4750,
        minPlayers = 1,
        maxPlayers = 2,
        locations = {
            {
                name = "Uitkijkplatform",
                coords = vec3(-839.03, 4187.03, 214.31),
                spots = {
                    {
                        name = "Platform",
                        areas = {
                            {
                                corners = {
                                    vec3(-844.28, 4181.37, 214.42),
                                    vec3(-841.86, 4178.90, 214.31),
                                    vec3(-836.45, 4184.69, 214.31),
                                    vec3(-839.03, 4187.03, 214.31),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.2,
                            },
                        },
                    },
                    {
                        name = "Reclamebord",
                        areas = {
                            {
                                corners = {
                                    vec3(-842.42, 4183.49, 215.50),
                                    vec3(-841.62, 4182.76, 215.24),
                                    vec3(-840.34, 4184.18, 215.25),
                                    vec3(-841.10, 4184.89, 215.49),
                                },
                                edgeFadeout = 0.1,
                                opacityMultiplier = 1.4,
                                cleaningMultiplier = 0.8,
                                dirtColor = {51, 47, 37},
                            },
                        },
                    },
                }
            },
        }
    },
    {
        name = "Richman Villa",
        description = "Was meerdere plekken rondom de Richman-villa.",
        reward = 12000,
        minPlayers = 1,
        maxPlayers = 4,
        locations = {
            {
                name = "Richman Villa",
                coords = vec3(-1514.10, 86.39, 55.03),
                spots = {
                    {
                        name = "Garagedeuren",
                        areas = {
                            {
                                corners = {
                                    vec3(-1522.35, 79.08, 58.73),
                                    vec3(-1522.32, 79.08, 55.90),
                                    vec3(-1525.63, 78.62, 55.88),
                                    vec3(-1525.72, 78.60, 58.72),
                                },
                                edgeFadeout = 0.15,
                                opacityMultiplier = 1.3,
                            },
                            {
                                corners = {
                                    vec3(-1526.62, 78.48, 58.78),
                                    vec3(-1526.65, 78.47, 55.90),
                                    vec3(-1529.87, 78.02, 55.96),
                                    vec3(-1529.92, 78.01, 58.74),
                                },
                                edgeFadeout = 0.15,
                                opacityMultiplier = 1.3,
                            },
                            {
                                corners = {
                                    vec3(-1533.69, 78.64, 58.75),
                                    vec3(-1533.70, 78.65, 55.91),
                                    vec3(-1536.11, 80.90, 55.92),
                                    vec3(-1536.15, 80.93, 58.74),
                                },
                                edgeFadeout = 0.15,
                                opacityMultiplier = 1.3,
                            },
                        },
                    },
                    {
                        name = "Overwoekerde muur",
                        areas = {
                            {
                                corners = {
                                    vec3(-1493.16, 113.72, 58.99),
                                    vec3(-1493.11, 113.66, 55.31),
                                    vec3(-1496.81, 117.14, 55.25),
                                    vec3(-1496.71, 117.04, 58.91),
                                },
                                edgeFadeout = 0.25,
                                opacityMultiplier = 1.3,
                                dirtColor = {25, 31, 22},
                            },
                        },
                    },
                    {
                        name = "Gemorste wijn",
                        areas = {
                            {
                                corners = {
                                    vec3(-1510.78, 140.59, 54.66),
                                    vec3(-1509.36, 140.53, 54.66),
                                    vec3(-1509.15, 142.10, 54.66),
                                    vec3(-1510.47, 141.95, 54.66),
                                },
                                edgeFadeout = 0.25,
                                opacityMultiplier = 1.3,
                                cleaningMultiplier = 0.6,
                                dirtColor = {51, 16, 36},
                            },
                        },
                    },
                    {
                        name = "Zwembadgedeelte",
                        areas = {
                            {
                                corners = {
                                    vec3(-1463.85, 166.96, 54.94),
                                    vec3(-1471.55, 166.13, 54.93),
                                    vec3(-1471.38, 161.88, 54.80),
                                    vec3(-1462.99, 161.97, 54.82),
                                },
                                edgeFadeout = 0.3,
                                opacityMultiplier = 1.1,
                            },
                            {
                                corners = {
                                    vec3(-1472.00, 166.44, 54.93),
                                    vec3(-1474.71, 169.14, 54.91),
                                    vec3(-1477.35, 167.05, 54.79),
                                    vec3(-1474.42, 162.59, 54.77),
                                },
                                edgeFadeout = 0.35,
                                opacityMultiplier = 1.1,
                            },
                            {
                                corners = {
                                    vec3(-1472.92, 166.48, 54.91),
                                    vec3(-1474.51, 163.39, 54.79),
                                    vec3(-1471.70, 162.33, 54.80),
                                    vec3(-1470.77, 165.77, 54.92),
                                },
                                edgeFadeout = 0.3,
                                opacityMultiplier = 1.1,
                            },
                        },
                    },
                    {
                        name = "Vuil in de zwembadgrot",
                        areas = {
                            {
                                corners = {
                                    vec3(-1462.17, 184.50, 54.93),
                                    vec3(-1461.74, 183.67, 54.93),
                                    vec3(-1460.97, 183.93, 54.93),
                                    vec3(-1461.37, 184.86, 54.93),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.4,
                                dirtColor = {33, 51, 16},
                            },
                        },
                    },
                    {
                        name = "Barvloer",
                        areas = {
                            {
                                corners = {
                                    vec3(-1434.85, 209.75, 56.83),
                                    vec3(-1433.96, 206.97, 56.83),
                                    vec3(-1431.68, 207.43, 56.83),
                                    vec3(-1432.95, 210.46, 56.83),
                                },
                                edgeFadeout = 0.2,
                                opacityMultiplier = 1.2,
                            },
                        },
                    },
                }
            },
        }
    },
}
