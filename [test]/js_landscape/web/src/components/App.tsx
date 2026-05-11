import React, { createRef, useEffect, useState } from 'react';
import './App.scss'
import { debugData } from "../utils/debugData";
import { fetchNui } from '../utils/fetchNui';
import { atom, useAtom, useAtomValue, useSetAtom } from 'jotai';
import { useNuiEvent } from '../hooks/useNuiEvent';
import { isEnvBrowser } from '../utils/misc';
import { configDATA, useConfigData, useSetConfigData } from '../exports/config';
import Job from './pages/job/job';
import bg from '../img/bg.png'
import Progress from './pages/progress/progress';
import { ProgressData, useProgressData, useSetProgressData } from '../exports/progress';
import Notification from './pages/notification/notification';
import ReactDOM from 'react-dom';
import { createRoot, Root } from 'react-dom/client';
import { playerNearby, useSetPlayersNearby } from '../exports/job/playersNearby';
import Invite from './pages/invite/invite';
import { InviteInterface, useInviteData, useSetInviteData } from '../exports/invite';
import Tutorial from './pages/tutorial/tutorial';
import { useSetShowTutorial, useShowTutorial } from '../exports/tutorial';
import { teamData, useSetTeamData, useTeamData } from '../exports/job/team';
import { playerData, useSetPlayerData } from '../exports/playerData';
import Minigame_Keys from './minigames/keys/keys';
import { useLocale } from '../utils/locale';
import Percantage from './pages/percentage/percantage';
import { useChangeSalaryData, useSetChangeSalaryData } from '../exports/salary_perc';
import JobProgress from './pages/job_progress/job_progress';
import { JobsToDo, useJobsToDoData, useSetJobsToDoData } from '../exports/job_progress';
import Minigame_Space from './minigames/space/space';
import Minigame_Hole from './minigames/holes/holes';

// debugData([
//   {
//     action: 'setVisible',
//     data: true,
//   }
// ])

debugData([
  {
    action: 'setJobsTODO',
    data: {},
  }
])

debugData([
  {
    action: 'setProgressData',
    data: {
      progress: true,
      name: 'penis',
      time: 5,
    },
  }
])

// debugData([
//   {
//     action: 'addInvite',
//     data: {
//       invite: true,
//       from: 'penis',
//       fromId: 5,
//     },
//   }
// ])

// debugData([
//   {
//     action: 'setPlayersNearby',
//     data: [
//       {
//         name: 'penis w cipie',
//         id: 1
//       },
//       {
//         name: 'penis w cipie',
//         id: 1
//       },
//       {
//         name: 'penis w cipie',
//         id: 1
//       },
//       {
//         name: 'penis w cipie',
//         id: 1
//       },
//       {
//         name: 'penis w cipie',
//         id: 1
//       },
//       {
//         name: 'penis w cipie',
//         id: 1
//       },
//       {
//         name: 'penis w cipie',
//         id: 1
//       },
//       {
//         name: 'penis w cipie',
//         id: 1
//       },
//       {
//         name: 'penis w cipie',
//         id: 1
//       },
//     ],
//   }
// ])

debugData([
  {
    action: 'setPlayersNearby',
    data: [
      {
        name: 'penis w cipie1',
        id: 1
      },
      {
        name: 'penis w cipie2',
        id: 3
      },
      {
        name: 'penis w cipie3',
        id: 4
      },
      {
        name: 'penis w cipie4',
        id: 5
      },
      {
        name: 'penis w cipie5',
        id: 6
      },

    ],
  }
])

// debugData([
//   {
//     action: 'forceShowTutorial',
//     data: true
//   }
// ])

debugData([
  {
    action: 'setPlayerData',
    data: {
      name: 'Fiut',
      id: 2,
      level: 2,
      xp: 3000
    }
  }
])

debugData([
  {
    action: 'setConfig',
    data: {
      max_players: 4,
      salary: 300,
    }
  }
])

// debugData([
//   {
//     action: 'showLightMinigame',
//     data: 30
//   }
// ])


// debugData([
//   {
//     action: 'showKeyMinigame',
//     data: 30
//   }
// ])

// debugData([
//   {
//     action: 'showCableMinigame',
//     data: 5
//   }
// ])

debugData([
  {
    action: 'showJobMenu',
    data: true
  }
])

debugData([
  {
    action: 'setJobsTODO',
    data: [
      {
        job_name: 'PROGRESS',
        job_did: 1,
        job_todo: 3,
      },
      {
        job_name: 'PROGRESS',
        job_did: 1,
        job_todo: 3,
      },
      {
        job_name: 'PROGRESS',
        job_did: 1,
        job_todo: 3,
      },
      {
        job_name: 'PROGRESS',
        job_did: 1,
        job_todo: 3,
      },
    ]
  }
])


debugData([
  {
    action: 'changeLanguage',
    data: {
      locale: {
        ['PARTY_INVITE_FROM']: 'You received invite from:',
        ['PARTY_INVITE_ACCEPT_ASK']: 'Do you want to accept party invite?',
        ['PARTY_FOCUS']: 'Middle Mouse Button to focus',

        ['JOB_SALARY']: 'Salary',
        ['JOB_MAXPLAYERS']: 'Max players',
        ['JOB_DESCRIPTION']: 'Lorem ipsum dolor sit amet consectetur adipisicing elit. At sapiente quasi officia cupiditate sint magnam repellendus incidunt distinctio, ad, possimus aliquam corrupti? Maiores debitis optio doloribus nemo iste, fugit culpa!',

        ['JOB_CLOTHES_SECTION']: 'Clothes',
        ['JOB_CLOTHES_SECTION_DESCRIPTION']: 'Select preset',
        ['JOB_CLOTHES_TYPE_PLAYER']: 'Player',
        ['JOB_CLOTHES_TYPE_JOB']: 'Job',

        ['JOB_TEAM_SECTION']: 'Create team',
        ['JOB_TEAM_SECTION_DESCRIPTION1']: 'You and',
        ['JOB_TEAM_SECTION_DESCRIPTION2']: 'players',

        ['JOB_NEARBY_SECTION']: 'Nearby players',
        ['JOB_NEARBY_SECTION_DESCRIPTION']: 'Players in range',

        ['JOB_STARTJOB']: 'Start job',

        ['NOTIFICATION']: 'Notification',

        ['PROGRESS_TITLE']: 'Job progress',

        ['TUTORIAL']: 'Tutorial',
        ['TUTORIAL_DESCRIPTION']: 'Gardener Job Tutorial',
        ['TUTORIAL_TEXT']: 'Lorem ipsum dolor sit amet consectetur, adipisicing elit. Cupiditate exercitationem officiis alias tenetur, cum ex totam nam esse excepturi ullam, explicabo repellat quis, fuga aut itaque? Qui dolor dolores eius commodi reprehenderit voluptatem tenetur. Odit itaque quidem magnam incidunt animi totam, praesentium libero soluta dolorum recusandae beatae nobis mollitia officiis!',
        ['TUTORIAL_CLOSE']: 'Close tutorial',
        ['TUTORIAL_DONT_SHOW_AGAIN']: 'Dont show again',

        ['TIME_LEFT']: 'Time left',

        ['YES']: 'Yes',
        ['NO']: 'No',

        ['JOB_PROGRESS']: 'Job progress',

        ['JOB_TITLE_HOLES']: 'Click on spots on time',
        ['JOB_TITLE_KEYS']: 'Click highlighted keys on time',
        ['JOB_TITLE_SPACE']: 'Click space as fast as you can',
        ['JOB_HOLES_REMANING']: 'Remaning holes'
      }
    }
  }
])

let notif_id = 0
const App: React.FC = () => {
  const setConfig = useSetConfigData()
  useNuiEvent<configDATA>('setConfig', setConfig)

  const setProgressData = useSetProgressData()
  const progress = useProgressData()
  useNuiEvent<ProgressData>('setProgressData', setProgressData)

  const setPlayersNearby = useSetPlayersNearby()
  useNuiEvent<playerNearby[]>('setPlayersNearby', setPlayersNearby)

  const setInvite = useSetInviteData()
  const invite = useInviteData()
  useNuiEvent<InviteInterface>('addInvite', setInvite)

  const setPlayerData = useSetPlayerData()
  useNuiEvent<playerData>('setPlayerData', setPlayerData)

  const tutorial = useShowTutorial()
  const setTutorial = useSetShowTutorial()
  useNuiEvent('showTutorial', () => {
    const savedTutorial = localStorage.getItem('show_tutorial')

    if (!savedTutorial) {
      localStorage.setItem('show_tutorial', 'true')
      setTutorial(true)
      return
    } else {
      if (savedTutorial == 'true') {
        setTutorial(true)
        return
      }
    }

    fetchNui('js_landscape:tutorial:close')
  })

  useNuiEvent('forceShowTutorial', () => {
    localStorage.setItem('show_tutorial', 'true')
    setTutorial(true)
  })

  useNuiEvent<string>('addNotification', (data) => {
    const elem = document.querySelector('.notifications') as HTMLDivElement
    notif_id += 1

    const notif_elem = document.createElement('div')

    const root = createRoot(notif_elem)
    root.render(<Notification text={data} id={notif_id} />)

    elem.appendChild(notif_elem)

    setTimeout(() => {
      notif_elem.remove()
    }, 8000);
  })


  const [showJob, setShowJob] = useState<boolean>(false)
  useNuiEvent<boolean>('showJobMenu', setShowJob)

  const [currentMinigame, setCurrentMinigame] = useState<{
    name: string,
    time: number,
    additional: number,
  }>({
    name: '',
    time: 0,
    additional: 0,
  })

  function StopMinigame() {
    setCurrentMinigame({ name: '', time: 0, additional: 0 })
    fetchNui('js_landscape:focus:off')
  }


  function CreateMinigame(name: string, time?: number, additional?: number) {
    if (!time) { time = 0 };
    if (!additional) { additional = 0 };

    setCurrentMinigame({ name, time, additional })
  }

  useNuiEvent<{holes: number}>('showdiggingMinigame', (data) => {
    CreateMinigame('digging', undefined, data.holes)
  })

  useNuiEvent<{holes: number}>('showpullingMinigame', (data) => {
    CreateMinigame('pulling')
  })

  const changeSalary = useChangeSalaryData()
  const setChangeSalary = useSetChangeSalaryData()

  useEffect(() => {
    if (!showJob) return;


    const keyHandler = (e: KeyboardEvent) => {
      if (["Escape"].includes(e.code)) {
        fetchNui("closeUI");

        setChangeSalary({
          change: false,
          for: '',
          forId: 1,
          fromId: 1,
        })
      }
    }

    window.addEventListener("keydown", keyHandler)

    return () => window.removeEventListener("keydown", keyHandler)
  }, [showJob])

  const [Locale, setLocale] = useLocale()
  useNuiEvent<{
    locale: { [key: string]: string };
  }>('changeLanguage', ({ locale }) => {
    const tempLocale = Locale
    for (const name in locale) {
      tempLocale[name] = locale[name]
    }
    setLocale(tempLocale)
  })

  const setTeamData = useSetTeamData()
  const teamData = useTeamData()

  useNuiEvent<{
    id: number,
    name: string,
    citizenid?: string
  }>('js_landscape:team:addToTeam', (data) => {
    let d_data = [...teamData, {
      name: data.name,
      id: data.id,
      citizenid: data.citizenid,
      salary: 0,
      owner: false
    }]

    setTeamData(d_data)
    fetchNui('js_landscape:team:update', { value: d_data })
  })

  useNuiEvent<{
    id: number,
    name: string,
    citizenid?: string,
    salary: number
  }[]>('js_landscape:team:setTeam', (data) => {
    const newTeamData = data.map((i) => ({
      name: i.name,
      id: i.id,
      citizenid: i.citizenid,
      salary: i.salary,
      owner: false
    }));

    setTeamData(newTeamData);

    setTeamData(prevTeamData =>
      prevTeamData.map(member => ({
        ...member,
      }))
    );
  })

  useNuiEvent<{
    id: number,
    name: string
  }[]>('js_landscape:team:updateTeamSalary', (data) => {
    setTeamData(prevTeamData =>
      prevTeamData.map(member => ({
        ...member,
        salary: 0,
      }))
    );
  })

  const JobsToDo = useJobsToDoData()
  const setJobsTODO = useSetJobsToDoData()

  useNuiEvent<JobsToDo[]>('setJobsTODO', setJobsTODO)

  return (
    <div className="kariee_container">
      {isEnvBrowser() && <img className='bgg' src={bg} />}

      {tutorial && <Tutorial />}
      {showJob && <Job />}
      {invite?.invite && <Invite />}
      {progress?.progress && <Progress />}
      {changeSalary?.change && <Percantage />}
      {JobsToDo.length > 0 && <JobProgress/>}

      <div className="notifications"></div>

      <div
        className="minigames"
        style={{
          background: currentMinigame.name != '' ? 'rgba(0, 0, 0, 0.6)' : 'transparent',
          pointerEvents: currentMinigame.name != '' ? 'auto' : 'none',
        }}
      >
        { currentMinigame.name == 'pulling' && <Minigame_Space end={StopMinigame}/> }
        { currentMinigame.name == 'digging' && <Minigame_Hole end={StopMinigame} holes={currentMinigame.additional} /> }
      </div>
    </div>
  )
}

export default App;