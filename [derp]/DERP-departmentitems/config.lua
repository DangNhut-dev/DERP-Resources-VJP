-- config.lua
Config = {}

Config.Jobs = {

bcso = {
        label = 'Lấy đồng phục BCSO',
        npc = {
            model    = 's_m_y_cop_01',
            coords   = vec4(1838.91, 3677.67, 38.93, 297.50),
            scenario = 'WORLD_HUMAN_STAND_IMPATIENT',
        },
        grades = {
            [0] = {
                outfits = {
                    {
                        label = 'Đồng phục Cadet',
                        items = {
                            {
                                name   = 'aokhoac',
                                male   = { drawable = 582, texture = 0 },
                                female = { drawable = 628, texture = 0 },
                            },
                            {
                                name   = 'quan',
                                male   = { drawable = 232, texture = 5 },
                                female = { drawable = 230, texture = 0 },
                            },
                            {
                                name   = 'giay',
                                male   = { drawable = 54, texture = 0 },
                                female = { drawable = 55, texture = 0 },
                            },
                        },
                    },
                },
            },
            [1] = {
                outfits = {
                    {
                        label = 'Đồng phục Solo Cadet',
                        items = {
                            {
                                name   = 'aokhoac',
                                male   = { drawable = 576, texture = 14 },
                                female = { drawable = 623, texture = 14 },
                            },
                            {
                                name   = 'aotrong',
                                male   = { drawable = 226, texture = 0 },
                                -- female = { drawable = 5000, texture = 0 },
                            },
                            {
                                name   = 'quan',
                                male   = { drawable = 232, texture = 5 },
                                female = { drawable = 230, texture = 5 },
                            },
                            {
                                name   = 'giay',
                                male   = { drawable = 54, texture = 0 },
                                female = { drawable = 55, texture = 0 },
                            },
                        },
                    },
                },
            },
            [2] = {
                outfits = {
                    {
                        label = 'Đồng phục Deputy (Tay dài)',
                        items = {
                            {
                                name   = 'aokhoac',
                                male   = { drawable = 578, texture = 14 },
                                female = { drawable = 625, texture = 14 },
                            },
                            {
                                name   = 'aotrong',
                                male   = { drawable = 233, texture = 0 },
                                -- female = { },
                            },
                            {
                                name   = 'giap',
                                male   = { drawable = 66, texture = 0 },
                                female = { drawable = 63, texture = 0 },
                            },
                            {
                                name   = 'quan',
                                male   = { drawable = 232, texture = 5 },
                                female = { drawable = 230, texture = 5 },
                            },
                            {
                                name   = 'giay',
                                male   = { drawable = 54, texture = 0 },
                                female = { drawable = 55, texture = 0 },
                            },
                            {
                                name   = 'huyhieu',
                                male   = { drawable = 211, texture = 1 },
                                female = { drawable = 225, texture = 1 },
                            }
                        },
                    },
                    {
                        label = 'Đồng phục Deputy (Tay ngắn)',
                        items = {
                            {
                                name   = 'aokhoac',
                                male   = { drawable = 577, texture = 14 },
                                female = { drawable = 630, texture = 7 },
                            },
                            {
                                name   = 'aotrong',
                                male   = { drawable = 233, texture = 0 },
                                -- female = {},
                            },
                            {
                                name   = 'giap',
                                male   = { drawable = 66, texture = 0 },
                                female = { drawable = 63, texture = 0 },
                            },
                            {
                                name   = 'quan',
                                male   = { drawable = 232, texture = 5 },
                                female = { drawable = 230, texture = 5 },
                            },
                            {
                                name   = 'giay',
                                male   = { drawable = 54, texture = 0 },
                                female = { drawable = 55, texture = 0 },
                            },
                            {
                                name   = 'huyhieu',
                                male   = { drawable = 210, texture = 1 },
                                female = { drawable = 227, texture = 1 },
                            }
                        },
                    },
                },
            },
            [3] = {
                outfits = {
                    {
                        label = 'Đồng phục Senior Deputy (Tay dài)',
                        items = {
                            {
                                name   = 'aokhoac',
                                male   = { drawable = 578, texture = 14 },
                                female = { drawable = 625, texture = 14 },
                            },
                            {
                                name   = 'aotrong',
                                male   = { drawable = 233, texture = 0 },
                                -- female = {},
                            },
                            {
                                name   = 'giap',
                                male   = { drawable = 66, texture = 0 },
                                female = { drawable = 63, texture = 0 },
                            },
                            {
                                name   = 'quan',
                                male   = { drawable = 232, texture = 5 },
                                female = { drawable = 230, texture = 5 },
                            },
                            {
                                name   = 'giay',
                                male   = { drawable = 54, texture = 0 },
                                female = { drawable = 55, texture = 0 },
                            },
                            {
                                name   = 'huyhieu',
                                male   = { drawable = 211, texture = 2 },
                                female = { drawable = 225, texture = 2 },
                            }
                        },
                    },
                    {
                        label = 'Đồng phục Senior Deputy (Tay ngắn)',
                        items = {
                            {
                                name   = 'aokhoac',
                                male   = { drawable = 577, texture = 14 },
                                female = { drawable = 630, texture = 7 },
                            },
                            {
                                name   = 'aotrong',
                                male   = { drawable = 233, texture = 0 },
                                -- female = {},
                            },
                            {
                                name   = 'giap',
                                male   = { drawable = 66, texture = 0 },
                                female = { drawable = 63, texture = 0 },
                            },
                            {
                                name   = 'quan',
                                male   = { drawable = 232, texture = 5 },
                                female = { drawable = 230, texture = 5 },
                            },
                            {
                                name   = 'giay',
                                male   = { drawable = 54, texture = 0 },
                                female = { drawable = 55, texture = 0 },
                            },
                            {
                                name   = 'huyhieu',
                                male   = { drawable = 210, texture = 2 },
                                female = { drawable = 227, texture = 2 },
                            }
                        },
                    },
                },
            },
            [4] = {
                outfits = {
                    {
                        label = 'Đồng phục Corporal (Tay dài)',
                        items = {
                            {
                                name   = 'aokhoac',
                                male   = { drawable = 578, texture = 14 },
                                female = { drawable = 625, texture = 14 },
                            },
                            {
                                name   = 'aotrong',
                                male   = { drawable = 226, texture = 0 },
                                -- female = {},
                            },
                            {
                                name   = 'giap',
                                male   = { drawable = 65, texture = 0 },
                                female = { drawable = 63, texture = 0 },
                            },
                            {
                                name   = 'quan',
                                male   = { drawable = 232, texture = 5 },
                                female = { drawable = 230, texture = 5 },
                            },
                            {
                                name   = 'giay',
                                male   = { drawable = 54, texture = 0 },
                                female = { drawable = 55, texture = 0 },
                            },
                            {
                                name   = 'huyhieu',
                                male   = { drawable = 211, texture = 3 },
                                female = { drawable = 225, texture = 3 },
                            }
                        },
                    },
                    {
                        label = 'Đồng phục Corporal (Tay ngắn)',
                        items = {
                            {
                                name   = 'aokhoac',
                                male   = { drawable = 577, texture = 14 },
                                female = { drawable = 630, texture = 7 },
                            },
                            {
                                name   = 'aotrong',
                                male   = { drawable = 226, texture = 0 },
                                -- female = {},
                            },
                            {
                                name   = 'giap',
                                male   = { drawable = 65, texture = 0 },
                                female = { drawable = 63, texture = 0 },
                            },
                            {
                                name   = 'quan',
                                male   = { drawable = 232, texture = 5 },
                                female = { drawable = 230, texture = 5 },
                            },
                            {
                                name   = 'giay',
                                male   = { drawable = 54, texture = 0 },
                                female = { drawable = 55, texture = 0 },
                            },
                            {
                                name   = 'huyhieu',
                                male   = { drawable = 210, texture = 3 },
                                female = { drawable = 227, texture = 3 },
                            }
                        },
                    },
                    {
                        label = 'Đồng phục Corporal (Áo khoác)',
                        items = {
                            {
                                name   = 'aokhoac',
                                male   = { drawable = 579, texture = 6 },
                                female = { drawable = 626, texture = 6 },
                            },
                            {
                                name   = 'aotrong',
                                male   = { drawable = 230, texture = 14 },
                                female = { drawable = 294, texture = 14 },
                            },
                            {
                                name   = 'quan',
                                male   = { drawable = 232, texture = 5 },
                                female = { drawable = 230, texture = 5 },
                            },
                            {
                                name   = 'giay',
                                male   = { drawable = 54, texture = 0 },
                                female = { drawable = 55, texture = 0 },
                            },
                            {
                                name   = 'huyhieu',
                                male   = { drawable = 215, texture = 0 },
                                female = { drawable = 229, texture = 0 },
                            }
                        },
                    },
                },
            },
            [5] = {
                outfits = {
                    {
                        label = 'Đồng phục Sergeant (Tay dài)',
                        items = {
                            {
                                name   = 'aokhoac',
                                male   = { drawable = 578, texture = 14 },
                                female = { drawable = 625, texture = 14 },
                            },
                            {
                                name   = 'aotrong',
                                male   = { drawable = 226, texture = 0 },
                                -- female = {},
                            },
                            {
                                name   = 'giap',
                                male   = { drawable = 65, texture = 0 },
                                female = { drawable = 63, texture = 0 },
                            },
                            {
                                name   = 'quan',
                                male   = { drawable = 232, texture = 5 },
                                female = { drawable = 230, texture = 5 },
                            },
                            {
                                name   = 'giay',
                                male   = { drawable = 54, texture = 0 },
                                female = { drawable = 55, texture = 0 },
                            },
                            {
                                name   = 'huyhieu',
                                male   = { drawable = 211, texture = 4 },
                                female = { drawable = 225, texture = 4 },
                            }
                        },
                    },
                    {
                        label = 'Đồng phục Sergeant (Tay ngắn)',
                        items = {
                            {
                                name   = 'aokhoac',
                                male   = { drawable = 577, texture = 14 },
                                female = { drawable = 630, texture = 7 },
                            },
                            {
                                name   = 'aotrong',
                                male   = { drawable = 226, texture = 0 },
                                -- female = {},
                            },
                            {
                                name   = 'giap',
                                male   = { drawable = 65, texture = 0 },
                                female = { drawable = 63, texture = 0 },
                            },
                            {
                                name   = 'quan',
                                male   = { drawable = 232, texture = 5 },
                                female = { drawable = 230, texture = 5 },
                            },
                            {
                                name   = 'giay',
                                male   = { drawable = 54, texture = 0 },
                                female = { drawable = 55, texture = 0 },
                            },
                            {
                                name   = 'huyhieu',
                                male   = { drawable = 210, texture = 4 },
                                female = { drawable = 227, texture = 4 },
                            }
                        },
                    },
                    {
                        label = 'Đồng phục Sergeant (Áo khoác)',
                        items = {
                            {
                                name   = 'aokhoac',
                                male   = { drawable = 579, texture = 6 },
                                female = { drawable = 626, texture = 6 },
                            },
                            {
                                name   = 'aotrong',
                                male   = { drawable = 230, texture = 14 },
                                female = { drawable = 294, texture = 14 },
                            },
                            {
                                name   = 'quan',
                                male   = { drawable = 232, texture = 5 },
                                female = { drawable = 230, texture = 5 },
                            },
                            {
                                name   = 'giay',
                                male   = { drawable = 54, texture = 0 },
                                female = { drawable = 55, texture = 0 },
                            },
                            {
                                name   = 'huyhieu',
                                male   = { drawable = 215, texture = 0 },
                                female = { drawable = 229, texture = 0 },
                            }
                        },
                    },
                },
            },
            [6] = {
                outfits = {
                    {
                        label = 'Đồng phục Lieutenant (Tay dài)',
                        items = {
                            {
                                name   = 'aokhoac',
                                male   = { drawable = 578, texture = 15 },
                                female = { drawable = 625, texture = 15 },
                            },
                            {
                                name   = 'quan',
                                male   = { drawable = 232, texture = 5 },
                                female = { drawable = 230, texture = 5 },
                            },
                            {
                                name   = 'giay',
                                male   = { drawable = 54, texture = 0 },
                                female = { drawable = 55, texture = 0 },
                            },
                            {
                                name   = 'giap',
                                male   = { drawable = 65, texture = 0 },
                                female = { drawable = 63, texture = 0 },
                            },
                            {
                                name   = 'huyhieu',
                                male   = { drawable = 211, texture = 0 },
                                female = { drawable = 225, texture = 0 },
                            }
                        },
                    },
                    {
                        label = 'Đồng phục Lieutenant (Tay ngắn)',
                        items = {
                            {
                                name   = 'aokhoac',
                                male   = { drawable = 577, texture = 16 },
                                female = { drawable = 630, texture = 8 },
                            },
                            {
                                name   = 'aotrong',
                                male   = { drawable = 226, texture = 0 },
                                -- female = {},
                            },
                            {
                                name   = 'giap',
                                male   = { drawable = 65, texture = 0 },
                                female = { drawable = 63, texture = 0 },
                            },
                            {
                                name   = 'quan',
                                male   = { drawable = 232, texture = 5 },
                                female = { drawable = 230, texture = 5 },
                            },
                            {
                                name   = 'giay',
                                male   = { drawable = 54, texture = 0 },
                                female = { drawable = 55, texture = 0 },
                            },
                            {
                                name   = 'huyhieu',
                                male   = { drawable = 210, texture = 0 },
                                female = { drawable = 227, texture = 0 },
                            }
                        },
                    },
                    {
                        label = 'Đồng phục Lieutenant (Áo khoác)',
                        items = {
                            {
                                name   = 'aokhoac',
                                male   = { drawable = 579, texture = 6 },
                                female = { drawable = 626, texture = 6 },
                            },
                            {
                                name   = 'aotrong',
                                male   = { drawable = 230, texture = 15 },
                                female = { drawable = 294, texture = 15 },
                            },
                            {
                                name   = 'quan',
                                male   = { drawable = 232, texture = 5 },
                                female = { drawable = 230, texture = 5 },
                            },
                            {
                                name   = 'giay',
                                male   = { drawable = 54, texture = 0 },
                                female = { drawable = 55, texture = 0 },
                            },
                            {
                                name   = 'huyhieu',
                                male   = { drawable = 215, texture = 0 },
                                female = { drawable = 229, texture = 0 },
                            }
                        },
                    }
                },
            },
            [7] = {
                outfits = {
                    {
                        label = 'Đồng phục Captain (Tay dài)',
                        items = {
                            {
                                name   = 'mu',
                                male   = { drawable = 222, texture = 1 },
                                female = { drawable = 221, texture = 1 },
                            },
                            {
                                name   = 'aokhoac',
                                male   = { drawable = 578, texture = 16 },
                                female = { drawable = 625, texture = 16 },
                            },
                            {
                                name   = 'quan',
                                male   = { drawable = 232, texture = 5 },
                                female = { drawable = 230, texture = 5 },
                            },
                            {
                                name   = 'giay',
                                male   = { drawable = 54, texture = 0 },
                                female = { drawable = 55, texture = 0 },
                            },
                            {
                                name   = 'giap',
                                male   = { drawable = 65, texture = 0 },
                                female = { drawable = 63, texture = 0 },
                            },
                            {
                                name   = 'huyhieu',
                                male   = { drawable = 211, texture = 0 },
                                female = { drawable = 225, texture = 0 },
                            }
                        },
                    },
                    {
                        label = 'Đồng phục Captain (Tay ngắn)',
                        items = {
                            {
                                name   = 'mu',
                                male   = { drawable = 222, texture = 1 },
                                female = { drawable = 221, texture = 1 },
                            },
                            {
                                name   = 'aokhoac',
                                male   = { drawable = 577, texture = 16 },
                                female = { drawable = 630, texture = 9 },
                            },
                            {
                                name   = 'aotrong',
                                male   = { drawable = 226, texture = 0 },
                                -- female = {  },
                            },
                            {
                                name   = 'giap',
                                male   = { drawable = 65, texture = 0 },
                                female = { drawable = 63, texture = 0 },
                            },
                            {
                                name   = 'quan',
                                male   = { drawable = 232, texture = 5 },
                                female = { drawable = 230, texture = 5 },
                            },
                            {
                                name   = 'giay',
                                male   = { drawable = 54, texture = 0 },
                                female = { drawable = 55, texture = 0 },
                            },
                            {
                                name   = 'huyhieu',
                                male   = { drawable = 210, texture = 0 },
                                female = { drawable = 227, texture = 0 },
                            }
                        },
                    },
                    {
                        label = 'Đồng phục Captain (Áo khoác)',
                        items = {
                            {
                                name   = 'mu',
                                male   = { drawable = 222, texture = 1 },
                                female = { drawable = 221, texture = 1 },
                            },
                            {
                                name   = 'aokhoac',
                                male   = { drawable = 581, texture = 0 },
                                female = { drawable = 627, texture = 0 },
                            },
                            {
                                name   = 'aotrong',
                                male   = { drawable = 230, texture = 16 },
                                female = { drawable = 293, texture = 16 },
                            },
                            {
                                name   = 'daychuyen',
                                male   = { drawable = 193, texture = 0 },
                                -- female = {  },
                            },
                            {
                                name   = 'quan',
                                male   = { drawable = 232, texture = 5 },
                                female = { drawable = 230, texture = 5 },
                            },
                            {
                                name   = 'giay',
                                male   = { drawable = 54, texture = 0 },
                                female = { drawable = 55, texture = 0 },
                            },
                        },
                    },
                },
            },
            [8] = {
                outfits = {
                    {
                        label = 'Đồng phục Commander (Tay dài)',
                        items = {
                            {
                                name   = 'mu',
                                male   = { drawable = 222, texture = 1 },
                                female = { drawable = 221, texture = 1 },
                            },
                            {
                                name   = 'aokhoac',
                                male   = { drawable = 578, texture = 17 },
                                female = { drawable = 625, texture = 17 },
                            },
                            {
                                name   = 'quan',
                                male   = { drawable = 232, texture = 5 },
                                female = { drawable = 230, texture = 5 },
                            },
                            {
                                name   = 'giay',
                                male   = { drawable = 54, texture = 0 },
                                female = { drawable = 55, texture = 0 },
                            },
                            {
                                name   = 'giap',
                                male   = { drawable = 65, texture = 0 },
                                female = { drawable = 63, texture = 0 },
                            },
                            {
                                name   = 'huyhieu',
                                male   = { drawable = 211, texture = 0 },
                                female = { drawable = 225, texture = 0 },
                            }
                        },
                    },
                    {
                        label = 'Đồng phục Commander (Tay ngắn)',
                        items = {
                            {
                                name   = 'mu',
                                male   = { drawable = 222, texture = 1 },
                                female = { drawable = 221, texture = 1 },
                            },
                            {
                                name   = 'aokhoac',
                                male   = { drawable = 577, texture = 17 },
                                female = { drawable = 630, texture = 10 },
                            },
                            {
                                name   = 'aotrong',
                                male   = { drawable = 226, texture = 0 },
                                -- female = {  },
                            },
                            {
                                name   = 'giap',
                                male   = { drawable = 65, texture = 0 },
                                female = { drawable = 63, texture = 0 },
                            },
                            {
                                name   = 'quan',
                                male   = { drawable = 232, texture = 5 },
                                female = { drawable = 230, texture = 5 },
                            },
                            {
                                name   = 'giay',
                                male   = { drawable = 54, texture = 0 },
                                female = { drawable = 55, texture = 0 },
                            },
                            {
                                name   = 'huyhieu',
                                male   = { drawable = 210, texture = 0 },
                                female = { drawable = 227, texture = 0 },
                            }
                        },
                    },
                    {
                        label = 'Đồng phục Commander (Áo khoác)',
                        items = {
                            {
                                name   = 'mu',
                                male   = { drawable = 222, texture = 1 },
                                female = { drawable = 221, texture = 1   },
                            },
                            {
                                name   = 'aokhoac',
                                male   = { drawable = 581, texture = 0 },
                                female = { drawable = 627, texture = 0 },
                            },
                            {
                                name   = 'aotrong',
                                male   = { drawable = 230, texture = 17 },
                                female = { drawable = 293, texture = 17 },
                            },
                            {
                                name   = 'daychuyen',
                                male   = { drawable = 193, texture = 0 },
                                -- female = {  },
                            },
                            {
                                name   = 'quan',
                                male   = { drawable = 232, texture = 5 },
                                female = { drawable = 230, texture = 5 },
                            },
                            {
                                name   = 'giay',
                                male   = { drawable = 54, texture = 0 },
                                female = { drawable = 55, texture = 0 },
                            },
                        },
                    },
                },
            },
            [9] = {
                outfits = {
                    {
                        label = 'Đồng phục Chief Deputy (Tay dài)',
                        items = {
                            {
                                name   = 'mu',
                                male   = { drawable = 222, texture = 1 },
                                female = { drawable = 221, texture = 1 },
                            },
                            {
                                name   = 'aokhoac',
                                male   = { drawable = 578, texture = 18 },
                                female = { drawable = 625, texture = 18 },
                            },
                            {
                                name   = 'quan',
                                male   = { drawable = 232, texture = 5 },
                                female = { drawable = 230, texture = 5 },
                            },
                            {
                                name   = 'giay',
                                male   = { drawable = 54, texture = 0 },
                                female = { drawable = 55, texture = 0 },
                            },
                            {
                                name   = 'giap',
                                male   = { drawable = 65, texture = 0 },
                                female = { drawable = 63, texture = 0 },
                            },
                            {
                                name   = 'huyhieu',
                                male   = { drawable = 211, texture = 0 },
                                female = { drawable = 225, texture = 0 },
                            }
                        },
                    },
                    {
                        label = 'Đồng phục Commander (Tay ngắn)',
                        items = {
                            {
                                name   = 'mu',
                                male   = { drawable = 222, texture = 1 },
                                female = { drawable = 221, texture = 1 },
                            },
                            {
                                name   = 'aokhoac',
                                male   = { drawable = 577, texture = 18 },
                                female = { drawable = 630, texture = 11 },
                            },
                            {
                                name   = 'aotrong',
                                male   = { drawable = 226, texture = 0 },
                                -- female = {  },
                            },
                            {
                                name   = 'giap',
                                male   = { drawable = 65, texture = 0 },
                                female = { drawable = 63, texture = 0 },
                            },
                            {
                                name   = 'quan',
                                male   = { drawable = 232, texture = 5 },
                                female = { drawable = 230, texture = 5 },
                            },
                            {
                                name   = 'giay',
                                male   = { drawable = 54, texture = 0 },
                                female = { drawable = 55, texture = 0 },
                            },
                            {
                                name   = 'huyhieu',
                                male   = { drawable = 210, texture = 0 },
                                female = { drawable = 227, texture = 0 },
                            }
                        },
                    },
                    {
                        label = 'Đồng phục Chief Deputy (Áo khoác)',
                        items = {
                            {
                                name   = 'mu',
                                male   = { drawable = 222, texture = 1 },
                                female = { drawable = 221, texture = 1 },
                            },
                            {
                                name   = 'aokhoac',
                                male   = { drawable = 581, texture = 0 },
                                female = { drawable = 627, texture = 0 },
                            },
                            {
                                name   = 'aotrong',
                                male   = { drawable = 230, texture = 18 },
                                female = { drawable = 293, texture = 18 },
                            },
                            {
                                name   = 'daychuyen',
                                male   = { drawable = 193, texture = 0 },
                                -- female = {  },
                            },
                            {
                                name   = 'quan',
                                male   = { drawable = 232, texture = 5 },
                                female = { drawable = 230, texture = 5 },
                            },
                            {
                                name   = 'giay',
                                male   = { drawable = 54, texture = 0 },
                                female = { drawable = 55, texture = 0 },
                            },
                        },
                    },
                },
            },
            [10] = {
                outfits = {
                    {
                        label = 'Đồng phục Undersheriff (Tay dài)',
                        items = {
                            {
                                name   = 'mu',
                                male   = { drawable = 222, texture = 1 },
                                female = { drawable = 221, texture = 1 },
                            },
                            {
                                name   = 'aokhoac',
                                male   = { drawable = 578, texture = 19 },
                                female = { drawable = 625, texture = 19 },
                            },
                            {
                                name   = 'quan',
                                male   = { drawable = 232, texture = 5 },
                                female = { drawable = 230, texture = 5 },
                            },
                            {
                                name   = 'giay',
                                male   = { drawable = 54, texture = 0 },
                                female = { drawable = 55, texture = 0 },
                            },
                            {
                                name   = 'giap',
                                male   = { drawable = 65, texture = 0 },
                                female = { drawable = 63, texture = 0 },
                            },
                            {
                                name   = 'huyhieu',
                                male   = { drawable = 211, texture = 0 },
                                female = { drawable = 225, texture = 0 },
                            }
                        },
                    },
                    {
                        label = 'Đồng phục Undersheriff (Tay ngắn)',
                        items = {
                            {
                                name   = 'mu',
                                male   = { drawable = 222, texture = 1 },
                                female = { drawable = 221, texture = 1 },
                            },
                            {
                                name   = 'aokhoac',
                                male   = { drawable = 577, texture = 19 },
                                female = { drawable = 630, texture = 12 },
                            },
                            {
                                name   = 'aotrong',
                                male   = { drawable = 226, texture = 0 },
                                -- female = {  },
                            },
                            {
                                name   = 'giap',
                                male   = { drawable = 65, texture = 0 },
                                female = { drawable = 63, texture = 0 },
                            },
                            {
                                name   = 'quan',
                                male   = { drawable = 232, texture = 5 },
                                female = { drawable = 230, texture = 5 },
                            },
                            {
                                name   = 'giay',
                                male   = { drawable = 54, texture = 0 },
                                female = { drawable = 55, texture = 0 },
                            },
                            {
                                name   = 'huyhieu',
                                male   = { drawable = 210, texture = 0 },
                                female = { drawable = 227, texture = 0 },
                            }
                        },
                    },
                    -- {
                    --     label = 'Đồng phục Undersheriff (Tự do)',
                    --     items = {
                    --         {
                    --             name   = 'mu',
                    --             male   = { drawable = 222, texture = 1 },
                    --             female = { drawable = 221, texture = 0 },
                    --         },
                    --         {
                    --             name   = 'aokhoac',
                    --             male   = { drawable = 575, texture = 0 },
                    --             female = { drawable = 591, texture = 0 },
                    --         },
                    --         {
                    --             name   = 'giap',
                    --             male   = { drawable = 67, texture = 0 },
                    --             female = { drawable = 591, texture = 0 },
                    --         },
                    --         {
                    --             name   = 'daychuyen',
                    --             male   = { drawable = 193, texture = 0 },
                    --             female = { drawable = 591, texture = 0 },
                    --         },
                    --     },
                    -- },
                },
            },
            [11] = {
                outfits = {
                    {
                        label = 'Đồng phục Sheriff (Tay dài)',
                        items = {
                            {
                                name   = 'mu',
                                male   = { drawable = 222, texture = 1 },
                                female = { drawable = 221, texture = 1 },
                            },
                            {
                                name   = 'aokhoac',
                                male   = { drawable = 578, texture = 20 },
                                female = { drawable = 625, texture = 20 },
                            },
                            {
                                name   = 'quan',
                                male   = { drawable = 232, texture = 5 },
                                female = { drawable = 230, texture = 5 },
                            },
                            {
                                name   = 'giay',
                                male   = { drawable = 54, texture = 0 },
                                female = { drawable = 55, texture = 0 },
                            },
                            {
                                name   = 'giap',
                                male   = { drawable = 65, texture = 0 },
                                female = { drawable = 63, texture = 0 },
                            },
                            {
                                name   = 'huyhieu',
                                male   = { drawable = 211, texture = 0 },
                                female = { drawable = 225, texture = 0 },
                            }
                        },
                    },
                    {
                        label = 'Đồng phục Sheriff (Tay ngắn)',
                        items = {
                            {
                                name   = 'mu',
                                male   = { drawable = 222, texture = 1 },
                                female = { drawable = 221, texture = 1 },
                            },
                            {
                                name   = 'aokhoac',
                                male   = { drawable = 577, texture = 20 },
                                female = { drawable = 630, texture = 13 },
                            },
                            {
                                name   = 'aotrong',
                                male   = { drawable = 226, texture = 0 },
                                -- female = {  },
                            },
                            {
                                name   = 'giap',
                                male   = { drawable = 65, texture = 0 },
                                female = { drawable = 63, texture = 0 },
                            },
                            {
                                name   = 'quan',
                                male   = { drawable = 232, texture = 5 },
                                female = { drawable = 230, texture = 5 },
                            },
                            {
                                name   = 'giay',
                                male   = { drawable = 54, texture = 0 },
                                female = { drawable = 55, texture = 0 },
                            },
                            {
                                name   = 'huyhieu',
                                male   = { drawable = 210, texture = 0 },
                                female = { drawable = 227, texture = 0 },
                            }
                        },
                    },
                    -- {
                    --     label = 'Đồng phục Sheriff (Tự do)',
                    --     items = {
                    --         {
                    --             name   = 'mu',
                    --             male   = { drawable = 222, texture = 1 },
                    --             female = { drawable = 221, texture = 0 },
                    --         },
                    --         {
                    --             name   = 'aokhoac',
                    --             male   = { drawable = 575, texture = 0 },
                    --             female = { drawable = 591, texture = 0 },
                    --         },
                    --         {
                    --             name   = 'giap',
                    --             male   = { drawable = 67, texture = 0 },
                    --             female = { drawable = 591, texture = 0 },
                    --         },
                    --         {
                    --             name   = 'daychuyen',
                    --             male   = { drawable = 193, texture = 0 },
                    --             female = { drawable = 591, texture = 0 },
                    --         },
                    --     },
                    -- },
                },
            }
        },
    },
    police = {
        label = 'Cảnh sát',
        npc = {
            model    = 's_m_y_cop_01',
            coords   = vec4(463.11, -996.57, 30.69, 88.46),
            scenario = 'WORLD_HUMAN_STAND_IMPATIENT',
        },
        backpack = {
            name     = 'balo',
            label    = 'Ba Lô',
            male     = { drawable = 126, texture = 0 },
            female   = { drawable = 129, texture = 0 },
            metadata = { level = 3 },
        },
        grades = {
            [0] = {
                outfits = {
                    {
                        label = 'Đồng phục Cadet',
                        items = {
                            {
                                name   = 'aokhoac',
                                male   = { drawable = 582, texture = 1 },
                                female = { drawable = 628, texture = 1 },
                            },
                            {
                                name   = 'quan',
                                male   = { drawable = 232, texture = 1 },
                                female = { drawable = 230, texture = 1 },
                            },
                            {
                                name   = 'giay',
                                male   = { drawable = 54, texture = 0 },
                                female = { drawable = 55, texture = 0 },
                            },
                            {
                                name   = 'matna',
                                male   = { drawable = 121, texture = 0 },
                                female = { drawable = 121, texture = 0 },
                            },
                        },
                    },
                },
            },
            [1] = {
                -- outfits = {
                --     {
                --         label = 'Đồng phục Solo Cadet',
                --         items = {
                --             {
                --                 name   = 'aokhoac',
                --                 male   = { drawable = 576, texture = 0 },
                --                 female = { drawable = 623, texture = 0 },
                --             },
                --             {
                --                 name   = 'aotrong',
                --                 male   = { drawable = 227, texture = 0 },
                --                 female = { drawable = 259, texture = 0 },
                --             },
                --             {
                --                 name   = 'quan',
                --                 male   = { drawable = 232, texture = 1 },
                --                 female = { drawable = 230, texture = 1 },
                --             },
                --             {
                --                 name   = 'giay',
                --                 male   = { drawable = 54, texture = 0 },
                --                 female = { drawable = 55, texture = 0 },
                --             },
                --             {
                --                 name   = 'matna',
                --                 male   = { drawable = 121, texture = 0 },
                --                 female = { drawable = 121, texture = 0 },
                --             },
                --         },
                --     },
                -- },
                outfits = {
                    {
                        label = 'Đồng phục Solo Cadet (Tay dài)',
                        items = {
                            {
                                name   = 'aokhoac',
                                male   = { drawable = 578, texture = 0 },
                                female = { drawable = 625, texture = 0 },
                            },
                            {
                                name   = 'aotrong',
                                male   = { drawable = 227, texture = 0 },
                                female = { drawable = 259, texture = 0 },
                            },
                            {
                                name   = 'giap',
                                male   = { drawable = 64, texture = 1 },
                                female = { drawable = 63, texture = 1 },
                            },
                            {
                                name   = 'quan',
                                male   = { drawable = 232, texture = 1 },
                                female = { drawable = 230, texture = 1 },
                            },
                            {
                                name   = 'giay',
                                male   = { drawable = 54, texture = 0 },
                                female = { drawable = 55, texture = 0 },
                            },
                            {
                                name   = 'huyhieu',
                                male  = { drawable = 212, texture = 0 },
                                female = { drawable = 226, texture = 0 },
                            },
                            {
                                name   = 'matna',
                                male   = { drawable = 121, texture = 0 },
                                female = { drawable = 121, texture = 0 },
                            },
                            -- {
                            --     name   = 'daychuyen',
                            --     male   = { drawable = 193, texture = 0 },
                            --     female = { drawable = 162, texture = 0 },
                            -- },
                        },
                    },
                    {
                        label = 'Đồng phục Solo Cadet (Tay ngắn)',
                        items = {
                            {
                                name   = 'aokhoac',
                                male   = { drawable = 577, texture = 0 },
                                female = { drawable = 624, texture = 0 },
                            },
                            {
                                name   = 'aotrong',
                                male   = { drawable = 227, texture = 0 },
                                female = { drawable = 259, texture = 0 },
                            },
                            {
                                name   = 'giap',
                                male   = { drawable = 64, texture = 1 },
                                female = { drawable = 63, texture = 1 },
                            },
                            {
                                name   = 'quan',
                                male   = { drawable = 232, texture = 1 },
                                female = { drawable = 230, texture = 1 },
                            },
                            {
                                name   = 'giay',
                                male   = { drawable = 54, texture = 0 },
                                female = { drawable = 55, texture = 0 },
                            },
                            {
                                name   = 'huyhieu',
                                male  = { drawable = 209, texture = 0 },
                                female = { drawable = 228, texture = 0 },
                            },
                            {
                                name   = 'matna',
                                male   = { drawable = 121, texture = 0 },
                                female = { drawable = 121, texture = 0 },
                            },
                            -- {
                            --     name   = 'daychuyen',
                            --     male   = { drawable = 193, texture = 0 },
                            --     female = { drawable = 162, texture = 0 },
                            -- },
                        },
                    },
                },
            },
            [2] = {
                outfits = {
                    {
                        label = 'Đồng phục Officer (Tay dài)',
                        items = {
                            {
                                name   = 'aokhoac',
                                male   = { drawable = 578, texture = 0 },
                                female = { drawable = 625, texture = 0 },
                            },
                            {
                                name   = 'aotrong',
                                male   = { drawable = 227, texture = 0 },
                                female = { drawable = 259, texture = 0 },
                            },
                            {
                                name   = 'giap',
                                male   = { drawable = 64, texture = 1 },
                                female = { drawable = 63, texture = 1 },
                            },
                            {
                                name   = 'quan',
                                male   = { drawable = 232, texture = 1 },
                                female = { drawable = 230, texture = 1 },
                            },
                            {
                                name   = 'giay',
                                male   = { drawable = 54, texture = 0 },
                                female = { drawable = 55, texture = 0 },
                            },
                            {
                                name   = 'huyhieu',
                                male  = { drawable = 212, texture = 1 },
                                female = { drawable = 226, texture = 1 },
                            },
                            {
                                name   = 'matna',
                                male   = { drawable = 121, texture = 0 },
                                female = { drawable = 121, texture = 0 },
                            },
                            {
                                name   = 'daychuyen',
                                male   = { drawable = 193, texture = 0 },
                                female = { drawable = 162, texture = 0 },
                            },
                        },
                    },
                    {
                        label = 'Đồng phục Officer (Tay ngắn)',
                        items = {
                            {
                                name   = 'aokhoac',
                                male   = { drawable = 577, texture = 0 },
                                female = { drawable = 624, texture = 0 },
                            },
                            {
                                name   = 'aotrong',
                                male   = { drawable = 227, texture = 0 },
                                female = { drawable = 259, texture = 0 },
                            },
                            {
                                name   = 'giap',
                                male   = { drawable = 64, texture = 1 },
                                female = { drawable = 63, texture = 1 },
                            },
                            {
                                name   = 'quan',
                                male   = { drawable = 232, texture = 1 },
                                female = { drawable = 230, texture = 1 },
                            },
                            {
                                name   = 'giay',
                                male   = { drawable = 54, texture = 0 },
                                female = { drawable = 55, texture = 0 },
                            },
                            {
                                name   = 'huyhieu',
                                male  = { drawable = 209, texture = 1 },
                                female = { drawable = 228, texture = 1 },
                            },
                            {
                                name   = 'matna',
                                male   = { drawable = 121, texture = 0 },
                                female = { drawable = 121, texture = 0 },
                            },
                            {
                                name   = 'daychuyen',
                                male   = { drawable = 193, texture = 0 },
                                female = { drawable = 162, texture = 0 },
                            },
                        },
                    },
                },
            },
            [3] = {
                outfits = {
                    {
                        label = 'Đồng phục Senior Officer (Tay dài)',
                        items = {
                            {
                                name   = 'aokhoac',
                                male   = { drawable = 578, texture = 0 },
                                female = { drawable = 625, texture = 0 },
                            },
                            {
                                name   = 'aotrong',
                                male   = { drawable = 227, texture = 0 },
                                female = { drawable = 259, texture = 0 },
                            },
                            {
                                name   = 'giap',
                                male   = { drawable = 64, texture = 1 },
                                female = { drawable = 63, texture = 1 },
                            },
                            {
                                name   = 'quan',
                                male   = { drawable = 232, texture = 1 },
                                female = { drawable = 230, texture = 1 },
                            },
                            {
                                name   = 'giay',
                                male   = { drawable = 54, texture = 0 },
                                female = { drawable = 55, texture = 0 },
                            },
                            {
                                name   = 'huyhieu',
                                male  = { drawable = 212, texture = 2 },
                                female = { drawable = 226, texture = 2 },
                            },
                            {
                                name   = 'matna',
                                male   = { drawable = 121, texture = 0 },
                                female = { drawable = 121, texture = 0 },
                            },
                            {
                                name   = 'daychuyen',
                                male   = { drawable = 193, texture = 0 },
                                female = { drawable = 162, texture = 0 },
                            },
                        },
                    },
                    {
                        label = 'Đồng phục Senior Officer (Tay ngắn)',
                        items = {
                            {
                                name   = 'aokhoac',
                                male   = { drawable = 577, texture = 0 },
                                female = { drawable = 624, texture = 0 },
                            },
                            {
                                name   = 'aotrong',
                                male   = { drawable = 227, texture = 0 },
                                female = { drawable = 259, texture = 0 },
                            },
                            {
                                name   = 'giap',
                                male   = { drawable = 64, texture = 1 },
                                female = { drawable = 63, texture = 1 },
                            },
                            {
                                name   = 'quan',
                                male   = { drawable = 232, texture = 1 },
                                female = { drawable = 230, texture = 1 },
                            },
                            {
                                name   = 'giay',
                                male   = { drawable = 54, texture = 0 },
                                female = { drawable = 55, texture = 0 },
                            },
                            {
                                name   = 'huyhieu',
                                male  = { drawable = 209, texture = 2 },
                                female = { drawable = 228, texture = 2 },
                            },
                            {
                                name   = 'matna',
                                male   = { drawable = 121, texture = 0 },
                                female = { drawable = 121, texture = 0 },
                            },
                            {
                                name   = 'daychuyen',
                                male   = { drawable = 193, texture = 0 },
                                female = { drawable = 162, texture = 0 },
                            },
                        },
                    },
                },
            },
            [4] = {
                outfits = {
                    {
                        label = 'Đồng phục Corporal (Tay dài)',
                        items = {
                            {
                                name   = 'aokhoac',
                                male   = { drawable = 578, texture = 0 },
                                female = { drawable = 625, texture = 0 },
                            },
                            {
                                name   = 'aotrong',
                                male   = { drawable = 227, texture = 0 },
                                female = { drawable = 259, texture = 0 },
                            },
                            {
                                name   = 'giap',
                                male   = { drawable = 64, texture = 1 },
                                female = { drawable = 63, texture = 1 },
                            },
                            {
                                name   = 'quan',
                                male   = { drawable = 232, texture = 1 },
                                female = { drawable = 230, texture = 1 },
                            },
                            {
                                name   = 'giay',
                                male   = { drawable = 54, texture = 0 },
                                female = { drawable = 55, texture = 0 },
                            },
                            {
                                name   = 'huyhieu',
                                male  = { drawable = 212, texture = 3 },
                                female = { drawable = 226, texture = 3 },
                            },
                            {
                                name   = 'matna',
                                male   = { drawable = 121, texture = 0 },
                                female = { drawable = 121, texture = 0 },
                            },
                            {
                                name   = 'daychuyen',
                                male   = { drawable = 193, texture = 0 },
                                female = { drawable = 162, texture = 0 },
                            },
                        },
                    },
                    {
                        label = 'Đồng phục Corporal (Tay ngắn)',
                        items = {
                            {
                                name   = 'aokhoac',
                                male   = { drawable = 577, texture = 0 },
                                female = { drawable = 624, texture = 0 },
                            },
                            {
                                name   = 'aotrong',
                                male   = { drawable = 227, texture = 0 },
                                female = { drawable = 259, texture = 0 },
                            },
                            {
                                name   = 'giap',
                                male   = { drawable = 64, texture = 1 },
                                female = { drawable = 63, texture = 1 },
                            },
                            {
                                name   = 'quan',
                                male   = { drawable = 232, texture = 1 },
                                female = { drawable = 230, texture = 1 },
                            },
                            {
                                name   = 'giay',
                                male   = { drawable = 54, texture = 0 },
                                female = { drawable = 55, texture = 0 },
                            },
                            {
                                name   = 'huyhieu',
                                male  = { drawable = 209, texture = 3 },
                                female = { drawable = 228, texture = 3 },
                            },
                            {
                                name   = 'matna',
                                male   = { drawable = 121, texture = 0 },
                                female = { drawable = 121, texture = 0 },
                            },
                            {
                                name   = 'daychuyen',
                                male   = { drawable = 193, texture = 0 },
                                female = { drawable = 162, texture = 0 },
                            },
                        },
                    },
                    {
                        label = 'Đồng phục Corporal (Áo khoác)',
                        items = {
                            {
                                name   = 'aokhoac',
                                male   = { drawable = 579, texture = 1 },
                                female = { drawable = 626, texture = 1 },
                            },
                            {
                                name   = 'aotrong',
                                male   = { drawable = 230, texture = 0 },
                                female = { drawable = 259, texture = 0 },
                            },
                            -- {
                            --     name   = 'giap',
                            --     male   = { drawable = 65, texture = 1 },
                            --     female = { drawable = 63, texture = 1 },
                            -- },
                            {
                                name   = 'quan',
                                male   = { drawable = 232, texture = 1 },
                                female = { drawable = 230, texture = 1 },
                            },
                            {
                                name   = 'giay',
                                male   = { drawable = 54, texture = 0 },
                                female = { drawable = 55, texture = 0 },
                            },
                            {
                                name   = 'huyhieu',
                                male  = { drawable = 216, texture = 0 },
                                female = { drawable = 230, texture = 0 },
                            },
                            {
                                name   = 'matna',
                                male   = { drawable = 121, texture = 0 },
                                female = { drawable = 121, texture = 0 },
                            },
                            {
                                name   = 'daychuyen',
                                male   = { drawable = 193, texture = 0 },
                                female = { drawable = 162, texture = 0 },
                            },
                        },
                    },
                },
            },
            [5] = {
                outfits = {
                    {
                        label = 'Đồng phục Sergeant (Tay dài)',
                        items = {
                            {
                                name   = 'aokhoac',
                                male   = { drawable = 578, texture = 0 },
                                female = { drawable = 625, texture = 0 },
                            },
                            {
                                name   = 'aotrong',
                                male   = { drawable = 227, texture = 0 },
                                female = { drawable = 259, texture = 0 },
                            },
                            {
                                name   = 'giap',
                                male   = { drawable = 64, texture = 1 },
                                female = { drawable = 63, texture = 1 },
                            },
                            {
                                name   = 'quan',
                                male   = { drawable = 232, texture = 1 },
                                female = { drawable = 230, texture = 1 },
                            },
                            {
                                name   = 'giay',
                                male   = { drawable = 54, texture = 0 },
                                female = { drawable = 55, texture = 0 },
                            },
                            {
                                name   = 'huyhieu',
                                male  = { drawable = 212, texture = 4 },
                                female = { drawable = 226, texture = 4 },
                            },
                            {
                                name   = 'matna',
                                male   = { drawable = 121, texture = 0 },
                                female = { drawable = 121, texture = 0 },
                            },
                            {
                                name   = 'daychuyen',
                                male   = { drawable = 193, texture = 0 },
                                female = { drawable = 162, texture = 0 },
                            },
                        },
                    },
                    {
                        label = 'Đồng phục Sergeant (Tay ngắn)',
                        items = {
                            {
                                name   = 'aokhoac',
                                male   = { drawable = 577, texture = 0 },
                                female = { drawable = 624, texture = 0 },
                            },
                            {
                                name   = 'aotrong',
                                male   = { drawable = 227, texture = 0 },
                                female = { drawable = 259, texture = 0 },
                            },
                            {
                                name   = 'giap',
                                male   = { drawable = 64, texture = 1 },
                                female = { drawable = 63, texture = 1 },
                            },
                            {
                                name   = 'quan',
                                male   = { drawable = 232, texture = 1 },
                                female = { drawable = 230, texture = 1 },
                            },
                            {
                                name   = 'giay',
                                male   = { drawable = 54, texture = 0 },
                                female = { drawable = 55, texture = 0 },
                            },
                            {
                                name   = 'huyhieu',
                                male  = { drawable = 209, texture = 4 },
                                female = { drawable = 228, texture = 4 },
                            },
                            {
                                name   = 'matna',
                                male   = { drawable = 121, texture = 0 },
                                female = { drawable = 121, texture = 0 },
                            },
                            {
                                name   = 'daychuyen',
                                male   = { drawable = 193, texture = 0 },
                                female = { drawable = 162, texture = 0 },
                            },
                        },
                    },
                    {
                        label = 'Đồng phục Sergeant (Áo khoác)',
                        items = {
                            {
                                name   = 'aokhoac',
                                male   = { drawable = 579, texture = 1 },
                                female = { drawable = 626, texture = 1 },
                            },
                            {
                                name   = 'aotrong',
                                male   = { drawable = 230, texture = 0 },
                                female = { drawable = 259, texture = 0 },
                            },
                            -- {
                            --     name   = 'giap',
                            --     male   = { drawable = 65, texture = 1 },
                            --     female = { drawable = 63, texture = 1 },
                            -- },
                            {
                                name   = 'quan',
                                male   = { drawable = 232, texture = 1 },
                                female = { drawable = 230, texture = 1 },
                            },
                            {
                                name   = 'giay',
                                male   = { drawable = 54, texture = 0 },
                                female = { drawable = 55, texture = 0 },
                            },
                            {
                                name   = 'huyhieu',
                                male  = { drawable = 216, texture = 0 },
                                female = { drawable = 230, texture = 0 },
                            },
                            {
                                name   = 'matna',
                                male   = { drawable = 121, texture = 0 },
                                female = { drawable = 121, texture = 0 },
                            },
                            {
                                name   = 'daychuyen',
                                male   = { drawable = 193, texture = 0 },
                                female = { drawable = 162, texture = 0 },
                            },
                        },
                    },
                },
            },
            [6] = {
                outfits = {
                    {
                        label = 'Đồng phục Lieutenant (Tay dài)',
                        items = {
                            {
                                name   = 'mu',
                                male   = { drawable = 222, texture = 0 },
                                female = { drawable = 221, texture = 0 },
                            },
                            {
                                name   = 'aokhoac',
                                male   = { drawable = 578, texture = 1 },
                                female = { drawable = 625, texture = 1 },
                            },
                            {
                                name   = 'aotrong',
                                male   = { drawable = 227, texture = 0 },
                                female = { drawable = 259, texture = 0 },
                            },
                            {
                                name   = 'giap',
                                male   = { drawable = 65, texture = 1 },
                                female = { drawable = 63, texture = 1 },
                            },
                            {
                                name   = 'quan',
                                male   = { drawable = 232, texture = 1 },
                                female = { drawable = 230, texture = 1 },
                            },
                            {
                                name   = 'giay',
                                male   = { drawable = 54, texture = 0 },
                                female = { drawable = 55, texture = 0 },
                            },
                            {
                                name   = 'huyhieu',
                                male  = { drawable = 212, texture = 0 },
                                female = { drawable = 226, texture = 0 },
                            },
                            {
                                name   = 'matna',
                                male   = { drawable = 121, texture = 0 },
                                female = { drawable = 121, texture = 0 },
                            },
                            {
                                name   = 'daychuyen',
                                male   = { drawable = 193, texture = 0 },
                                female = { drawable = 162, texture = 0 },
                            },
                        },
                    },
                    {
                        label = 'Đồng phục Lieutenant (Tay ngắn)',
                        items = {
                            {
                                name   = 'mu',
                                male   = { drawable = 222, texture = 0 },
                                female = { drawable = 221, texture = 0 },
                            },
                            {
                                name   = 'aokhoac',
                                male   = { drawable = 577, texture = 1 },
                                female = { drawable = 624, texture = 1 },
                            },
                            {
                                name   = 'aotrong',
                                male   = { drawable = 227, texture = 0 },
                                female = { drawable = 259, texture = 0 },
                            },
                            {
                                name   = 'giap',
                                male   = { drawable = 65, texture = 1 },
                                female = { drawable = 63, texture = 1 },
                            },
                            {
                                name   = 'quan',
                                male   = { drawable = 232, texture = 1 },
                                female = { drawable = 230, texture = 1 },
                            },
                            {
                                name   = 'giay',
                                male   = { drawable = 54, texture = 0 },
                                female = { drawable = 55, texture = 0 },
                            },
                            {
                                name   = 'huyhieu',
                                male  = { drawable = 209, texture = 0 },
                                female = { drawable = 228, texture = 0 },
                            },
                            {
                                name   = 'matna',
                                male   = { drawable = 121, texture = 0 },
                                female = { drawable = 121, texture = 0 },
                            },
                            {
                                name   = 'daychuyen',
                                male   = { drawable = 193, texture = 0 },
                                female = { drawable = 162, texture = 0 },
                            },
                        },
                    },
                    {
                        label = 'Đồng phục Lieutenant (Áo khoác)',
                        items = {
                            {
                                name   = 'mu',
                                male   = { drawable = 222, texture = 0 },
                                female = { drawable = 221, texture = 0 },
                            },
                            {
                                name   = 'aokhoac',
                                male   = { drawable = 579, texture = 1 },
                                female = { drawable = 626, texture = 1 },
                            },
                            {
                                name   = 'aotrong',
                                male   = { drawable = 230, texture = 1 },
                                female = { drawable = 292, texture = 1 },
                            },
                            -- {
                            --     name   = 'giap',
                            --     male   = { drawable = 65, texture = 1 },
                            --     female = { drawable = 63, texture = 1 },
                            -- },
                            {
                                name   = 'quan',
                                male   = { drawable = 232, texture = 1 },
                                female = { drawable = 230, texture = 1 },
                            },
                            {
                                name   = 'giay',
                                male   = { drawable = 54, texture = 0 },
                                female = { drawable = 55, texture = 0 },
                            },
                            {
                                name   = 'huyhieu',
                                male  = { drawable = 216, texture = 0 },
                                female = { drawable = 230, texture = 0 },
                            },
                            {
                                name   = 'matna',
                                male   = { drawable = 121, texture = 0 },
                                female = { drawable = 121, texture = 0 },
                            },
                            {
                                name   = 'daychuyen',
                                male   = { drawable = 193, texture = 0 },
                                female = { drawable = 162, texture = 0 },
                            },
                        },
                    },
                },
            },
            [7] = {
                outfits = {
                    {
                        label = 'Đồng phục Captain (Tay dài)',
                        items = {
                            {
                                name   = 'mu',
                                male   = { drawable = 222, texture = 0 },
                                female = { drawable = 221, texture = 0 },
                            },
                            {
                                name   = 'aokhoac',
                                male   = { drawable = 578, texture = 2 },
                                female = { drawable = 625, texture = 2 },
                            },
                            {
                                name   = 'aotrong',
                                male   = { drawable = 227, texture = 0 },
                                female = { drawable = 259, texture = 0 },
                            },
                            {
                                name   = 'giap',
                                male   = { drawable = 65, texture = 1 },
                                female = { drawable = 63, texture = 1 },
                            },
                            {
                                name   = 'quan',
                                male   = { drawable = 232, texture = 1 },
                                female = { drawable = 230, texture = 1 },
                            },
                            {
                                name   = 'giay',
                                male   = { drawable = 54, texture = 0 },
                                female = { drawable = 55, texture = 0 },
                            },
                            {
                                name   = 'huyhieu',
                                male  = { drawable = 212, texture = 0 },
                                female = { drawable = 226, texture = 0 },
                            },
                            {
                                name   = 'matna',
                                male   = { drawable = 121, texture = 0 },
                                female = { drawable = 121, texture = 0 },
                            },
                            {
                                name   = 'daychuyen',
                                male   = { drawable = 193, texture = 0 },
                                female = { drawable = 162, texture = 0 },
                            },
                        },
                    },
                    {
                        label = 'Đồng phục Captain (Tay ngắn)',
                        items = {
                            {
                                name   = 'mu',
                                male   = { drawable = 222, texture = 0 },
                                female = { drawable = 221, texture = 0 },
                            },
                            {
                                name   = 'aokhoac',
                                male   = { drawable = 577, texture = 2 },
                                female = { drawable = 624, texture = 2 },
                            },
                            {
                                name   = 'aotrong',
                                male   = { drawable = 227, texture = 0 },
                                female = { drawable = 259, texture = 0 },
                            },
                            {
                                name   = 'giap',
                                male   = { drawable = 65, texture = 1 },
                                female = { drawable = 63, texture = 1 },
                            },
                            {
                                name   = 'quan',
                                male   = { drawable = 232, texture = 1 },
                                female = { drawable = 230, texture = 1 },
                            },
                            {
                                name   = 'giay',
                                male   = { drawable = 54, texture = 0 },
                                female = { drawable = 55, texture = 0 },
                            },
                            {
                                name   = 'huyhieu',
                                male  = { drawable = 209, texture = 0 },
                                female = { drawable = 228, texture = 0 },
                            },
                            {
                                name   = 'matna',
                                male   = { drawable = 121, texture = 0 },
                                female = { drawable = 121, texture = 0 },
                            },
                            {
                                name   = 'daychuyen',
                                male   = { drawable = 193, texture = 0 },
                                female = { drawable = 162, texture = 0 },
                            },
                        },
                    },
                    {
                        label = 'Đồng phục Captain (Áo khoác)',
                        items = {
                            {
                                name   = 'mu',
                                male   = { drawable = 222, texture = 0 },
                                female = { drawable = 221, texture = 0 },
                            },
                            {
                                name   = 'aokhoac',
                                male   = { drawable = 579, texture = 1 },
                                female = { drawable = 626, texture = 1 },
                            },
                            {
                                name   = 'aotrong',
                                male   = { drawable = 230, texture = 2 },
                                female = { drawable = 292, texture = 2 },
                            },
                            -- {
                            --     name   = 'giap',
                            --     male   = { drawable = 65, texture = 1 },
                            --     female = { drawable = 63, texture = 1 },
                            -- },
                            {
                                name   = 'quan',
                                male   = { drawable = 232, texture = 1 },
                                female = { drawable = 230, texture = 1 },
                            },
                            {
                                name   = 'giay',
                                male   = { drawable = 54, texture = 0 },
                                female = { drawable = 55, texture = 0 },
                            },
                            {
                                name   = 'huyhieu',
                                male  = { drawable = 216, texture = 0 },
                                female = { drawable = 230, texture = 0 },
                            },
                            {
                                name   = 'matna',
                                male   = { drawable = 121, texture = 0 },
                                female = { drawable = 121, texture = 0 },
                            },
                            {
                                name   = 'daychuyen',
                                male   = { drawable = 193, texture = 0 },
                                female = { drawable = 162, texture = 0 },
                            },
                        },
                    },
                },
            },
            [8] = {
                outfits = {
                    {
                        label = 'Đồng phục Commander (Tay dài)',
                        items = {
                            {
                                name   = 'mu',
                                male   = { drawable = 222, texture = 0 },
                                female = { drawable = 221, texture = 0 },
                            },
                            {
                                name   = 'aokhoac',
                                male   = { drawable = 578, texture = 3 },
                                female = { drawable = 625, texture = 3 },
                            },
                            {
                                name   = 'aotrong',
                                male   = { drawable = 227, texture = 0 },
                                female = { drawable = 259, texture = 0 },
                            },
                            {
                                name   = 'giap',
                                male   = { drawable = 65, texture = 1 },
                                female = { drawable = 63, texture = 1 },
                            },
                            {
                                name   = 'quan',
                                male   = { drawable = 232, texture = 1 },
                                female = { drawable = 230, texture = 1 },
                            },
                            {
                                name   = 'giay',
                                male   = { drawable = 54, texture = 0 },
                                female = { drawable = 55, texture = 0 },
                            },
                            {
                                name   = 'huyhieu',
                                male  = { drawable = 212, texture = 0 },
                                female = { drawable = 226, texture = 0 },
                            },
                            {
                                name   = 'matna',
                                male   = { drawable = 121, texture = 0 },
                                female = { drawable = 121, texture = 0 },
                            },
                            {
                                name   = 'daychuyen',
                                male   = { drawable = 193, texture = 0 },
                                female = { drawable = 162, texture = 0 },
                            },
                        },
                    },
                    {
                        label = 'Đồng phục Commander (Tay ngắn)',
                        items = {
                            {
                                name   = 'mu',
                                male   = { drawable = 222, texture = 0 },
                                female = { drawable = 221, texture = 0 },
                            },
                            {
                                name   = 'aokhoac',
                                male   = { drawable = 577, texture = 3 },
                                female = { drawable = 624, texture = 3 },
                            },
                            {
                                name   = 'aotrong',
                                male   = { drawable = 227, texture = 0 },
                                female = { drawable = 259, texture = 0 },
                            },
                            {
                                name   = 'giap',
                                male   = { drawable = 65, texture = 1 },
                                female = { drawable = 63, texture = 1 },
                            },
                            {
                                name   = 'quan',
                                male   = { drawable = 232, texture = 1 },
                                female = { drawable = 230, texture = 1 },
                            },
                            {
                                name   = 'giay',
                                male   = { drawable = 54, texture = 0 },
                                female = { drawable = 55, texture = 0 },
                            },
                            {
                                name   = 'huyhieu',
                                male  = { drawable = 209, texture = 0 },
                                female = { drawable = 228, texture = 0 },
                            },
                            {
                                name   = 'matna',
                                male   = { drawable = 121, texture = 0 },
                                female = { drawable = 121, texture = 0 },
                            },
                            {
                                name   = 'daychuyen',
                                male   = { drawable = 193, texture = 0 },
                                female = { drawable = 162, texture = 0 },
                            },
                        },
                    },
                    {
                        label = 'Đồng phục Commander (Áo khoác)',
                        items = {
                            {
                                name   = 'mu',
                                male   = { drawable = 222, texture = 0 },
                                female = { drawable = 221, texture = 0 },
                            },
                            {
                                name   = 'aokhoac',
                                male   = { drawable = 581, texture = 1 },
                                female = { drawable = 627, texture = 1 },
                            },
                            {
                                name   = 'aotrong',
                                male   = { drawable = 230, texture = 3 },
                                female = { drawable = 292, texture = 3 },
                            },
                            -- {
                            --     name   = 'giap',
                            --     male   = { drawable = 65, texture = 1 },
                            --     female = { drawable = 63, texture = 1 },
                            -- },
                            {
                                name   = 'quan',
                                male   = { drawable = 232, texture = 1 },
                                female = { drawable = 230, texture = 1 },
                            },
                            {
                                name   = 'giay',
                                male   = { drawable = 54, texture = 0 },
                                female = { drawable = 55, texture = 0 },
                            },
                            {
                                name   = 'matna',
                                male   = { drawable = 121, texture = 0 },
                                female = { drawable = 121, texture = 0 },
                            },
                            {
                                name   = 'daychuyen',
                                male   = { drawable = 193, texture = 0 },
                                female = { drawable = 162, texture = 0 },
                            },
                        },
                    },
                },
            },
            [9] = {
                outfits = {
                     {
                        label = 'Đồng phục Deputy Chief (Tay dài)',
                        items = {
                            {
                                name   = 'mu',
                                male   = { drawable = 222, texture = 0 },
                                female = { drawable = 221, texture = 0 },
                            },
                            {
                                name   = 'aokhoac',
                                male   = { drawable = 578, texture = 4 },
                                female = { drawable = 625, texture = 4 },
                            },
                            {
                                name   = 'aotrong',
                                male   = { drawable = 227, texture = 0 },
                                female = { drawable = 259, texture = 0 },
                            },
                            {
                                name   = 'giap',
                                male   = { drawable = 65, texture = 1 },
                                female = { drawable = 63, texture = 1 },
                            },
                            {
                                name   = 'quan',
                                male   = { drawable = 232, texture = 1 },
                                female = { drawable = 230, texture = 1 },
                            },
                            {
                                name   = 'giay',
                                male   = { drawable = 54, texture = 0 },
                                female = { drawable = 55, texture = 0 },
                            },
                            {
                                name   = 'huyhieu',
                                male  = { drawable = 212, texture = 0 },
                                female = { drawable = 226, texture = 0 },
                            },
                            {
                                name   = 'matna',
                                male   = { drawable = 121, texture = 0 },
                                female = { drawable = 121, texture = 0 },
                            },
                            {
                                name   = 'daychuyen',
                                male   = { drawable = 193, texture = 0 },
                                female = { drawable = 162, texture = 0 },
                            },
                        },
                    },
                    {
                        label = 'Đồng phục Deputy Chief (Tay ngắn)',
                        items = {
                            {
                                name   = 'mu',
                                male   = { drawable = 222, texture = 0 },
                                female = { drawable = 221, texture = 0 },
                            },
                            {
                                name   = 'aokhoac',
                                male   = { drawable = 577, texture = 4 },
                                female = { drawable = 624, texture = 4 },
                            },
                            {
                                name   = 'aotrong',
                                male   = { drawable = 227, texture = 0 },
                                female = { drawable = 259, texture = 0 },
                            },
                            {
                                name   = 'giap',
                                male   = { drawable = 65, texture = 1 },
                                female = { drawable = 63, texture = 1 },
                            },
                            {
                                name   = 'quan',
                                male   = { drawable = 232, texture = 1 },
                                female = { drawable = 230, texture = 1 },
                            },
                            {
                                name   = 'giay',
                                male   = { drawable = 54, texture = 0 },
                                female = { drawable = 55, texture = 0 },
                            },
                            {
                                name   = 'huyhieu',
                                male  = { drawable = 209, texture = 0 },
                                female = { drawable = 228, texture = 0 },
                            },
                            {
                                name   = 'matna',
                                male   = { drawable = 121, texture = 0 },
                                female = { drawable = 121, texture = 0 },
                            },
                            {
                                name   = 'daychuyen',
                                male   = { drawable = 193, texture = 0 },
                                female = { drawable = 162, texture = 0 },
                            },
                        },
                    },
                    {
                        label = 'Đồng phục Deputy Chief (Áo khoác)',
                        items = {
                            {
                                name   = 'mu',
                                male   = { drawable = 222, texture = 0 },
                                female = { drawable = 221, texture = 0 },
                            },
                            {
                                name   = 'aokhoac',
                                male   = { drawable = 581, texture = 1 },
                                female = { drawable = 627, texture = 1 },
                            },
                            {
                                name   = 'aotrong',
                                male   = { drawable = 230, texture = 4 },
                                female = { drawable = 292, texture = 4 },
                            },
                            -- {
                            --     name   = 'giap',
                            --     male   = { drawable = 65, texture = 1 },
                            --     female = { drawable = 63, texture = 1 },
                            -- },
                            {
                                name   = 'quan',
                                male   = { drawable = 232, texture = 1 },
                                female = { drawable = 230, texture = 1 },
                            },
                            {
                                name   = 'giay',
                                male   = { drawable = 54, texture = 0 },
                                female = { drawable = 55, texture = 0 },
                            },
                            {
                                name   = 'matna',
                                male   = { drawable = 121, texture = 0 },
                                female = { drawable = 121, texture = 0 },
                            },
                            {
                                name   = 'daychuyen',
                                male   = { drawable = 193, texture = 0 },
                                female = { drawable = 162, texture = 0 },
                            },
                        },
                    },
                },
            },
            [10] = {
                outfits = {
                    {
                        label = 'Đồng phục Assistant Chief (Tay dài)',
                        items = {
                            {
                                name   = 'mu',
                                male   = { drawable = 222, texture = 0 },
                                female = { drawable = 221, texture = 0 },
                            },
                            {
                                name   = 'aokhoac',
                                male   = { drawable = 578, texture = 5 },
                                female = { drawable = 625, texture = 5 },
                            },
                            {
                                name   = 'aotrong',
                                male   = { drawable = 227, texture = 0 },
                                female = { drawable = 259, texture = 0 },
                            },
                            {
                                name   = 'giap',
                                male   = { drawable = 65, texture = 1 },
                                female = { drawable = 63, texture = 1 },
                            },
                            {
                                name   = 'quan',
                                male   = { drawable = 232, texture = 1 },
                                female = { drawable = 230, texture = 1 },
                            },
                            {
                                name   = 'giay',
                                male   = { drawable = 54, texture = 0 },
                                female = { drawable = 55, texture = 0 },
                            },
                            {
                                name   = 'huyhieu',
                                male  = { drawable = 212, texture = 0 },
                                female = { drawable = 226, texture = 0 },
                            },
                            {
                                name   = 'matna',
                                male   = { drawable = 121, texture = 0 },
                                female = { drawable = 121, texture = 0 },
                            },
                            {
                                name   = 'daychuyen',
                                male   = { drawable = 193, texture = 0 },
                                female = { drawable = 162, texture = 0 },
                            },
                        },
                    },
                    {
                        label = 'Đồng phục Assistant Chief (Tay ngắn)',
                        items = {
                            {
                                name   = 'mu',
                                male   = { drawable = 222, texture = 0 },
                                female = { drawable = 221, texture = 0 },
                            },
                            {
                                name   = 'aokhoac',
                                male   = { drawable = 577, texture = 5 },
                                female = { drawable = 624, texture = 5 },
                            },
                            {
                                name   = 'aotrong',
                                male   = { drawable = 227, texture = 0 },
                                female = { drawable = 259, texture = 0 },
                            },
                            {
                                name   = 'giap',
                                male   = { drawable = 65, texture = 1 },
                                female = { drawable = 63, texture = 1 },
                            },
                            {
                                name   = 'quan',
                                male   = { drawable = 232, texture = 1 },
                                female = { drawable = 230, texture = 1 },
                            },
                            {
                                name   = 'giay',
                                male   = { drawable = 54, texture = 0 },
                                female = { drawable = 55, texture = 0 },
                            },
                            {
                                name   = 'huyhieu',
                                male  = { drawable = 209, texture = 0 },
                                female = { drawable = 228, texture = 0 },
                            },
                            {
                                name   = 'matna',
                                male   = { drawable = 121, texture = 0 },
                                female = { drawable = 121, texture = 0 },
                            },
                            {
                                name   = 'daychuyen',
                                male   = { drawable = 193, texture = 0 },
                                female = { drawable = 162, texture = 0 },
                            },
                        },
                    },
                    {
                        label = 'Đồng phục Assistant Chief (Áo khoác)',
                        items = {
                            {
                                name   = 'mu',
                                male   = { drawable = 222, texture = 0 },
                                female = { drawable = 221, texture = 0 },
                            },
                            {
                                name   = 'aokhoac',
                                male   = { drawable = 581, texture = 1 },
                                female = { drawable = 627, texture = 1 },
                            },
                            {
                                name   = 'aotrong',
                                male   = { drawable = 230, texture = 5 },
                                female = { drawable = 292, texture = 5 },
                            },
                            -- {
                            --     name   = 'giap',
                            --     male   = { drawable = 65, texture = 1 },
                            --     female = { drawable = 63, texture = 1 },
                            -- },
                            {
                                name   = 'quan',
                                male   = { drawable = 232, texture = 1 },
                                female = { drawable = 230, texture = 1 },
                            },
                            {
                                name   = 'giay',
                                male   = { drawable = 54, texture = 0 },
                                female = { drawable = 55, texture = 0 },
                            },
                            {
                                name   = 'matna',
                                male   = { drawable = 121, texture = 0 },
                                female = { drawable = 121, texture = 0 },
                            },
                            {
                                name   = 'daychuyen',
                                male   = { drawable = 193, texture = 0 },
                                female = { drawable = 162, texture = 0 },
                            },
                        },
                    },
                },
            },
            [11] = {
                outfits = {
                    {
                        label = 'Đồng phục Chief of Police (Tay dài)',
                        items = {
                            {
                                name   = 'mu',
                                male   = { drawable = 222, texture = 0 },
                                female = { drawable = 221, texture = 0 },
                            },
                            {
                                name   = 'aokhoac',
                                male   = { drawable = 578, texture = 6 },
                                female = { drawable = 625, texture = 6 },
                            },
                            {
                                name   = 'aotrong',
                                male   = { drawable = 227, texture = 0 },
                                female = { drawable = 259, texture = 0 },
                            },
                            {
                                name   = 'giap',
                                male   = { drawable = 65, texture = 1 },
                                female = { drawable = 63, texture = 1 },
                            },
                            {
                                name   = 'quan',
                                male   = { drawable = 232, texture = 1 },
                                female = { drawable = 230, texture = 1 },
                            },
                            {
                                name   = 'giay',
                                male   = { drawable = 54, texture = 0 },
                                female = { drawable = 55, texture = 0 },
                            },
                            {
                                name   = 'huyhieu',
                                male  = { drawable = 212, texture = 0 },
                                female = { drawable = 226, texture = 0 },
                            },
                            {
                                name   = 'matna',
                                male   = { drawable = 121, texture = 0 },
                                female = { drawable = 121, texture = 0 },
                            },
                            {
                                name   = 'daychuyen',
                                male   = { drawable = 193, texture = 0 },
                                female = { drawable = 162, texture = 0 },
                            },
                        },
                    },
                    {
                        label = 'Đồng phục Chief of Police (Tay ngắn)',
                        items = {
                            {
                                name   = 'mu',
                                male   = { drawable = 222, texture = 0 },
                                female = { drawable = 221, texture = 0 },
                            },
                            {
                                name   = 'aokhoac',
                                male   = { drawable = 577, texture = 6 },
                                female = { drawable = 624, texture = 6 },
                            },
                            {
                                name   = 'aotrong',
                                male   = { drawable = 227, texture = 0 },
                                female = { drawable = 259, texture = 0 },
                            },
                            {
                                name   = 'giap',
                                male   = { drawable = 65, texture = 1 },
                                female = { drawable = 63, texture = 1 },
                            },
                            {
                                name   = 'quan',
                                male   = { drawable = 232, texture = 1 },
                                female = { drawable = 230, texture = 1 },
                            },
                            {
                                name   = 'giay',
                                male   = { drawable = 54, texture = 0 },
                                female = { drawable = 55, texture = 0 },
                            },
                            {
                                name   = 'huyhieu',
                                male  = { drawable = 209, texture = 0 },
                                female = { drawable = 228, texture = 0 },
                            },
                            {
                                name   = 'matna',
                                male   = { drawable = 121, texture = 0 },
                                female = { drawable = 121, texture = 0 },
                            },
                            {
                                name   = 'daychuyen',
                                male   = { drawable = 193, texture = 0 },
                                female = { drawable = 162, texture = 0 },
                            },
                        },
                    },
                    {
                        label = 'Đồng phục Chief of Police (Áo khoác)',
                        items = {
                            {
                                name   = 'mu',
                                male   = { drawable = 222, texture = 0 },
                                female = { drawable = 221, texture = 0 },
                            },
                            {
                                name   = 'aokhoac',
                                male   = { drawable = 581, texture = 1 },
                                female = { drawable = 627, texture = 1 },
                            },
                            {
                                name   = 'aotrong',
                                male   = { drawable = 230, texture = 6 },
                                female = { drawable = 292, texture = 6 },
                            },
                            -- {
                            --     name   = 'giap',
                            --     male   = { drawable = 65, texture = 1 },
                            --     female = { drawable = 63, texture = 1 },
                            -- },
                            {
                                name   = 'quan',
                                male   = { drawable = 232, texture = 1 },
                                female = { drawable = 230, texture = 1 },
                            },
                            {
                                name   = 'giay',
                                male   = { drawable = 54, texture = 0 },
                                female = { drawable = 55, texture = 0 },
                            },
                            {
                                name   = 'matna',
                                male   = { drawable = 121, texture = 0 },
                                female = { drawable = 121, texture = 0 },
                            },
                            {
                                name   = 'daychuyen',
                                male   = { drawable = 193, texture = 0 },
                                female = { drawable = 162, texture = 0 },
                            },
                        },
                    },
                },
            },
        },
    },

    ambulance = {
        label = 'Nhận Đồng Phục',
        npc = {
            model    = 's_m_m_paramedic_01',
            coords   = vec4(-480.95, -1019.33, 33.69, 90.70),
            scenario = 'WORLD_HUMAN_STAND_IMPATIENT',
        },
        grades = {
            [0] = {
                outfits = {
                    {
                        label = 'Đồng Phục Thử Việc',
                        items = {
                            {
                                name   = 'daychuyen',
                                male   = { drawable = 249, texture = 0 },
                                female = { drawable = 182, texture = 0 },
                            },
                            {
                                name   = 'aokhoac',
                                male   = { drawable = 572, texture = 0 },
                                female = { drawable = 619, texture = 0 },
                            },
                            {
                                name   = 'quan',
                                male   = { drawable = 20, texture = 0 },
                                female = { drawable = 23, texture = 0 },
                            },
                            {
                                name   = 'giay',
                                male   = { drawable = 54, texture = 0 },
                                female = { drawable = 55, texture = 0 },
                            },
                        },
                    },
                },
            },
            [1] = {
                outfits = {
                    {
                        label = 'Đồng Phục Bác Sĩ',
                        items = {
                            {
                                name   = 'daychuyen',
                                male   = { drawable = 249, texture = 0 },
                                female = { drawable = 182, texture = 0 },
                            },
                            {
                                name   = 'aokhoac',
                                male   = { drawable = 573, texture = 0 },
                                female = { drawable = 620, texture = 0 },
                            },
                            {
                                name   = 'aotrong',
                                male   = { drawable = 28, texture = 0 },
                                female = { drawable = 38, texture = 0 },
                            },
                            {
                                name   = 'quan',
                                male   = { drawable = 20, texture = 0 },
                                female = { drawable = 23, texture = 0 },
                            },
                            {
                                name   = 'giay',
                                male   = { drawable = 54, texture = 0 },
                                female = { drawable = 55, texture = 0 },
                            },
                        },
                    },
                },
            },
            [2] = {
                outfits = {
                    {
                        label = 'Đồng Phục Quản Lý Khoa',
                        items = {
                            {
                                name   = 'daychuyen',
                                male   = { drawable = 249, texture = 0 },
                                female = { drawable = 182, texture = 0 },
                            },
                            {
                                name   = 'aokhoac',
                                male   = { drawable = 573, texture = 0 },
                                female = { drawable = 620, texture = 0 },
                            },
                            {
                                name   = 'aotrong',
                                male   = { drawable = 28, texture = 0 },
                                female = { drawable = 38, texture = 0 },
                            },
                            {
                                name   = 'quan',
                                male   = { drawable = 20, texture = 0 },
                                female = { drawable = 23, texture = 0 },
                            },
                            {
                                name   = 'giay',
                                male   = { drawable = 54, texture = 0 },
                                female = { drawable = 55, texture = 0 },
                            },
                        },
                    },
                },
            },
            [3] = {
                outfits = {
                    {
                        label = 'Đồng Phục Phó Viện Trưởng',
                        items = {
                            {
                                name   = 'daychuyen',
                                male   = { drawable = 249, texture = 0 },
                                female = { drawable = 182, texture = 0 },
                            },
                            {
                                name   = 'aokhoac',
                                male   = { drawable = 573, texture = 0 },
                                female = { drawable = 620, texture = 0 },
                            },
                            {
                                name   = 'aotrong',
                                male   = { drawable = 28, texture = 0 },
                                female = { drawable = 38, texture = 0 },
                            },
                            {
                                name   = 'quan',
                                male   = { drawable = 20, texture = 0 },
                                female = { drawable = 23, texture = 0 },
                            },
                            {
                                name   = 'giay',
                                male   = { drawable = 54, texture = 0 },
                                female = { drawable = 55, texture = 0 },
                            },
                        },
                    },
                },
            },
            [4] = {
                outfits = {
                    {
                        label = 'Đồng Phục Viện Trưởng',
                        items = {
                            {
                                name   = 'daychuyen',
                                male   = { drawable = 249, texture = 0 },
                                female = { drawable = 182, texture = 0 },
                            },
                            {
                                name   = 'aokhoac',
                                male   = { drawable = 573, texture = 0 },
                                female = { drawable = 620, texture = 0 },
                            },
                            {
                                name   = 'aotrong',
                                male   = { drawable = 28, texture = 0 },
                                female = { drawable = 38, texture = 0 },
                            },
                            {
                                name   = 'quan',
                                male   = { drawable = 20, texture = 0 },
                                female = { drawable = 23, texture = 0 },
                            },
                            {
                                name   = 'giay',
                                male   = { drawable = 54, texture = 0 },
                                female = { drawable = 55, texture = 0 },
                            },
                        },
                    },
                },
            },
        },
    },

    mechanic = {
        label = 'Nhận Đồng Phục',
        npc = {
            model    = 's_m_m_autoshop_02',
            coords   = vec4(-349.62, -154.01, 38.99, 122.50),
            scenario = 'WORLD_HUMAN_STAND_IMPATIENT',
        },
        grades = {
            [0] = {
                outfits = {
                    {
                        label = 'Đồng Phục Tay Ngắn',
                        items = {
                            {
                                name   = 'aokhoac',
                                male   = { drawable = 66, texture = 0 },
                                female = { drawable = 60, texture = 0 },
                            },
                            {
                                name   = 'quan',
                                male   = { drawable = 39, texture = 0 },
                                female = { drawable = 39, texture = 0 },
                            },
                            {
                                name   = 'giay',
                                male   = { drawable = 97, texture = 0 },
                                female = { drawable = 86, texture = 0 },
                            },
                        },
                    },
                    {
                        label = 'Đồng Phục Tay Dài',
                        items = {
                            {
                                name   = 'aokhoac',
                                male   = { drawable = 65, texture = 0 },
                                female = { drawable = 59, texture = 0 },
                            },
                            {
                                name   = 'quan',
                                male   = { drawable = 38, texture = 0 },
                                female = { drawable = 38, texture = 0 },
                            },
                            {
                                name   = 'giay',
                                male   = { drawable = 97, texture = 0 },
                                female = { drawable = 86, texture = 0 },
                            },
                        },
                    },
                }
            },
            [1] = {
                outfits = {
                    {
                        label = 'Đồng Phục Tay Ngắn',
                        items = {
                            {
                                name   = 'aokhoac',
                                male   = { drawable = 66, texture = 0 },
                                female = { drawable = 60, texture = 0 },
                            },
                            {
                                name   = 'quan',
                                male   = { drawable = 39, texture = 0 },
                                female = { drawable = 39, texture = 0 },
                            },
                            {
                                name   = 'giay',
                                male   = { drawable = 97, texture = 0 },
                                female = { drawable = 86, texture = 0 },
                            },
                        },
                    },
                    {
                        label = 'Đồng Phục Tay Dài',
                        items = {
                            {
                                name   = 'aokhoac',
                                male   = { drawable = 65, texture = 0 },
                                female = { drawable = 59, texture = 0 },
                            },
                            {
                                name   = 'quan',
                                male   = { drawable = 38, texture = 0 },
                                female = { drawable = 38, texture = 0 },
                            },
                            {
                                name   = 'giay',
                                male   = { drawable = 97, texture = 0 },
                                female = { drawable = 86, texture = 0 },
                            },
                        },
                    },
                }
            },
            [2] = {
                outfits = {
                    {
                        label = 'Đồng Phục Tay Ngắn',
                        items = {
                            {
                                name   = 'aokhoac',
                                male   = { drawable = 66, texture = 0 },
                                female = { drawable = 60, texture = 0 },
                            },
                            {
                                name   = 'quan',
                                male   = { drawable = 39, texture = 0 },
                                female = { drawable = 39, texture = 0 },
                            },
                            {
                                name   = 'giay',
                                male   = { drawable = 97, texture = 0 },
                                female = { drawable = 86, texture = 0 },
                            },
                        },
                    },
                    {
                        label = 'Đồng Phục Tay Dài',
                        items = {
                            {
                                name   = 'aokhoac',
                                male   = { drawable = 65, texture = 0 },
                                female = { drawable = 59, texture = 0 },
                            },
                            {
                                name   = 'quan',
                                male   = { drawable = 38, texture = 0 },
                                female = { drawable = 38, texture = 0 },
                            },
                            {
                                name   = 'giay',
                                male   = { drawable = 97, texture = 0 },
                                female = { drawable = 86, texture = 0 },
                            },
                        },
                    },
                }
            },
            [3] = {
                outfits = {
                    {
                        label = 'Đồng Phục Tay Ngắn',
                        items = {
                            {
                                name   = 'aokhoac',
                                male   = { drawable = 66, texture = 0 },
                                female = { drawable = 60, texture = 0 },
                            },
                            {
                                name   = 'quan',
                                male   = { drawable = 39, texture = 0 },
                                female = { drawable = 39, texture = 0 },
                            },
                            {
                                name   = 'giay',
                                male   = { drawable = 97, texture = 0 },
                                female = { drawable = 86, texture = 0 },
                            },
                        },
                    },
                    {
                        label = 'Đồng Phục Tay Dài',
                        items = {
                            {
                                name   = 'aokhoac',
                                male   = { drawable = 65, texture = 0 },
                                female = { drawable = 59, texture = 0 },
                            },
                            {
                                name   = 'quan',
                                male   = { drawable = 38, texture = 0 },
                                female = { drawable = 38, texture = 0 },
                            },
                            {
                                name   = 'giay',
                                male   = { drawable = 97, texture = 0 },
                                female = { drawable = 86, texture = 0 },
                            },
                        },
                    },
                }
            },
            [4] = {
                outfits = {
                    {
                        label = 'Đồng Phục Tay Ngắn',
                        items = {
                            {
                                name   = 'aokhoac',
                                male   = { drawable = 66, texture = 0 },
                                female = { drawable = 60, texture = 0 },
                            },
                            {
                                name   = 'quan',
                                male   = { drawable = 39, texture = 0 },
                                female = { drawable = 39, texture = 0 },
                            },
                            {
                                name   = 'giay',
                                male   = { drawable = 97, texture = 0 },
                                female = { drawable = 86, texture = 0 },
                            },
                        },
                    },
                    {
                        label = 'Đồng Phục Tay Dài',
                        items = {
                            {
                                name   = 'aokhoac',
                                male   = { drawable = 65, texture = 0 },
                                female = { drawable = 59, texture = 0 },
                            },
                            {
                                name   = 'quan',
                                male   = { drawable = 38, texture = 0 },
                                female = { drawable = 38, texture = 0 },
                            },
                            {
                                name   = 'giay',
                                male   = { drawable = 97, texture = 0 },
                                female = { drawable = 86, texture = 0 },
                            },
                        },
                    },
                }
            },
        }
    }
}