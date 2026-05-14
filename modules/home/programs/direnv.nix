{ inputs, ... }:
{
  flake.homeModules.direnv = {
    imports = [
      inputs.direnv-instant.homeModules.direnv-instant
    ];

    programs.direnv-instant.enable = true;

    programs.direnv = {
      enable = true;
      silent = true;
      enableZshIntegration = false;
      nix-direnv.enable = true;
      stdlib = ''
        layout_uv() {
            if [[ -d ".venv" ]]; then
                VIRTUAL_ENV="$(pwd)/.venv"
            fi

            if [[ -z $VIRTUAL_ENV || ! -d $VIRTUAL_ENV ]]; then
                log_status "No virtual environment exists. Executing \`uv venv\` to create one."
                uv venv
                VIRTUAL_ENV="$(pwd)/.venv"
            fi

            PATH_add "$VIRTUAL_ENV/bin"
            export UV_ACTIVE=1  # or VENV_ACTIVE=1
            export VIRTUAL_ENV
        }
      '';
    };
  };
}
