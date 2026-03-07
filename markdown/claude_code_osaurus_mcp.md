
# How to Connect Claude Code to Osaurus MCP

If you want to use **[Claude Code](https://code.claude.com/docs/en/overview)** together with **[Osaurus](https://github.com/osaurus-ai/osaurus)**, there are two different pieces to understand:

![claude_code_osaurus_mcp_qwen3](https://raw.githubusercontent.com/ebal/ebal.github.io/main/img/claude_code_osaurus_mcp_qwen3.png)

1. **Model backend** — the LLM that answers your prompts
2. **MCP tools** — the tools Claude Code can call

This is the most important idea:

* **Osaurus MCP** gives Claude Code access to tools
* **Osaurus API** can also be used as the model backend, if your setup supports it

These are separate.

## Install Claude Code and Osaurus

Let's start by installing both tools via homebrew on a macbook.

> Disclaimer: I like asaurus because it's small and amazing, I find Ollama big and ugly in macbook.

### claude code installation

```bash
brew install --cask claude-code
```

### osaurus

```bash
brew install --cask osaurus
```

Open `osaurus ui` to **setup** osaurus, in this blog post we will not cover this.

#### language models

At some point you will download a couple LLMs or SLMs to start with osaurus and you should already have install some tools.

	curl -s http://localhost:1337/v1/models | jq .

```json
{
  "data": [
    {
      "id": "llama-3.2-3b-instruct-4bit",
      "created": 1772877371,
      "object": "model",
      "owned_by": "osaurus",
      "root": "llama-3.2-3b-instruct-4bit"
    },
    {
      "id": "qwen3-vl-4b-instruct-8bit",
      "created": 1772877371,
      "object": "model",
      "owned_by": "osaurus",
      "root": "qwen3-vl-4b-instruct-8bit"
    },
    {
      "id": "qwen3.5-0.8b-mlx-4bit",
      "created": 1772877371,
      "object": "model",
      "owned_by": "osaurus",
      "root": "qwen3.5-0.8b-mlx-4bit"
    }
  ],
  "object": "list"
}
```

#### status

```bash
❯ osaurus status
running (port 1337)
```

#### tools 

```bash
❯ osaurus tools list
osaurus.browser  version=1.2.0
osaurus.fetch  version=1.0.2
osaurus.filesystem  version=1.0.3
osaurus.git  version=1.0.3
osaurus.images  version=1.0.3
osaurus.macos-use  version=1.2.1
osaurus.search  version=1.0.4
osaurus.time  version=1.0.3
osaurus.vision  version=1.0.1
```

## Connect Claude Code to Osaurus via a MCP server

So by default claude code with autostart an interactive configuration setup to connect with your anthropic subscription or with any major ai subscription. We want to override this behaviour to enable claude to connect with osaurus. best way to do that is via an mcp server.

Create `~/.claude.json`:

```bash
cat > ~/.claude.json <<EOF
{
  "theme": "dark-daltonized",
  "hasCompletedOnboarding": true,
  "mcpServers": {
    "osaurus": {
      "command": "osaurus",
      "args": [
        "mcp"
      ]
    }
  }
}
EOF
```

This tells Claude Code to start Osaurus as an MCP server.

> **Note on `hasCompletedOnboarding`:** Setting this to `true` prevents a startup error where Claude Code tries to connect to Anthropic's servers before your local endpoint is configured. It is not required for the MCP setup itself, but it avoids a confusing first-run failure.

> **Note on MCP config location:** MCP servers must be defined in `~/.claude.json` (or a project-local `.mcp.json`). Placing them in `~/.claude/settings.json` will not work — that file is for environment variables and permissions, not MCP server definitions.

### Configure Claude Code to use Osaurus as the model endpoint

Create `~/.claude/settings.json`:

```bash
mkdir -p ~/.claude/

cat > ~/.claude/settings.json <<EOF
{
  "env": {
    "ANTHROPIC_BASE_URL": "http://127.0.0.1:1337",
    "ANTHROPIC_AUTH_TOKEN": "osaurus",
    "ANTHROPIC_MODEL": "qwen3-vl-4b-instruct-8bit"
  }
}
EOF
```

This does three things:

* points Claude Code to your local Osaurus server
* authenticates with the local Osaurus endpoint using a static token
* selects the model to use

> **Note on `ANTHROPIC_MODEL` vs `ANTHROPIC_DEFAULT_SONNET_MODEL`:** `ANTHROPIC_MODEL` sets the model directly and is the simpler choice when Osaurus exposes a single model. `ANTHROPIC_DEFAULT_SONNET_MODEL` overrides only the model Claude Code uses when it internally requests a "sonnet"-class model — useful if you want different models for different internal roles, but unnecessary for a basic local setup.

and 

> Claude Code requires custom auth token values to be explicitly approved. **ANTHROPIC_AUTH_TOKEN** is for that

Without this, Claude Code may still prompt for authentication even though your token is set.

## Start Claude Code

Run:

```bash
claude
```

Inside Claude Code, you can check your setup with:

```text
/status
```

![claude code status with osaurus mcp](https://raw.githubusercontent.com/ebal/ebal.github.io/main/img/claude_code_status_osaurus_mcp.png)

## Simple mental model

Think of it like this:

* **Model** = the brain
* **MCP** = the toolbox

Changing the model does **not** remove the tools.

---

That is enough to get started.

