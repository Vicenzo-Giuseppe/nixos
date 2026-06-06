const state = {
  activeView: "dashboard",
  busy: false,
  health: null,
  overview: null,
  library: null,
  libraryItems: [],
  libraryMode: { date: null, kind: "image", scope: "session" },
  search: { query: "", contentType: "all", start: "2h ago", end: "now", limit: 12 },
  searchResults: null,
  activity: { start: "4h ago", end: "now", appName: "" },
  activitySummary: null,
  meetings: [],
  selectedMeetingId: null,
  selectedMeeting: null,
  selectedTranscript: [],
  frameContext: null,
  consolePath: "/openapi.yaml",
  consoleBody: "",
  consoleMethod: "GET",
  consoleOutput: "",
  notices: [],
};

const root = document.getElementById("app");

function pushNotice(message, tone = "warn") {
  state.notices = [{ message, tone, id: crypto.randomUUID() }, ...state.notices].slice(0, 5);
}

function formatNumber(value) {
  return value == null ? "-" : Intl.NumberFormat().format(value);
}

function formatDate(value) {
  if (!value) return "-";
  const date = new Date(value);
  return Number.isNaN(date.getTime()) ? value : date.toLocaleString();
}

function formatBytes(value) {
  if (!value && value !== 0) return "-";
  const units = ["B", "KB", "MB", "GB"];
  let size = value;
  let unit = 0;
  while (size >= 1024 && unit < units.length - 1) {
    size /= 1024;
    unit += 1;
  }
  return `${size.toFixed(size >= 100 || unit === 0 ? 0 : 1)} ${units[unit]}`;
}

function escapeHtml(value) {
  return String(value ?? "")
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#39;");
}

async function request(path, options = {}) {
  const response = await fetch(path, {
    headers: {
      "Content-Type": "application/json",
      ...(options.headers || {}),
    },
    ...options,
  });

  const text = await response.text();
  let payload;
  try {
    payload = text ? JSON.parse(text) : null;
  } catch {
    payload = text;
  }

  if (!response.ok) {
    const message = payload?.error || payload?.message || response.statusText;
    throw new Error(message || `Request failed with ${response.status}`);
  }

  return payload;
}

async function refreshOverview() {
  state.overview = await request("/api/overview");
  state.health = state.overview.health;
  state.library = state.overview.library;
  if (!state.libraryMode.date && state.library?.currentSession?.date) {
    state.libraryMode.date = state.library.currentSession.date;
  }
}

async function refreshLibraryItems() {
  const params = new URLSearchParams({
    kind: state.libraryMode.kind,
    scope: state.libraryMode.scope,
    limit: "80",
  });
  if (state.libraryMode.date) params.set("date", state.libraryMode.date);
  const payload = await request(`/api/library/items?${params.toString()}`);
  state.libraryItems = payload.items || [];
}

async function refreshSearch() {
  const params = new URLSearchParams({
    content_type: state.search.contentType,
    start_time: state.search.start,
    end_time: state.search.end,
    limit: String(state.search.limit),
  });
  if (state.search.query.trim()) params.set("q", state.search.query.trim());
  state.searchResults = await request(`/api/search?${params.toString()}`);
}

async function refreshActivity() {
  const params = new URLSearchParams({
    start_time: state.activity.start,
    end_time: state.activity.end,
    include_recording: "true",
    include_memories: "true",
    include_snippets: "true",
    include_guidance: "true",
  });
  if (state.activity.appName.trim()) params.set("app_name", state.activity.appName.trim());
  state.activitySummary = await request(`/api/activity-summary?${params.toString()}`);
}

async function refreshMeetings() {
  state.meetings = await request("/api/meetings?start_time=7d%20ago&end_time=now&limit=24&offset=0");
  if (!state.selectedMeetingId && state.meetings[0]?.id) {
    await selectMeeting(state.meetings[0].id);
  }
}

async function selectMeeting(id) {
  state.selectedMeetingId = id;
  state.selectedMeeting = await request(`/api/meetings/${id}`);
  state.selectedTranscript = await request(`/api/meetings/${id}/transcript`);
}

async function loadFrameContext(frameId) {
  state.frameContext = await request(`/api/frames/${frameId}/context`);
  state.activeView = "frames";
}

async function runConsole() {
  const path = state.consolePath.startsWith("/") ? state.consolePath : `/${state.consolePath}`;
  const body = state.consoleBody.trim();
  const payload = await request(`/api/proxy${path}`, {
    method: state.consoleMethod,
    body: state.consoleMethod === "GET" || !body ? undefined : body,
    headers: body ? { "Content-Type": "application/json" } : {},
  });
  state.consoleOutput = typeof payload === "string" ? payload : JSON.stringify(payload, null, 2);
}

async function controlAudio(action, deviceName) {
  const path =
    action === "start-all"
      ? "/api/audio/start"
      : action === "stop-all"
        ? "/api/audio/stop"
        : action === "start-device"
          ? "/api/audio/device/start"
          : "/api/audio/device/stop";
  const options = {
    method: "POST",
  };
  if (deviceName) {
    options.body = JSON.stringify({ device_name: deviceName });
  }
  await request(path, options);
  pushNotice(action.startsWith("start") ? "Audio capture request sent." : "Audio pause request sent.", "good");
  await refreshOverview();
}

async function serviceAction(action) {
  await request("/api/service", {
    method: "POST",
    body: JSON.stringify({ action, service: "screenpipe" }),
  });
  pushNotice(`Requested ${action} on screenpipe.service`, "good");
  await refreshOverview();
}

function categorizeDevices(devices = []) {
  const output = [];
  const input = [];
  const other = [];

  for (const device of devices) {
    const name = device.name || "";
    if (/(output|speaker|sink|monitor)/i.test(name)) {
      output.push(device);
    } else if (/(input|mic|microphone|source)/i.test(name)) {
      input.push(device);
    } else {
      other.push(device);
    }
  }

  return { output, input, other };
}

function renderHero() {
  const health = state.health;
  const online = !!health?.status_code;
  const pipeline = health?.pipeline || {};
  const sessions = state.library?.sessions || [];
  const currentSession = state.library?.currentSession;

  return `
    <section class="hero">
      <div class="panel hero-main">
        <div class="panel-inner">
          <div class="eyebrow">Screenpipe Studio</div>
          <h1 class="hero-title">Harvest the whole session, not just a token-protected API root.</h1>
          <p class="hero-copy">A local command deck for screen OCR, meetings, frame context, session JPGs, compact MP4 timelines, and audio capture controls. The browser never sees your Screenpipe token. The server proxies it upstream and scans the local archive directly.</p>
          <div class="hero-actions">
            <button class="button" data-action="refresh-all">Refresh Everything</button>
            <button class="ghost" data-action="focus-view" data-view="library">Open Session Library</button>
            <button class="ghost" data-action="focus-view" data-view="capture">Capture Controls</button>
            <button class="ghost" data-action="focus-view" data-view="developer">API Console</button>
          </div>
        </div>
      </div>
      <div class="panel">
        <div class="panel-inner status-grid">
          <div class="status-card">
            <div class="status-label">Recorder</div>
            <div class="status-value ${online ? "status-online" : "status-offline"}">${online ? health.status : "offline"}</div>
            <div class="subtle">${escapeHtml(health?.message || state.overview?.upstreamStatus?.message || "No live health payload available.")}</div>
          </div>
          <div class="status-card">
            <div class="status-label">Audio</div>
            <div class="status-value small">${escapeHtml(health?.audio_status || "disabled")}</div>
            <div class="subtle">Input tap ${health?.ui_recorder?.input_tap_running ? "running" : "off"}</div>
          </div>
          <div class="status-card">
            <div class="status-label">Frames Stored</div>
            <div class="status-value">${formatNumber(pipeline.frames_db_written)}</div>
            <div class="subtle">${escapeHtml(currentSession?.date || sessions[0]?.date || "No session folders yet")}</div>
          </div>
          <div class="status-card">
            <div class="status-label">Monitor / Sessions</div>
            <div class="status-value small">${escapeHtml((health?.monitors || [])[0] || "No live monitor")}</div>
            <div class="subtle">${formatNumber(sessions.length)} session folders harvested</div>
          </div>
        </div>
      </div>
    </section>
  `;
}

function renderRail() {
  const items = [
    ["dashboard", "Overview"],
    ["capture", "Capture Controls"],
    ["search", "Search + Frames"],
    ["library", "Session Library"],
    ["meetings", "Meetings"],
    ["frames", "Frame Context"],
    ["developer", "Developer"],
  ];

  return `
    <aside class="panel rail">
      ${items
        .map(
          ([id, label]) => `<button class="tab ${state.activeView === id ? "active" : ""}" data-action="focus-view" data-view="${id}">${label}</button>`,
        )
        .join("")}
    </aside>
  `;
}

function renderOverview() {
  const overview = state.overview || {};
  const health = state.health || {};
  const library = state.library || {};
  const devices = overview.devices || {};
  const audioBuckets = categorizeDevices(devices.audioDevices || []);

  return `
    <section class="panel">
      <div class="panel-inner stack">
        <div class="section-head">
          <div>
            <div class="section-kicker">Recorder state</div>
            <h2 class="section-title">Know what is alive before you inspect anything.</h2>
            <p class="section-copy">Live status from Screenpipe if the daemon is up, plus archive stats from the session folders even if capture is currently down.</p>
          </div>
          <div class="status-actions">
            <button class="ghost" data-action="service" data-service-action="restart">Restart recorder</button>
            <button class="ghost" data-action="service" data-service-action="start">Start recorder</button>
          </div>
        </div>
        <div class="overview-grid status-grid">
          <div class="metric">
            <div class="metric-label">Live status</div>
            <div class="metric-value ${health?.status_code ? "status-online" : "status-offline"}">${escapeHtml(health?.status || overview.upstreamStatus?.status || "offline")}</div>
            <div class="subtle">Last frame: ${escapeHtml(formatDate(health?.last_frame_timestamp))}</div>
          </div>
          <div class="metric">
            <div class="metric-label">OCR / queue</div>
            <div class="metric-value small">${formatNumber(health?.pipeline?.frames_captured || library.totalImages || 0)} frames</div>
            <div class="subtle">Queue depth ${formatNumber(health?.pipeline?.video_queue_depth || 0)}</div>
          </div>
          <div class="metric">
            <div class="metric-label">Archive</div>
            <div class="metric-value small">${formatNumber(library.totalImages || 0)} JPGs</div>
            <div class="subtle">${formatNumber(library.totalVideos || 0)} compact videos · ${formatNumber(library.totalAudio || 0)} audio files</div>
          </div>
          <div class="metric">
            <div class="metric-label">Devices</div>
            <div class="metric-value small">${formatNumber((devices.monitors || []).length)} screens</div>
            <div class="subtle">${formatNumber(audioBuckets.output.length)} output · ${formatNumber(audioBuckets.input.length)} input</div>
          </div>
        </div>
        <div class="notice">${escapeHtml(overview.upstreamStatus?.message || "The webview scans your archive directly and proxies authenticated API calls when the recorder is available.")}</div>
      </div>
    </section>
  `;
}

function renderCaptureControls() {
  const devices = state.overview?.devices || {};
  const statuses = new Map((devices.audioStatus || []).map((entry) => [entry.name, entry]));
  const buckets = categorizeDevices(devices.audioDevices || []);
  const renderGroup = (title, items, mode) => `
    <div class="list-card">
      <div class="meeting-title">${title}</div>
      ${(items.length ? items : [{ name: `No ${title.toLowerCase()} detected`, unavailable: true }])
        .map((device) => {
          const status = statuses.get(device.name) || {};
          const active = status.is_running;
          return `
            <div class="control-card ${active ? "active" : ""}">
              <div class="panel-inner">
                <div class="control-title">${escapeHtml(device.name)}</div>
                <div class="chip-row">
                  <span class="pill ${active ? "good" : "warn"}">${active ? "capturing" : "paused"}</span>
                  ${device.is_default ? '<span class="pill">default</span>' : ""}
                  ${status.is_user_disabled ? '<span class="pill bad">user disabled</span>' : ""}
                </div>
                <div class="result-actions">
                  ${device.unavailable
                    ? '<span class="pill bad">No live device route available</span>'
                    : `<button class="button" data-action="audio-device" data-device-action="start-device" data-device-name="${escapeHtml(device.name)}">Enable ${mode}</button>
                       <button class="ghost" data-action="audio-device" data-device-action="stop-device" data-device-name="${escapeHtml(device.name)}">Pause ${mode}</button>`}
                </div>
              </div>
            </div>
          `;
        })
        .join("")}
    </div>
  `;

  return `
    <section class="panel">
      <div class="panel-inner stack">
        <div class="section-head">
          <div>
            <div class="section-kicker">Audio and capture orchestration</div>
            <h2 class="section-title">Separate machine output, microphone capture, and recorder lifecycle.</h2>
            <p class="section-copy">Screenpipe exposes start/stop controls for audio globally and per device. The UI groups likely output devices separately from mic/input devices, then lets you toggle them without touching raw curl commands.</p>
          </div>
        </div>
        <div class="toolbar">
          <button class="button" data-action="audio" data-audio-action="start-all">Start All Audio</button>
          <button class="ghost" data-action="audio" data-audio-action="stop-all">Stop All Audio</button>
          <button class="ghost" data-action="refresh-all">Refresh Device State</button>
        </div>
        <div class="control-grid">
          ${renderGroup("Machine output", buckets.output, "output")}
          ${renderGroup("Microphone / input", buckets.input, "mic")}
        </div>
        <div class="list-card">
          <div class="meeting-title">Monitors</div>
          <div class="chip-row">
            ${(devices.monitors || []).map((monitor) => `<span class="pill good">${escapeHtml(monitor.name || monitor)}</span>`).join("") || '<span class="pill bad">No live monitors from Screenpipe</span>'}
          </div>
          <div class="subtle">If the recorder is offline with “0 enumerated monitors”, the service likely needs Wayland session context or a restart after login.</div>
        </div>
      </div>
    </section>
  `;
}

function renderSearch() {
  const results = state.searchResults?.data || [];
  return `
    <section class="panel">
      <div class="panel-inner stack">
        <div class="section-head">
          <div>
            <div class="section-kicker">Search everything</div>
            <h2 class="section-title">OCR, audio, input, memory: one workbench.</h2>
            <p class="section-copy">Use the live API for timeline search, then jump straight into frame context without dragging screenshots into the LLM context unless you explicitly want to inspect a file.</p>
          </div>
        </div>
        <div class="field-grid">
          <div class="field-wide">
            <label for="search-query">Query</label>
            <input id="search-query" value="${escapeHtml(state.search.query)}" placeholder="meeting notes, stripe, screenpipe" />
          </div>
          <div class="field">
            <label for="search-type">Content type</label>
            <select id="search-type">
              ${["all", "ocr", "audio", "input", "memory"].map((value) => `<option value="${value}" ${state.search.contentType === value ? "selected" : ""}>${value}</option>`).join("")}
            </select>
          </div>
          <div class="field">
            <label for="search-start">Start</label>
            <input id="search-start" value="${escapeHtml(state.search.start)}" />
          </div>
          <div class="field">
            <label for="search-end">End</label>
            <input id="search-end" value="${escapeHtml(state.search.end)}" />
          </div>
          <div class="field">
            <label for="search-limit">Limit</label>
            <input id="search-limit" type="number" min="1" max="50" value="${escapeHtml(String(state.search.limit))}" />
          </div>
        </div>
        <div class="toolbar">
          <button class="button" data-action="run-search">Run Search</button>
          <button class="ghost" data-action="set-search-preset" data-start="30m ago" data-end="now">30m</button>
          <button class="ghost" data-action="set-search-preset" data-start="4h ago" data-end="now">4h</button>
          <button class="ghost" data-action="set-search-preset" data-start="1d ago" data-end="now">1d</button>
        </div>
        <div class="result-list stack">
          ${results.length ? results.map(renderResultCard).join("") : '<div class="empty">Run a search to inspect OCR, audio, input, or memory rows.</div>'}
        </div>
      </div>
    </section>
  `;
}

function renderResultCard(result) {
  const frameId = result?.content?.frame_id ?? result?.frame_id;
  const text = result?.content?.text || result?.text || result?.content || "";
  const filePath = result?.content?.file_path || result?.file_path;
  return `
    <article class="result-card">
      <div class="panel-inner">
        <div class="result-title">${escapeHtml(result?.content_type || result?.type || "result")}</div>
        <div class="chip-row">
          <span class="pill">${escapeHtml(formatDate(result?.timestamp || result?.created_at))}</span>
          ${frameId ? `<span class="pill mono">frame ${escapeHtml(String(frameId))}</span>` : ""}
          ${filePath ? `<a class="pill muted-link mono" href="/media?path=${encodeURIComponent(filePath)}" target="_blank" rel="noreferrer">open file</a>` : ""}
        </div>
        <div class="code-block">${escapeHtml(text || "No text payload")}</div>
        <div class="result-actions">
          ${frameId ? `<button class="ghost" data-action="frame-context" data-frame-id="${escapeHtml(String(frameId))}">Inspect Frame Context</button>` : ""}
        </div>
      </div>
    </article>
  `;
}

function renderLibrary() {
  const sessions = state.library?.sessions || [];
  const selected = state.libraryMode.date;
  const sessionButtons = `
    <div class="session-actions">
      <button class="button" data-action="library-mode" data-scope="session" data-kind="image">Session JPGs</button>
      <button class="ghost" data-action="library-mode" data-scope="all" data-kind="image">All session JPGs</button>
      <button class="ghost" data-action="library-mode" data-scope="session" data-kind="video">Session screens</button>
      <button class="ghost" data-action="library-mode" data-scope="all" data-kind="video">All screens</button>
      <button class="ghost" data-action="library-mode" data-scope="session" data-kind="audio">Session audio</button>
      <button class="ghost" data-action="library-mode" data-scope="all" data-kind="audio">All audio</button>
    </div>
  `;

  return `
    <section class="panel">
      <div class="panel-inner stack">
        <div class="section-head">
          <div>
            <div class="section-kicker">Archive browser</div>
            <h2 class="section-title">Harvest JPGs, compact MP4 screens, and session media across the whole recorder archive.</h2>
            <p class="section-copy">The library panel scans `${escapeHtml(state.library?.dataRoot || "your Screenpipe data directory")}` directly, so it still works even when the live recorder is down.</p>
          </div>
        </div>
        ${sessionButtons}
        <div class="session-grid">
          <div class="list-card session-list">
            <div class="meeting-title">Sessions</div>
            ${sessions.length
              ? sessions
                  .map(
                    (session) => `
                      <button class="session-item ${selected === session.date ? "active" : ""}" data-action="select-session" data-date="${escapeHtml(session.date)}">
                        <div class="session-name">${escapeHtml(session.date)}</div>
                        <div class="subtle">${formatNumber(session.imageCount)} JPGs · ${formatNumber(session.videoCount)} videos · ${formatNumber(session.audioCount)} audio</div>
                        <div class="subtle">Last update ${escapeHtml(formatDate(session.newestAt))}</div>
                      </button>
                    `,
                  )
                  .join("")
              : '<div class="empty">No session folders found under the Screenpipe data directory.</div>'}
          </div>
          <div class="stack">
            <div class="list-card">
              <div class="meeting-title">Current mode</div>
              <div class="chip-row">
                <span class="pill good">${escapeHtml(state.libraryMode.scope)}</span>
                <span class="pill">${escapeHtml(state.libraryMode.kind)}</span>
                ${selected ? `<span class="pill mono">${escapeHtml(selected)}</span>` : ""}
              </div>
              <div class="subtle">Use the buttons above to jump between current-session JPGs, all session JPGs, compact screen videos, or audio files.</div>
            </div>
            <div class="media-grid">
              ${state.libraryItems.length ? state.libraryItems.map(renderMediaCard).join("") : '<div class="empty">Choose a session and media kind to load harvested files.</div>'}
            </div>
          </div>
        </div>
      </div>
    </section>
  `;
}

function renderMediaCard(item) {
  const preview =
    item.kind === "image"
      ? `<img src="${escapeHtml(item.url)}" alt="${escapeHtml(item.name)}" loading="lazy" />`
      : item.kind === "video"
        ? `<video src="${escapeHtml(item.url)}" controls preload="metadata"></video>`
        : item.kind === "audio"
          ? `<div class="panel-inner"><audio src="${escapeHtml(item.url)}" controls preload="metadata"></audio></div>`
          : `<div class="panel-inner mono">${escapeHtml(item.name)}</div>`;

  return `
    <article class="media-card">
      <div class="media-preview">${preview}</div>
      <div class="media-body">
        <div class="media-name mono">${escapeHtml(item.name)}</div>
        <div class="chip-row">
          <span class="pill">${escapeHtml(item.kind)}</span>
          <span class="pill">${escapeHtml(item.session)}</span>
        </div>
        <div class="subtle">${escapeHtml(formatDate(item.timestamp || item.mtime))} · ${escapeHtml(formatBytes(item.size))}</div>
        <a class="muted-link mono" href="${escapeHtml(item.url)}" target="_blank" rel="noreferrer">open raw file</a>
      </div>
    </article>
  `;
}

function renderMeetings() {
  const meeting = state.selectedMeeting;
  const transcript = state.selectedTranscript || [];
  return `
    <section class="panel">
      <div class="panel-inner stack">
        <div class="section-head">
          <div>
            <div class="section-kicker">Meetings</div>
            <h2 class="section-title">Review sessions, titles, attendees, notes, and transcripts.</h2>
            <p class="section-copy">This section talks to Screenpipe’s meetings API directly when the recorder is available.</p>
          </div>
          <div class="meeting-actions">
            <button class="ghost" data-action="refresh-meetings">Reload meetings</button>
          </div>
        </div>
        <div class="meeting-grid">
          <div class="list-card meeting-list">
            ${state.meetings.length
              ? state.meetings
                  .map(
                    (item) => `
                      <button class="meeting-item ${state.selectedMeetingId === item.id ? "active" : ""}" data-action="select-meeting" data-meeting-id="${escapeHtml(String(item.id))}">
                        <div class="meeting-title">${escapeHtml(item.title || item.meeting_title || `Meeting ${item.id}`)}</div>
                        <div class="subtle">${escapeHtml(formatDate(item.meeting_start || item.created_at))}</div>
                        <div class="subtle">${escapeHtml(item.attendees || item.meeting_app || "No attendee metadata")}</div>
                      </button>
                    `,
                  )
                  .join("")
              : '<div class="empty">No meetings returned from Screenpipe.</div>'}
          </div>
          <div class="stack">
            ${meeting
              ? `
                <div class="meeting-card">
                  <div class="panel-inner">
                    <div class="meeting-title">${escapeHtml(meeting.title || meeting.meeting_title || `Meeting ${meeting.id}`)}</div>
                    <div class="chip-row">
                      <span class="pill mono">${escapeHtml(String(meeting.id))}</span>
                      <span class="pill">${escapeHtml(formatDate(meeting.meeting_start))}</span>
                      <span class="pill">${escapeHtml(formatDate(meeting.meeting_end))}</span>
                    </div>
                    <p class="section-copy">${escapeHtml(meeting.note || "No note stored for this meeting yet.")}</p>
                    <div class="code-block">${escapeHtml(meeting.attendees || "No attendee list")}</div>
                  </div>
                </div>
                <div class="meeting-card">
                  <div class="panel-inner">
                    <div class="meeting-title">Transcript</div>
                    <div class="result-list stack">
                      ${transcript.length
                        ? transcript
                            .map(
                              (segment) => `
                                <div class="result-card">
                                  <div class="panel-inner">
                                    <div class="chip-row">
                                      <span class="pill">${escapeHtml(formatDate(segment.timestamp || segment.start_time))}</span>
                                      ${segment.speaker_name ? `<span class="pill">${escapeHtml(segment.speaker_name)}</span>` : ""}
                                    </div>
                                    <div class="code-block">${escapeHtml(segment.text || segment.content || "")}</div>
                                  </div>
                                </div>
                              `,
                            )
                            .join("")
                        : '<div class="empty">No transcript segments returned for this meeting.</div>'}
                    </div>
                  </div>
                </div>
              `
              : '<div class="empty">Select a meeting to inspect its metadata and transcript.</div>'}
          </div>
        </div>
      </div>
    </section>
  `;
}

function renderFrameContext() {
  const context = state.frameContext;
  const activity = state.activitySummary;
  return `
    <section class="panel">
      <div class="panel-inner stack">
        <div class="section-head">
          <div>
            <div class="section-kicker">Frame detail and activity</div>
            <h2 class="section-title">Jump from a search hit into full frame context and summarized time ranges.</h2>
            <p class="section-copy">Frame context exposes accessibility text, parsed nodes, and URLs. Activity summary rolls up apps, windows, snippets, and recording hints over a time range.</p>
          </div>
        </div>
        <div class="content-grid">
          <div class="stack">
            <div class="field-grid">
              <div class="field">
                <label for="activity-start">Summary start</label>
                <input id="activity-start" value="${escapeHtml(state.activity.start)}" />
              </div>
              <div class="field">
                <label for="activity-end">Summary end</label>
                <input id="activity-end" value="${escapeHtml(state.activity.end)}" />
              </div>
              <div class="field-wide">
                <label for="activity-app">App filter</label>
                <input id="activity-app" value="${escapeHtml(state.activity.appName)}" placeholder="Slack, Google Chrome, code" />
              </div>
            </div>
            <div class="toolbar">
              <button class="button" data-action="run-activity">Run Activity Summary</button>
            </div>
            <div class="code-block">${escapeHtml(activity ? JSON.stringify(activity, null, 2) : "Run an activity summary to inspect apps, windows, snippets, and recording status." )}</div>
          </div>
          <div class="stack">
            <div class="meeting-card">
              <div class="panel-inner">
                <div class="meeting-title">Frame context</div>
                <div class="code-block">${escapeHtml(context ? JSON.stringify(context, null, 2) : "Choose “Inspect Frame Context” from a search result to load parsed accessibility nodes and URLs for that frame.")}</div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  `;
}

function renderDeveloper() {
  return `
    <section class="panel">
      <div class="panel-inner stack">
        <div class="section-head">
          <div>
            <div class="section-kicker">Developer console</div>
            <h2 class="section-title">Probe Screenpipe routes without exposing the auth token to the browser.</h2>
            <p class="section-copy">Use this to hit raw API paths like <span class="mono">/health</span>, <span class="mono">/openapi.yaml</span>, or <span class="mono">/meetings</span>. The webview server proxies the request upstream and injects the bearer token itself.</p>
          </div>
        </div>
        <div class="developer-grid">
          <div class="stack">
            <div class="field-grid">
              <div class="field">
                <label for="console-method">Method</label>
                <select id="console-method">
                  ${["GET", "POST"].map((method) => `<option value="${method}" ${state.consoleMethod === method ? "selected" : ""}>${method}</option>`).join("")}
                </select>
              </div>
              <div class="field-wide">
                <label for="console-path">Path</label>
                <input id="console-path" value="${escapeHtml(state.consolePath)}" placeholder="/health" />
              </div>
            </div>
            <div class="field">
              <label for="console-body">JSON body</label>
              <textarea id="console-body" placeholder='{"device_name": "alsa_output..."}'>${escapeHtml(state.consoleBody)}</textarea>
            </div>
            <div class="toolbar">
              <button class="button" data-action="run-console">Run request</button>
              <button class="ghost" data-action="console-preset" data-console-path="/openapi.yaml" data-console-method="GET">OpenAPI</button>
              <button class="ghost" data-action="console-preset" data-console-path="/health" data-console-method="GET">Health</button>
              <button class="ghost" data-action="console-preset" data-console-path="/meetings?limit=5&offset=0" data-console-method="GET">Meetings</button>
            </div>
          </div>
          <div class="console-output"><pre>${escapeHtml(state.consoleOutput || "Console output appears here.")}</pre></div>
        </div>
      </div>
    </section>
  `;
}

function renderNotices() {
  if (!state.notices.length) return "";
  return `
    <section class="stack">
      ${state.notices
        .map(
          (notice) => `<div class="notice"><span class="pill ${notice.tone}">${escapeHtml(notice.tone)}</span> ${escapeHtml(notice.message)}</div>`,
        )
        .join("")}
    </section>
  `;
}

function render() {
  const viewMap = {
    dashboard: `${renderOverview()}${renderCaptureControls()}`,
    capture: renderCaptureControls(),
    search: renderSearch(),
    library: renderLibrary(),
    meetings: renderMeetings(),
    frames: renderFrameContext(),
    developer: renderDeveloper(),
  };

  root.innerHTML = `
    <div class="shell">
      ${renderHero()}
      ${renderNotices()}
      <div class="workspace">
        ${renderRail()}
        <main class="stack">
          ${viewMap[state.activeView]}
        </main>
      </div>
    </div>
  `;

  bindEvents();
}

function bindEvents() {
  root.querySelectorAll("[data-action]").forEach((element) => {
    element.addEventListener("click", handleAction);
  });
}

async function handleAction(event) {
  const element = event.currentTarget;
  const action = element.dataset.action;

  try {
    if (action === "focus-view") {
      state.activeView = element.dataset.view;
      render();
      return;
    }

    if (action === "refresh-all") {
      await boot();
      return;
    }

    if (action === "audio") {
      await controlAudio(element.dataset.audioAction);
      return;
    }

    if (action === "audio-device") {
      await controlAudio(element.dataset.deviceAction, element.dataset.deviceName);
      return;
    }

    if (action === "service") {
      await serviceAction(element.dataset.serviceAction);
      return;
    }

    if (action === "run-search") {
      state.search.query = document.getElementById("search-query").value;
      state.search.contentType = document.getElementById("search-type").value;
      state.search.start = document.getElementById("search-start").value;
      state.search.end = document.getElementById("search-end").value;
      state.search.limit = Number(document.getElementById("search-limit").value || 12);
      await refreshSearch();
      render();
      return;
    }

    if (action === "set-search-preset") {
      state.search.start = element.dataset.start;
      state.search.end = element.dataset.end;
      await refreshSearch();
      render();
      return;
    }

    if (action === "frame-context") {
      await loadFrameContext(element.dataset.frameId);
      render();
      return;
    }

    if (action === "library-mode") {
      state.libraryMode.scope = element.dataset.scope;
      state.libraryMode.kind = element.dataset.kind;
      await refreshLibraryItems();
      render();
      return;
    }

    if (action === "select-session") {
      state.libraryMode.date = element.dataset.date;
      if (state.libraryMode.scope !== "all") {
        await refreshLibraryItems();
      }
      render();
      return;
    }

    if (action === "refresh-meetings") {
      await refreshMeetings();
      render();
      return;
    }

    if (action === "select-meeting") {
      await selectMeeting(Number(element.dataset.meetingId));
      render();
      return;
    }

    if (action === "run-activity") {
      state.activity.start = document.getElementById("activity-start").value;
      state.activity.end = document.getElementById("activity-end").value;
      state.activity.appName = document.getElementById("activity-app").value;
      await refreshActivity();
      render();
      return;
    }

    if (action === "run-console") {
      state.consoleMethod = document.getElementById("console-method").value;
      state.consolePath = document.getElementById("console-path").value;
      state.consoleBody = document.getElementById("console-body").value;
      await runConsole();
      render();
      return;
    }

    if (action === "console-preset") {
      state.consoleMethod = element.dataset.consoleMethod;
      state.consolePath = element.dataset.consolePath;
      state.consoleBody = "";
      await runConsole();
      render();
    }
  } catch (error) {
    pushNotice(error.message || String(error), "bad");
    render();
  }
}

async function boot() {
  try {
    await refreshOverview();
  } catch (error) {
    pushNotice(error.message || String(error), "bad");
  }

  try {
    await refreshLibraryItems();
  } catch (error) {
    pushNotice(error.message || String(error), "warn");
  }

  try {
    await refreshSearch();
  } catch (error) {
    pushNotice(error.message || String(error), "warn");
  }

  try {
    await refreshActivity();
  } catch (error) {
    pushNotice(error.message || String(error), "warn");
  }

  try {
    await refreshMeetings();
  } catch (error) {
    pushNotice(error.message || String(error), "warn");
  }

  render();
}

boot();
