<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>VideoHub Lite — Gallery Video (GitHub Pages)</title>
  <meta name="description" content="Trang video tĩnh miễn phí — host GitHub Pages. Hỗ trợ tìm kiếm, lọc, thẻ, phân trang, modal player. Nhúng YouTube / Vimeo / Google Drive / MP4." />
  <!--
  =====================
  HƯỚNG DẪN SỬ DỤNG NHANH
  1) Mở Google Sheet, tạo các cột: title, description, thumbnail, url, category, tags, duration, views, uploadedAt
     - tags phân cách bằng dấu | (ví dụ: food|vlog|street)
     - duration: 596 hoặc 09:56
     - views: số (vd 12345) — có thể bỏ trống
     - uploadedAt: YYYY-MM-DD (vd 2025-07-01) — có thể bỏ trống
  2) File → Chia sẻ → Xuất bản lên web → Chọn sheet → Định dạng CSV → Xuất bản.
     Sao chép URL CSV và dán vào biến SHEET_CSV_URL bên dưới.
  3) Lưu file này thành index.html, upload lên GitHub Pages (repo public) → Settings → Pages → Branch: main.
  4) Thay favicon/logo/brand theo ý.
  =====================
  -->
  <style>
    :root{--bg:#0b0d10;--card:#12161b;--muted:#9aa4b2;--text:#e6edf3;--accent:#66d9e8;--border:#1f2630}
    *{box-sizing:border-box}
    body{margin:0;background:var(--bg);color:var(--text);font:16px/1.5 system-ui,-apple-system,Segoe UI,Roboto,Ubuntu,"Helvetica Neue",Arial}
    a{color:inherit;text-decoration:none}
    .container{max-width:1180px;margin:0 auto;padding:16px}
    header{position:sticky;top:0;z-index:50;background:linear-gradient(180deg,rgba(11,13,16,.95),rgba(11,13,16,.75));backdrop-filter:saturate(120%) blur(6px);border-bottom:1px solid var(--border)}
    .nav{display:flex;gap:12px;align-items:center;justify-content:space-between}
    .brand{display:flex;align-items:center;gap:10px;font-weight:700}
    .logo{width:36px;height:36px;border-radius:10px;background:conic-gradient(from 180deg,#4dabf7,#63e6be,#ffd43b,#845ef7,#4dabf7);box-shadow:0 0 0 3px #0002}
    .searchbar{flex:1;max-width:680px;display:flex;gap:8px;margin:8px 16px}
    .input,.select{flex:1;background:#0f1317;border:1px solid var(--border);padding:10px 12px;border-radius:12px;color:var(--text)}
    .select{max-width:220px}
    .tags{display:flex;gap:8px;flex-wrap:wrap;margin:8px 0 12px}
    .chip{border:1px solid var(--border);padding:6px 10px;border-radius:999px;color:var(--muted);cursor:pointer;user-select:none}
    .chip.active{border-color:var(--accent);color:var(--accent)}
    main{padding:16px 0}
    .grid{display:grid;grid-template-columns:repeat(1,minmax(0,1fr));gap:14px}
    @media(min-width:600px){.grid{grid-template-columns:repeat(2,minmax(0,1fr))}}
    @media(min-width:960px){.grid{grid-template-columns:repeat(3,minmax(0,1fr))}}
    @media(min-width:1260px){.grid{grid-template-columns:repeat(4,minmax(0,1fr))}}
    .card{background:var(--card);border:1px solid var(--border);border-radius:16px;overflow:hidden;transition:transform .12s ease, box-shadow .12s ease}
    .thumbwrap{position:relative;aspect-ratio:16/9;background:#0f1317}
    .thumb{width:100%;height:100%;object-fit:cover;display:block}
    .duration{position:absolute;right:8px;bottom:8px;background:#000c;color:#fff;padding:2px 6px;border-radius:6px;font-size:12px}
    .meta{padding:10px 12px}
    .title{font-weight:600;margin:0 0 6px 0;display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden}
    .sub{color:var(--muted);font-size:13px}
    .card:hover{transform:translateY(-2px);box-shadow:0 8px 24px #0006}
    .empty{color:var(--muted);text-align:center;padding:40px}
    footer{border-top:1px solid var(--border);color:var(--muted);text-align:center;padding:28px}
    .btn{display:inline-flex;align-items:center;gap:8px;background:#0f1317;border:1px solid var(--border);color:var(--text);padding:10px 14px;border-radius:12px;cursor:pointer}
    .btn:hover{border-color:var(--accent);color:var(--accent)}
    /* Modal */
    .modal{position:fixed;inset:0;display:none;align-items:center;justify-content:center;background:rgba(0,0,0,.72);padding:20px}
    .modal.open{display:flex}
    .dialog{width:min(980px,100%);background:var(--card);border:1px solid var(--border);border-radius:16px;overflow:hidden}
    .player{aspect-ratio:16/9;background:#000}
    .dialog header{display:flex;justify-content:space-between;align-items:center;padding:10px 12px;border-bottom:1px solid var(--border);background:var(--card)}
    .dialog h3{margin:0;font-size:16px}
    .dialog .content{padding:12px}
    .close{cursor:pointer;border:1px solid var(--border);border-radius:10px;padding:6px 10px}
    .badges{display:flex;gap:8px;flex-wrap:wrap;margin-top:10px}
    .badge{border:1px solid var(--border);color:var(--muted);padding:4px 8px;border-radius:999px;font-size:12px}
  </style>
</head>
<body>
  <header>
    <div class="container nav">
      <div class="brand"><div class="logo"></div><span>VideoHub <span style="color:var(--accent)">Lite</span></span></div>
      <div class="searchbar">
        <input id="q" class="input" placeholder="Tìm kiếm video... (tiêu đề, thẻ)" />
        <select id="cat" class="select">
          <option value="">Tất cả chuyên mục</option>
        </select>
        <button id="clear" class="btn" title="Xoá lọc">Xoá</button>
      </div>
    </div>
    <div class="container">
      <div id="tagBar" class="tags"></div>
    </div>
  </header>

  <main class="container">
    <div id="grid" class="grid"></div>
    <div id="empty" class="empty" style="display:none">Không tìm thấy video phù hợp.</div>
    <div style="text-align:center;margin:22px 0">
      <button id="loadMore" class="btn">Tải thêm</button>
    </div>
  </main>

  <footer>
    <div class="container">
      Mã nguồn tĩnh, host trên GitHub Pages. Nhúng nguồn ngoài (YouTube/Vimeo/Drive/MP4). Vui lòng tuân thủ pháp luật và nội dung phù hợp.
    </div>
  </footer>

  <!-- Modal Player -->
  <div id="modal" class="modal" role="dialog" aria-modal="true">
    <div class="dialog">
      <header>
        <h3 id="modalTitle">Xem video</h3>
        <button id="close" class="close">Đóng</button>
      </header>
      <div class="player" id="player"></div>
      <div class="content">
        <div class="sub" id="meta"></div>
        <div class="badges" id="tags"></div>
      </div>
    </div>
  </div>

<script>
// =========================
// CẤU HÌNH — THAY BÊN DƯỚI
// =========================
// 1) Dán link CSV của Google Sheet đã "Xuất bản lên web" vào đây.
//    Nếu để nguyên chữ PASTE..., trang sẽ dùng dữ liệu DEMO ở dưới.
const SHEET_CSV_URL = "PASTE_YOUR_GOOGLE_SHEET_PUBLISHED_CSV_URL_HERE";

// 2) Số item hiển thị mỗi trang (Load more)
const PAGE_SIZE = 12;

// 3) Ảnh placeholder nếu thiếu thumbnail
const PLACEHOLDER_THUMB = "https://images.unsplash.com/photo-1478720568477-152d9b164e26?q=80&w=800&auto=format&fit=crop";

// =========================
// HÀM TIỆN ÍCH
// =========================
function fmtDuration(secOrStr){
  if(!secOrStr) return '';
  if(typeof secOrStr === 'string' && secOrStr.includes(':')) return secOrStr;
  const s = parseInt(secOrStr||0,10);
  const h=Math.floor(s/3600), m=Math.floor((s%3600)/60), sec=s%60;
  return (h>0?String(h).padStart(2,'0')+':':'')+String(m).padStart(2,'0')+':'+String(sec).padStart(2,'0');
}
function kfmt(n){
  n = parseInt(n||0,10);
  if(n>=1e9) return (n/1e9).toFixed(1)+'B';
  if(n>=1e6) return (n/1e6).toFixed(1)+'M';
  if(n>=1e3) return (n/1e3).toFixed(1)+'K';
  return String(n);
}
function timeAgo(dateStr){
  if(!dateStr) return '';
  const d=new Date(dateStr);
  if(isNaN(d)) return '';
  const diff=Date.now()-d.getTime();
  const s=Math.floor(diff/1000), m=Math.floor(s/60), h=Math.floor(m/60), day=Math.floor(h/24), mo=Math.floor(day/30), y=Math.floor(day/365);
  if(y>0) return y+" năm trước"; if(mo>0) return mo+" tháng trước"; if(day>0) return day+" ngày trước"; if(h>0) return h+" giờ trước"; if(m>0) return m+" phút trước"; return "vừa xong";
}
function uniq(arr){return [...new Set(arr.filter(Boolean))];}

// Tách CSV an toàn (ngăn dấu phẩy trong dấu ")
function parseCSV(text){
  const lines = text.replace(/\r/g,'').split('\n').filter(x=>x.trim().length);
  if(lines.length===0) return [];
  const headers = splitCSVLine(lines[0]).map(h=>h.trim());
  const rows=[];
  for(let i=1;i<lines.length;i++){
    const cols = splitCSVLine(lines[i]);
    if(cols.length===1 && !cols[0]) continue;
    const obj={};
    headers.forEach((h,idx)=>{ obj[h]= (cols[idx]||'').replace(/^"|"$/g,''); });
    rows.push(obj);
  }
  return rows;
}
function splitCSVLine(line){
  const out=[]; let cur=''; let inQ=false;
  for(let i=0;i<line.length;i++){
    const c=line[i]; const n=line[i+1];
    if(c==='"'){
      if(inQ && n==='"'){ cur+='"'; i++; }
      else inQ=!inQ;
    } else if(c===',' && !inQ){ out.push(cur); cur=''; }
    else { cur+=c; }
  }
  out.push(cur);
  return out;
}

// Nhận diện nguồn & tạo URL embed + thumbnail fallback
function detectSource(url, thumb){
  if(!url) return {type:'unknown', embed:null, thumb:thumb||PLACEHOLDER_THUMB};
  const u = url.trim();
  // YouTube
  const y1 = u.match(/(?:v=|\/embed\/|youtu\.be\/)([A-Za-z0-9_-]{6,})/);
  if(y1){
    const id=y1[1];
    return {type:'youtube', embed:`https://www.youtube.com/embed/${id}`, thumb: thumb||`https://i.ytimg.com/vi/${id}/hqdefault.jpg`};
  }
  // Vimeo
  const v1 = u.match(/vimeo\.com\/(?:video\/)?(\d+)/);
  if(v1){
    const id=v1[1];
    return {type:'vimeo', embed:`https://player.vimeo.com/video/${id}`, thumb: thumb||PLACEHOLDER_THUMB};
  }
  // Google Drive
  const g1 = u.match(/drive\.google\.com\/file\/d\/([A-Za-z0-9_-]+)/);
  if(g1){
    const id=g1[1];
    return {type:'drive', embed:`https://drive.google.com/file/d/${id}/preview`, thumb: thumb||PLACEHOLDER_THUMB};
  }
  // MP4 trực tiếp
  if(/\.(mp4|webm|ogg)(\?|#|$)/i.test(u)){
    return {type:'mp4', embed:u, thumb: thumb||PLACEHOLDER_THUMB};
  }
  // Fallback
  return {type:'unknown', embed:u, thumb: thumb||PLACEHOLDER_THUMB};
}

// =========================
// DỮ LIỆU DEMO (dùng khi chưa cấu hình SHEET_CSV_URL)
// =========================
const DEMO_VIDEOS = [
  {title:'Big Buck Bunny (Demo)', description:'Open movie', thumbnail:'', url:'https://www.youtube.com/watch?v=YE7VzlLtp-4', category:'Demo', tags:'demo|animation|open-source', duration:'09:56', views:12840, uploadedAt:'2024-10-05'},
  {title:'Sintel (Open Movie)', description:'Blender short film', thumbnail:'', url:'https://youtu.be/eRsGyueVLvQ', category:'Demo', tags:'blender|short-film', duration:'14:48', views:44321, uploadedAt:'2024-08-20'},
  {title:'Tears of Steel', description:'Sci-fi short', thumbnail:'', url:'https://www.youtube.com/watch?v=R6MlUcmOul8', category:'Demo', tags:'blender|vfx', duration:'12:14', views:30122, uploadedAt:'2023-05-02'}
];

// =========================
// STATE & DOM
// =========================
let ALL = [];
let FILTERED = [];
let PAGE = 1;
const grid = document.getElementById('grid');
const empty = document.getElementById('empty');
const q = document.getElementById('q');
const cat = document.getElementById('cat');
const clearBtn = document.getElementById('clear');
const loadMore = document.getElementById('loadMore');
const tagBar = document.getElementById('tagBar');
let activeTag = '';

async function loadData(){
  try{
    let rows;
    if(!SHEET_CSV_URL || SHEET_CSV_URL.includes('PASTE_')){
      rows = DEMO_VIDEOS;
    } else {
      const res = await fetch(SHEET_CSV_URL);
      const text = await res.text();
      rows = parseCSV(text);
    }
    // Chuẩn hoá
    ALL = rows.map(r => {
      const title = r.title || r.Title || r.TITLE || '';
      const description = r.description || r.desc || '';
      const thumbnail = r.thumbnail || r.thumb || '';
      const url = r.url || r.link || '';
      const category = r.category || r.cat || '';
      const tags = r.tags || r.tag || '';
      const duration = r.duration || '';
      const views = parseInt(r.views||0,10);
      const uploadedAt = r.uploadedAt || r.date || '';
      const src = detectSource(url, thumbnail);
      return {title, description, thumbnail:src.thumb, url, category, tags, duration:fmtDuration(duration), views, uploadedAt, _src:src};
    });

    buildFilters();
    applyFilters();
  }catch(e){
    console.error(e);
    grid.innerHTML = '<div class="empty">Lỗi tải dữ liệu. Kiểm tra link CSV hoặc CORS.</div>';
  }
}

function buildFilters(){
  // categories
  const cats = uniq(ALL.map(v=>v.category).filter(Boolean));
  cat.innerHTML = '<option value="">Tất cả chuyên mục</option>' + cats.map(c=>`<option value="${escapeHtml(c)}">${escapeHtml(c)}</option>`).join('');
  // tags
  const tagSet = new Set();
  ALL.forEach(v=> (v.tags||'').split('|').forEach(t=> t && tagSet.add(t.trim())));
  const tags = [...tagSet];
  tagBar.innerHTML = '<span class="chip'+(activeTag===''?' active':'')+'" data-tag="">Tất cả</span>' + tags.map(t=>`<span class="chip" data-tag="${escapeHtml(t)}">#${escapeHtml(t)}</span>`).join('');
  tagBar.querySelectorAll('.chip').forEach(chip=>{
    chip.addEventListener('click',()=>{
      activeTag = chip.getAttribute('data-tag');
      tagBar.querySelectorAll('.chip').forEach(c=>c.classList.remove('active'));
      chip.classList.add('active');
      PAGE=1; applyFilters();
    });
  });
}

function applyFilters(){
  const query = (q.value||'').toLowerCase().trim();
  const c = cat.value||'';
  FILTERED = ALL.filter(v => {
    const hitQ = !query || v.title.toLowerCase().includes(query) || (v.tags||'').toLowerCase().includes(query);
    const hitC = !c || v.category === c;
    const hitT = !activeTag || (v.tags||'').split('|').map(t=>t.trim()).includes(activeTag);
    return hitQ && hitC && hitT;
  });
  render();
}

function render(){
  grid.innerHTML = '';
  const slice = FILTERED.slice(0, PAGE*PAGE_SIZE);
  slice.forEach(item=> grid.appendChild(cardEl(item)) );
  empty.style.display = slice.length? 'none':'block';
  loadMore.style.display = FILTERED.length > slice.length ? 'inline-flex':'none';
}

function cardEl(item){
  const wrap = document.createElement('div');
  wrap.className = 'card';
  wrap.innerHTML = `
    <div class="thumbwrap">
      <img src="${escapeAttr(item.thumbnail||PLACEHOLDER_THUMB)}" class="thumb" alt="thumbnail">
      ${item.duration?`<span class="duration">${escapeHtml(item.duration)}</span>`:''}
    </div>
    <div class="meta">
      <h3 class="title">${escapeHtml(item.title)}</h3>
      <div class="sub">${item.views?`${kfmt(item.views)} lượt xem · `:''}${escapeHtml(timeAgo(item.uploadedAt))}</div>
    </div>`;
  wrap.addEventListener('click', ()=> openModal(item));
  return wrap;
}

// Modal
const modal = document.getElementById('modal');
const player = document.getElementById('player');
const modalTitle = document.getElementById('modalTitle');
const meta = document.getElementById('meta');
const tagsEl = document.getElementById('tags');

function openModal(item){
  modal.classList.add('open');
  modalTitle.textContent = item.title;
  meta.textContent = `${item.category?item.category+' · ':''}${item.views?kfmt(item.views)+' lượt xem · ':''}${timeAgo(item.uploadedAt)}`;
  tagsEl.innerHTML = '';
  (item.tags||'').split('|').filter(Boolean).forEach(t=>{
    const b=document.createElement('span'); b.className='badge'; b.textContent='#'+t; tagsEl.appendChild(b);
  });
  player.innerHTML = '';
  const s = item._src;
  if(s.type==='youtube' || s.type==='vimeo' || s.type==='drive' || s.type==='unknown'){
    const ifr = document.createElement('iframe');
    ifr.width='100%'; ifr.height='100%'; ifr.allow='accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share'; ifr.allowFullscreen=true; ifr.src=s.embed;
    player.appendChild(ifr);
  } else if(s.type==='mp4'){
    const v = document.createElement('video');
    v.src = s.embed; v.controls = true; v.autoplay = true; v.style.width='100%'; v.style.height='100%'; v.preload='none';
    player.appendChild(v);
  }
}

function closeModal(){
  modal.classList.remove('open');
  player.innerHTML = '';
}

document.getElementById('close').addEventListener('click', closeModal);
modal.addEventListener('click', (e)=>{ if(e.target===modal) closeModal(); });

// events
q.addEventListener('input', ()=>{ PAGE=1; applyFilters(); });
cat.addEventListener('change', ()=>{ PAGE=1; applyFilters(); });
clearBtn.addEventListener('click', ()=>{ q.value=''; cat.value=''; activeTag=''; PAGE=1; buildFilters(); applyFilters(); });
loadMore.addEventListener('click', ()=>{ PAGE++; render(); });

function escapeHtml(str=''){ return String(str).replace(/[&<>"]g, s=> ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[s]) ); }
function escapeAttr(str=''){ return String(str).replace(/"/g,'&quot;'); }

// init
loadData();
</script>
</body>
</html>
