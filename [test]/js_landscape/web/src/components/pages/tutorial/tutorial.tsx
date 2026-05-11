import './tutorial.scss'
import logo from '../../../img/logo_plain.png'
import { useSetShowTutorial } from '../../../exports/tutorial'
import { fetchNui } from '../../../utils/fetchNui'
import { useLocaleState } from '../../../utils/locale'

const Tutorial: React.FC = () => {
    const changeTutorialState = useSetShowTutorial()
    const Locale = useLocaleState()
    
    const onClickFunction = (e: string) => {

        if(e == 'close'){
            changeTutorialState(false)
            fetchNui('js_landscape:focus:off')
            fetchNui('js_landscape:tutorial:close')
        } else if (e == 'stop') {
            changeTutorialState(false)
            localStorage.setItem('show_tutorial', 'false')
            fetchNui('js_landscape:focus:off')
            fetchNui('js_landscape:tutorial:close')
        }
    }

    return (
        <div className="tutorial">
            <div className="topper">
                <div className="logo">
                    <img src={logo}/>
                </div>
                <div className="text">
                    <span>{Locale['TUTORIAL']}</span>
                    <span>{Locale['TUTORIAL_DESCRIPTION']}</span>
                </div>
            </div>
            <div className="line"></div>
            <div className="text">{Locale['TUTORIAL_TEXT']}</div>
            <div className="btns">
                <div className="btn" onClick={() => onClickFunction('close')}>{Locale['TUTORIAL_CLOSE']}</div>
                <div className="btn" onClick={() => onClickFunction('stop')}>{Locale['TUTORIAL_DONT_SHOW_AGAIN']}</div>
            </div>
        </div>
    )
}

export default Tutorial