#!/usr/bin/env bash
set -euo pipefail

DOMAIN="${1:-}"
SPORT="${2:-9000}"

if [[ $EUID -ne 0 ]]; then
    echo "Run as root"
    exit 1
fi

if [[ -z "$DOMAIN" ]]; then
    echo "Usage: $0 domain.tld [local_https_port]"
    echo "Example: $0 example.com 9000"
    exit 1
fi

echo "[1/9] Installing packages..."

dnf install -y \
    nginx \
    certbot \
    python3-certbot-nginx \
    curl \
    bind-utils \
    policycoreutils-python-utils

echo "[2/9] Opening HTTP/HTTPS firewall ports..."

systemctl enable --now firewalld 2>/dev/null || true

firewall-cmd --permanent --add-service=http >/dev/null 2>&1 || true
firewall-cmd --permanent --add-port=443/tcp >/dev/null 2>&1 || true
firewall-cmd --reload >/dev/null 2>&1 || true

echo "[3/9] Checking DNS..."

SERVER_IP="$(curl -4 -fsS https://api.ipify.org || true)"
DOMAIN_IP="$(dig +short A "$DOMAIN" | tail -n1)"

echo "Server IPv4 : ${SERVER_IP:-unknown}"
echo "Domain IPv4 : ${DOMAIN_IP:-unknown}"

if [[ -n "$SERVER_IP" && -n "$DOMAIN_IP" && "$SERVER_IP" != "$DOMAIN_IP" ]]; then
    echo
    echo "WARNING: $DOMAIN resolves to $DOMAIN_IP but server IP is $SERVER_IP"
    echo "Let's Encrypt may fail."
    echo
fi

echo "[4/9] Creating temporary HTTP nginx config..."

mkdir -p /var/www/html

PAGE_VARIANT=$((RANDOM % 5 + 1))

case "$PAGE_VARIANT" in
    1)
        PAGE_HERO="Invoker"
        cat > /var/www/html/index.html <<'EOF'
<!doctype html>
<html lang="ru">
<head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<meta name="description" content="Портрет Invoker — героя Dota 2"><title>Invoker — Архив стихий</title>
<style>
*{box-sizing:border-box}body{margin:0;color:#f6e8cb;font-family:Georgia,serif;background:radial-gradient(circle at 78% 47%,#703829 0,#311b21 31%,#100f1c 73%);min-height:100vh}main{max-width:1180px;min-height:100vh;margin:auto;padding:32px;display:grid;grid-template-rows:auto 1fr auto}header,footer{display:flex;justify-content:space-between;gap:20px;align-items:center;border-bottom:1px solid #cba76a66;padding-bottom:16px;color:#d4b989;font:12px Arial,sans-serif;letter-spacing:.22em;text-transform:uppercase}footer{border:0;border-top:1px solid #cba76a66;padding:18px 0 0}.hero{display:grid;grid-template-columns:1fr 1fr;gap:40px;align-items:center}.eyebrow{color:#d4b989;font:700 13px Arial,sans-serif;letter-spacing:.25em;text-transform:uppercase}h1{font-size:clamp(72px,10vw,150px);line-height:.85;letter-spacing:-.07em;margin:25px 0}p{max-width:550px;font-size:21px;line-height:1.55;color:#d4c2ae}.orbs{height:470px;position:relative;display:grid;place-items:center}.orb{position:absolute;width:175px;aspect-ratio:1;border-radius:50%;border:3px solid #ffffff70;box-shadow:0 0 50px currentColor,inset 0 0 35px currentColor;display:grid;place-items:center;color:#fff;font:700 35px Arial,sans-serif}.orb:nth-child(1){top:4%;left:31%;background:#f5945a88}.orb:nth-child(2){bottom:8%;left:4%;background:#75adf088}.orb:nth-child(3){bottom:8%;right:4%;background:#b876e688}.seal{width:330px;aspect-ratio:1;border:1px solid #d4b98988;border-radius:50%;box-shadow:0 0 0 25px #d4b98912,0 0 0 50px #d4b98908}@media(max-width:750px){main{padding:22px}.hero{grid-template-columns:1fr;padding:55px 0}.orbs{height:300px}.seal{width:210px}.orb{width:115px;font-size:24px}footer{flex-direction:column;align-items:flex-start}}
</style></head>
<body><main><header><span>Архив стихий</span><span>Dota 2 · Герой 01</span></header>
<section class="hero"><div><div class="eyebrow">Мастер заклинаний</div><h1>INVOKER</h1><p>Три сферы, бесчисленные сочетания и поле боя, на котором каждый ход становится частью большого замысла.</p></div><div class="orbs" aria-label="Три магические сферы"><div class="seal"></div><div class="orb">Q</div><div class="orb">W</div><div class="orb">E</div></div></section>
<footer><span>Quas · Wex · Exort</span><span>Искусство выбирать момент</span></footer></main></body></html>
EOF
        ;;
    2)
        PAGE_HERO="Pudge"
        cat > /var/www/html/index.html <<'EOF'
<!doctype html>
<html lang="ru">
<head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<meta name="description" content="Портрет Pudge — героя Dota 2"><title>Pudge — Из тумана</title>
<style>
*{box-sizing:border-box}body{margin:0;min-height:100vh;background:#101713;color:#f3e8d4;font-family:Impact,'Arial Narrow',sans-serif;overflow-x:hidden}body:before{content:"";position:fixed;inset:0;background:repeating-linear-gradient(0deg,transparent 0 5px,#0004 6px 7px),radial-gradient(ellipse at 70% 45%,#53683b88,transparent 50%);pointer-events:none}.wrap{position:relative;max-width:1250px;min-height:100vh;margin:auto;padding:32px;display:flex;flex-direction:column}.top{display:flex;justify-content:space-between;color:#b7d47c;font:700 12px monospace;letter-spacing:.2em}.scene{flex:1;display:grid;grid-template-columns:1fr 1fr;align-items:center;gap:30px}.label{display:inline-block;padding:10px 16px;background:#c6dd85;color:#152014;font:700 13px monospace;text-transform:uppercase;transform:rotate(-3deg)}h1{font-size:clamp(110px,17vw,250px);line-height:.75;letter-spacing:-.07em;margin:35px 0;text-shadow:8px 10px #334629}.copy{max-width:460px;color:#c7cdb7;font:20px/1.5 Arial,sans-serif}.hook{position:relative;height:480px;display:grid;place-items:center}.hook:before{content:"";position:absolute;left:50%;top:-100px;width:14px;height:320px;background:repeating-linear-gradient(135deg,#829275 0 12px,#394b39 12px 23px);transform:rotate(-18deg);box-shadow:10px 0 25px #000}.hook:after{content:"";width:230px;height:230px;border:46px solid #a6b4a0;border-top-color:transparent;border-left-color:transparent;border-radius:50%;transform:rotate(39deg);filter:drop-shadow(18px 25px 8px #0009)}.note{border-top:2px solid #b7d47c;padding-top:16px;color:#b7d47c;font:700 14px monospace;letter-spacing:.13em}@media(max-width:750px){.scene{grid-template-columns:1fr;padding:65px 0}.hook{height:240px}.hook:before{height:180px}.hook:after{width:145px;height:145px;border-width:30px}h1{font-size:clamp(88px,19vw,140px)}}
</style></head>
<body><main class="wrap"><div class="top"><span>THE HOOK FILES</span><span>DOTA 2 / 02</span></div><section class="scene"><div><span class="label">Кто-то рядом</span><h1>PUDGE</h1><p class="copy">В тумане слышен скрежет цепи. Один точный крюк — и безопасная дистанция превращается в ловушку.</p></div><div class="hook" aria-hidden="true"></div></section><div class="note">★ ОСТОРОЖНО: НЕ ПОДХОДИТЕ К КРАЮ ТУМАНА</div></main></body></html>
EOF
        ;;
    3)
        PAGE_HERO="Crystal Maiden"
        cat > /var/www/html/index.html <<'EOF'
<!doctype html>
<html lang="ru">
<head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<meta name="description" content="Портрет Crystal Maiden — героя Dota 2"><title>Crystal Maiden — Северное сияние</title>
<style>
*{box-sizing:border-box}body{margin:0;min-height:100vh;color:#14354b;font-family:Arial,sans-serif;background:linear-gradient(145deg,#e7faff,#b6ddec 60%,#d8eeff)}main{max-width:1180px;min-height:100vh;margin:auto;padding:30px;display:flex;flex-direction:column}header{display:flex;justify-content:space-between;color:#32657c;font-size:12px;font-weight:700;letter-spacing:.18em;text-transform:uppercase}.hero{flex:1;display:grid;grid-template-columns:1.1fr .9fr;gap:55px;align-items:center}.tag{color:#4389ab;font-size:13px;letter-spacing:.24em;text-transform:uppercase}h1{font-family:Georgia,serif;font-size:clamp(66px,9vw,130px);line-height:.9;font-weight:400;letter-spacing:-.06em;margin:25px 0}.lead{max-width:560px;color:#426779;font-size:21px;line-height:1.6}.snow{height:480px;position:relative;display:grid;place-items:center;background:radial-gradient(circle,#fff 0,#d9f7ff 42%,transparent 70%)}.snow:before,.snow:after{content:"❄";position:absolute;color:#6fc2e1;text-shadow:0 0 25px #fff}.snow:before{font-size:280px;animation:turn 35s linear infinite}.snow:after{font-size:130px;color:#fff}.flake{position:absolute;color:#74bfd9;font-size:35px}.flake:nth-child(1){top:12%;left:15%}.flake:nth-child(2){right:14%;top:22%}.flake:nth-child(3){bottom:10%;left:26%}@keyframes turn{to{transform:rotate(360deg)}}footer{padding:18px 0;border-top:1px solid #78afc5;color:#32657c;font-size:14px}@media(max-width:750px){.hero{grid-template-columns:1fr;padding:70px 0 20px}.snow{height:280px}.snow:before{font-size:200px}.snow:after{font-size:90px}}
</style></head>
<body><main><header><span>Северный атлас</span><span>Герой Dota 2 / 03</span></header><section class="hero"><div><div class="tag">Холод, который меняет битву</div><h1>Crystal<br>Maiden</h1><p class="lead">Рилай превращает мороз в защиту для союзников и угрозу для тех, кто подошёл слишком близко.</p></div><div class="snow" aria-label="Снежинка"><span class="flake">✦</span><span class="flake">✧</span><span class="flake">✦</span></div></section><footer>Тишина перед ледяной бурей.</footer></main></body></html>
EOF
        ;;
    4)
        PAGE_HERO="Phantom Assassin"
        cat > /var/www/html/index.html <<'EOF'
<!doctype html>
<html lang="ru">
<head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<meta name="description" content="Портрет Phantom Assassin — героя Dota 2"><title>Phantom Assassin — Тень клинка</title>
<style>
*{box-sizing:border-box}body{margin:0;min-height:100vh;color:#f6ecff;font-family:Arial,sans-serif;background:#110d1c;background-image:linear-gradient(125deg,transparent 47%,#9f46c326 48% 52%,transparent 53%),radial-gradient(circle at 73% 48%,#522366 0,transparent 47%)}main{max-width:1200px;min-height:100vh;margin:auto;padding:32px;display:flex;flex-direction:column}.top,.bottom{display:flex;justify-content:space-between;gap:15px;color:#d890ef;text-transform:uppercase;font-size:12px;letter-spacing:.2em}.bottom{border-top:1px solid #9f46c366;padding-top:20px}.hero{flex:1;display:grid;grid-template-columns:1fr 1fr;gap:30px;align-items:center}.index{font:700 14px monospace;color:#e9a6ff}h1{font-size:clamp(66px,9vw,132px);line-height:.85;letter-spacing:-.075em;text-transform:uppercase;margin:22px 0}.lead{max-width:510px;color:#c6afd0;font-size:21px;line-height:1.55}.mark{position:relative;height:500px;display:grid;place-items:center}.mark:before,.mark:after{content:"";position:absolute;width:80px;height:440px;clip-path:polygon(50% 0,100% 74%,57% 100%,0 74%);background:linear-gradient(90deg,#623168,#f5c6ff 50%,#7c3caa);filter:drop-shadow(0 0 25px #c37be8)}.mark:before{transform:rotate(38deg)}.mark:after{transform:rotate(-38deg)}.ring{width:290px;height:290px;border:1px solid #c16cdb;border-radius:50%;box-shadow:0 0 80px #b355d577, inset 0 0 50px #a13ac644}@media(max-width:750px){.hero{grid-template-columns:1fr;padding:60px 0}.mark{height:300px}.mark:before,.mark:after{height:270px;width:50px}.ring{width:190px;height:190px}.bottom{flex-direction:column}}
</style></head>
<body><main><div class="top"><span>Досье теней</span><span>Dota 2 / 04</span></div><section class="hero"><div><div class="index">ЦЕЛЬ НЕ УВИДИТ УДАРА</div><h1>Phantom<br>Assassin</h1><p class="lead">Мортред приходит из тени. Скорость, внезапность и один решающий удар — её подпись на поле боя.</p></div><div class="mark" aria-label="Скрещённые клинки"><div class="ring"></div></div></section><div class="bottom"><span>Тишина. Рывок. Удар.</span><span>Тень всегда ближе, чем кажется.</span></div></main></body></html>
EOF
        ;;
    5)
        PAGE_HERO="Juggernaut"
        cat > /var/www/html/index.html <<'EOF'
<!doctype html>
<html lang="ru">
<head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<meta name="description" content="Портрет Juggernaut — героя Dota 2"><title>Juggernaut — Путь маски</title>
<style>
*{box-sizing:border-box}body{margin:0;min-height:100vh;background:#f2ede3;color:#292521;font-family:Georgia,serif}main{max-width:1200px;min-height:100vh;margin:auto;padding:32px;display:grid;grid-template-rows:auto 1fr auto}header,footer{display:flex;justify-content:space-between;gap:16px;align-items:center;font:700 12px Arial,sans-serif;letter-spacing:.17em;text-transform:uppercase;border-bottom:1px solid #a9a097;padding-bottom:18px}footer{border:0;border-top:1px solid #a9a097;padding:18px 0 0;color:#8b493f}.hero{display:grid;grid-template-columns:.85fr 1.15fr;gap:75px;align-items:center}.sun{aspect-ratio:1;position:relative;display:grid;place-items:center;background:#c14836;border-radius:50%;box-shadow:0 0 0 35px #c1483614}.sun:before{content:"";width:60%;height:75%;background:#f9f4e9;clip-path:polygon(20% 5%,80% 5%,94% 27%,82% 85%,50% 100%,18% 85%,6% 27%);box-shadow:0 0 30px #7c291e}.face{position:absolute;width:35%;height:12%;top:42%;border-top:18px solid #242323;border-bottom:9px solid #c14836;transform:skewY(-5deg)}.eyebrow{color:#b34a36;font:700 13px Arial,sans-serif;letter-spacing:.2em;text-transform:uppercase}h1{font-size:clamp(69px,10vw,145px);line-height:.84;letter-spacing:-.07em;margin:24px 0}.lead{max-width:570px;color:#665d55;font-size:21px;line-height:1.6}.stamp{display:inline-block;margin-top:25px;border:2px solid #b34a36;color:#b34a36;padding:9px 15px;font:700 12px Arial,sans-serif;letter-spacing:.15em;transform:rotate(-5deg)}@media(max-width:750px){main{padding:22px}.hero{grid-template-columns:1fr;padding:60px 0}.sun{width:min(75%,330px);justify-self:center;grid-row:2}.face{border-top-width:12px;border-bottom-width:6px}footer{flex-direction:column;align-items:flex-start}}
</style></head>
<body><main><header><span>Путь воина</span><span>Герой Dota 2 / 05</span></header><section class="hero"><div class="sun" aria-label="Маска на красном солнце"><div class="face"></div></div><div><div class="eyebrow">Искусство движения</div><h1>Jugger&shy;naut</h1><p class="lead">Юрнеро скрывает лицо за маской, но его стиль узнают сразу: стремительное вращение и точный удар клинка.</p><span class="stamp">Маска / Меч / Дисциплина</span></div></section><footer><span>На поле боя важен каждый шаг</span><span>Yurnero</span></footer></main></body></html>
EOF
        ;;
esac

echo "Selected Dota 2 hero: $PAGE_HERO"

chown -R nginx:nginx /var/www/html
chmod 755 /var/www/html
chmod 644 /var/www/html/index.html
restorecon -RF /var/www/html || true

cat > /etc/nginx/conf.d/fakesite-http.conf <<EOF
server {
    listen 80;
    listen [::]:80;

    server_name $DOMAIN;

    root /var/www/html;
    index index.html;

    location / {
        try_files \$uri \$uri/ /index.html;
    }
}
EOF

nginx -t
systemctl enable --now nginx
systemctl reload nginx

echo "[5/9] Requesting Let's Encrypt certificate..."

if [[ ! -f "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" ]]; then

    systemctl stop nginx

    certbot certonly \
        --standalone \
        --non-interactive \
        --agree-tos \
        --register-unsafely-without-email \
        -d "$DOMAIN"

    systemctl start nginx
else
    echo "Certificate already exists."
fi

echo "[6/9] Configuring SELinux port $SPORT..."

semanage port -a -t http_port_t -p tcp "$SPORT" 2>/dev/null || \
semanage port -m -t http_port_t -p tcp "$SPORT"

echo "[7/9] Creating final nginx configuration..."

rm -f /etc/nginx/conf.d/fakesite-http.conf

cat > /etc/nginx/conf.d/sni.conf <<EOF
server {
    listen 80;
    listen [::]:80;

    server_name $DOMAIN;

    return 301 https://\$host\$request_uri;
}

server {
    listen 127.0.0.1:${SPORT} ssl proxy_protocol;

    server_name $DOMAIN;

    ssl_certificate     /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;

    ssl_protocols TLSv1.2 TLSv1.3;

    http2 on;

    real_ip_header proxy_protocol;
    set_real_ip_from 127.0.0.1;

    root /var/www/html;
    index index.html;

    location / {
        try_files \$uri \$uri/ /index.html;
    }
}
EOF

echo "[8/9] Testing nginx..."

nginx -t
systemctl restart nginx

echo "[9/9] Checking listener..."

ss -lntp | grep -E ":80|:${SPORT}" || true

echo
echo "Done."
echo
echo "REALITY settings:"
echo "  Target/Dest : 127.0.0.1:${SPORT}"
echo "  SNI         : ${DOMAIN}"
echo "  xver        : 1"
echo
echo "Do NOT open ${SPORT}/tcp in firewalld."
