$env.STARSHIP_CONFIG = ($env.HOME | path join ".config" "nushell" "starship-nu.toml")
mkdir ~/.cache/starship
starship init nu | save -f ~/.cache/starship/init.nu

zoxide init nushell | save -f ~/.cache/zoxide.nu

$env.ATUIN_CONFIG_DIR = ($env.HOME | path join ".config" "atuin")
atuin init nu | save -f ~/.cache/atuin.nu

carapace _carapace nushell | save --force ~/.cache/carapace.nu

# Rustup (keg-only Homebrew formula)
$env.PATH = ($env.PATH | prepend "/opt/homebrew/opt/rustup/bin")

# Cargo binaries (created by rustup install)
let cargo_env = ($env.HOME | path join ".cargo" "env.nu")
if ($cargo_env | path exists) { source $cargo_env }
