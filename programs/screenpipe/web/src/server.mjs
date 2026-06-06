import { spawnSync } from "node:child_process";
import { existsSync, readdirSync, statSync } from "node:fs";
import path from "node:path";

const root = process.env.SCREENPIPE_WEBVIEW_ROOT || path.resolve(import.meta.dir, "..");
const sourceRoot = path.join(root, "src");
const upstream = (process.env.SCREENPIPE_UPSTREAM || "http://127.0.0.1:3030").replace(/\/$/, "");
const host = process.env.SCREENPIPE_WEBVIEW_HOST || "127.0.0.1";
const port = Number(process.env.SCREENPIPE_WEBVIEW_PORT || "3031");
const dataDir = process.env.SCREENPIPE_DATA_DIR || path.join(process.env.HOME || "/tmp", ".screenpipe");
const mediaRoots = (process.env.SCREENPIPE_MEDIA_DIRS || dataDir)
  .split(":")
  .filter(Boolean)
  .map((entry) => path.resolve(entry));
const mediaScanLimit = Number(process.env.SCREENPIPE_MEDIA_SCAN_LIMIT || "700");
const allowRawSql = process.env.SCREENPIPE_ALLOW_RAW_SQL === "1";
const serviceName = process.env.SCREENPIPE_SERVICE_NAME || "screenpipe";
const webviewServiceName = process.env.SCREENPIPE_WEBVIEW_SERVICE_NAME || "screenpipe-webview";
const sessionDataRoot = path.join(dataDir, "data", "data");

const token = discoverToken();

const staticFiles = {
  "/": [path.join(sourceRoot, "index.html"), "text/html; charset=utf-8"],
  "/assets/app.js": [path.join(sourceRoot, "app.js"), "application/javascript; charset=utf-8"],
  "/assets/styles.css": [path.join(sourceRoot, "styles.css"), "text/css; charset=utf-8"],
};

function discoverToken() {
  const envToken = process.env.SCREENPIPE_LOCAL_API_KEY || process.env.SCREENPIPE_API_KEY;
  if (envToken) return envToken.trim();

  const result = spawnSync("screenpipe", ["auth", "token"], { encoding: "utf8" });
  return result.status === 0 ? result.stdout.trim() : "";
}

function json(data, status = 200) {
  return Response.json(data, { status });
}

function error(status, message, extra = {}) {
  return json({ error: message, ...extra }, status);
}

function normalizeFilePath(filePath) {
  if (!filePath) return null;
  const resolved = path.resolve(filePath);
  return mediaRoots.some((rootDir) => resolved.startsWith(rootDir)) ? resolved : null;
}

function mediaUrl(filePath) {
  return `/media?path=${encodeURIComponent(filePath)}`;
}

function getTimestampFromName(name) {
  const match = name.match(/(\d{13,})/);
  if (!match) return null;
  const value = Number(match[1]);
  if (!Number.isFinite(value)) return null;
  return new Date(value).toISOString();
}

function classifyKind(fileName) {
  const ext = path.extname(fileName).toLowerCase();
  if ([".jpg", ".jpeg", ".png", ".webp"].includes(ext)) return "image";
  if ([".mp4", ".mov", ".webm", ".mkv"].includes(ext)) return "video";
  if ([".wav", ".mp3", ".m4a", ".aac", ".flac", ".ogg"].includes(ext)) return "audio";
  return "other";
}

function collectSessionDirs() {
  if (!existsSync(sessionDataRoot)) return [];

  return readdirSync(sessionDataRoot, { withFileTypes: true })
    .filter((entry) => entry.isDirectory())
    .filter((entry) => /^\d{4}-\d{2}-\d{2}$/.test(entry.name))
    .map((entry) => path.join(sessionDataRoot, entry.name))
    .sort((a, b) => b.localeCompare(a));
}

function scanSession(dirPath) {
  const date = path.basename(dirPath);
  let imageCount = 0;
  let videoCount = 0;
  let audioCount = 0;
  let newestAt = null;
  let totalBytes = 0;
  const items = [];

  for (const entry of readdirSync(dirPath, { withFileTypes: true })) {
    if (!entry.isFile()) continue;
    const absolute = path.join(dirPath, entry.name);
    const stats = statSync(absolute);
    const kind = classifyKind(entry.name);
    if (kind === "image") imageCount += 1;
    if (kind === "video") videoCount += 1;
    if (kind === "audio") audioCount += 1;
    totalBytes += stats.size;

    const timestamp = getTimestampFromName(entry.name) || stats.mtime.toISOString();
    if (!newestAt || timestamp > newestAt) newestAt = timestamp;

    if (items.length < mediaScanLimit) {
      items.push({
        name: entry.name,
        path: absolute,
        kind,
        session: date,
        size: stats.size,
        timestamp,
        mtime: stats.mtime.toISOString(),
        url: mediaUrl(absolute),
      });
    }
  }

  items.sort((a, b) => (b.timestamp || "").localeCompare(a.timestamp || ""));

  return {
    date,
    path: dirPath,
    imageCount,
    videoCount,
    audioCount,
    totalBytes,
    newestAt,
    items,
  };
}

function buildLibraryOverview() {
  const sessions = collectSessionDirs().map(scanSession);
  const currentSession = sessions[0] || null;
  const totalImages = sessions.reduce((sum, session) => sum + session.imageCount, 0);
  const totalVideos = sessions.reduce((sum, session) => sum + session.videoCount, 0);
  const totalAudio = sessions.reduce((sum, session) => sum + session.audioCount, 0);
  const recentItems = sessions.flatMap((session) => session.items.slice(0, 24)).sort((a, b) => (b.timestamp || "").localeCompare(a.timestamp || "")).slice(0, 18);

  return {
    dataRoot: sessionDataRoot,
    sessions: sessions.map(({ items, ...rest }) => rest),
    currentSession: currentSession ? { ...currentSession, items: undefined } : null,
    totalImages,
    totalVideos,
    totalAudio,
    recentItems,
  };
}

function libraryItems({ date, kind, scope, limit }) {
  const sessions = collectSessionDirs().map(scanSession);
  const selectedSessions = scope === "all" ? sessions : sessions.filter((session) => session.date === date || (!date && session.date === sessions[0]?.date));
  return selectedSessions
    .flatMap((session) => session.items)
    .filter((item) => !kind || item.kind === kind)
    .sort((a, b) => (b.timestamp || "").localeCompare(a.timestamp || ""))
    .slice(0, limit);
}

async function proxyToUpstream(request, pathname, search = "") {
  try {
    const body = request.method === "GET" || request.method === "HEAD" ? undefined : await request.arrayBuffer();
    const headers = new Headers(request.headers);
    headers.delete("host");
    headers.delete("content-length");
    if (token) headers.set("authorization", `Bearer ${token}`);

    return await fetch(`${upstream}${pathname}${search}`, {
      method: request.method,
      headers,
      body,
    });
  } catch (caughtError) {
    return error(502, caughtError.message || "Upstream Screenpipe API is unavailable.", { upstream, pathname });
  }
}

async function upstreamJson(pathname, search = "") {
  try {
    const response = await fetch(`${upstream}${pathname}${search}`, {
      headers: token ? { authorization: `Bearer ${token}` } : {},
    });
    const text = await response.text();
    let payload;
    try {
      payload = text ? JSON.parse(text) : null;
    } catch {
      payload = text;
    }
    if (!response.ok) {
      return { ok: false, status: response.status, message: payload?.error || payload?.message || response.statusText, payload };
    }
    return { ok: true, status: response.status, payload };
  } catch (error) {
    return { ok: false, status: 502, message: error.message };
  }
}

function runService(action, target) {
  const service = target === "webview" ? webviewServiceName : serviceName;
  const result = spawnSync("systemctl", ["--user", action, `${service}.service`], { encoding: "utf8" });
  return {
    ok: result.status === 0,
    status: result.status,
    stdout: result.stdout,
    stderr: result.stderr,
    service,
    action,
  };
}

const server = Bun.serve({
  hostname: host,
  port,
  async fetch(request) {
    const url = new URL(request.url);

    if (staticFiles[url.pathname]) {
      const [filePath, contentType] = staticFiles[url.pathname];
      return new Response(Bun.file(filePath), { headers: { "content-type": contentType } });
    }

    if (url.pathname === "/api/overview") {
      const [health, audioDevices, audioStatus, monitors] = await Promise.all([
        upstreamJson("/health"),
        upstreamJson("/audio/list"),
        upstreamJson("/audio/device/status"),
        upstreamJson("/vision/list"),
      ]);
      return json({
        upstream,
        tokenAvailable: Boolean(token),
        health: health.ok ? health.payload : null,
        devices: {
          audioDevices: audioDevices.ok ? audioDevices.payload : [],
          audioStatus: audioStatus.ok ? audioStatus.payload : [],
          monitors: monitors.ok ? monitors.payload : [],
        },
        upstreamStatus: health.ok
          ? { status: "online", message: "Screenpipe API reachable." }
          : { status: "offline", message: health.message || "Screenpipe API unavailable." },
        library: buildLibraryOverview(),
      });
    }

    if (url.pathname === "/api/library/overview") {
      return json(buildLibraryOverview());
    }

    if (url.pathname === "/api/library/items") {
      const kind = url.searchParams.get("kind") || "image";
      const scope = url.searchParams.get("scope") || "session";
      const date = url.searchParams.get("date") || "";
      const limit = Number(url.searchParams.get("limit") || "80");
      return json({ items: libraryItems({ date, kind, scope, limit }) });
    }

    if (url.pathname === "/media") {
      const requestedPath = normalizeFilePath(url.searchParams.get("path"));
      if (!requestedPath || !existsSync(requestedPath)) {
        return error(404, "File not found or outside allowed media roots.", { roots: mediaRoots });
      }
      return new Response(Bun.file(requestedPath));
    }

    if (url.pathname === "/api/service" && request.method === "POST") {
      const body = await request.json();
      return json(runService(body.action || "restart", body.service || "screenpipe"));
    }

    if (url.pathname.startsWith("/api/proxy")) {
      const upstreamPath = url.pathname.replace("/api/proxy", "") || "/";
      if (!allowRawSql && upstreamPath.startsWith("/raw_sql")) {
        return error(403, "Raw SQL proxying is disabled in this webview.");
      }
      return proxyToUpstream(request, upstreamPath, url.search);
    }

    const passthroughRoutes = {
      "/api/health": "/health",
      "/api/search": "/search",
      "/api/activity-summary": "/activity-summary",
      "/api/meetings": "/meetings",
      "/api/audio/start": "/audio/start",
      "/api/audio/stop": "/audio/stop",
      "/api/audio/device/start": "/audio/device/start",
      "/api/audio/device/stop": "/audio/device/stop",
      "/api/audio/device/status": "/audio/device/status",
      "/api/openapi.yaml": "/openapi.yaml",
    };

    if (passthroughRoutes[url.pathname]) {
      return proxyToUpstream(request, passthroughRoutes[url.pathname], url.search);
    }

    const meetingMatch = url.pathname.match(/^\/api\/meetings\/(\d+)(\/transcript)?$/);
    if (meetingMatch) {
      const [, meetingId, transcript] = meetingMatch;
      return proxyToUpstream(request, transcript ? `/meetings/${meetingId}/transcript` : `/meetings/${meetingId}`, url.search);
    }

    const frameMatch = url.pathname.match(/^\/api\/frames\/(\d+)\/context$/);
    if (frameMatch) {
      return proxyToUpstream(request, `/frames/${frameMatch[1]}/context`, url.search);
    }

    return error(404, "Unknown route.", { pathname: url.pathname });
  },
});

console.log(`screenpipe webview listening on http://${host}:${port}`);
console.log(`upstream: ${upstream}`);
console.log(`data root: ${sessionDataRoot}`);
console.log(`token available: ${token ? "yes" : "no"}`);
