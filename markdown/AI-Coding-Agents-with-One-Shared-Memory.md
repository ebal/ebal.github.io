# AI Coding Agents with One Shared Memory

coding agents are useful, but they forget. I've find it from time and time to either repeat my self or creating skills to reuse them. But I also use multiple agents and on different machines too which is also complicated. I was looking for a way to keep a common memory to my agents. And built my services and setup without ... forgeting !

This guide shows a simple MVP setup for giving your AI coding agents one shared memory system.

![coding agents talk to MCP](https://raw.githubusercontent.com/ebal/ebal.github.io/main/img/basic-memory.png)

---

## What we are building

I will be using **Basic Memory** as the memory service and connect agents through MCP, running it with docker compose using the official image.

> Model Context Protocol (MCP) is an open standard introduced by Anthropic in November 2024 that enables AI agents and large language models (LLMs) to securely connect with external tools, data sources, and services

One agent writes a note, any agent — in any later session — can retrieve it back. You can also open the same files yourself, since they are just Markdown files on disk.So basic memory becomes a shared notebook for your coding agents.

---

## What you need

You need:

- Docker
- Docker Compose
- Git (optional)
- A terminal
- One coding agent with MCP support

No model provider API key needed here. Basic Memory's default semantic search runs on local FastEmbed embeddings.

Official docs:

- Basic Memory repo: https://github.com/basicmachines-co/basic-memory
- Basic Memory docs: https://docs.basicmemory.com/
- Basic Memory Docker guide: https://github.com/basicmachines-co/basic-memory/blob/main/docs/Docker.md

---

## Why no model provider is needed

Some memory systems have an LLM read your conversation and extract facts before storing anything - every save costs a model call, and you need a provider API key for that.

Basic Memory skips this. The agent (or you) writes structured Markdown directly:

```markdown
---
title: Testing Conventions
permalink: testing-conventions
tags: [testing]
---

# Testing Conventions

## Observations
- [tool] Use Vitest instead of Jest
- [rule] Do not edit generated files

## Relations
- relates_to [[Project Architecture]]
```

Observations, Relations, done. A local SQLite index gives full-text and semantic search over these files, no cloud calls.

---

## Step 1: Start Basic Memory with Docker Compose

> Default install is `uv tool install basic-memory` (or `uvx basic-memory mcp`), a stdio MCP server per agent - no Docker needed. I wanted one server for all my agents, so Docker it is.

The pre-built image runs as UID/GID 1000, so create and own the folders first:

```bash
mkdir -p knowledge basic-memory-config
sudo chown -R 1000:1000 knowledge basic-memory-config
```

### docker compose

`docker-compose.yml`

```yaml
name: basic-memory

# runs the MCP server over SSE/HTTP on :8000 - no auth on that endpoint.
# keep it on a trusted network, or put a reverse proxy + auth in front of it.

services:
  basic-memory:
    image: ghcr.io/basicmachines-co/basic-memory:latest
    container_name: basic-memory-server

    volumes:
      - ./knowledge:/app/data:rw
      # config + sqlite index, container user is appuser -> /home/appuser
      - ./basic-memory-config:/home/appuser/.basic-memory:rw

    environment:
      - BASIC_MEMORY_DEFAULT_PROJECT=main
      - BASIC_MEMORY_SYNC_CHANGES=true
      - BASIC_MEMORY_LOG_LEVEL=INFO
      - BASIC_MEMORY_SYNC_DELAY=1000

    ports:
      - "8000:8000"

    command: ["basic-memory", "mcp", "--transport", "sse", "--host", "0.0.0.0", "--port", "8000"]

    restart: unless-stopped

    healthcheck:
      test: ["CMD", "basic-memory", "--version"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 30s
```

and start it:

```bash
docker compose -v up -d
```

Confirm it's healthy:

```bash
docker compose -v ps -a

# view logs
docker compose logs -f basic-memory
```

a healthy container looks like this in the logs:

```text
❯ docker compose logs -f basic-memory
basic-memory-server  | [07/06/26 09:23:04] INFO     Starting MCP server 'Basic Memory'
basic-memory-server  |                              with transport 'sse' on
basic-memory-server  |                              http://0.0.0.0:8000/mcp
basic-memory-server  | INFO:     Uvicorn running on http://0.0.0.0:8000 (Press CTRL+C to quit)
```

---

## Step 2: Confirm the project

The default project (`main`) is your `./knowledge` folder, mounted into the container at `/app/data`. To add another project pointing at a different mounted folder:

```bash
docker exec basic-memory-server basic-memory project add my-project /app/data/my-project
docker exec basic-memory-server basic-memory project list
```

Decide upfront whether you want one shared notebook across all your repos, or one project per repo — it's easier to choose now than to migrate later.

If you just want to have one shared notebook, then ignore `project add my-project` command.

---

## Step 3: Connect Claude Code

Claude Code connects over SSE, worked fine against the Dockerized server:

```bash
claude mcp add --transport sse basic-memory http://localhost:8000/mcp
```

Verify inside Claude Code:

```text
/mcp
```

Expect something like:

```text
Local MCPs (/home/<user>/.claude.json [project: <project path>])
❯ basic-memory · ✔ connected · 23 tools
```

To remove it:

```bash
claude mcp remove basic-memory
```

There's also a Claude Code plugin for session-start briefings and `/basic-memory:*` commands, optional:

```bash
claude plugin marketplace add basicmachines-co/basic-memory --sparse .claude-plugin plugins/claude-code
claude plugin install basic-memory@basicmachines-co
```

---

## OpenCode example

OpenCode has a native `"remote"` MCP type, also worked directly against the same server, no proxy. Add to `~/.config/opencode/opencode.json`:

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "basic-memory": {
      "type": "remote",
      "url": "http://localhost:8000/mcp",
      "enabled": true
    }
  }
}
```

Verify:

```bash
opencode mcp list
```

Expect:

```text
┌  MCP Servers
│
●  ✓ basic-memory connected
│      http://localhost:8000/mcp
│
└  1 server(s)
```

OpenCode's config shape for remote MCP servers might change, check their docs if it stops working: https://opencode.ai/docs/mcp-servers/

---

## Test it

Ask your connected agent, in plain language:

```text
"Create a note about our project architecture decisions."
```

A Markdown file should appear under `./knowledge` on your host in real time. Open it — you'll see the frontmatter, an Observations list, and a Relations list. That's the entire format.

Then start a **fresh session** (or switch agents) and ask:

```text
Retrieve all notes from basic-memory
```

If the agent surfaces what you saved earlier, memory is working end to end. In practice it looks like this:

---

## What to put in memory

Good:

* Project conventions
* Folder structure
* Testing framework
* Architecture decisions
* Things the agent should avoid

here is an example from my homepc:

```text
❯ tree knowledge/
knowledge/
└── basic-memory
    ├── conventions
    │   └── Docker Healthcheck Convention.md
    ├── projects
    │   ├── Changelog Conventions.md
    │   ├── Deployment Preferences.md
    │   ├── Git Commit Conventions.md
    │   └── README Conventions.md
    └── services
        ├── Hermes Agent.md
        ├── Port Registry.md
        ├── Port Suggestion Registry.md
        └── Service Registry.md

5 directories, 9 files
```

Bad:

do not put

* Passwords
* Private keys
* Production tokens
* Customer private data

See the Security notes near the top — treat `./knowledge` like any other sensitive project directory, and don't commit it to a public repo unless that's actually intended.

---

## Troubleshooting

Agent can't connect to the MCP server? run the proxy bridge manually and see what breaks:

```bash
uvx mcp-proxy http://localhost:8000/mcp
```

Your coding agent cannot connect to an MCP server that isn't reachable, obviously.

Notes not showing up, or search feels stale:

```bash
docker exec basic-memory-server basic-memory status
docker exec basic-memory-server basic-memory doctor
```

`doctor` checks file-vs-database consistency and rebuilds the local search index if it's out of sync.

Running multiple projects and not sure which one is active:

```bash
docker exec basic-memory-server basic-memory project list
```

---

I hope you find the article useful.

That's it !
-Evaggelos

