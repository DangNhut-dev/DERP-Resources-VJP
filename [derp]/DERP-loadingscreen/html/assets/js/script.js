(() => {
    'use strict';

    /* ═══════════════════════════════════════════════
       1  APPLICATION STATE
       ═══════════════════════════════════════════════ */

    const State = {
        progress: 0,
        targetProgress: 0,
        stepIndex: 0,
        isPlaying: true,
        isLogoVisible: true,
        volume: CONFIG.defaultVolume,
        simulationActive: true,
        animFrameId: null,
        currentTrack: 0,
        playlist: [],
    };

    /* ═══════════════════════════════════════════════
       2  DOM CACHE
       ═══════════════════════════════════════════════ */

    const DOM = {};

    function cacheDom() {
        const ids = [
            'progressBar', 'progressText', 'progressStatus',
            'background-video', 'background-audio',
            'playPauseBtn', 'playPauseIcon', 'volumeBtn', 'toggleLogoBtn',
            'prevBtn', 'nextBtn',
            'musicTitle', 'musicArtist', 'musicArt', 'trackCounter',
            'heroLogo', 'heroName', 'heroTagline',
            'serverName', 'serverDiscordText',
            'changelogTitleText', 'changelogList',
            'staffTitleText', 'staffList',
            'socialDiscord', 'socialYoutube', 'socialTiktok',
        ];

        ids.forEach(id => {
            const key = id.replace(/-([a-z])/g, (_, c) => c.toUpperCase());
            DOM[key] = document.getElementById(id);
        });
    }

    /* ═══════════════════════════════════════════════
       3  PROGRESS SYSTEM
       ═══════════════════════════════════════════════ */

    function setProgress(value) {
        State.targetProgress = Math.min(100, Math.max(0, value));
        if (!State.animFrameId) {
            State.animFrameId = requestAnimationFrame(animateProgress);
        }
    }

    function animateProgress() {
        const diff = State.targetProgress - State.progress;

        if (Math.abs(diff) < 0.1) {
            State.progress = State.targetProgress;
            State.animFrameId = null;
        } else {
            State.progress += diff * 0.08;
            State.animFrameId = requestAnimationFrame(animateProgress);
        }

        const rounded = Math.floor(State.progress);
        if (DOM.progressBar) DOM.progressBar.style.width = State.progress + '%';
        if (DOM.progressText) DOM.progressText.textContent = rounded + '%';
    }

    function setStatusText(text) {
        if (DOM.progressStatus) DOM.progressStatus.textContent = text;
    }

    /* ═══════════════════════════════════════════════
       4  PLAYLIST MANAGEMENT
       ═══════════════════════════════════════════════ */

    function loadPlaylist() {
        if (typeof PLAYLIST === 'undefined' || !Array.isArray(PLAYLIST) || !PLAYLIST.length) {
            console.warn('[DoogieLoadingScreen] No tracks found in playlist.js');
            return;
        }

        State.playlist = [...PLAYLIST];

        if (CONFIG.shuffle) shuffleArray(State.playlist);

        State.currentTrack = 0;
        applyTrack(0);
    }

    function shuffleArray(arr) {
        for (let i = arr.length - 1; i > 0; i--) {
            const j = Math.floor(Math.random() * (i + 1));
            [arr[i], arr[j]] = [arr[j], arr[i]];
        }
    }

    function applyTrack(index) {
        const track = State.playlist[index];
        if (!track) return;

        updateAudioSource(track);
        updateVideoSource(track);
        updateCoverArt(track);
        updateTrackInfo(track, index);
    }

    function updateAudioSource(track) {
        if (!DOM.backgroundAudio) return;

        DOM.backgroundAudio.oncanplaythrough = null;
        DOM.backgroundAudio.src = track.src;
        DOM.backgroundAudio.load();

        DOM.backgroundAudio.oncanplaythrough = () => {
            DOM.backgroundAudio.oncanplaythrough = null;
            if (State.isPlaying) {
                DOM.backgroundAudio.play().catch(() => { });
            }
        };
    }

    function updateVideoSource(track) {
        if (!DOM.backgroundVideo || !track.video) return;

        const source = DOM.backgroundVideo.querySelector('source');
        const currentSrc = source
            ? source.getAttribute('src')
            : DOM.backgroundVideo.getAttribute('src');

        if (currentSrc === track.video) return;

        if (source) {
            source.src = track.video;
        } else {
            DOM.backgroundVideo.src = track.video;
        }

        DOM.backgroundVideo.load();
        DOM.backgroundVideo.play().catch(() => { });
    }

    function updateCoverArt(track) {
        if (!DOM.musicArt) return;
        const img = DOM.musicArt.querySelector('img');
        if (img) {
            img.src = track.cover;
            img.alt = `${track.title} — ${track.artist}`;
        }
    }

    function updateTrackInfo(track, index) {
        if (DOM.musicTitle) DOM.musicTitle.textContent = track.title;
        if (DOM.musicArtist) DOM.musicArtist.textContent = track.artist;
        if (DOM.trackCounter) DOM.trackCounter.textContent = `${index + 1} / ${State.playlist.length}`;
    }

    function nextTrack() {
        if (!State.playlist.length) return;
        State.currentTrack = (State.currentTrack + 1) % State.playlist.length;
        applyTrack(State.currentTrack);
    }

    function prevTrack() {
        if (!State.playlist.length) return;

        // If >3s into song → restart instead of going back
        if (DOM.backgroundAudio && DOM.backgroundAudio.currentTime > 3) {
            DOM.backgroundAudio.currentTime = 0;
            return;
        }

        State.currentTrack = (State.currentTrack - 1 + State.playlist.length) % State.playlist.length;
        applyTrack(State.currentTrack);
    }

    /* ═══════════════════════════════════════════════
       5  MUSIC PLAYER CONTROLS
       ═══════════════════════════════════════════════ */

    const SVG_ICON = {
        play: '<path d="M8 5v14l11-7z"/>',
        pause: '<path d="M6 19h4V5H6v14zm8-14v14h4V5h-4z"/>',
        volumeOn: '<svg viewBox="0 0 24 24" fill="currentColor" width="16" height="16"><path d="M3 9v6h4l5 5V4L7 9H3zm13.5 3c0-1.77-1.02-3.29-2.5-4.03v8.05c1.48-.73 2.5-2.25 2.5-4.02z"/></svg>',
        volumeOff: '<svg viewBox="0 0 24 24" fill="currentColor" width="16" height="16"><path d="M16.5 12c0-1.77-1.02-3.29-2.5-4.03v2.21l2.45 2.45c.03-.2.05-.41.05-.63zm2.5 0c0 .94-.2 1.82-.54 2.64l1.51 1.51C20.63 14.91 21 13.5 21 12c0-4.28-2.99-7.86-7-8.77v2.06c2.89.86 5 3.54 5 6.71zM4.27 3L3 4.27 7.73 9H3v6h4l5 5v-6.73l4.25 4.25c-.67.52-1.42.93-2.25 1.18v2.06c1.38-.31 2.63-.95 3.69-1.81L19.73 21 21 19.73l-9-9L4.27 3zM12 4L9.91 6.09 12 8.18V4z"/></svg>',
        eyeOpen: '<svg viewBox="0 0 24 24" fill="currentColor" width="16" height="16"><path d="M12 4.5C7 4.5 2.73 7.61 1 12c1.73 4.39 6 7.5 11 7.5s9.27-3.11 11-7.5c-1.73-4.39-6-7.5-11-7.5zM12 17c-2.76 0-5-2.24-5-5s2.24-5 5-5 5 2.24 5 5-2.24 5-5 5zm0-8c-1.66 0-3 1.34-3 3s1.34 3 3 3 3-1.34 3-3-1.34-3-3-3z"/></svg>',
        eyeClosed: '<svg viewBox="0 0 24 24" fill="currentColor" width="16" height="16"><path d="M12 7c2.76 0 5 2.24 5 5 0 .65-.13 1.26-.36 1.83l2.92 2.92c1.51-1.26 2.7-2.89 3.43-4.75-1.73-4.39-6-7.5-11-7.5-1.4 0-2.74.25-3.98.7l2.16 2.16C10.74 7.13 11.35 7 12 7zM2 4.27l2.28 2.28.46.46C3.08 8.3 1.78 10.02 1 12c1.73 4.39 6 7.5 11 7.5 1.55 0 3.03-.3 4.38-.84l.42.42L19.73 22 21 20.73 3.27 3 2 4.27zM7.53 9.8l1.55 1.55c-.05.21-.08.43-.08.65 0 1.66 1.34 3 3 3 .22 0 .44-.03.65-.08l1.55 1.55c-.67.33-1.41.53-2.2.53-2.76 0-5-2.24-5-5 0-.79.2-1.53.53-2.2zm4.31-.78l3.15 3.15.02-.16c0-1.66-1.34-3-3-3l-.17.01z"/></svg>',
    };

    function setupMusicPlayer() {
        bindControl(DOM.playPauseBtn, togglePlayPause);
        bindControl(DOM.volumeBtn, toggleMute);
        bindControl(DOM.toggleLogoBtn, toggleLogo);
        bindControl(DOM.prevBtn, prevTrack);
        bindControl(DOM.nextBtn, nextTrack);

        if (DOM.backgroundAudio) {
            DOM.backgroundAudio.addEventListener('ended', nextTrack);
        }
    }

    function bindControl(element, handler) {
        if (element) element.addEventListener('click', handler);
    }

    function togglePlayPause() {
        if (!DOM.backgroundAudio) return;

        if (State.isPlaying) {
            DOM.backgroundAudio.pause();
            if (DOM.backgroundVideo) DOM.backgroundVideo.pause();
            State.isPlaying = false;
            DOM.playPauseIcon.innerHTML = SVG_ICON.play;
        } else {
            DOM.backgroundAudio.play().catch(() => { });
            if (DOM.backgroundVideo) DOM.backgroundVideo.play().catch(() => { });
            State.isPlaying = true;
            DOM.playPauseIcon.innerHTML = SVG_ICON.pause;
        }
    }

    function toggleMute() {
        if (!DOM.backgroundAudio) return;

        DOM.backgroundAudio.muted = !DOM.backgroundAudio.muted;
        DOM.volumeBtn.innerHTML = DOM.backgroundAudio.muted
            ? SVG_ICON.volumeOff
            : SVG_ICON.volumeOn;
    }

    function toggleLogo() {
        if (!DOM.heroLogo) return;

        State.isLogoVisible = !State.isLogoVisible;
        
        if (State.isLogoVisible) {
            DOM.heroLogo.classList.remove('hidden-logo');
            DOM.toggleLogoBtn.innerHTML = SVG_ICON.eyeOpen;
        } else {
            DOM.heroLogo.classList.add('hidden-logo');
            DOM.toggleLogoBtn.innerHTML = SVG_ICON.eyeClosed;
        }
    }

    /* ═══════════════════════════════════════════════
       6  AUDIO & VIDEO SETUP
       ═══════════════════════════════════════════════ */

    function setupAudio() {
        if (!DOM.backgroundAudio) return;
        DOM.backgroundAudio.volume = State.volume;

        // Autoplay fallback — play on first user interaction
        document.addEventListener('click', () => {
            if (DOM.backgroundAudio.paused && State.isPlaying) {
                DOM.backgroundAudio.play().catch(() => { });
            }
        }, { once: true });
    }

    function setupVideo() {
        if (!DOM.backgroundVideo) return;
        DOM.backgroundVideo.addEventListener('error', () => {
            document.body.style.background =
                'linear-gradient(135deg, #0a0a1a 0%, #1a0a2e 50%, #0a1a2a 100%)';
        });
    }

    /* ═══════════════════════════════════════════════
       7  HERO TITLE & SOCIAL LINKS
       ═══════════════════════════════════════════════ */

    function setupHeroTitle() {
        if (DOM.heroLogo) {
            if (CONFIG.serverLogo && CONFIG.serverLogo.trim() !== '') {
                DOM.heroLogo.src = CONFIG.serverLogo;
                DOM.heroLogo.style.display = 'inline-block';
            } else {
                DOM.heroLogo.style.display = 'none';
                if (DOM.toggleLogoBtn) DOM.toggleLogoBtn.style.display = 'none';
            }
        }

        if (DOM.heroName && CONFIG.heroTitle) {
            DOM.heroName.textContent = CONFIG.heroTitle;
        }

        if (DOM.heroTagline) {
            if (CONFIG.heroTagline) {
                DOM.heroTagline.textContent = CONFIG.heroTagline;
            } else {
                DOM.heroTagline.style.display = 'none';
            }
        }
    }

    function setupServerBranding() {
        if (DOM.serverName && CONFIG.serverName) {
            DOM.serverName.textContent = CONFIG.serverName;
        }

        if (DOM.serverDiscordText) {
            if (CONFIG.serverDiscordText) {
                DOM.serverDiscordText.textContent = CONFIG.serverDiscordText;
            } else {
                DOM.serverDiscordText.style.display = 'none';
            }
        }
    }

    function setupChangelogs() {
        if (DOM.changelogTitleText && CONFIG.changelogTitle) {
            DOM.changelogTitleText.textContent = CONFIG.changelogTitle;
        }

        if (DOM.changelogList && CONFIG.changelogs) {
            DOM.changelogList.innerHTML = '';
            const fragment = document.createDocumentFragment();

            CONFIG.changelogs.forEach(log => {
                const entry = document.createElement('div');
                entry.className = 'changelog-entry';
                
                const meta = document.createElement('div');
                meta.className = 'changelog-meta';
                meta.textContent = `${log.version} · ${log.date}`;
                
                const desc = document.createElement('div');
                desc.className = 'changelog-desc';
                desc.textContent = log.desc;

                entry.appendChild(meta);
                entry.appendChild(desc);
                fragment.appendChild(entry);
            });
            DOM.changelogList.appendChild(fragment);
        }
    }

    function setupStaffList() {
        if (DOM.staffTitleText && CONFIG.staffTitle) {
            DOM.staffTitleText.textContent = CONFIG.staffTitle;
        }

        if (DOM.staffList && CONFIG.staffList) {
            DOM.staffList.innerHTML = '';
            const fragment = document.createDocumentFragment();

            CONFIG.staffList.forEach(member => {
                const entry = document.createElement('div');
                entry.className = 'staff-entry';
                
                const role = document.createElement('div');
                role.className = 'staff-role';
                role.textContent = member.role;
                
                const name = document.createElement('div');
                name.className = 'staff-name';
                name.innerHTML = member.name;

                entry.appendChild(role);
                entry.appendChild(name);
                fragment.appendChild(entry);
            });
            DOM.staffList.appendChild(fragment);
        }
    }

    function setupSocialLinks() {
        const mapping = [
            { id: 'socialDiscord', url: CONFIG.discordUrl },
            { id: 'socialYoutube', url: CONFIG.youtubeUrl },
            { id: 'socialTiktok', url: CONFIG.tiktokUrl },
        ];

        mapping.forEach(({ id, url }) => {
            const el = DOM[id];
            if (!el) return;

            if (!url) {
                el.style.display = 'none';
                return;
            }

            el.href = '#';
            el.addEventListener('click', (e) => {
                e.preventDefault();
                if (typeof window.invokeNative === 'function') {
                    window.invokeNative('openUrl', url);
                } else {
                    window.open(url, '_blank');
                }
            });
        });
    }

    /* ═══════════════════════════════════════════════
       8  FIVEM INTEGRATION
       ═══════════════════════════════════════════════ */

    function setupFiveMEvents() {
        const handlers = {
            loadProgress(data) {
                const pct = Math.floor((data.loadFraction || 0) * 100);
                if (pct === State.targetProgress) return; // Prevent unnecessary DOM reflows
                
                setProgress(pct);
                setStatusText(getStatusLabel(pct));
                
                if (State.simulationActive) {
                    State.simulationActive = false;
                    clearTimeout(State.simulationTimer);
                }
            },

            startInitFunctionOrder(data) {
                setStatusText(`Initializing: ${data.type || ''}`.trim());
            },

            initFunctionInvoking(data) {
                setStatusText(`Loading: ${data.name || ''}`.trim());
            },

            startDataFileEntries(data) {
                setStatusText(`Loading data files: ${data.count || 0}`);
            },

            performMapLoadFunction() {
                setStatusText('Loading map...');
            },

            onLogLine(data) {
                if (data.message && data.message.length < 80) {
                    setStatusText(data.message);
                }
            },

            shutdown() {
                document.body.style.transition = 'opacity 1s ease';
                document.body.style.opacity = '0';
                setTimeout(() => {
                    if (DOM.backgroundAudio) DOM.backgroundAudio.pause();
                }, 1000);
            },
        };

        window.addEventListener('message', (event) => {
            const handler = handlers[event.data.eventName];
            if (handler) handler(event.data);
        });
    }

    function getStatusLabel(pct) {
        if (pct < 15) return 'Connecting to server...';
        if (pct < 35) return 'Loading assets...';
        if (pct < 55) return 'Loading resources...';
        if (pct < 75) return 'Loading map...';
        if (pct < 90) return 'Initializing scripts...';
        if (pct < 100) return 'Almost Ready...';
        return 'Ready!';
    }

    /* ═══════════════════════════════════════════════
       9  FALLBACK SIMULATION
       ═══════════════════════════════════════════════ */

    function runSimulation() {
        if (!State.simulationActive) return;

        const steps = CONFIG.loadingSteps;

        function tick() {
            if (State.stepIndex >= steps.length || !State.simulationActive) return;

            const step = steps[State.stepIndex];
            setStatusText(step.label);
            setProgress(step.target);
            State.stepIndex++;

            if (State.stepIndex < steps.length) {
                State.simulationTimer = setTimeout(tick, 1500 + Math.random() * 2500);
            }
        }

        State.simulationTimer = setTimeout(tick, 1200);
    }

    /* ═══════════════════════════════════════════════
       10  INITIALIZATION
       ═══════════════════════════════════════════════ */

    function init() {
        cacheDom();

        // Media
        loadPlaylist();
        setupAudio();
        setupVideo();
        setupMusicPlayer();

        // UI
        setupHeroTitle();
        setupServerBranding();
        setupChangelogs();
        setupStaffList();
        setupSocialLinks();

        // FiveM events
        setupFiveMEvents();

        // Fallback progress simulation (dev / local testing)
        setTimeout(() => {
            if (State.simulationActive) runSimulation();
        }, 500);
    }

    // Boot
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }

})();