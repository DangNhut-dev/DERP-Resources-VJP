import { useState } from 'react'
import './notification.scss'
import { useLocaleState } from '../../../utils/locale';

const Notification: React.FC<{text: string; id: number}> = ({text, id}) => {
    const [waiting, setWaiting] = useState<boolean>(false)
    const Locale = useLocaleState()

    setTimeout(() => {
        if(!waiting){
            setWaiting(true)
            const elem = document.querySelector('#notif'+id+' > .pb > .p_bar') as HTMLDivElement
            if(elem){
                elem.style.width = '100%'
            }
        }
    }, 1000);

    return(
        <div className="notification" id={"notif"+id}>
            <div className="text">
                <span>{Locale['NOTIFICATION']}</span>
                <span>{text}</span>
            </div>

            <div className="pb">
                <div className="p_bar"></div>
            </div>
        </div>
    )
}

export default Notification