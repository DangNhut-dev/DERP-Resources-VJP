import { useState } from 'react'
import { useProgressData, useSetProgressData } from '../../../exports/progress'
import './progress.scss'
import { useLocaleState } from '../../../utils/locale'
import { fetchNui } from '../../../utils/fetchNui'

const Progress: React.FC = () => {
    const progress = useProgressData()
    const setProgressData = useSetProgressData()
    const Locale = useLocaleState()

    let progress_procent = 0

    const [progressProcent, setProgressProcent] = useState<number>(0)
    const [progressed, setProgressed] = useState<boolean>(false)

    setTimeout(() => {
        if (!progressed && progress) {
            setProgressed(true)

            const elem = document.querySelector('.progress') as HTMLDivElement
            if(elem){
                elem.style.animation = `progress_anim ${progress.time + 2}s forwards`
            }

            setTimeout(() => {
                const intervalTime = progress.time * 10;
                const interval = setInterval(() => {
                    progress_procent++;
                    setProgressProcent(progress_procent)

                    if (progress_procent >= 100) {
                        clearInterval(interval);
                        setTimeout(() => {
                            setProgressData({
                                progress: false,
                                name: '',
                                time: 0
                            })
                            fetchNui('js_landscape:minigame:result', {value: true})
                        }, 1000);

                    }
                }, intervalTime);
            }, 1000);
        }
    }, 1000);

    return (
        <div className="progress">
            <div className="info">
                <span>{progress ? progress.name : Locale['PROGRESS_TITLE']}:</span>
                <span>{progressProcent}%</span>
            </div>

            <div className="bars">
                <div className="bar">
                    <div className="pb" style={{ opacity: progressProcent <= 25 ? (progressProcent / 25) : 1 }}></div>
                </div>
                <div className="bar">
                    <div className="pb" style={{ opacity: progressProcent > 25 && progressProcent <= 50 ? ((progressProcent - 25) / 25) : progressProcent > 50 ? 1 : 0 }}></div>
                </div>
                <div className="bar">
                    <div className="pb" style={{ opacity: progressProcent > 50 && progressProcent <= 75 ? ((progressProcent - 50) / 25) : progressProcent > 75 ? 1 : 0 }}></div>
                </div>
                <div className="bar">
                    <div className="pb" style={{ opacity: progressProcent > 75 && progressProcent <= 100 ? ((progressProcent - 75) / 25) : progressProcent > 100 ? 1 : 0 }}></div>
                </div>
            </div>
        </div>
    )
}

export default Progress