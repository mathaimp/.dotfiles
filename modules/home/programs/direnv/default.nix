{ options
, config
, lib
, pkgs
, inputs
, namespace
, ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.programs.direnv;
in
{
  options.${namespace}.programs.direnv = with types; {
    enable = mkBoolOpt false "Enable direnv";
  };
  config = mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      silent = true;
      enableZshIntegration = true; # see note on other shells below
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
