from pathlib import Path
import asyncio
import json
import uuid
import webbrowser
import threading
from dataclasses import dataclass
from http.server import BaseHTTPRequestHandler, HTTPServer
from typing import Any, Dict, Optional, Callable, Coroutine
from functools import wraps

from .exceptions import SuiError
from .config import (
    HITL_MAX_RETRIES,
    REQUIRED_RATIONALE,
    get_hitl_port,
    HITL_HOST as CONFIG_HOST,
)

# --- ANSI Colors ---
CYAN = "\033[0;36m"
YELLOW = "\033[1;33m"
GREEN = "\033[0;32m"
RED = "\033[0;31m"
BOLD = "\033[1m"
NC = "\033[0m"


@dataclass
class HITLResponse:
    status: str  # "APPROVED", "REJECTED", "ADJUSTED"
    payload: Optional[Any] = None
    comment: str = ""


class HITLServer(BaseHTTPRequestHandler):
    active_requests: Dict[str, Dict[str, Any]] = {}

    def log_message(self, format, *args):
        pass

    def do_GET(self):
        if self.path.startswith("/review"):
            query = self.path.split("?")[-1]
            request_id = query.split("id=")[-1]
            if request_id not in self.active_requests:
                self.send_error(404)
                return
            req = self.active_requests[request_id]
            self.send_response(200)
            self.send_header("Content-type", "text/html")
            self.end_headers()
            self.wfile.write(self._render_ui(request_id, req).encode("utf-8"))
        else:
            self.send_error(404)

    def do_POST(self):
        if self.path == "/submit":
            content_length = int(self.headers["Content-Length"])
            data = json.loads(self.rfile.read(content_length).decode("utf-8"))
            request_id = data.get("id")
            if request_id in self.active_requests:
                req = self.active_requests[request_id]
                req["result"] = HITLResponse(
                    status=data.get("status"),
                    payload=data.get("payload"),
                    comment=data.get("comment", ""),
                )
                self.send_response(200)
                self.send_header("Content-type", "application/json")
                self.end_headers()
                self.wfile.write(json.dumps({"status": "ok"}).encode("utf-8"))
                req["loop"].call_soon_threadsafe(req["event"].set)
            else:
                self.send_error(404)

    def _render_ui(self, request_id: str, req: Dict[str, Any]) -> str:
        """Renders the UI using specific or default template."""
        func_name = req["func_name"]
        template_dir = Path(__file__).parent / "template"
        template_path = template_dir / "default.html"

        try:
            with open(template_path, "r") as f:
                template = f.read()
        except Exception as e:
            return f"<html><body>Critical Error: Template {template_path.name} not found or unreadable: {e}</body></html>"

        # Safe data injection via JSON blob
        client_data = {
            "id": request_id,
            "func_name": func_name,
            "rationale": req.get("rationale", ""),
            "payload": req["payload"],
            "is_text": req.get("is_text", False),
        }

        data_json = json.dumps(client_data).replace("</script>", "<\\/script>")

        # Simple template substitution
        replacements = {
            "{{HITL_DATA_JSON}}": data_json,
            "{{FUNC_NAME}}": "ELEVATION"
            if func_name == "execute"
            else func_name.upper(),
            "{{RATIONALE}}": req.get("rationale", ""),
        }

        rendered = template
        for key, val in replacements.items():
            rendered = rendered.replace(key, str(val))

        return rendered


async def request_approval(
    func_name: str,
    payload: Any,
    is_text: bool = False,
    rationale: str = "",
) -> HITLResponse:
    if REQUIRED_RATIONALE and not rationale:
        raise SuiError(f"Rationale is required for action: {func_name}")

    request_id = str(uuid.uuid4())
    event = asyncio.Event()
    loop = asyncio.get_running_loop()
    req_context = {
        "func_name": func_name,
        "payload": payload,
        "is_text": is_text,
        "rationale": rationale,
        "event": event,
        "loop": loop,
        "result": None,
    }
    HITLServer.active_requests[request_id] = req_context

    host = CONFIG_HOST
    port = get_hitl_port()
    server = None
    for i in range(HITL_MAX_RETRIES):
        try:
            server = HTTPServer((host, port + i), HITLServer)
            port = port + i
            break
        except OSError:
            continue

    url = f"http://{host}:{port}/review?id={request_id}"
    print(f"\n{BOLD}🚀 [SUI] ELEVATION REVIEW REQUIRED{NC}")
    print(f"🔗 BROWSER: {url}")
    print(f"HITL_REQUIRED: {url}")

    def serve_until_done():
        while not event.is_set():
            server.handle_request()

    threading.Thread(target=serve_until_done, daemon=True).start()
    try:
        webbrowser.open(url)
    except Exception:
        pass

    await event.wait()
    response = req_context["result"]
    del HITLServer.active_requests[request_id]
    server.server_close()
    return response


def require_approval():
    def decorator(func: Callable[..., Coroutine[Any, Any, Any]]):
        @wraps(func)
        async def wrapper(self, *args, **kwargs):
            payload = kwargs.get("payload") or (args[0] if args else None)
            rationale = kwargs.get("rationale", "")
            response = await request_approval(
                func.__name__, payload, rationale=rationale
            )
            if response.status == "REJECTED":
                raise SuiError("Action rejected.")
            return await func(self, *args, **kwargs)

        return wrapper

    return decorator
