import { useInviteData, useSetInviteData } from '../../../exports/invite'
import { fetchNui } from '../../../utils/fetchNui'
import { useLocale, useLocaleState } from '../../../utils/locale'
import './invite.scss'

const Invite: React.FC = () => {
    const invite = useInviteData()
    const setInviteData = useSetInviteData()

    const Locale = useLocaleState()

    const onClickFunction = (data: boolean) => {
        fetchNui('js_landscape:invite:result', {value: invite?.fromId, invite: data, name: invite?.from})
        fetchNui('js_landscape:focus:off')

        if(!data){
            setInviteData({
                invite: false,
                from: '',
                fromId: 0
            })
        }
        
    }

    return (
        <div className="invite">
            <div className="text">
                <span>{Locale['PARTY_INVITE_FROM']} {invite?.from} (<span>{invite?.fromCitizenid || invite?.fromId}</span>)</span>
                <span>{Locale['PARTY_INVITE_ACCEPT_ASK']}</span>
            </div>

            <div className="btns">
                <div className="btn" onClick={() => onClickFunction(true)}>{Locale['YES']}</div>
                <div className="btn" onClick={() => onClickFunction(false)}>{Locale['NO']}</div>
            </div>
        </div>
    )
}

export default Invite