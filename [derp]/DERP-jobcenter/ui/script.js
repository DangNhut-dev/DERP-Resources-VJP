const RESOURCE = GetParentResourceName ? GetParentResourceName() : 'DERP-jobcenter'

const root = document.getElementById('jobcenter')
const jobListEl = document.getElementById('job-list')
const uiTitleEl = document.getElementById('ui-title')
const playerNameEl = document.getElementById('player-name')
const playerJobEl = document.getElementById('player-job')
const btnClose = document.getElementById('btn-close')

const normalizeColor = (hex) => {
  if (!hex) return '#FFB900'
  const c = hex.trim().replace(/^#/,'')
  return `#${c}`
}

const clampIfOverflow = (el) => {
  if (el.scrollHeight > el.clientHeight + 1) {
    el.classList.add('clamped')
  }
}

const createJobCard = (jobName, def) => {
  const color = normalizeColor(def.color || '#FFB900')
  const card = document.createElement('div')
  card.className = 'job'
  const img = document.createElement('img')
  img.className = 'job-img'
  img.alt = def.title || jobName
  img.src = def.image || 'images/placeholder.png'
  const box = document.createElement('div')
  box.className = 'job-box'
  const title = document.createElement('p')
  title.className = 'job-title'
  title.textContent = def.title || jobName
  title.style.color = color
  const desc = document.createElement('p')
  desc.className = 'job-description'
  desc.textContent = def.description || ''

  const btnWrap = document.createElement('div')
  btnWrap.className = 'job-buttons'

  const btn = document.createElement('button')
  btn.className = 'job-button'
  btn.textContent = def.setJob ? 'Bắt Đầu Công Việc' : 'Đánh Dấu Vị Trí'
  btn.style.setProperty('--btn-color', color)
  btn.style.setProperty('--btn-text', '#121214')
  btn.addEventListener('click', () => {
    fetch(`https://${RESOURCE}/puffin:jobcenter:selectJob`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json; charset=UTF-8' },
      body: JSON.stringify({
        action: 'puffin:jobcenter:selectJob',
        job: jobName,
        title: def.title || jobName,
        setJob: !!def.setJob
      })
    }).catch(() => {})
  })

  btnWrap.appendChild(btn)

  if (def.guide) {
    const guideBtn = document.createElement('button')
    guideBtn.className = 'job-button job-button-guide'
    guideBtn.textContent = 'Hướng Dẫn'
    guideBtn.style.setProperty('--btn-color', color)
    guideBtn.style.setProperty('--btn-text', '#121214')
    guideBtn.addEventListener('click', () => {
      openGuide(def.guide)
    })
    btnWrap.appendChild(guideBtn)
  }

  box.appendChild(title)
  box.appendChild(desc)
  box.appendChild(btnWrap)
  card.appendChild(img)
  card.appendChild(box)
  requestAnimationFrame(() => clampIfOverflow(desc))
  return card
}


const renderJobs = (config) => {
  jobListEl.innerHTML = ''
  const jobs = (config && config.Jobs) || {}
  for (const [name, def] of Object.entries(jobs)) {
    jobListEl.appendChild(createJobCard(name, def))
  }
}

const openUI = () => {
  root.style.display = 'block'
  document.body.style.overflow = 'hidden'
}

const closeUI = () => {
  root.style.display = 'none';
  document.body.style.overflow = '';
  fetch(`https://${RESOURCE}/puffin:jobcenter:close`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json; charset=UTF-8' },
    body: JSON.stringify({})
  }).catch(() => {});
};

document.addEventListener('keyup', (e) => {
  if (e.key === 'Escape') {
    closeUI();
  }
});

btnClose.addEventListener('click', closeUI)

window.addEventListener('message', (event) => {
  const data = event.data || {}
  if (data.action === 'open') {
    const payload = data.payload || {}
    const config = payload.config || {}
    const player = payload.player || {}
    if (config.Title) uiTitleEl.textContent = config.Title
    if (player.name) playerNameEl.textContent = player.name
    if (player.currentJob) playerJobEl.textContent = player.currentJob
    renderJobs(config)
    openUI()
  } else if (data.action === 'close') {
    closeUI()
  }
})

let guideOverlay = null

const openGuide = (url) => {
  if (guideOverlay) closeGuide()
  const videoId = url.match(/[?&]v=([^&]+)/)?.[1] || url.split('/').pop()
  if (!videoId) return

  guideOverlay = document.createElement('div')
  guideOverlay.className = 'guide-overlay'
  guideOverlay.innerHTML = `
    <div class="guide-wrap">
      <div class="guide-header">
        <p>Hướng Dẫn</p>
        <svg class="guide-close" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
          <path d="M17 7L7 17M7 7L17 17" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
        </svg>
      </div>
      <iframe src="https://www.youtube.com/embed/${videoId}?autoplay=1&rel=0" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>
    </div>
  `
  guideOverlay.querySelector('.guide-close').addEventListener('click', closeGuide)
  guideOverlay.addEventListener('click', (e) => {
    if (e.target === guideOverlay) closeGuide()
  })
  document.body.appendChild(guideOverlay)
}

const closeGuide = () => {
  if (!guideOverlay) return
  guideOverlay.remove()
  guideOverlay = null
}