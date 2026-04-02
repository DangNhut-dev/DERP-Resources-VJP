let cfg        = {};
let score      = 0;
let timeLeft   = 160;
let gameActive = false;
let basketX    = 191;
let keys       = { left: false, right: false };
let animFrame  = null;
let timerInterval = null;
let spawnInterval = null;
let items      = [];

const ARENA_W       = 440;
const BASKET_W      = 58;
const ITEM_W        = 40;
const BASKET_SPEED  = 6;

window.addEventListener('message', function(e) {
    if (e.data.action === 'start') {
        cfg      = e.data.config;
        timeLeft = cfg.duration;
        score    = 0;
        startGame();
    }
});

window.addEventListener('keydown', function(e) {
    if (e.code === 'KeyA') keys.left  = true;
    if (e.code === 'KeyD') keys.right = true;
});

window.addEventListener('keyup', function(e) {
    if (e.code === 'KeyA') keys.left  = false;
    if (e.code === 'KeyD') keys.right = false;
});

function startGame() {
    gameActive = true;
    score      = 0;
    items      = [];
    keys       = { left: false, right: false };

    document.getElementById('overlay').classList.remove('hidden');
    document.getElementById('result-overlay').classList.add('hidden');
    document.getElementById('arena').querySelectorAll('.falling-item,.catch-fx').forEach(e => e.remove());

    basketX = (ARENA_W - BASKET_W) / 2;
    updateBasket();

    const inner = document.getElementById('timer-bar-inner');
    inner.style.transition = 'none';
    inner.style.width = '100%';
    document.getElementById('timer-text').textContent = timeLeft + 's';
    setTimeout(() => { inner.style.transition = 'width 0.9s linear'; }, 50);

    timerInterval = setInterval(() => {
        timeLeft = Math.max(0, timeLeft - 1);
        document.getElementById('timer-text').textContent = timeLeft + 's';
        inner.style.width = (timeLeft / cfg.duration * 100) + '%';
        if (timeLeft <= 0) endGame();
    }, 1000);

    spawnInterval = setInterval(spawnItem, cfg.spawnRate);
    spawnItem();
    gameLoop();
}

function updateBasket() {
    document.getElementById('basket').style.left = basketX + 'px';
}

function gameLoop() {
    if (!gameActive) return;

    if (keys.left)  basketX = Math.max(0, basketX - BASKET_SPEED);
    if (keys.right) basketX = Math.min(ARENA_W - BASKET_W, basketX + BASKET_SPEED);
    updateBasket();

    const arenaH   = 360;
    const basketTop = arenaH - 14 - 50;

    for (let i = items.length - 1; i >= 0; i--) {
        const item = items[i];
        item.y += item.speed;
        item.el.style.top = item.y + 'px';

        const cx = item.x + ITEM_W / 2;
        const caught = item.y + ITEM_W >= basketTop
            && item.y <= basketTop + 50
            && cx >= basketX
            && cx <= basketX + BASKET_W;

        if (caught || item.y > arenaH) {
            item.el.remove();
            items.splice(i, 1);
            if (caught) {
                if (item.isBomb) {
                    score = Math.max(0, score - cfg.bombPenalty);
                    spawnFx('-' + cfg.bombPenalty, item.x, basketTop, true);
                    shakeBasket();
                } else {
                    score = Math.min(cfg.maxReward, score + cfg.coinValue);
                    spawnFx('+' + cfg.coinValue, item.x, basketTop, false);
                }
            }
        }
    }

    animFrame = requestAnimationFrame(gameLoop);
}

function spawnItem() {
    if (!gameActive) return;
    const arena  = document.getElementById('arena');
    const isBomb = Math.random() < 0.40;
    const el     = document.createElement('div');
    el.className   = 'falling-item ' + (isBomb ? 'is-bomb' : 'is-coin');
    el.textContent = '💰';

    const x = Math.random() * (ARENA_W - ITEM_W);
    el.style.left = x + 'px';
    el.style.top  = '-44px';
    arena.appendChild(el);

    const timeRatio = 1 - (timeLeft / cfg.duration);
    items.push({
        el,
        x,
        y:      -44,
        speed:  (1.8 + Math.random() * 1.4) + timeRatio * 2.5,
        isBomb,
    });
}

function spawnFx(text, x, y, negative) {
    const arena = document.getElementById('arena');
    const el    = document.createElement('div');
    el.className   = 'catch-fx ' + (negative ? 'negative' : 'positive');
    el.textContent = text;
    el.style.left  = Math.min(x, ARENA_W - 60) + 'px';
    el.style.top   = (y - 10) + 'px';
    arena.appendChild(el);
    setTimeout(() => el.remove(), 850);
}

function shakeBasket() {
    const b = document.getElementById('basket');
    b.style.transform = 'rotate(-14deg) scale(1.1)';
    setTimeout(() => b.style.transform = 'rotate(14deg)', 80);
    setTimeout(() => b.style.transform = 'rotate(0deg) scale(1)', 160);
}

function endGame() {
    gameActive = false;
    clearInterval(timerInterval);
    clearInterval(spawnInterval);
    cancelAnimationFrame(animFrame);
    keys = { left: false, right: false };
    items.forEach(i => i.el.remove());
    items = [];

    document.getElementById('overlay').classList.add('hidden');

    // score là số coin * coinValue (0.5), làm tròn lên
    const money = Math.ceil(score);
    document.getElementById('result-amount').textContent = '$' + money.toLocaleString();
    document.getElementById('result-overlay').classList.remove('hidden');

    window._finalMoney = money;
}

function confirmResult() {
    document.getElementById('result-overlay').classList.add('hidden');
    fetch(`https://${GetParentResourceName()}/moneyGameEnd`, {
        method:  'POST',
        headers: { 'Content-Type': 'application/json' },
        body:    JSON.stringify({ amount: window._finalMoney || 0 })
    });
}