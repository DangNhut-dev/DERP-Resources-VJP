import { useInviteData, useSetInviteData } from '../../../exports/invite'
import { useSetTeamData, useTeamData } from '../../../exports/job/team'
import { useChangeSalaryData, useSetChangeSalaryData } from '../../../exports/salary_perc'
import { fetchNui } from '../../../utils/fetchNui'
import { useLocale, useLocaleState } from '../../../utils/locale'
import './percantage.scss'

const Percantage: React.FC = () => {
    const changeSalary = useChangeSalaryData()
    const setChangeSalary = useSetChangeSalaryData()
    const setTeam = useSetTeamData()
    const team = useTeamData()

    const Locale = useLocaleState()

    const distributeSalary = (updatedId: number, newSalary: number) => {
        let remainingSalary = 100 - newSalary;
        let otherMembers = team.filter(member => member.id !== updatedId);
        
        otherMembers.forEach(member => {
            member.salary = remainingSalary / otherMembers.length;
        });
    }

    const onClickFunction = (data: boolean) => {
        if(data && changeSalary){
            const elem = document.querySelector('.input_percantage') as HTMLInputElement

            if(parseInt(elem.value) >= 100){
                return
            }            
            
            const user = team.find(p => p.id === changeSalary.forId)
            if(user){
                user.salary = parseInt(elem.value);
                distributeSalary(user.id, user.salary);
            }

            const totalsalary = team.reduce((sum, m) => sum + m.salary, 0)

            if(totalsalary > 100){
                return
            }
            
            fetchNui('js_landscape:team:update', { value: team })
            fetchNui('js_landscape:team:changePlayerSalary', {id: changeSalary.forId, value: parseInt(elem.value)})
        }

        setChangeSalary({
            change: false,
            for: '',
            forId: 1,
            fromId: 1,
        })
    }

    const changeInput = (e: HTMLInputElement) => {
        const value = parseInt(e.value)

        if(value > 100){
            e.value = '100'
        } else if (value < 1){
            e.value = '1'
        }
    }

    return (
        <div className="percentage">
            <div className="text">
                <span>{Locale['SALARY_FOR']}</span>
                <span>{changeSalary ? changeSalary.for : 'Unknown'}</span>
            </div>

            <input type='number' min={0} max={100} placeholder='50' className="input_percantage" onInput={(e) => changeInput(e.currentTarget)}/>

            <div className="btns">
                <div className="btn" onClick={() => onClickFunction(true)}>{Locale['YES']}</div>
                <div className="btn" onClick={() => onClickFunction(false)}>{Locale['NO']}</div>
            </div>
        </div>
    )
}

export default Percantage