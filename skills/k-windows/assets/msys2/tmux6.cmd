@echo off
REM tmux6 — lance tmux SUR deep-pc6 (authentification par cle SSH)
REM Usage : tmux6 ls              (liste les sessions distantes)
REM         tmux6 attach          (attache la session par defaut)
REM         tmux6 attach -t foo  (attache une session nommee)
REM         tmux6 new             (cree une nouvelle session)
REM         tmux6 kill-server     (tue le serveur tmux distant)
REM
REM La cle SSH (id_ed25519_deep_pc6) evite toute demande de mot de passe.
REM -tt force le TTY (necessaire pour tmux attach).
REM BatchMode=yes = ne jamais demander de mot de passe (mode degrade = echec)
ssh -o BatchMode=yes -tt deep-pc6 "tmux %*"
