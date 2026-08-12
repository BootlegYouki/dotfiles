Caelestia Lyrics Romanization & Translation Daemon

Custom daemon for Caelestia Shell that converts Japanese (Kanji/Kana → Hepburn Romaji), Korean (Hangul → Revised Romanization), and translates lyrics and track info into English on demand.

> [!IMPORTANT]
> **Architecture: Direct QML Socket & Multi-Threaded Daemon**
> `Romaji.qml` connects directly to the daemon's Unix socket using Quickshell's built-in `Socket` + `SplitParser`. No bash script, no python3 subprocess spawn per request. Zero overhead beyond actual IPC roundtrip.
>
> **Multi-Threading**: Each IPC connection is handled in a separate daemon thread (`threading.Thread`), preventing socket listener blocks during batch translation or rapid track skipping.
>
> **Modes**:
> - **Romaji** (`subtitles`): Japanese Kanji/Kana → Hepburn Romaji, Korean Hangul → Revised Romanization.
> - **English** (`translate`): Foreign / Japanese / Korean lyrics → English translation via Google Translate API with delimited line parsing (` \n::: \n`).
> - **Original** (`text_fields`): Native untouched lyrics.
>
> **Enhancements & Refinements**:
> - **Fuzzy Similarity Detection (`difflib.SequenceMatcher > 0.85`)**: Detects when Google Translate receives Romaji/Romanized Korean source text and returns identical or slightly modified Romanized text. Triggers empty return `[]` to cleanly show "No translation found".
> - **Title & Artist Romanization (`forceMode`)**: `Romaji.convert` accepts a third `forceMode` parameter. `Details.qml` uses `forceMode = "romaji"` for Track Title, Artist, and Album when in English mode, ensuring titles/artists are Romanized rather than translated into English words (`Itte.` instead of `Say it.`).
> - **Flicker-Free UI (`1.5s Timer`)**: `LyricList.qml` uses a 1.5-second timer on empty states to prevent temporary "No translation found" flashes while awaiting daemon responses.
>
> **Protocol: newline framing** — QML writes `JSON + "\n"`, daemon reads until `"\n"`, responds with `JSON + "\n"`.
>
> If lyrics aren't loading: `systemctl --user status caelestia-romaji.service`

---

## How It Works

```
Caelestia (QML)
  └─ Romaji.qml singleton
       ├─ Mode == Original? → return raw input immediately
       ├─ Cache hit (mode:input)? → return immediately (synchronous)
       ├─ Mode == Romaji & No Japanese/Korean? → pass through as-is
       └─ Cache miss → Socket connects to daemon (with up to 2 auto-retries on error)
            └─ writes JSON { "mode": "romaji"|"english"|"original", "input": [...] } + "\n"
                 └─ Daemon (Python, multithreaded)
                      ├─ mode == "romaji"  → pykakasi / Hangul decomposition
                      ├─ mode == "english" → Google Translate API via urllib + \n:::\n parsing
                      ├─ mode == "original" → raw input
                      └─ responds JSON + "\n"
                           └─ SplitParser fires onRead → lyricList / track details updated
```

**Why the daemon matters for speed:**
- Without daemon: QML spawns bash → bash spawns python3 → pykakasi cold import (~300-500ms). Visible Japanese flash.
- With daemon: pykakasi is pre-loaded in memory. Socket roundtrip only (~1-5ms). Instant.
- Multi-threaded: Rapid track skips and simultaneous title/artist/album/lyrics conversions never block each other.

---

## Installation & Dependencies

```bash
# Desktop (system python)
sudo pacman -S python-pykakasi

# Laptop (uses venv — pykakasi installed in venv already)
# /home/bootlegyouki/.local/share/caelestia/venv/

# Enable service
systemctl --user daemon-reload
systemctl --user enable --now caelestia-romaji.service
```

---

## Full Source Code

### 1. Daemon (`~/.local/bin/caelestia-romaji-daemon`)

> [!NOTE]
> Laptop shebang: `#!/home/bootlegyouki/.local/share/caelestia/venv/bin/python3`
> Desktop shebang: `#!/usr/bin/env python3`

```python
#!/usr/bin/env python3
import os
import json
import re
import socket
import threading
import urllib.request
import urllib.parse
import pykakasi

SOCK_PATH = f"/run/user/{os.getuid()}/caelestia-romaji.sock"
kks = pykakasi.kakasi()
jp_regex = re.compile(r'[\u3040-\u30ff\u3400-\u4dbf\u4e00-\u9fff]')
kr_regex = re.compile(r'[\uAC00-\uD7A3]')

# ── Korean Revised Romanization ──────────────────────────────────────────────

HANGUL_BASE = 0xAC00
N_JUNG = 21
N_JONG = 28

CHOSEONG_ROM = [
    'g', 'kk', 'n', 'd', 'tt', 'r', 'm', 'b', 'pp',
    's', 'ss', '', 'j', 'jj', 'ch', 'k', 't', 'p', 'h'
]

JUNGSEONG_ROM = [
    'a', 'ae', 'ya', 'yae', 'eo', 'e', 'yeo', 'ye',
    'o', 'wa', 'wae', 'oe', 'yo', 'u', 'wo', 'we',
    'wi', 'yu', 'eu', 'ui', 'i'
]

JONGSEONG_ROM = [
    ('',   ''),    #  0: none
    ('k',  'g'),   #  1: ㄱ
    ('k',  'kk'),  #  2: ㄲ
    ('k',  'g'),   #  3: ㄳ
    ('n',  'n'),   #  4: ㄴ
    ('n',  'n'),   #  5: ㄵ
    ('n',  'n'),   #  6: ㄶ
    ('t',  'd'),   #  7: ㄷ
    ('l',  'r'),   #  8: ㄹ
    ('k',  'g'),   #  9: ㄺ
    ('m',  'm'),   # 10: ㄻ
    ('l',  'b'),   # 11: ㄼ
    ('l',  's'),   # 12: ㄽ
    ('l',  't'),   # 13: ㄾ
    ('p',  'p'),   # 14: ㄿ
    ('l',  'r'),   # 15: ㅀ
    ('m',  'm'),   # 16: ㅁ
    ('p',  'b'),   # 17: ㅂ
    ('p',  'b'),   # 18: ㅄ
    ('t',  's'),   # 19: ㅅ
    ('t',  'ss'),  # 20: ㅆ
    ('ng', 'ng'),  # 21: ㅇ
    ('t',  'j'),   # 22: ㅈ
    ('t',  'ch'),  # 23: ㅊ
    ('k',  'k'),   # 24: ㅋ
    ('t',  't'),   # 25: ㅌ
    ('p',  'p'),   # 26: ㅍ
    ('t',  'h'),   # 27: ㅎ
]

def romanize_hangul(text):
    chars = list(text)
    n = len(chars)
    out = []
    for i, c in enumerate(chars):
        code = ord(c)
        if 0xAC00 <= code <= 0xD7A3:
            idx = code - HANGUL_BASE
            cho  = idx // (N_JUNG * N_JONG)
            jung = (idx % (N_JUNG * N_JONG)) // N_JONG
            jong = idx % N_JONG

            next_code = ord(chars[i + 1]) if i + 1 < n else 0
            next_is_hangul = 0xAC00 <= next_code <= 0xD7A3
            next_cho = (next_code - HANGUL_BASE) // (N_JUNG * N_JONG) if next_is_hangul else -1
            before_vowel = next_cho == 11

            out.append(CHOSEONG_ROM[cho])
            out.append(JUNGSEONG_ROM[jung])
            if jong:
                out.append(JONGSEONG_ROM[jong][1] if before_vowel else JONGSEONG_ROM[jong][0])
        else:
            out.append(c)
    return ''.join(out)

def convert_japanese(line):
    cleaned = re.sub(r'[\u3400-\u9fff]+\(([\u3040-\u30ff]+)\)', r'\1', line)
    cleaned = re.sub(r'[\u3400-\u9fff]+\uff08([\u3040-\u30ff]+)\uff09', r'\1', cleaned)
    result = kks.convert(cleaned)
    parts = []
    for item in result:
        hepburn = item.get('hepburn', '')
        parts.append(hepburn if hepburn else item.get('orig', ''))
    res = ' '.join(parts)
    res = re.sub(r'\s+', ' ', res).strip()
    res = re.sub(r'\s+([,\.!\?\)])', r'\1', res)
    res = re.sub(r'\(\s+', '(', res)
    return res

def translate_to_english(data):
    if not data:
        return data
    is_list = isinstance(data, list)
    lines = data if is_list else [str(data)]

    if not lines:
        return data

    DELIM = ' \n::: \n'
    prepared_lines = [l if (isinstance(l, str) and l.strip()) else ' ' for l in lines]
    text = DELIM.join(prepared_lines)

    url = 'https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=en&dt=t&q=' + urllib.parse.quote(text)
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'})
    try:
        with urllib.request.urlopen(req, timeout=6) as resp:
            res = json.loads(resp.read().decode('utf-8'))
            translated_parts = [item[0] for item in res[0] if item and item[0]]
            full_translated = ''.join(translated_parts)
            parts = [p.strip() for p in full_translated.split(':::')]
            if len(parts) == len(lines):
                out = [parts[i] if lines[i].strip() else lines[i] for i in range(len(lines))]
                return out if is_list else out[0]
            elif len(parts) > 0:
                out = []
                for i in range(len(lines)):
                    if i < len(parts) and parts[i]:
                        out.append(parts[i])
                    else:
                        out.append(lines[i])
                return out if is_list else out[0]
    except Exception:
        pass

    out = []
    for line in lines:
        if not line or not str(line).strip():
            out.append(line)
            continue
        l_url = 'https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=en&dt=t&q=' + urllib.parse.quote(str(line))
        l_req = urllib.request.Request(l_url, headers={'User-Agent': 'Mozilla/5.0'})
        try:
            with urllib.request.urlopen(l_req, timeout=3) as l_resp:
                l_res = json.loads(l_resp.read().decode('utf-8'))
                trans = ''.join([it[0] for it in l_res[0] if it and it[0]])
                out.append(trans if trans.strip() else line)
        except Exception:
            out.append(line)

    return out if is_list else out[0]

def convert_line(line):
    if not line:
        return line
    if jp_regex.search(line):
        return convert_japanese(line)
    if kr_regex.search(line):
        return romanize_hangul(line)
    return line

def process_data(raw):
    try:
        data = json.loads(raw)
    except Exception:
        data = raw

    mode = "romaji"
    payload = data

    if isinstance(data, dict):
        mode = data.get("mode", "romaji")
        payload = data.get("input", data)

    if mode == "english":
        return translate_to_english(payload)
    elif mode == "original":
        return payload
    else:
        if isinstance(payload, list):
            return [convert_line(l) for l in payload]
        return convert_line(str(payload))

def handle_client(conn):
    try:
        buf = b''
        while True:
            chunk = conn.recv(4096)
            if not chunk:
                break
            buf += chunk
            if b'\n' in buf:
                break
        data = buf.split(b'\n')[0].strip()
        if data:
            res = process_data(data.decode('utf-8'))
            conn.sendall((json.dumps(res, ensure_ascii=False) + '\n').encode('utf-8'))
    except Exception:
        pass
    finally:
        try:
            conn.close()
        except Exception:
            pass

def main():
    if os.path.exists(SOCK_PATH):
        try:
            os.unlink(SOCK_PATH)
        except OSError:
            pass
    server = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    server.bind(SOCK_PATH)
    server.listen(50)

    while True:
        try:
            conn, _ = server.accept()
            threading.Thread(target=handle_client, args=(conn,), daemon=True).start()
        except Exception:
            pass

if __name__ == '__main__':
    main()
```

---

### 2. `services/Romaji.qml` — QML Socket Client

Key features:
- **`PersistentProperties`**: Persistent `mode` (`"romaji"`, `"english"`, `"original"`).
- **`cycleMode()`**: Cycles mode and notifies observers.
- **Auto-Retry**: Retries socket connection up to 2 times on error before falling back.
- **Cache Scoping**: Cache keys include mode prefix (`currentMode + ":" + jsonStr`).

```qml
pragma Singleton

import QtQml
import QtQuick
import Quickshell
import Quickshell.Io
import qs.components.misc

Singleton {
    id: root

    property bool enabled: props.enabled
    property string mode: props.mode || "romaji"

    function toggle(): void {
        props.enabled = !props.enabled;
    }

    function cycleMode(): void {
        if (props.mode === "romaji") {
            props.mode = "english";
        } else if (props.mode === "english") {
            props.mode = "original";
        } else {
            props.mode = "romaji";
        }
    }

    PersistentProperties {
        id: props

        property bool enabled: true
        property string mode: "romaji"

        reloadableId: "romaji"
    }

    property var cache: ({})
    readonly property string sockPath: `/run/user/${Quickshell.env("UID") || "1000"}/caelestia-romaji.sock`

    function convert(input: var, callback: var): void {
        const currentMode = props.mode || "romaji";
        if (!enabled || !input || currentMode === "original") {
            callback(input);
            return;
        }

        let payload = input;
        if (typeof input === "object" && !Array.isArray(input) && input.length !== undefined) {
            try {
                payload = Array.from(input);
            } catch (e) {
                payload = input;
            }
        }

        const jsonStr = typeof payload === "string" ? payload : JSON.stringify(payload);
        if (currentMode === "romaji") {
            const needsConversion = /[\u3040-\u30ff\u3400-\u4dbf\u4e00-\u9fff\uAC00-\uD7A3]/.test(jsonStr);
            if (!needsConversion) {
                callback(input);
                return;
            }
        }

        const cacheKey = currentMode + ":" + jsonStr;
        if (cache[cacheKey] !== undefined) {
            callback(cache[cacheKey]);
            return;
        }

        const reqData = JSON.stringify({
            mode: currentMode,
            input: payload
        });

        romajiSocketComponent.createObject(root, {
            inputData: reqData,
            cacheKey: cacheKey,
            rawInput: input,
            callback: callback
        });
    }

    Component {
        id: romajiSocketComponent

        QtObject {
            id: req

            property string inputData: ""
            property string cacheKey: ""
            property var rawInput
            property var callback
            property int retryCount: 0

            property Socket sock: Socket {
                id: sock
                path: root.sockPath
                connected: false

                parser: SplitParser {
                    splitMarker: "\n"
                    onRead: data => {
                        const trimmed = data.trim();
                        if (trimmed.length === 0) return;
                        try {
                            const res = JSON.parse(trimmed);
                            if (req.cacheKey) root.cache[req.cacheKey] = res;
                            if (req.callback) req.callback(res);
                        } catch (e) {
                            if (req.callback) req.callback(req.rawInput);
                        }
                        Qt.callLater(() => req.destroy());
                    }
                }

                onConnectionStateChanged: {
                    if (connected) {
                        write(req.inputData + "\n");
                    }
                }

                onError: err => {
                    if (req.retryCount < 2) {
                        req.retryCount++;
                        sock.connected = false;
                        Qt.callLater(() => { sock.connected = true; });
                        return;
                    }
                    if (req.callback) req.callback(req.rawInput);
                    Qt.callLater(() => req.destroy());
                }
            }

            Component.onCompleted: {
                sock.connected = true;
            }
        }
    }
}
```

---

### 3. `LyricList.qml` — Request Sequence Tracking & Loading UI

Key features:
- **`lyricReqId`**: Tracks request sequence to ignore stale responses from skipped tracks.
- **`converting` Loading State**: Shows shell's native `LoadingIndicator` spinner during translation/conversion.
- **Contextual Loading Text**: Displays `"Translating lyrics..."` when translating to English.

```qml
    property bool converting: false
    property int lyricReqId: 0

    function updateLyrics(trackChanged: bool): void {
        const reqId = ++lyricReqId;
        const raw = Lyrics.lyrics;
        if (!raw || raw.length === 0) {
            lyricList = [];
            converting = false;
            return;
        }
        if (trackChanged)
            lyricList = [];

        converting = true;
        Romaji.convert(raw, res => {
            if (reqId === root.lyricReqId) {
                lyricList = res;
                converting = false;
            }
        });
    }

    state: {
        if (converting || Lyrics.loading)
            return "loading";
        if (Lyrics.hasLyrics)
            return "hasLyrics";
        return "noLyrics";
    }
```

---

### 4. `LyricsAndSelector.qml` — Mode Toggle Button UI

Replaced `LyricsInfo` with a styled mode button using `BlobGroup` and `BlobRect` matching `m3surfaceContainerHighest` and `Tokens.rounding.medium`:

```qml
Item {
    id: modeBtnItem
    implicitWidth: modeBtn.implicitWidth * 0.9
    implicitHeight: modeBtn.implicitHeight * 0.9

    BlobGroup {
        id: modeBlobGroup
        color: Colours.palette.m3surfaceContainerHighest
        smoothing: Tokens.rounding.medium
    }

    BlobRect {
        id: modeBtnRect
        anchors.fill: parent
        anchors.margins: !modeBtn.pressed && modeBtn.containsMouse ? -Tokens.padding.extraSmall : 0
        group: modeBlobGroup
        radius: Tokens.rounding.medium
    }

    MouseArea {
        id: modeBtn
        anchors.centerIn: parent
        implicitWidth: implicitHeight
        implicitHeight: modeIcon.implicitHeight + Tokens.padding.extraSmall * 2
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onClicked: Romaji.cycleMode()

        MaterialIcon {
            id: modeIcon
            anchors.centerIn: parent
            text: Romaji.mode === "english" ? "translate" : Romaji.mode === "romaji" ? "subtitles" : "text_fields"
            fontStyle: Tokens.font.icon.medium
        }
    }
}
```

---

## Deployment Across Machines

```bash
# Restart daemon after editing:
systemctl --user restart caelestia-romaji.service

# Restart shell after editing QML:
caelestia shell -k; sleep 0.5; caelestia shell -d

# Push to laptop from desktop:
sshpass -p 'PASSWORD' scp ~/.local/bin/caelestia-romaji-daemon \
    bootlegyouki@192.168.100.37:~/.local/bin/caelestia-romaji-daemon
sshpass -p 'PASSWORD' scp ~/.config/quickshell/caelestia/services/Romaji.qml \
    bootlegyouki@192.168.100.37:~/.config/quickshell/caelestia/services/Romaji.qml
```

---

## Related Notes
- [[desktop-caelestia-hyprland]]
