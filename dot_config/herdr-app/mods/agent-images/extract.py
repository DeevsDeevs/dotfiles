# Lists the images in an agent's conversation: Claude Code, Codex or pi.
# argv[1]: JSON {pid, argv, cwd, have: [hash, ...]}.
# Prints JSON {transcript, images: [{h, mime, who, at, data?}]}; data only for hashes not in `have`.
import base64
import glob
import hashlib
import json
import os
import subprocess
import sys

HOME = os.path.expanduser("~")
TOOL_TYPES = {"tool_result", "function_call_output", "custom_tool_call_output"}


def tree(root):
    out = subprocess.run(["ps", "-A", "-o", "pid=,ppid="], capture_output=True, text=True).stdout
    kids = {}
    for row in out.splitlines():
        parts = row.split()
        if len(parts) == 2:
            kids.setdefault(int(parts[1]), []).append(int(parts[0]))
    pids, todo = [], [root]
    while todo:
        p = todo.pop()
        pids.append(p)
        todo.extend(kids.get(p, []))
    return pids


def open_jsonl(pids):
    if os.path.isdir("/proc"):
        for p in pids:
            for fd in glob.glob(f"/proc/{p}/fd/*"):
                try:
                    path = os.readlink(fd)
                except OSError:
                    continue
                if path.endswith(".jsonl"):
                    yield path
    else:
        out = subprocess.run(["lsof", "-Fn", "-p", ",".join(map(str, pids))], capture_output=True, text=True).stdout
        for row in out.splitlines():
            if row.startswith("n") and row.endswith(".jsonl"):
                yield row[1:]


def newest(pattern):
    files = glob.glob(pattern)
    return max(files, key=os.path.getmtime) if files else None


def find_transcript(pid, argv, cwd):
    pids = tree(pid) if pid else []
    for p in pids:
        try:
            sid = json.load(open(f"{HOME}/.claude/sessions/{p}.json"))["sessionId"]
        except (OSError, ValueError, KeyError):
            continue
        hit = glob.glob(f"{HOME}/.claude/projects/*/{sid}.jsonl")
        if hit:
            return hit[0]
    for path in open_jsonl(pids):
        if "/.codex/sessions/" in path or "/.pi/agent/sessions/" in path or "/.claude/projects/" in path:
            return path
    if "--session" in argv:
        path = os.path.expanduser(argv[argv.index("--session") + 1])
        if os.path.isfile(path):
            return path
    # pi appends without keeping the file open: its newest session for this folder.
    name = os.path.basename(argv[0]) if argv else ""
    if name == "pi" and cwd:
        return newest(f"{HOME}/.pi/agent/sessions/--{cwd.strip('/').replace('/', '-')}--/*.jsonl")
    return None


def images(o, who):
    if isinstance(o, list):
        for v in o:
            yield from images(v, who)
        return
    if not isinstance(o, dict):
        return
    kind = o.get("type")
    role = o.get("role")
    if role == "user":
        who = "you"
    elif role in ("toolResult", "tool") or kind in TOOL_TYPES:
        who = "tool"
    if kind == "image":
        src = o.get("source")
        if isinstance(src, dict) and src.get("type") == "base64" and isinstance(src.get("data"), str):
            yield src.get("media_type") or "image/png", src["data"], who
            return
        if isinstance(o.get("data"), str):
            yield o.get("mimeType") or o.get("mime_type") or "image/png", o["data"], who
            return
    if kind == "input_image" and str(o.get("image_url", "")).startswith("data:"):
        head, _, data = o["image_url"].partition(",")
        yield head[5:].split(";")[0] or "image/png", data, who
        return
    for v in o.values():
        if isinstance(v, (dict, list)):
            yield from images(v, who)


def size(data):
    # PNG IHDR or a JPEG SOF marker; the header sits in the first bytes, so decode only those.
    b = base64.b64decode(data[:262144] + "=" * (-min(len(data), 262144) % 4), validate=False)
    if b[:8] == b"\x89PNG\r\n\x1a\n":
        return int.from_bytes(b[16:20], "big"), int.from_bytes(b[20:24], "big")
    i = 2
    while b[:2] == b"\xff\xd8" and i + 9 < len(b):
        if b[i] != 0xFF:
            i += 1
            continue
        marker = b[i + 1]
        if marker in (0xC0, 0xC1, 0xC2):
            return int.from_bytes(b[i + 7:i + 9], "big"), int.from_bytes(b[i + 5:i + 7], "big")
        i += 2 + int.from_bytes(b[i + 2:i + 4], "big")
    return None, None


def main():
    req = json.loads(sys.argv[1])
    have = set(req.get("have") or [])
    path = find_transcript(req.get("pid"), req.get("argv") or [], req.get("cwd"))
    found, seen = [], set()
    if path:
        with open(path, errors="replace") as f:
            for line in f:
                if '"image' not in line:
                    continue
                try:
                    d = json.loads(line)
                except ValueError:
                    continue
                # Claude Code repeats each request's images in api-request-blob lines.
                if d.get("type") == "api-request-blob":
                    continue
                start = "you" if d.get("type") in ("user", "attachment") else "tool"
                for mime, data, who in images(d, start):
                    h = hashlib.sha1(data.encode()).hexdigest()[:16]
                    if h in seen:
                        continue
                    seen.add(h)
                    w, ht = size(data)
                    item = {"h": h, "mime": mime, "who": who, "at": d.get("timestamp"), "w": w, "ht": ht}
                    if h not in have:
                        item["data"] = data
                    found.append(item)
    json.dump({"transcript": path, "images": found}, sys.stdout)


if __name__ == "__main__":
    main()
