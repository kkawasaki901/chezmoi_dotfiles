'use strict';

// Turn individual features off here as the design is simplified later.
const FEATURES = {
  aurora: true,
  grid: true,
  scanlines: true,
  hud: true,
  metrics: true,
  dock: true,
  commandPalette: true,
  themeSwitcher: true
};

const THEMES = {
  nebula: {accent: '#8b5cf6', accent2: '#22d3ee', glow: '139, 92, 246'},
  cyber: {accent: '#00f5a0', accent2: '#00d9f5', glow: '0, 245, 160'},
  ember: {accent: '#ff6b6b', accent2: '#fbbf24', glow: '255, 107, 107'}
};

exports.decorateConfig = config => ({
  ...config,
  fontSize: 14,
  fontFamily: '"0xProto Nerd Font", "JetBrainsMono NF", Consolas, monospace',
  lineHeight: 1.18,
  letterSpacing: 0.2,
  cursorShape: 'BEAM',
  cursorBlink: true,
  cursorColor: '#22d3ee',
  cursorAccentColor: '#07111f',
  foregroundColor: '#dbeafe',
  backgroundColor: '#07111f',
  selectionColor: 'rgba(139, 92, 246, .34)',
  borderColor: 'rgba(139, 92, 246, .45)',
  padding: '72px 20px 88px',
  shell: 'C:\\Program Files\\PowerShell\\7\\pwsh.exe',
  shellArgs: ['-NoLogo'],
  colors: {
    black: '#07111f', red: '#ff6b8a', green: '#4ade80', yellow: '#facc15',
    blue: '#60a5fa', magenta: '#c084fc', cyan: '#22d3ee', white: '#dbeafe',
    lightBlack: '#52627a', lightRed: '#ff8fa6', lightGreen: '#86efac',
    lightYellow: '#fde047', lightBlue: '#93c5fd', lightMagenta: '#d8b4fe',
    lightCyan: '#67e8f9', lightWhite: '#f8fafc'
  },
  css: `${config.css || ''}
    :root {
      --hrcc-accent: #8b5cf6;
      --hrcc-accent-2: #22d3ee;
      --hrcc-glow: 139, 92, 246;
      --hrcc-panel: rgba(7, 17, 31, .72);
      --hrcc-line: rgba(148, 163, 184, .16);
      --hrcc-text: #dbeafe;
      --hrcc-muted: #7f91aa;
    }
    html[data-hrcc-theme="cyber"] { --hrcc-accent:#00f5a0; --hrcc-accent-2:#00d9f5; --hrcc-glow:0,245,160; }
    html[data-hrcc-theme="ember"] { --hrcc-accent:#ff6b6b; --hrcc-accent-2:#fbbf24; --hrcc-glow:255,107,107; }
    body { background:#07111f !important; }
    .hyper_main { position:relative; background:transparent !important; }
    .hyper_main::before {
      content:""; position:fixed; inset:0; pointer-events:none; z-index:0;
      background:
        radial-gradient(circle at 12% 18%, rgba(var(--hrcc-glow),.24), transparent 34%),
        radial-gradient(circle at 85% 72%, rgba(34,211,238,.16), transparent 32%),
        linear-gradient(135deg,#050a14 0%,#07111f 48%,#0a1022 100%);
      animation:hrcc-breathe 9s ease-in-out infinite alternate;
    }
    .hyper_main::after {
      content:""; position:fixed; inset:0; pointer-events:none; z-index:1; opacity:.22;
      background-image:linear-gradient(rgba(100,116,139,.10) 1px,transparent 1px),linear-gradient(90deg,rgba(100,116,139,.10) 1px,transparent 1px);
      background-size:32px 32px; mask-image:linear-gradient(to bottom,black,transparent 78%);
    }
    html.hrcc-no-effects .hyper_main::before { animation:none; }
    html.hrcc-no-effects .hyper_main::after { display:none; }
    @keyframes hrcc-breathe { from{filter:hue-rotate(0deg);transform:scale(1)} to{filter:hue-rotate(12deg);transform:scale(1.04)} }
    .terms_terms, .term_fit, .term_term { position:relative; z-index:2; background:transparent !important; }
    .header_header { background:rgba(5,10,20,.76)!important; backdrop-filter:blur(18px); border-bottom:1px solid var(--hrcc-line)!important; }
    .tabs_title { color:var(--hrcc-muted)!important; transition:.2s ease; }
    .tab_active .tabs_title { color:var(--hrcc-text)!important; text-shadow:0 0 16px rgba(var(--hrcc-glow),.65); }
    .tab_active { border-color:var(--hrcc-accent)!important; }
    .hrcc-root { position:fixed; inset:0; z-index:1000; pointer-events:none; color:var(--hrcc-text); font-family:Inter,"Segoe UI",sans-serif; }
    .hrcc-hud { pointer-events:auto; position:fixed; top:46px; left:18px; right:18px; height:52px; display:flex; align-items:center; justify-content:space-between; padding:0 16px; border:1px solid var(--hrcc-line); border-radius:16px; background:var(--hrcc-panel); backdrop-filter:blur(22px) saturate(150%); box-shadow:0 18px 55px rgba(0,0,0,.28),inset 0 1px rgba(255,255,255,.04); }
    .hrcc-brand,.hrcc-metrics,.hrcc-actions,.hrcc-themes { display:flex; align-items:center; gap:10px; }
    .hrcc-orb { width:10px;height:10px;border-radius:50%;background:var(--hrcc-accent);box-shadow:0 0 18px var(--hrcc-accent);animation:hrcc-pulse 1.8s ease infinite; }
    @keyframes hrcc-pulse { 50%{opacity:.45;transform:scale(.75)} }
    .hrcc-brand strong { font-size:12px; letter-spacing:.22em; }
    .hrcc-chip { border:1px solid var(--hrcc-line);border-radius:999px;padding:6px 10px;color:var(--hrcc-muted);font-size:11px;background:rgba(255,255,255,.025); }
    .hrcc-time { font-variant-numeric:tabular-nums;color:var(--hrcc-accent-2);font-weight:700;letter-spacing:.08em; }
    .hrcc-dock { pointer-events:auto; position:fixed; left:50%; bottom:18px; transform:translateX(-50%); display:flex;align-items:center;gap:7px;padding:8px;border:1px solid var(--hrcc-line);border-radius:18px;background:var(--hrcc-panel);backdrop-filter:blur(22px) saturate(150%);box-shadow:0 22px 60px rgba(0,0,0,.36); }
    .hrcc-btn { appearance:none;border:1px solid transparent;border-radius:11px;padding:9px 12px;background:transparent;color:var(--hrcc-muted);font:600 11px/1 Inter,"Segoe UI",sans-serif;cursor:pointer;transition:.18s ease; }
    .hrcc-btn:hover,.hrcc-btn.active { color:#fff;border-color:rgba(var(--hrcc-glow),.42);background:rgba(var(--hrcc-glow),.14);box-shadow:0 0 24px rgba(var(--hrcc-glow),.13);transform:translateY(-2px); }
    .hrcc-divider { width:1px;height:24px;background:var(--hrcc-line);margin:0 2px; }
    .hrcc-swatch { width:24px;height:24px;border-radius:50%;border:2px solid transparent;cursor:pointer;transition:.2s; }
    .hrcc-swatch.active { border-color:white;transform:scale(1.12);box-shadow:0 0 18px rgba(var(--hrcc-glow),.55); }
    .hrcc-palette-backdrop { pointer-events:auto;position:fixed;inset:0;display:grid;place-items:center;background:rgba(1,5,12,.72);backdrop-filter:blur(12px); }
    .hrcc-palette { position:fixed;left:50%;top:50%;z-index:2;transform:translate(-50%,-50%);width:min(620px,calc(100vw - 48px));border:1px solid rgba(var(--hrcc-glow),.38);border-radius:22px;background:rgba(7,17,31,.95);box-shadow:0 30px 100px rgba(0,0,0,.55),0 0 70px rgba(var(--hrcc-glow),.14);padding:18px; }
    .hrcc-palette-head { display:flex;justify-content:space-between;align-items:center;margin-bottom:14px; }
    .hrcc-palette-title { font-size:12px;letter-spacing:.18em;text-transform:uppercase;color:var(--hrcc-accent-2); }
    .hrcc-command { width:100%;box-sizing:border-box;border:1px solid var(--hrcc-line);border-radius:13px;padding:13px 14px;background:rgba(255,255,255,.035);color:white;outline:none;font:14px Inter,"Segoe UI",sans-serif; }
    .hrcc-command:focus { border-color:var(--hrcc-accent);box-shadow:0 0 0 3px rgba(var(--hrcc-glow),.12); }
    .hrcc-command-list { display:grid;grid-template-columns:repeat(2,1fr);gap:8px;margin-top:14px; }
    .hrcc-command-item { text-align:left;padding:13px;border:1px solid var(--hrcc-line);border-radius:13px;background:rgba(255,255,255,.025);color:var(--hrcc-text);cursor:pointer; }
    .hrcc-command-item:hover { border-color:rgba(var(--hrcc-glow),.5);background:rgba(var(--hrcc-glow),.11); }
    .hrcc-command-item small { display:block;color:var(--hrcc-muted);margin-top:5px; }
    html.hrcc-focus .hrcc-hud,html.hrcc-focus .hrcc-dock { opacity:0;transform:translateY(10px);pointer-events:none; }
    html.hrcc-focus .hrcc-dock { transform:translate(-50%,10px); }
    @media (max-width: 1100px) {
      .hrcc-metrics .hrcc-chip:nth-child(n+3) { display:none; }
      .hrcc-hud { left:10px;right:10px;padding:0 12px; }
      .hrcc-btn { padding:8px; }
    }
  `
});

exports.decorateHyper = (Hyper, {React}) => {
  const h = React.createElement;

  return class ReactCommandCenter extends React.Component {
    constructor(props) {
      super(props);
      const savedTheme = localStorage.getItem('hrcc-theme') || 'nebula';
      this.state = {
        now: new Date(), online: navigator.onLine, battery: null,
        theme: THEMES[savedTheme] ? savedTheme : 'nebula',
        focus: false, effects: true, palette: false, query: '', tabs: 1
      };
      this.tick = this.tick.bind(this);
      this.onKey = this.onKey.bind(this);
    }

    componentDidMount() {
      document.documentElement.dataset.hrccTheme = this.state.theme;
      this.timer = setInterval(this.tick, 1000);
      window.addEventListener('keydown', this.onKey, true);
      window.addEventListener('online', this.tick);
      window.addEventListener('offline', this.tick);
      if (navigator.getBattery) navigator.getBattery().then(b => {
        this.battery = b;
        b.addEventListener('levelchange', this.tick);
        b.addEventListener('chargingchange', this.tick);
        this.tick();
      }).catch(() => {});
    }

    componentWillUnmount() {
      clearInterval(this.timer);
      window.removeEventListener('keydown', this.onKey, true);
      window.removeEventListener('online', this.tick);
      window.removeEventListener('offline', this.tick);
      if (this.battery) {
        this.battery.removeEventListener('levelchange', this.tick);
        this.battery.removeEventListener('chargingchange', this.tick);
      }
    }

    tick() {
      const memory = performance.memory ? Math.round(performance.memory.usedJSHeapSize / 1048576) : null;
      const tabs = Math.max(1, document.querySelectorAll('.tab_tab').length || document.querySelectorAll('[role="tab"]').length);
      this.setState({
        now: new Date(), online: navigator.onLine, tabs, memory,
        battery: this.battery ? Math.round(this.battery.level * 100) : null,
        charging: this.battery ? this.battery.charging : false
      });
    }

    onKey(event) {
      if (FEATURES.commandPalette && event.ctrlKey && event.shiftKey && event.code === 'Space') {
        event.preventDefault(); event.stopPropagation();
        this.setState(s => ({palette: !s.palette, query: ''}));
      } else if (event.key === 'Escape' && this.state.palette) {
        event.preventDefault(); this.setState({palette: false, query: ''});
      }
    }

    command(name) {
      if (window.rpc) window.rpc.emit(`command ${name}`);
      this.setState({palette: false, query: ''});
    }

    setTheme(theme) {
      document.documentElement.dataset.hrccTheme = theme;
      localStorage.setItem('hrcc-theme', theme);
      this.setState({theme});
    }

    toggleFocus() {
      const focus = !this.state.focus;
      document.documentElement.classList.toggle('hrcc-focus', focus);
      this.setState({focus});
    }

    toggleEffects() {
      const effects = !this.state.effects;
      document.documentElement.classList.toggle('hrcc-no-effects', !effects);
      this.setState({effects});
    }

    renderHud() {
      if (!FEATURES.hud) return null;
      const s = this.state;
      const time = s.now.toLocaleTimeString('ja-JP', {hour:'2-digit', minute:'2-digit', second:'2-digit'});
      const date = s.now.toLocaleDateString('ja-JP', {month:'short', day:'numeric', weekday:'short'});
      const chips = [
        h('span', {className:'hrcc-chip', key:'net'}, `${s.online ? '● ONLINE' : '○ OFFLINE'}`),
        s.battery !== null && h('span', {className:'hrcc-chip', key:'bat'}, `${s.charging ? '⚡' : 'BAT'} ${s.battery}%`),
        s.memory && h('span', {className:'hrcc-chip', key:'mem'}, `JS ${s.memory}MB`),
        h('span', {className:'hrcc-chip', key:'tabs'}, `${s.tabs} TAB${s.tabs === 1 ? '' : 'S'}`)
      ].filter(Boolean);
      return h('div', {className:'hrcc-hud'},
        h('div', {className:'hrcc-brand'}, h('i', {className:'hrcc-orb'}), h('strong', null, 'HYPER // REACT')),
        FEATURES.metrics && h('div', {className:'hrcc-metrics'}, chips),
        h('div', {className:'hrcc-actions'}, h('span', {className:'hrcc-chip'}, date), h('span', {className:'hrcc-time'}, time))
      );
    }

    renderDock() {
      if (!FEATURES.dock) return null;
      const button = (label, action, active, title) => h('button', {className:`hrcc-btn${active ? ' active' : ''}`, title, onClick:action}, label);
      return h('div', {className:'hrcc-dock'},
        button('＋ TAB', () => this.command('tab:new'), false, '新しいタブ'),
        button('⇥ RIGHT', () => this.command('pane:splitRight'), false, '右に分割'),
        button('⇩ DOWN', () => this.command('pane:splitDown'), false, '下に分割'),
        button('⌫ CLEAR', () => this.command('editor:clearBuffer'), false, 'バッファをクリア'),
        h('i', {className:'hrcc-divider'}),
        FEATURES.commandPalette && button('⌘ COMMAND', () => this.setState({palette:true, query:''}), false, 'Ctrl+Shift+Space'),
        button('◉ FOCUS', () => this.toggleFocus(), this.state.focus, 'HUDを隠す'),
        button('✦ FX', () => this.toggleEffects(), this.state.effects, '背景効果'),
        h('i', {className:'hrcc-divider'}),
        FEATURES.themeSwitcher && h('div', {className:'hrcc-themes'}, Object.keys(THEMES).map(name =>
          h('button', {key:name, className:`hrcc-swatch${this.state.theme === name ? ' active' : ''}`, title:name,
            style:{background:`linear-gradient(135deg,${THEMES[name].accent},${THEMES[name].accent2})`}, onClick:() => this.setTheme(name)})
        ))
      );
    }

    renderPalette() {
      if (!this.state.palette || !FEATURES.commandPalette) return null;
      const commands = [
        ['New tab','tab:new','新しい作業タブを開く'], ['Split right','pane:splitRight','右側にペインを作る'],
        ['Split down','pane:splitDown','下側にペインを作る'], ['Clear buffer','editor:clearBuffer','表示履歴をクリア'],
        ['Preferences','window:preferences','Hyper設定を開く'], ['Reload UI','window:reload','React UIを再読み込み']
      ];
      const q = this.state.query.toLowerCase();
      const visible = commands.filter(c => c.join(' ').toLowerCase().includes(q));
      return h('div', {className:'hrcc-palette-backdrop', onMouseDown:e => {if(e.target === e.currentTarget)this.setState({palette:false});}},
        h('div', {className:'hrcc-palette'},
          h('div', {className:'hrcc-palette-head'}, h('span', {className:'hrcc-palette-title'}, 'React Command Center'), h('span', {className:'hrcc-chip'}, 'ESC TO CLOSE')),
          h('input', {className:'hrcc-command', autoFocus:true, value:this.state.query, placeholder:'コマンドを検索…', onChange:e => this.setState({query:e.target.value}), onKeyDown:e => {if(e.key === 'Enter' && visible[0])this.command(visible[0][1]);}}),
          h('div', {className:'hrcc-command-list'}, visible.map(c => h('button', {key:c[1], className:'hrcc-command-item', onClick:() => this.command(c[1])}, c[0], h('small', null, c[2]))))
        )
      );
    }

    render() {
      return h(React.Fragment, null,
        h(Hyper, this.props),
        // Hyper 3.4 can skip CSS returned by a newly loaded local plugin until
        // a later config cycle, so mount the same stylesheet with React too.
        h('style', {dangerouslySetInnerHTML:{__html:exports.decorateConfig({css:''}).css}}),
        h('div', {className:'hrcc-root'}, this.renderHud(), this.renderDock(), this.renderPalette())
      );
    }
  };
};
