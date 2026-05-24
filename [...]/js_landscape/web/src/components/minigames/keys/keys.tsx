import './keys.scss'
import { useEffect, useRef, useState } from 'react'
import { fetchNui } from '../../../utils/fetchNui'
import { useLocaleState } from '../../../utils/locale'

let progress_global = 50
let selectedkey_global = 0

let waiting_for_key = false;
const Minigame_Keys: React.FC<{end: () => void}> = ({end}) => {
    const [progress, setProgress] = useState<number>(10)
    const Locale = useLocaleState()

    const intervalRef = useRef<number | null>(null);

    function getRandomNumber(min: number, max: number): number {
        if (min >= max) {
            throw new Error("Minimum must be less than maximum.");
        }

        return Math.floor(Math.random() * (max - min)) + min;
    }

    function randomKey(){
        const pinka = document.querySelectorAll('.key')
        pinka.forEach(e => {
            const elem = document.querySelector('.' + e.classList[2]) as HTMLDivElement
            if(elem){
                elem.style.backgroundColor = 'rgba(20, 20, 20, 0.90)'
                elem.style.color = 'var(--color)'
            }
        })

        if(progress_global >= 100){
            progress_global = 100;
            setProgress(100)
            if(intervalRef.current){
                clearInterval(intervalRef.current);
                finish(true)
                return
            }
        } else if(progress_global <= 0){
            progress_global = 0;
            setProgress(0)
            if(intervalRef.current){
                clearInterval(intervalRef.current);
                finish(false)
                return
            }
        }

        const a = getRandomNumber(1, 6)
        selectedkey_global = a

        const elem = document.querySelector('.key_' + selectedkey_global) as HTMLDivElement
        if(elem){
            elem.style.backgroundColor = 'var(--color)'
            elem.style.color = 'rgba(20, 20, 20, 0.90)'
        }

        waiting_for_key = false;


    }


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
                progress_global -= 0.5
                setProgress(progress_global)
            } else {
                if(intervalRef.current){
                    if(progress_global <= 0){
                        finish(false)
                        clearInterval(intervalRef.current);
                    }
                }
            }
        }, 100);

        
        randomKey()

        return () => {
            if (intervalRef.current !== null) {
                clearInterval(intervalRef.current);
            }
        };
    }, []);


    const keyMap: { [key: string]: number } = {
        'a': 1,
        's': 2,
        'd': 3,
        'j': 4,
        'k': 5,
        'l': 6
    };



    function wrongKey(key: number) {
        const elem = document.querySelector('.key_' + key) as HTMLDivElement

        if(elem){
            const pinka = document.querySelectorAll('.key')
            pinka.forEach(e => {
                const elem = document.querySelector('.' + e.classList[2]) as HTMLDivElement
                if(elem){
                    elem.style.backgroundColor = 'rgba(20, 20, 20, 0.90)'
                    elem.style.color = 'var(--color)'
                }
            })

            elem.style.backgroundColor = 'red'
            elem.style.color = 'white'


            setTimeout(() => {
                randomKey()
            }, 1000);
        }
    }

    async function checkKey(key: number) {
        if(waiting_for_key || (progress_global >= 100 && progress_global <= 0)){return}

        if (key === selectedkey_global) {
            waiting_for_key = true
            progress_global += 5
            setProgress(progress_global)
            
            randomKey()
        } else {
            waiting_for_key = true
            progress_global -= 5
            setProgress(progress_global)

            wrongKey(key)
        }
    }

    function handleKeyDown(event: KeyboardEvent): void {
        if (keyMap[event.key]) {
            checkKey(keyMap[event.key])
        }
    }


    useEffect(() => {
        const keyHandler = (e: KeyboardEvent) => {
            if (["Escape"].includes(e.code)) {
                finish(false)
            }
        }

        setProgress(50)
        progress_global = 50

        document.addEventListener('keydown', handleKeyDown);

        window.addEventListener("keydown", keyHandler)

        return () => window.removeEventListener("keydown", keyHandler)
    }, [])

    return (
        <div className="minigame_keys">
            <span>{Locale['JOB_TITLE_KEYS']}</span>

            <div className="p_bar_container">
                <div className="p_bar">
                    <div className="pb" style={{ width: progress + '%' }}></div>
                </div>
            </div>

            <div className="keys">
                <div className="key key_a key_1" style={{ background: selectedkey_global == 1 ? 'var(--color)' : 'rgba(20, 20, 20, 0.90)', color: selectedkey_global == 1 ? 'rgba(20, 20, 20)' : 'var(--color)' }}>A</div>
                <div className="key key_s key_2" style={{ background: selectedkey_global == 2 ? 'var(--color)' : 'rgba(20, 20, 20, 0.90)', color: selectedkey_global == 2 ? 'rgba(20, 20, 20)' : 'var(--color)' }}>S</div>
                <div className="key key_d key_3" style={{ background: selectedkey_global == 3 ? 'var(--color)' : 'rgba(20, 20, 20, 0.90)', color: selectedkey_global == 3 ? 'rgba(20, 20, 20)' : 'var(--color)' }}>D</div>
                <div className="key key_j key_4" style={{ background: selectedkey_global == 4 ? 'var(--color)' : 'rgba(20, 20, 20, 0.90)', color: selectedkey_global == 4 ? 'rgba(20, 20, 20)' : 'var(--color)' }}>J</div>
                <div className="key key_k key_5" style={{ background: selectedkey_global == 5 ? 'var(--color)' : 'rgba(20, 20, 20, 0.90)', color: selectedkey_global == 5 ? 'rgba(20, 20, 20)' : 'var(--color)' }}>K</div>
                <div className="key key_l key_6" style={{ background: selectedkey_global == 6 ? 'var(--color)' : 'rgba(20, 20, 20, 0.90)', color: selectedkey_global == 6 ? 'rgba(20, 20, 20)' : 'var(--color)' }}>L</div>
            </div>
        </div>
    )
}

export default Minigame_Keys