@echo off
REM ollama-server.cmd — run the ollama CLI against a remote server's Ollama
REM through a local SSH tunnel (see assets/remote-server/tunnel-server.service
REM for the tunnel side). Generic template — personalize LOCAL_PORT below (or
REM set it as an env var before calling). Part of the k-windows "remote
REM server access" family — see references/remote-server-access.md.
if "%LOCAL_PORT%"=="" set LOCAL_PORT=11435
set OLLAMA_HOST=http://127.0.0.1:%LOCAL_PORT%
ollama %*
