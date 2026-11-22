# Inventory source workflow

- Treat the live GT image as authoritative for Smalltalk source. Inspect,
  compile, execute and export through GT MCP. Never generate or edit Smalltalk
  source files with external scripts or patches.
- Never externally modify files or Git metadata in a checkout registered with a
  running GT image. Recover pending changes through GT MCP into an independent
  clean clone and verify class/method definitions against the live image before
  testing, committing and pushing. Keep GT open until recovery is verified.
- After each tested change set, commit with a very concise summary and push.
