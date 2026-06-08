import { useJobsToDoData } from '../../../exports/job_progress'
import { useLocaleState } from '../../../utils/locale'
import './job_progress.scss'

const JobProgress: React.FC = () => {
    const Locale = useLocaleState()
    const Jobs = useJobsToDoData()

    return (
        <div className="job_progress">
            <div className="info">
                {Locale['JOB_PROGRESS']}
            </div>

            <div className="line"></div>

            <div className="data">
                {Jobs.map((value, index) => (
                    <div className="dd">
                        {value.job_did == value.job_todo && <div className="finished_line"></div>}
                        <div className="left">
                            <span>{index+1}.</span>
                            <span>{Locale['JOB_'+value.job_name.toUpperCase()]}</span>
                        </div>
                        <span>{value.job_did}/{value.job_todo}</span>
                    </div>
                ))}

                {Jobs.length <= 0 && <div className='dd'><span style={{color: 'white'}}>No more jobs to do</span></div>}
            </div>
        </div>
    )
}

export default JobProgress