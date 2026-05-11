import { useConfigData } from '../../../exports/config'
import './job.scss'
import logo from '../../../img/logo.png'
import team from '../../../img/team.png'
import nearby from '../../../img/nearby.png'
import plus from '../../../img/plus.png'
import { usePlayersNearby, useSetPlayersNearby } from '../../../exports/job/playersNearby'
import { fetchNui } from '../../../utils/fetchNui'
import { useIsTeamCreated, useSetIsTeamCreated, useSetTeamData, useTeamData } from '../../../exports/job/team'
import { usePlayerData } from '../../../exports/playerData'
import { useNuiEvent } from '../../../hooks/useNuiEvent'
import { useLocaleState } from '../../../utils/locale'
import { useSetChangeSalaryData } from '../../../exports/salary_perc'

const Job: React.FC = () => {
    const config = useConfigData()
    const playersNearby = usePlayersNearby()
    const setPlayersNearby = useSetPlayersNearby()

    const isTeamCreated = useIsTeamCreated()
    const setIsTeamCreated = useSetIsTeamCreated()

    const teamData = useTeamData()
    const setTeamData = useSetTeamData()

    const playerData = usePlayerData()

    const Locale = useLocaleState()

    const addPlayer = (id: number, name: string) => {
        if (config && teamData.length >= config.max_players) { return }
        fetchNui('js_landscape:team:sendInviteForPlayer', { id: id, name: name })
    }

    const createTeam = () => {
        setIsTeamCreated(true)
        fetchNui('js_landscape:team:createTeam')

        if (playerData) {
            setTeamData([
                {
                    name: playerData.name,
                    id: playerData.id,
                    salary: 100,
                    owner: true,
                }
            ])

        }
    }

    const removePlayer = (id: number, name: string) => {
        const update = teamData.filter(member => member.id !== id)
        setTeamData(update)
        fetchNui('js_landscape:team:update', { value: update, id: id })
    }

    const leaveTeam = () => {
        setTeamData([])
        fetchNui('js_landscape:team:leave')
    }

    const onClickStart = () => {
        fetchNui('js_landscape:startjob')
    }

    const onClickQuit = () => {
        fetchNui('js_landscape:team:quit')
    }
    const setChangeSalary = useSetChangeSalaryData()
    const changeSalary = (id: number, name: string) => {
        
        if(playerData && playerData.ownage){
            setChangeSalary({
                change: true,
                for: name,
                forId: id,
                fromId: playerData.id
            })
        }
    }

    return (
        <div className="job">
            <div className="h_section">
                <div className="logo">
                    <img src={logo} />
                </div>

                <div className="level_section">
                    <div className="top">
                        <span>{playerData ? playerData.level : '#'} lvl</span>
                        <span>{Locale['JOB_LEVEL_TITLE']}</span>
                        <span>{playerData ? playerData.level + 1 : '#'} lvl</span>
                    </div>

                    <div className="lvl_progress">
                        <div className="bar" style={{width: (playerData && playerData.xp ? ((playerData.xp / (1000 + (playerData.level * 1000))) * 100)+'%' : '0%')}}></div>
                    </div>
                    
                    <div className="bottom">
                        <span>{Locale['JOB_CURRENT_LEVEL']}</span>
                        <span>{playerData?.xp}/{playerData ? 1000 + (playerData.level * 1000) : '?'}xp</span>
                        <span>+{config && config.salary_multiplier ? config.salary_multiplier : '?'}% {Locale['JOB_SALARY'].toLowerCase()}</span>
                    </div>
                </div>

                <div className="info">
                    <div className="btn">
                        <span>{Locale['JOB_MAXPLAYERS']}:</span>
                        <span>{config ? config.max_players : '0'}</span>
                    </div>
                    <div className="btn">
                        <span>{Locale['JOB_SALARY']}:</span>
                        <span>{config ? config.salary : '0'}{Locale['MONEY_TYPE']}</span>
                    </div>
                </div>

                <div className="desc">
                    {Locale['JOB_DESCRIPTION']}
                </div>

                <div className="line"></div>

                <div className="section">
                    <div className="top">
                        <div className="icon">
                            <img src={team} />
                        </div>
                        <div className="text">
                            <span>{Locale['JOB_TEAM_SECTION']}</span>
                            <span>{Locale['JOB_TEAM_SECTION_DESCRIPTION1']} {config ? config.max_players - 1 : 0} {Locale['JOB_TEAM_SECTION_DESCRIPTION2']}</span>
                        </div>
                    </div>

                    {teamData.length > 0
                        ?

                        <>
                            <div className="full_team">
                                {teamData.map((value, index) => (
                                    <div className={"team team_" + value.id} key={index}>
                                        <div className="name">
                                            <span>{value.name}</span>
                                            <span>(<span>{value.citizenid || value.id}</span>)</span>
                                        </div>
                                        <div className="right">

                                            <div className="salary" onClick={() => changeSalary(value.id, value.name)}>
                                                {value.salary}%
                                            </div>

                                            {((playerData && (playerData.id != value.id)) && playerData.ownage) &&
                                                <div className="del" onClick={() => removePlayer(value.id, value.name)}>
                                                    <i className="fa-solid fa-trash-can"></i>
                                                </div>
                                            }

                                            {((playerData && (playerData.id == value.id)) && playerData.ownage) &&
                                                <div className="del" onClick={() => leaveTeam()}>
                                                    <i className="fa-solid fa-right-from-bracket"></i>
                                                </div>
                                            }
                                        </div>
                                    </div>
                                ))}
                            </div>
                        </>

                        :

                        <div className="btns">
                            <div className="btn" onClick={createTeam}>{Locale['JOB_TEAM_SECTION']}</div>
                        </div>
                    }
                </div>

                {playerData && playerData.ownage &&
                    <>
                        <div className="line"></div>

                        <div className="section plrs">
                            <div className="top">
                                <div className="icon">
                                    <img src={nearby} />
                                </div>
                                <div className="text">
                                    <span>{Locale['JOB_NEARBY_SECTION']}</span>
                                    <span>{Locale['JOB_NEARBY_SECTION_DESCRIPTION']}</span>
                                </div>
                            </div>

                            <div className="players">
                                {playersNearby.map((value, index) => (
                                    <div className={"pl pl_" + value.id} key={index}>
                                        <div className="name">
                                            <span>{value.name}</span>
                                            <span>(<span>{value.citizenid || value.id}</span>)</span>
                                        </div>
                                        <div className="add" onClick={() => addPlayer(value.id, value.name)}>
                                            <i className="fa-solid fa-plus"></i>
                                        </div>
                                    </div>
                                ))}

                            </div>
                        </div>
                    </>
                }
            </div>

            {((playerData && playerData.ownage) || (teamData.length == 0)) ?
                <div className="start_job" onClick={onClickStart}>
                    {Locale['JOB_STARTJOB']}
                </div>

                :

                <div className="start_job" onClick={onClickQuit}>
                    {Locale['JOB_QUIT']}
                </div>
            }
        </div>
    )
}

export default Job