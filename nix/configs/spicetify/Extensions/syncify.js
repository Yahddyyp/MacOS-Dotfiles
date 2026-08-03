// NAME: Syncify
// AUTHOR: wsoltani
// DESCRIPTION: Back up and restore Spicetify extensions and themes.
"use strict";(()=>{var Le=Object.defineProperty,Oe=Object.defineProperties;var je=Object.getOwnPropertyDescriptors;var ee=Object.getOwnPropertySymbols;var He=Object.prototype.hasOwnProperty,Re=Object.prototype.propertyIsEnumerable;var te=(e,t,n)=>t in e?Le(e,t,{enumerable:!0,configurable:!0,writable:!0,value:n}):e[t]=n,S=(e,t)=>{for(var n in t||(t={}))He.call(t,n)&&te(e,n,t[n]);if(ee)for(var n of ee(t))Re.call(t,n)&&te(e,n,t[n]);return e},x=(e,t)=>Oe(e,je(t));var ne=`/* Spotify PopupModal shell tweaks scoped to Syncify. Keep these minimal so the
   Spotify modal can size naturally instead of being forced/cropped. */
.syncify-modal-shell .main-trackCreditsModal-header,
.main-trackCreditsModal-header:has(+ * .syncify-panel),
.main-trackCreditsModal-header:has(~ * .syncify-panel) {
    display: flex !important;
    align-items: center !important;
    justify-content: space-between !important;
    gap: 12px !important;
    padding: 16px 20px 8px !important;
}

.syncify-modal-shell .main-trackCreditsModal-header h1,
.main-trackCreditsModal-header:has(+ * .syncify-panel) h1,
.main-trackCreditsModal-header:has(~ * .syncify-panel) h1 {
    margin: 0 !important;
    font-size: 18px !important;
    line-height: 1.25 !important;
}

.syncify-modal-shell .main-trackCreditsModal-mainSection,
.syncify-modal-shell .main-trackCreditsModal-content,
.main-trackCreditsModal-mainSection:has(.syncify-panel),
.main-trackCreditsModal-content:has(.syncify-panel) {
    box-sizing: border-box !important;
    max-height: calc(100vh - 140px) !important;
    padding: 10px 20px 18px !important;
    overflow-y: auto !important;
    overflow-x: hidden !important;
}

.syncify-modal-shell .syncify-modal-close {
    display: inline-flex !important;
    align-items: center !important;
    justify-content: center !important;
    width: 32px !important;
    height: 32px !important;
    min-width: 32px !important;
    padding: 0 !important;
    border: 0 !important;
    border-radius: 999px !important;
    color: var(--spice-subtext) !important;
    background: transparent !important;
    cursor: pointer !important;
    transition:
        color 120ms ease,
        background-color 120ms ease,
        transform 120ms ease !important;
}

.syncify-modal-shell .syncify-modal-close svg {
    width: 18px !important;
    height: 18px !important;
    fill: none !important;
    stroke: currentColor !important;
    stroke-width: 2 !important;
    stroke-linecap: round !important;
    stroke-linejoin: round !important;
    pointer-events: none !important;
}

.syncify-modal-shell .syncify-modal-close:hover {
    color: var(--spice-text) !important;
    background: rgba(255, 255, 255, 0.12) !important;
}

.syncify-modal-shell .syncify-modal-close:active {
    transform: scale(0.96) !important;
}

.syncify-panel {
    box-sizing: border-box;
    display: flex;
    flex-direction: column;
    gap: 12px;
    width: 100%;
    max-width: 100%;
    min-width: 0;
    margin: 0;
    padding: 0;
    color: var(--spice-text);
}

.syncify-hero {
    display: flex;
    flex-direction: column;
    gap: 8px;
    min-width: 0;
}

.syncify-status-row,
.syncify-section-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 12px;
    min-width: 0;
}

.syncify-description,
.syncify-card-label,
.syncify-backup-details {
    margin: 0;
    color: var(--spice-subtext);
    line-height: 1.5;
}

.syncify-heading {
    min-width: 0;
    margin: 0;
    font-size: clamp(18px, 4vw, 23px);
    line-height: 1.2;
}

.syncify-description {
    max-width: 64ch;
    font-size: 13px;
}

.syncify-status-pill,
.syncify-backup-time {
    display: inline-flex;
    flex: 0 0 auto;
    align-items: center;
    justify-content: center;
    border-radius: 999px;
    font-size: 12px;
    font-weight: 700;
    line-height: 1.35;
    white-space: nowrap;
}

.syncify-status-pill {
    padding: 4px 9px;
    color: var(--spice-subtext);
    background: rgba(255, 255, 255, 0.08);
}

.syncify-backup-time {
    padding: 4px 9px;
    color: var(--spice-text);
    background: rgba(255, 255, 255, 0.09);
}

.syncify-status-pill[data-kind="success"],
.syncify-card[data-tone="success"] .syncify-card-value {
    color: var(--spice-button-active, #1ed760);
}

.syncify-status-pill[data-kind="warning"],
.syncify-card[data-tone="warning"] .syncify-card-value {
    color: #f6c343;
}

.syncify-status-pill[data-kind="error"] {
    color: var(--spice-notification-error, #ff6b6b);
}

.syncify-grid {
    display: flex;
    flex-wrap: wrap;
    gap: 10px;
    min-width: 0;
}

.syncify-card,
.syncify-section {
    box-sizing: border-box;
    min-width: 0;
    border: 1px solid rgba(255, 255, 255, 0.1);
    border-radius: 12px;
    background: rgba(255, 255, 255, 0.045);
}

.syncify-card {
    display: flex;
    flex: 1 1 calc(50% - 5px);
    flex-direction: column;
    gap: 4px;
    min-width: 180px;
    padding: 11px 12px;
}

.syncify-card-label {
    overflow: hidden;
    font-size: 11px;
    text-overflow: ellipsis;
    text-transform: uppercase;
    white-space: nowrap;
}

.syncify-card-value {
    overflow: hidden;
    color: var(--spice-text);
    font-size: 17px;
    font-weight: 700;
    line-height: 1.25;
    text-overflow: ellipsis;
    white-space: nowrap;
}

.syncify-section {
    display: flex;
    flex-direction: column;
    gap: 10px;
    padding: 12px;
}

.syncify-backup-section {
    background: linear-gradient(
        135deg,
        rgba(255, 255, 255, 0.07),
        rgba(255, 255, 255, 0.035)
    );
}

.syncify-section-title {
    min-width: 0;
    margin: 0;
    font-size: 14px;
    line-height: 1.3;
}

.syncify-backup-list {
    display: flex;
    flex-direction: column;
    gap: 8px;
}

.syncify-backup-version {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 10px;
    min-width: 0;
    padding: 9px 10px;
    border: 1px solid rgba(255, 255, 255, 0.1);
    border-radius: 10px;
    color: var(--spice-text);
    background: rgba(255, 255, 255, 0.045);
    text-align: left;
    cursor: pointer;
    transition:
        border-color 120ms ease,
        background-color 120ms ease,
        opacity 120ms ease,
        transform 120ms ease;
}

.syncify-backup-version:hover:not(:disabled),
.syncify-backup-version[data-selected="true"] {
    border-color: rgba(30, 215, 96, 0.45);
    background: rgba(30, 215, 96, 0.1);
}

.syncify-backup-version:active:not(:disabled) {
    transform: scale(0.99);
}

.syncify-backup-version:disabled {
    cursor: not-allowed;
    opacity: 0.65;
}

.syncify-backup-version-main {
    display: flex;
    flex: 1 1 auto;
    flex-direction: column;
    gap: 2px;
    min-width: 0;
}

.syncify-backup-version-main strong,
.syncify-backup-version-main span {
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
}

.syncify-backup-version-main span,
.syncify-backup-details {
    color: var(--spice-subtext);
    font-size: 12px;
}

.syncify-backup-details {
    display: flex;
    flex: 0 1 auto;
    flex-wrap: wrap;
    justify-content: flex-end;
    gap: 8px;
}

.syncify-backup-details span {
    display: inline-flex;
    align-items: center;
    min-width: 0;
    padding: 4px 8px;
    border-radius: 999px;
    background: rgba(255, 255, 255, 0.07);
}

.syncify-actions,
.syncify-footer,
.syncify-footer-actions {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
}

.syncify-actions {
    align-items: center;
}

.syncify-confirm-restore {
    display: flex;
    flex-direction: column;
    gap: 8px;
}

.syncify-footer {
    align-items: center;
    justify-content: space-between;
}

.syncify-footer-actions {
    justify-content: flex-end;
}

.syncify-version {
    color: var(--spice-subtext);
    font-size: 12px;
    line-height: 1.4;
}

.syncify-button,
.syncify-link-button {
    border: 0;
    border-radius: 999px;
    font-weight: 700;
    line-height: 1.25;
    cursor: pointer;
    transition:
        color 120ms ease,
        background-color 120ms ease,
        box-shadow 120ms ease,
        opacity 120ms ease,
        transform 120ms ease;
}

.syncify-button {
    padding: 8px 14px;
    color: var(--spice-button-text, #000);
    background: var(--spice-button, #1ed760);
}

.syncify-button:hover:not(:disabled) {
    background: var(--spice-button-active, #1fdf64);
    box-shadow: 0 0 0 1px rgba(255, 255, 255, 0.08) inset;
}

.syncify-button:active:not(:disabled),
.syncify-link-button:active:not(:disabled) {
    transform: scale(0.98);
}

.syncify-button.secondary,
.syncify-link-button {
    color: var(--spice-text);
    background: rgba(255, 255, 255, 0.11);
}

.syncify-button.secondary:hover:not(:disabled),
.syncify-link-button:hover:not(:disabled) {
    color: var(--spice-text);
    background: rgba(255, 255, 255, 0.18);
}

.syncify-button.danger {
    color: #fff;
    background: #c92a2a;
}

.syncify-button.danger:hover:not(:disabled) {
    background: #e03131;
}

.syncify-button:disabled,
.syncify-link-button:disabled {
    cursor: not-allowed;
    opacity: 0.55;
}

.syncify-toggle {
    display: flex;
    align-items: flex-start;
    gap: 7px;
    color: var(--spice-subtext);
    font-size: 12px;
    line-height: 1.45;
    cursor: pointer;
}

.syncify-toggle input {
    flex: 0 0 auto;
    margin-top: 2px;
    cursor: pointer;
}

.syncify-toggle:has(input:disabled),
.syncify-toggle input:disabled {
    cursor: not-allowed;
    opacity: 0.65;
}

.syncify-link-button {
    padding: 7px 12px;
    font-size: 12px;
}

.syncify-message {
    display: flex;
    align-items: flex-start;
    gap: 8px;
    margin: 0;
    padding: 8px 10px;
    border: 1px solid rgba(255, 255, 255, 0.1);
    border-radius: 10px;
    color: var(--spice-text);
    background: rgba(255, 255, 255, 0.055);
    font-size: 12px;
    line-height: 1.45;
}

.syncify-message::before {
    flex: 0 0 auto;
    width: 7px;
    height: 7px;
    margin-top: 5px;
    border-radius: 999px;
    background: var(--spice-subtext);
    content: "";
}

.syncify-message[data-kind="success"] {
    border-color: rgba(30, 215, 96, 0.35);
    background: rgba(30, 215, 96, 0.1);
}

.syncify-message[data-kind="success"]::before {
    background: var(--spice-button-active, #1ed760);
}

.syncify-message[data-kind="warning"] {
    border-color: rgba(246, 195, 67, 0.38);
    background: rgba(246, 195, 67, 0.1);
}

.syncify-message[data-kind="warning"]::before {
    background: #f6c343;
}

.syncify-message[data-kind="error"] {
    border-color: rgba(255, 107, 107, 0.4);
    background: rgba(255, 107, 107, 0.1);
}

.syncify-message[data-kind="error"]::before {
    background: var(--spice-notification-error, #ff6b6b);
}

.syncify-message.inline {
    padding: 7px 9px;
}

@media (max-width: 560px) {
    .syncify-modal-shell .main-trackCreditsModal-mainSection,
    .syncify-modal-shell .main-trackCreditsModal-content,
    .main-trackCreditsModal-mainSection:has(.syncify-panel),
    .main-trackCreditsModal-content:has(.syncify-panel) {
        max-height: calc(100vh - 110px) !important;
        padding: 10px 14px 14px !important;
    }

    .syncify-status-row,
    .syncify-section-header {
        align-items: flex-start;
        flex-direction: column;
        gap: 6px;
    }

    .syncify-card {
        flex-basis: 100%;
        min-width: 0;
    }

    .syncify-backup-version {
        align-items: flex-start;
        flex-direction: column;
    }

    .syncify-backup-details {
        justify-content: flex-start;
    }

    .syncify-actions,
    .syncify-footer,
    .syncify-footer-actions {
        flex-direction: column;
    }

    .syncify-footer {
        align-items: stretch;
    }

    .syncify-button,
    .syncify-link-button {
        width: 100%;
    }
}
`;var ie=`<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-cloud-sync-icon lucide-cloud-sync"><path d="m17 18-1.535 1.605a5 5 0 0 1-8-1.5"/><path d="M17 22v-4h-4"/><path d="M20.996 15.251A4.5 4.5 0 0 0 17.495 8h-1.79a7 7 0 1 0-12.709 5.607"/><path d="M7 10v4h4"/><path d="m7 14 1.535-1.605a5 5 0 0 1 8 1.5"/></svg>\r
`;var oe="x-syncify-user-hash";async function ae(e,t,n){let i=await fetch(e,{method:"POST",headers:{"content-type":"application/json",[oe]:t},body:JSON.stringify(n)});if(!i.ok)throw new Error(`Backup failed with HTTP ${i.status}.`)}async function re(e,t){var s;let n=await fetch(e,{method:"GET",headers:{[oe]:t}});if(n.status===404)return{exists:!1,payload:null,backups:[]};if(!n.ok)throw new Error(`Restore failed with HTTP ${n.status}.`);let i=await n.json(),a=[i,...(s=i.backup_history)!=null?s:[]].slice(0,3);return{exists:!0,payload:i,backups:a}}var g={extensionName:"Syncify",version:"1.1.0",workerUrl:"https://syncify-worker.wsoltani.com",githubUrl:"https://github.com/wSoltani/Syncify",kofiUrl:"https://ko-fi.com/wsoltani",issueUrl:"https://github.com/wSoltani/Syncify/issues/new"};function d(){var t,n,i,a,s,c;let e=window.SyncifyConfig;return{extensionName:(t=w(e==null?void 0:e.extensionName))!=null?t:g.extensionName,version:(n=se(e==null?void 0:e.version))!=null?n:g.version,workerUrl:(i=w(e==null?void 0:e.workerUrl))!=null?i:g.workerUrl,githubUrl:(a=w(e==null?void 0:e.githubUrl))!=null?a:g.githubUrl,kofiUrl:(s=w(e==null?void 0:e.kofiUrl))!=null?s:g.kofiUrl,issueUrl:(c=w(e==null?void 0:e.issueUrl))!=null?c:g.issueUrl}}function w(e){return se(e)}function se(e){return typeof e=="string"&&e.trim()?e.trim():null}var E="syncify:config",D={workerUrl:d().workerUrl,autoBackupEnabled:!1};function _(){var n,i;let e=d(),t=(i=(n=Spicetify.LocalStorage)==null?void 0:n.get(E))!=null?i:window.localStorage.getItem(E);if(!t)return x(S({},D),{workerUrl:e.workerUrl});try{let a=JSON.parse(t);return{workerUrl:e.workerUrl,autoBackupEnabled:a.autoBackupEnabled===void 0?D.autoBackupEnabled:!!a.autoBackupEnabled}}catch(a){return x(S({},D),{workerUrl:e.workerUrl})}}function ce(e){var n;let t=JSON.stringify({workerUrl:d().workerUrl,autoBackupEnabled:e.autoBackupEnabled});if((n=Spicetify.LocalStorage)!=null&&n.set){Spicetify.LocalStorage.set(E,t);return}window.localStorage.setItem(E,t)}function Y(e){return typeof e.workerUrl=="string"&&e.workerUrl.length>0}async function v(e){let t=new TextEncoder().encode(e),n=await crypto.subtle.digest("SHA-256",t);return[...new Uint8Array(n)].map(i=>i.toString(16).padStart(2,"0")).join("")}function K(e){return JSON.stringify(F(e))}function F(e){return Array.isArray(e)?e.map(F):e&&typeof e=="object"?Object.keys(e).sort().reduce((t,n)=>(t[n]=F(e[n]),t),{}):e}async function $(){let e=await Ye();return v(e)}async function Ye(){var i,a,s,c,l;let e=(i=Spicetify.Platform)==null?void 0:i.UserAPI;if(!(e!=null&&e.getUser))throw new Error("Spicetify Platform UserAPI is unavailable.");let t=await e.getUser(),n=(l=(c=(s=(a=t==null?void 0:t.username)!=null?a:t==null?void 0:t.canonicalUsername)!=null?s:t==null?void 0:t.id)!=null?c:t==null?void 0:t.uri)!=null?l:t==null?void 0:t.displayName;if(!n)throw new Error("Unable to resolve the active Spotify user.");return n}function le(){let e=navigator.userAgent;return/Windows/i.test(e)?"Windows":/Mac OS|Macintosh/i.test(e)?"macOS":/Linux/i.test(e)?"Linux":e}var ye="marketplace:",de=["marketplace:installed-extensions","marketplace:installed-snippets","marketplace:installed-themes"];function fe(){let e={};for(let t=0;t<window.localStorage.length;t+=1){let n=window.localStorage.key(t);if(!(n!=null&&n.startsWith(ye)))continue;let i=window.localStorage.getItem(n);i!==null&&(e[n]=i)}return e}async function P(){let e=fe();return{keyCount:Object.keys(e).length,hash:await v(K(e))}}async function pe(){let e=fe();return{schema_version:1,metadata:{last_sync_datetime:new Date().toISOString(),device_info:le(),marketplace_key_count:Object.keys(e).length},payload_hash:await v(K(e)),marketplace_data:{keys:e}}}function ue(e){var i,a;let t=(a=(i=e.marketplace_data)==null?void 0:i.keys)!=null?a:{},n=0;for(let[s,c]of Object.entries(t))s.startsWith(ye)&&(window.localStorage.setItem(s,c),n+=1);return n}function me(){return de.reduce((e,t)=>e+Ke(window.localStorage.getItem(t)),0)}function ge(){return!!(window.Marketplace||de.some(t=>window.localStorage.getItem(t)!==null)||window.localStorage.getItem("marketplace:tabs")!==null)}function be(e,t){return t===0?!1:e===0?!0:e<Math.max(2,Math.floor(t*.5))}function Ke(e){if(!e)return 0;try{let t=JSON.parse(e);return Array.isArray(t)?t.length:0}catch(t){return 0}}async function U(e){if(!Y(e))throw new Error("Syncify backup service is not configured.");let[t,n]=await Promise.all([$(),pe()]);if(n.metadata.marketplace_key_count===0)throw new Error("Syncify will not back up an empty extension/theme state.");return await ae(e.workerUrl,t,n),n}async function C(e){if(!Y(e))throw new Error("Syncify backup service is not configured.");return re(e.workerUrl,await $())}async function ke(e,t){let n=t!=null?t:(await C(e)).payload;if(!n)throw new Error("No Syncify cloud backup was found for this Spotify account.");let i=ue(n);return{payload:n,restoredCount:i}}async function he(){var t,n,i;let e=_();if(!(!e.workerUrl||!e.autoBackupEnabled))try{let[a,s]=await Promise.all([P(),C(e)]),c=(n=(t=s.payload)==null?void 0:t.metadata.marketplace_key_count)!=null?n:0;if(s.exists&&be(a.keyCount,c)){Spicetify.showNotification("Syncify found a larger cloud backup. Open Syncify to restore before backing up.",!0,8e3);return}if(((i=s.payload)==null?void 0:i.payload_hash)===a.hash||a.keyCount===0)return;await U(e),Spicetify.showNotification("Syncify auto-backup complete")}catch(a){let s=a instanceof Error?a.message:String(a);console.warn("Syncify startup sync failed:",a),Spicetify.showNotification(`Syncify auto-sync skipped: ${s}`,!0,8e3)}}function xe(){var Z;let e=Spicetify.React,t=e.useEffect,n=e.useMemo,i=e.useState,[a,s]=i(()=>_()),[c,l]=i("idle"),[u,y]=i(null),[ve,Ce]=i(0),[Ne,Me]=i(0),[V,Ee]=i(null),[f,I]=i(null),[J,q]=i([]),[p,k]=i(null),[N,A]=i(!1),[_e,h]=i(!1),M=n(()=>d(),[]),m=c==="loading",L=(u==null?void 0:u.kind)==="warning"||(u==null?void 0:u.kind)==="error"?u:null,O=n(()=>ge(),[]),Pe=(Z=f==null?void 0:f.metadata.marketplace_key_count)!=null?Z:0,Ue=!!(f&&V&&f.payload_hash!==V);t(()=>{Q({silent:!0})},[]);async function X(){let o=await P();return Ce(o.keyCount),Ee(o.hash),Me(me()),o}async function Q(o){try{h(!1),l("loading"),o!=null&&o.silent||y({kind:"info",text:"Checking your Syncify backup\u2026"}),await X();let r=await C(a);I(r.payload),q(r.backups),k(r.payload),A(!0),l(r.exists?"success":"idle"),o!=null&&o.silent||y(r.exists&&r.payload?{kind:"success",text:`Backup found from ${Se(r.payload.metadata.last_sync_datetime)}.`}:{kind:"info",text:"No backup exists yet. Create one from this device when you're ready."})}catch(r){H(r)}}function Be(o){let r=x(S({},a),{autoBackupEnabled:o});s(r),ce(r),y({kind:"success",text:o?"Automatic backups are on. Syncify will still protect larger cloud backups from being overwritten.":"Automatic backups are off. You can still back up manually."})}async function Te(){try{h(!1),l("loading"),y({kind:"info",text:"Backing up your extensions and themes\u2026"});let o=await U(a);I(o),q(r=>[o,...r.filter(z=>z.payload_hash!==o.payload_hash)].slice(0,3)),k(o),A(!0),await X(),l("success"),y({kind:"success",text:`Backed up ${o.metadata.marketplace_key_count} entries.`}),Spicetify.showNotification("Syncify backup complete")}catch(o){H(o)}}function Ie(o=p){if(!O){let r="Spicetify Marketplace is required to restore extensions and themes. Install and enable it, then try again.";y({kind:"error",text:r}),Spicetify.showNotification(r,!0,6e3);return}if(!o){let r="No Syncify cloud backup was found for this Spotify account.";y({kind:"error",text:r}),Spicetify.showNotification(r,!0,6e3);return}k(o),h(!0)}async function Ae(){try{h(!1),l("loading"),y({kind:"info",text:"Restoring your extensions and themes\u2026"});let{payload:o,restoredCount:r}=await ke(a,p!=null?p:void 0);I(o),k(o),A(!0),l("success"),y({kind:"success",text:`Restored ${r} entries. Reloading Spotify\u2026`}),Spicetify.showNotification("Syncify restore complete. Reloading\u2026"),setTimeout(()=>window.location.reload(),1e3)}catch(o){H(o)}}function j(o){if(o.startsWith("mailto:")){window.location.href=o;return}window.open(o,"_blank","noopener,noreferrer")}function H(o){let r=o instanceof Error?o.message:String(o);l("error"),y({kind:"error",text:r}),Spicetify.showNotification(r,!0,6e3)}function R(o){o.stopPropagation()}return e.createElement("div",{className:"syncify-panel",onClick:R,onMouseDown:R,onPointerDown:R},e.createElement("section",{className:"syncify-hero","aria-label":"Syncify status"},e.createElement("p",{className:"syncify-description"},"Back up your installed extensions and themes, then restore them whenever Spotify or Spicetify needs a fresh setup."),e.createElement("div",{className:"syncify-status-row"},e.createElement("h3",{className:"syncify-heading"},$e(c,N)),e.createElement("span",{className:"syncify-status-pill","data-kind":Ge(c)},We(c,N))),L?e.createElement("p",{className:"syncify-message","data-kind":L.kind},L.text):null),e.createElement("section",{className:"syncify-grid","aria-label":"Syncify backup details"},e.createElement(B,{label:"Backup entries",value:ve}),e.createElement(B,{label:"Extensions/themes",value:Ne}),e.createElement(B,{label:"Backup",value:f?`${Pe} entries`:N?"None":"Checking",tone:f?"success":N?"warning":"neutral"}),e.createElement(B,{label:"Restore",value:O?"Ready":"Missing",tone:O?"success":"warning"})),f?e.createElement("section",{className:"syncify-section syncify-backup-section"},e.createElement("div",{className:"syncify-section-header"},e.createElement("h4",{className:"syncify-section-title"},"Version history"),e.createElement("span",{className:"syncify-backup-time"},J.length," saved")),e.createElement("div",{className:"syncify-backup-list"},J.map((o,r)=>{let z=(p==null?void 0:p.payload_hash)===o.payload_hash;return e.createElement("button",{className:"syncify-backup-version","data-selected":z?"true":"false",type:"button",key:`${o.payload_hash}-${o.metadata.last_sync_datetime}`,onClick:()=>k(o),disabled:m},e.createElement("span",{className:"syncify-backup-version-main"},e.createElement("strong",null,r===0?"Latest":`Backup ${r+1}`),e.createElement("span",null,Se(o.metadata.last_sync_datetime))),e.createElement("span",{className:"syncify-backup-details"},e.createElement("span",null,o.metadata.device_info),e.createElement("span",null,o.metadata.marketplace_key_count," entries")))})),Ue?e.createElement("p",{className:"syncify-message inline","data-kind":"warning"},"This device differs from your latest backup. Select any saved version to restore it, or back up to add a new version."):null):null,e.createElement("section",{className:"syncify-section compact"},e.createElement("h4",{className:"syncify-section-title"},"Sync controls"),_e?e.createElement("div",{className:"syncify-confirm-restore"},e.createElement("p",{className:"syncify-message inline","data-kind":"warning"},"Restore will replace this device's saved extensions and themes with the selected backup, then reload Spotify."),e.createElement("div",{className:"syncify-actions"},e.createElement("button",{className:"syncify-button secondary",type:"button",onClick:()=>h(!1),disabled:m},"Cancel"),e.createElement("button",{className:"syncify-button danger",type:"button",onClick:Ae,disabled:m},"Confirm restore"))):e.createElement("div",{className:"syncify-actions"},e.createElement("button",{className:"syncify-button",type:"button",onClick:Te,disabled:m},"Back up"),e.createElement("button",{className:"syncify-button danger",type:"button",onClick:()=>Ie(),disabled:m||!p},"Restore selected"),e.createElement("button",{className:"syncify-button secondary",type:"button",onClick:()=>{Q()},disabled:m},"Refresh status")),e.createElement("label",{className:"syncify-toggle"},e.createElement("input",{type:"checkbox",checked:a.autoBackupEnabled,onChange:o=>Be(o.currentTarget.checked),disabled:m}),e.createElement("span",null,"Auto-backup extensions and themes after startup safety checks"))),e.createElement("section",{className:"syncify-footer","aria-label":"Syncify links"},e.createElement("span",{className:"syncify-version"},"v",M.version),e.createElement("div",{className:"syncify-footer-actions"},e.createElement("button",{className:"syncify-link-button",type:"button",onClick:()=>j(M.issueUrl)},"Report an issue"),e.createElement("button",{className:"syncify-link-button",type:"button",onClick:()=>j(M.githubUrl)},"GitHub"),e.createElement("button",{className:"syncify-link-button",type:"button",onClick:()=>j(M.kofiUrl)},"Ko-fi"))))}function B({label:e,value:t,tone:n="neutral"}){let i=Spicetify.React;return i.createElement("div",{className:"syncify-card","data-tone":n},i.createElement("span",{className:"syncify-card-label"},e),i.createElement("strong",{className:"syncify-card-value"},t))}function $e(e,t){return e==="loading"?"Checking status\u2026":e==="error"?"Sync needs attention":e==="success"?"Backup available":e==="needs-restore"?"Restore recommended":t?"Ready to back up":"Loading Syncify"}function We(e,t){return e==="loading"?"Checking":e==="error"?"Error":e==="success"?"Synced":e==="needs-restore"?"Restore":t?"Ready":"Starting"}function Ge(e){return e==="success"?"success":e==="error"?"error":e==="needs-restore"?"warning":"neutral"}function Se(e){let t=new Date(e);if(Number.isNaN(t.getTime()))return e;let n=t.toLocaleDateString(void 0,{month:"short",day:"numeric"}),i=t.toLocaleTimeString(void 0,{hour:"2-digit",minute:"2-digit"});return`${n}, ${i}`}var T="[Syncify]";function b(e,t){if(t===void 0){console.debug(T,e);return}console.debug(T,e,t)}function G(e,t){if(t===void 0){console.warn(T,e);return}console.warn(T,e,t)}(function e(){if(!Ve()){setTimeout(e,100);return}b("Spicetify APIs ready"),Je()})();function Ve(){var e;return!!(Spicetify!=null&&Spicetify.Platform&&(Spicetify!=null&&Spicetify.LocalStorage)&&((e=Spicetify==null?void 0:Spicetify.Topbar)!=null&&e.Button)&&(Spicetify!=null&&Spicetify.PopupModal)&&(Spicetify!=null&&Spicetify.React)&&(Spicetify!=null&&Spicetify.ReactDOM)&&(Spicetify!=null&&Spicetify.showNotification))}function Je(){qe(),Xe(),he().catch(e=>{G("Startup sync check failed",e)})}function qe(){let e="syncify-styles";if(document.getElementById(e))return;let t=document.createElement("style");t.id=e,t.textContent=ne,document.head.appendChild(t)}function Xe(){let{extensionName:e}=d(),t=new Spicetify.Topbar.Button(e,ie,n=>{b("Topbar button clicked",W(n)),we()},!1,!0);Qe(t),Ze(t),b("Topbar button registered",W(t))}function Qe(e){var n;let t=e;e.element.style.setProperty("-webkit-app-region","no-drag"),(n=t.button)==null||n.style.setProperty("-webkit-app-region","no-drag")}function Ze(e){Object.assign(window,{SyncifyDebug:{button:e,element:e.element,openModal:we,inspect:()=>W(e),clickElement:()=>{var t;return(t=e.element)==null?void 0:t.click()},clickInnerButton:()=>{var t;return(t=e.button)==null?void 0:t.click()},clickCallback:()=>e.onClick(e)}})}function W(e){var t,n,i,a,s;return{label:e.label,disabled:e.disabled,isRight:e.isRight,hasElement:!!e.element,elementConnected:(t=e.element)==null?void 0:t.isConnected,elementDisabled:(n=e.element)==null?void 0:n.disabled,elementAriaDisabled:(i=e.element)==null?void 0:i.getAttribute("aria-disabled"),elementClass:(a=e.element)==null?void 0:a.className,appRegion:e.element?getComputedStyle(e.element).getPropertyValue("-webkit-app-region"):null,innerButtonAppRegion:e.button?getComputedStyle(e.button).getPropertyValue("-webkit-app-region"):null,pointerEvents:e.element?getComputedStyle(e.element).pointerEvents:null,visibility:e.element?getComputedStyle(e.element).visibility:null,display:e.element?getComputedStyle(e.element).display:null,rect:(s=e.element)==null?void 0:s.getBoundingClientRect().toJSON()}}function we(){b("Opening modal");let e=document.createElement("div");try{Spicetify.PopupModal.display({title:d().extensionName,content:e,isLarge:!1})}catch(t){throw G("Failed to open PopupModal",t),t}et(e),nt(e)}function et(e){requestAnimationFrame(()=>{let t=tt(e);t==null||t.classList.add("syncify-modal-shell");let n=t==null?void 0:t.querySelector('button[aria-label*="close" i], button[title*="close" i], .main-trackCreditsModal-header button:last-of-type');n&&(n.classList.add("syncify-modal-close"),n.setAttribute("aria-label",`Close ${d().extensionName}`),n.title="Close",n.innerHTML='<svg viewBox="0 0 24 24" aria-hidden="true" focusable="false"><path d="M18 6 6 18"/><path d="m6 6 12 12"/></svg>')})}function tt(e){let t=e.parentElement;for(;t&&t!==document.body;){if(t.querySelector(".main-trackCreditsModal-header"))return t;t=t.parentElement}return e.closest('[class*="trackCreditsModal"]')}function nt(e){try{let t=Spicetify.React.createElement(xe);if(typeof Spicetify.ReactDOM.createRoot=="function"){Spicetify.ReactDOM.createRoot(e).render(t),b("Modal rendered",{renderer:"createRoot"});return}Spicetify.ReactDOM.render(t,e),b("Modal rendered",{renderer:"render"})}catch(t){throw G("Failed to render modal",t),t}}})();
