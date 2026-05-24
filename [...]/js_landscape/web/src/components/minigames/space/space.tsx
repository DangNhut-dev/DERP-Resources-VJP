import './space.scss'
import { useEffect, useRef, useState } from 'react'
import { fetchNui } from '../../../utils/fetchNui'
import { useLocaleState } from '../../../utils/locale'

let progress_global = 50
let selectedkey_global = 0
let clicked = false;

const Minigame_Space: React.FC<{end: () => void}> = ({end}) => {
    const [progress, setProgress] = useState<number>(10)
    const intervalRef = useRef<number | null>(null);
    const Locale = useLocaleState()

    function finish(result: boolean) {
        fetchNui('js_landscape:minigame:result', {value: result})
        end()
        if (intervalRef.current !== null) {
            clearInterval(intervalRef.current);
        }
    }

    useEffect(() => {
        intervalRef.current = window.setInterval(() => {
            if (progress_global < 100 && progress_global > 0) {
                progress_global -= 1
                setProgress(progress_global)
            } else {
                if(intervalRef.current){
                    if(progress_global <= 0){
                        finish(false)
                        clearInterval(intervalRef.current);
                    }
                }
            }
        }, 50);

        return () => {
            if (intervalRef.current !== null) {
                clearInterval(intervalRef.current);
            }
        };
    }, []);



    useEffect(() => {
        const keyHandler = (e: KeyboardEvent) => {
            if (["Escape"].includes(e.code)) {
                finish(false)
            } else if (["Space"].includes(e.code)){
                if(clicked){return}

                if(progress_global >= 100){
                    progress_global = 100;
                    setProgress(100)
                    if(intervalRef.current){
                        clearInterval(intervalRef.current);
                        finish(true)
                    }
                    return
                } else if (progress_global <= 0){
                    progress_global = 0;
                    setProgress(0)
                    if(intervalRef.current){
                        clearInterval(intervalRef.current);
                        finish(false)
                    }
                    return
                }

                clicked = true;
                progress_global += 7
                setProgress(progress_global)
            }
        }

        const keyHandlerUp = (e: KeyboardEvent) => {
            if (["Space"].includes(e.code)){
                clicked = false
            }
        }

        setProgress(50)
        progress_global = 50

        window.addEventListener("keydown", keyHandler)
        window.addEventListener("keyup", keyHandlerUp)
    }, [])

    return (
        <div className="minigame_space">
            <span>{Locale['JOB_TITLE_SPACE']}</span>

            <div className="p_bar_container">
                <div className="p_bar">
                    <div className="pb" style={{ width: progress + '%' }}></div>
                </div>
            </div>

            <div className="keys" style={{transform: clicked ? 'scale(0.95)' : 'scale(1.0)'}}>
                SPACE
            </div>
        </div>
    )
}

export default Minigame_Space