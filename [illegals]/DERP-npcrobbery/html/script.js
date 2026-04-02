const ICONS   = ['👕', '👛', '🎒']
let zonesData = []

window.addEventListener('message', function(e) {
    if (e.data.action === 'show') {
        zonesData = e.data.zones
        const root = document.getElementById('zones-root')
        root.innerHTML = ''

        zonesData.forEach((z, idx) => {
            const el = document.createElement('div')
            el.className = 'zone-marker'
            el.id = 'zone-' + z.id
            el.innerHTML = `
                <div class="zone-circle">${ICONS[idx] || '💰'}</div>
                <div class="zone-label">${z.label}</div>
            `
            el.addEventListener('click', function() {
                if (el.classList.contains('done')) return
                fetch(`https://${GetParentResourceName()}/zoneClick`, {
                    method:  'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body:    JSON.stringify({ id: z.id })
                })
            })
            root.appendChild(el)
        })

        document.getElementById('overlay').classList.remove('hidden')
    }

    if (e.data.action === 'updatePositions') {
        e.data.zones.forEach(z => {
            const el = document.getElementById('zone-' + z.id)
            if (!el) return

            if (!z.visible) {
                el.style.opacity = '0'
                return
            }

            el.style.opacity = z.done ? '0.35' : '1'
            el.style.left    = (z.x * 100) + '%'
            el.style.top     = (z.y * 100) + '%'

            if (z.done && !el.classList.contains('done')) {
                el.classList.add('done')
                el.querySelector('.zone-circle').innerHTML = '<span class="done-check">✓</span>'
            }
        })
    }

    if (e.data.action === 'hide') {
        document.getElementById('overlay').classList.add('hidden')
        document.getElementById('zones-root').innerHTML = ''
        zonesData = []
    }
})

window.addEventListener('keydown', function(e) {
    if (e.code === 'Escape') {
        fetch(`https://${GetParentResourceName()}/closeUI`, {
            method:  'POST',
            headers: { 'Content-Type': 'application/json' },
            body:    JSON.stringify({})
        })
    }
})