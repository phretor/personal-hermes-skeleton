# Docker helpers for running Hermes in a sandboxed container.
#
# .devcontainer/devcontainer.json is the source of truth for the container
# workspace/user/mount layout. Keep the docker run mounts below aligned with it.
#
# All Hermes agent state (.hermes/) and tool config (.config/gws/) lives inside
# .devcontainer/persist-home/, which is bind-mounted as /opt/data.
#
# Layout inside the container:
#   /data       — Notes vault and Hermes's CWD (bind-mounted from $PWD on host)
#   /workspace  — persistent scratch area (bind-mounted from persist-workspace)
#   /opt/data   — persistent agent state (bind-mounted from persist-home)
#
# The base nousresearch/hermes-agent image uses s6-overlay as its ENTRYPOINT
# (`/init ...`). Do not pass Docker's `--init`: it inserts tini as PID 1,
# pushes s6's `/init` down to PID 2, and s6 exits with
# `s6-overlay-suexec: fatal: can only run as pid 1`.
#
# Common flow:
#   just build          # build the image
#   just hermes         # start or reattach to hermes (idempotent, via tmux)
#   just browser-setup  # one-time: download Chrome for agent-browser

set dotenv-load := true

image := "hermes-sandbox"
container := "hermes-agent"
dockerfile := ".devcontainer/Dockerfile"
persist_home := ".devcontainer/persist-home"
persist_workspace := ".devcontainer/persist-workspace"
host_uid := `id -u`
host_gid := `id -g`

# Show available recipes.
default:
    @just --list

# Build the sandbox image.
build:
    docker build \
        --build-arg USER_UID={{host_uid}} \
        --build-arg USER_GID={{host_gid}} \
        -t {{image}} -f {{dockerfile}} .

# Rebuild the sandbox image without Docker layer cache.
rebuild:
    docker build --no-cache \
        --build-arg USER_UID={{host_uid}} \
        --build-arg USER_GID={{host_gid}} \
        -t {{image}} -f {{dockerfile}} .

# Start the always-running agent container.
start: build
    @test -s "{{persist_home}}/.hermes/.env" || echo "⚠  {{persist_home}}/.hermes/.env is empty — seed your provider creds before 'just hermes'"
    @docker rm -f {{container}} >/dev/null 2>&1 || true
    docker run -d \
        --name {{container}} \
        --user {{host_uid}}:{{host_gid}} \
        --mount type=bind,src="$PWD",dst=/data \
        --mount type=bind,src="$PWD/{{persist_home}}",dst=/opt/data \
        --mount type=bind,src="$PWD/{{persist_workspace}}",dst=/workspace \
        {{image}} \
        sleep infinity

# Stop and remove the agent container.
stop:
    @docker rm -f {{container}} >/dev/null 2>&1 || true

# Restart the agent container.
restart: stop start

# Show the agent container status.
ps:
    @docker ps -a --filter name=^/{{container}}$

# Tail the agent container logs.
logs:
    docker logs -f {{container}}

# Start or reattach to hermes inside the container (idempotent).
hermes *args:
    @docker ps -q --filter name=^/{{container}}$ --filter status=running | grep -q . || just start
    @docker exec {{container}} tmux has-session -t hermes 2>/dev/null \
        && docker exec -it {{container}} tmux attach -t hermes \
        || docker exec -it {{container}} tmux new -s hermes 'hermes {{args}}'

# Shell into the agent container.
shell:
    @docker ps -q --filter name=^/{{container}}$ --filter status=running | grep -q . || just start
    docker exec -it {{container}} bash

# Shell into the agent container as root.
root-shell:
    @docker ps -q --filter name=^/{{container}}$ --filter status=running | grep -q . || just start
    docker exec -u root -it {{container}} bash

# One-time: download Chrome for agent-browser (persists in persist-home).
browser-setup:
    @docker ps -q --filter name=^/{{container}}$ --filter status=running | grep -q . || just start
    docker exec {{container}} agent-browser install

# Remove the agent container and sandbox image.
clean: stop
    @docker rmi {{image}} >/dev/null 2>&1 || true
