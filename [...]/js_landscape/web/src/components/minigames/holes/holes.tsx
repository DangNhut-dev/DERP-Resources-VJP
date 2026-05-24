import './holes.scss'
import { useEffect, useRef, useState } from 'react'
import { fetchNui } from '../../../utils/fetchNui'
import { useLocaleState } from '../../../utils/locale';

let progress_global = 100
let count_global = 0;

const Minigame_Hole: React.FC<{ end: () => void, holes: number }> = ({ end, holes }) => {
    const [progress, setProgress] = useState<number>(100)
    const [count, setCount] = useState<number>(0)
    const intervalRef = useRef<number | null>(null);
    const intervalSpawnRef = useRef<number | null>(null);
    const Locale = useLocaleState()

    function blockKeys(event: KeyboardEvent) {
        event.preventDefault();
    }

    function blockSpaceKey(event: KeyboardEvent) {
        if (event.code === 'Space' || event.keyCode === 32) {
            event.preventDefault();
            event.stopImmediatePropagation();
        }
    }

    function finish(result: boolean) {
        fetchNui('js_landscape:minigame:result', { value: result })
        end()
        if (intervalRef.current !== null) {
            clearInterval(intervalRef.current);
        }
        if (intervalSpawnRef.current) {
            clearInterval(intervalSpawnRef.current);
        }
        window.removeEventListener('keydown', blockKeys);
        window.removeEventListener('keydown', blockSpaceKey, true);
    }

    function spawnElement() {
        const container = document.querySelector(".click_container") as HTMLElement;

        if (!container) return;

        const element = document.createElement("div");
        element.style.width = "38px";
        element.style.height = "38px";
        element.style.background = "radial-gradient(circle, #d8ffe9 0%, var(--color) 58%, #128e53 100%)";
        element.style.position = "absolute";
        element.style.borderRadius = '100%';
        element.style.border = "2px solid rgba(255, 255, 255, 0.82)";
        element.style.boxShadow = "0 0 0 8px rgba(56, 217, 137, 0.16), 0 10px 28px rgba(0, 0, 0, 0.36)";
        element.style.cursor = "pointer";

        const containerRect = container.getBoundingClientRect();
        const x = Math.random() * (containerRect.width - 20);
        const y = Math.random() * (containerRect.height - 20);

        element.style.left = `${x}px`;
        element.style.top = `${y}px`;

        element.addEventListener("click", () => {
            element.remove();
            count_global += 1
            setCount(count_global)

            if (count_global === holes) {
                if (intervalRef.current) {
                    clearInterval(intervalRef.current);
                }
                if (intervalSpawnRef.current) {
                    clearInterval(intervalSpawnRef.current);
                }
                finish(true)
            }
        });

        while (container.firstChild) {
            container.removeChild(container.firstChild);
        }

        container.appendChild(element);
    }

    useEffect(() => {
        window.addEventListener('keydown', blockKeys);
        window.addEventListener('keydown', blockSpaceKey, true);
        return () => {
            window.removeEventListener('keydown', blockKeys);
            window.removeEventListener('keydown', blockSpaceKey, true);
        };
    }, []);

    useEffect(() => {
        intervalSpawnRef.current = window.setInterval(() => {
            if (progress_global < 100 && progress_global > 0) {
                spawnElement()
            }
        }, 1000);

        return () => {
            if (intervalSpawnRef.current !== null) {
                clearInterval(intervalSpawnRef.current);
            }
        };
    }, []);

    useEffect(() => {
        intervalRef.current = window.setInterval(() => {
            if (progress_global > 0) {
                progress_global -= 0.15
                setProgress(progress_global)
            } else {
                if (intervalRef.current) {
                    finish(false)
                    clearInterval(intervalRef.current);
                    if (intervalSpawnRef.current) {
                        clearInterval(intervalSpawnRef.current);
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
        progress_global = 100
        count_global = 0;
        setCount(0)
        setProgress(100)
    }, []);

    return (
        <div className="minigame_holes">
            <div className="title">
                <span className='tit'>{Locale['JOB_TITLE_HOLES']}</span>
                <span className='rem'>{Locale['JOB_HOLES_REMANING']}: <span>{count}/{holes}</span></span>
            </div>

            <div className="click_container">
            </div>

            <div className="p_bar_container">
                <div className="p_bar">
                    <div className="pb" style={{ width: progress + '%' }}></div>
                </div>
            </div>

        </div>
    )
}

export default Minigame_Hole;