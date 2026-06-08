# Sandbox Hermes inside a container while mounting a persisted project-local
# home, a persisted project-local scratch workspace, and the host notes folder
# as the data dir.
#
# Build:
#   docker build \
#     --build-arg USER_UID="$(id -u)" \
#     --build-arg USER_GID="$(id -g)" \
#     -t hermes-sandbox -f .devcontainer/Dockerfile .
# Run from the Notes folder on the host:
#   docker run --rm -it \
#     --user "$(id -u):$(id -g)" \
#     --mount type=bind,src="$PWD/.devcontainer/persist-home",dst=/opt/data \
#     --mount type=bind,src="$PWD/.devcontainer/persist-workspace",dst=/workspace \
#     --mount type=bind,src="$PWD",dst=/data \
#     hermes-sandbox
#
# Binaries-vs-state split: every tool (hermes, gws, yt-dlp, uv, plaid-cli,
# chromium, ...) is installed into the image at /opt/* or /usr/local/*.
# Nothing tool-binary lives under /home/hermes — that path is bind-mounted at
# runtime from .devcontainer/persist-home/ and would shadow anything baked
# there. The bind mount carries only state: auth tokens, browser profiles,
# caches, configs, the .hermes/ runtime directory.

FROM nousresearch/hermes-agent:latest

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG GWS_VERSION=0.22.5
ARG YTDLP_VERSION=2026.03.17
ARG UV_VERSION=0.11.16
ARG PLAID_CLI_VERSION=v0.0.6
ARG USER_UID=1000
ARG USER_GID=${USER_UID}
ARG TZ=America/Los_Angeles
ENV TZ=${TZ}

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ffmpeg \
        jq \
        less \
        tzdata \
        libasound2 \
        libatk-bridge2.0-0 \
        libcups2 \
        libdrm2 \
        libgbm1 \
        libnspr4 \
        libnss3 \
        libxcomposite1 \
        libxdamage1 \
        libxfixes3 \
        libxkbcommon0 \
        libxrandr2 \
        openssh-client \
        poppler-utils \
        procps \
        python3 \
        python3-venv \
        python3-pip \
        python-is-python3 \
        qpdf \
        git \
        make \
        ripgrep \
        tmux \
        ca-certificates \
        curl \
    && rm -rf /var/lib/apt/lists/* \
    && ln -snf "/usr/share/zoneinfo/${TZ}" /etc/localtime \
    && echo "${TZ}" > /etc/timezone

RUN set -eux; \
    arch="$(dpkg --print-architecture)"; \
    case "${arch}" in \
        amd64) go_arch="amd64" ;; \
        arm64) go_arch="arm64" ;; \
        *) echo "Unsupported architecture: ${arch}" >&2; exit 1 ;; \
    esac; \
    curl -fsSL "https://go.dev/dl/go1.25.0.linux-${go_arch}.tar.gz" \
        | tar -C /usr/local -xz

ENV PATH="${PATH}:/usr/local/go/bin"

# Node-side CLIs. Pi removed; agent-browser + snaptrade-cli kept.
RUN npm install -g npm@latest && \
    npm install -g @snaptrade/snaptrade-cli

RUN set -eux; \
    arch="$(dpkg --print-architecture)"; \
    case "${arch}" in \
        amd64) gws_arch="x86_64" ;; \
        arm64) gws_arch="aarch64" ;; \
        *) echo "Unsupported architecture: ${arch}" >&2; exit 1 ;; \
    esac; \
    tmpdir="$(mktemp -d)"; \
    git clone https://github.com/bpauli/gccli.git "${tmpdir}/gccli"; \
    cd "${tmpdir}/gccli"; \
    make build; \
    ./bin/gccli --help; \
    install -m 0755 "${tmpdir}/gccli/bin/gccli" /usr/local/bin/gccli; \
    cd "${tmpdir}"; \
    gws_file="google-workspace-cli-${gws_arch}-unknown-linux-musl.tar.gz"; \
    curl -fsSL \
        "https://github.com/googleworkspace/cli/releases/download/v${GWS_VERSION}/${gws_file}" \
        -o "${tmpdir}/${gws_file}"; \
    curl -fsSL \
        "https://github.com/googleworkspace/cli/releases/download/v${GWS_VERSION}/${gws_file}.sha256" \
        -o "${tmpdir}/${gws_file}.sha256"; \
    sha256sum -c "${gws_file}.sha256"; \
    tar -xzf "${gws_file}" ./gws; \
    install -m 0755 ./gws /usr/local/bin/gws; \
    ytdlp_file="yt-dlp_linux"; \
    [ "${arch}" = "arm64" ] && ytdlp_file="yt-dlp_linux_aarch64"; \
    curl -fsSL \
        "https://github.com/yt-dlp/yt-dlp/releases/download/${YTDLP_VERSION}/${ytdlp_file}" \
        -o "${tmpdir}/${ytdlp_file}"; \
    curl -fsSL \
        "https://github.com/yt-dlp/yt-dlp/releases/download/${YTDLP_VERSION}/SHA2-256SUMS" \
        -o "${tmpdir}/yt-dlp-SHA2-256SUMS"; \
    grep " ${ytdlp_file}$" yt-dlp-SHA2-256SUMS | sha256sum -c -; \
    install -m 0755 "${tmpdir}/${ytdlp_file}" /usr/local/bin/yt-dlp; \
    yt-dlp --version; \
    uv_arch="x86_64"; \
    [ "${arch}" = "arm64" ] && uv_arch="aarch64"; \
    uv_file="uv-${uv_arch}-unknown-linux-gnu.tar.gz"; \
    curl -fsSL \
        "https://github.com/astral-sh/uv/releases/download/${UV_VERSION}/${uv_file}" \
        -o "${tmpdir}/${uv_file}"; \
    curl -fsSL \
        "https://github.com/astral-sh/uv/releases/download/${UV_VERSION}/${uv_file}.sha256" \
        -o "${tmpdir}/${uv_file}.sha256"; \
    sha256sum -c "${uv_file}.sha256"; \
    tar -xzf "${uv_file}" \
        "uv-${uv_arch}-unknown-linux-gnu/uv" \
        "uv-${uv_arch}-unknown-linux-gnu/uvx"; \
    install -m 0755 "uv-${uv_arch}-unknown-linux-gnu/uv" /usr/local/bin/uv; \
    install -m 0755 "uv-${uv_arch}-unknown-linux-gnu/uvx" /usr/local/bin/uvx; \
    uv --version; \
    rm -rf "${tmpdir}"

RUN GOBIN=/usr/local/bin go install "github.com/landakram/plaid-cli@${PLAID_CLI_VERSION}"; \
    plaid-cli --help >/dev/null 2>&1 || plaid-cli --version 2>&1 | head -3 || true; \
    test -x /usr/local/bin/plaid-cli

# ---------- User ----------
RUN set -eux; \
    mkdir -p /data /workspace /opt/data /home/hermes; \
    groupmod -o -g "${USER_GID}" hermes; \
    usermod -o -u "${USER_UID}" -g "${USER_GID}" --shell /bin/bash hermes; \
    chown -R "${USER_UID}:${USER_GID}" /data /workspace /opt/data /home/hermes

ENV SHELL=/bin/bash
WORKDIR /data
USER hermes

# Persistent-container model: `just start` keeps the container alive, you
# `just hermes` / `just shell` to attach. No interactive CMD here.
CMD ["sleep", "infinity"]
