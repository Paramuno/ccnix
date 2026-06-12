{ pkgs, ... }:

{
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "opencode" ''
      export PATH="${pkgs.nodejs}/bin:$PATH"
      if [ -n "$DEEPSEEK_API_KEY" ]; then
        export OPENCODE_DEEPSEEK_API_KEY="$DEEPSEEK_API_KEY"
      fi
      exec npx opencode-ai@latest "$@"
    '')
  ];
}
