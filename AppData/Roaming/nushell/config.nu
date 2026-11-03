# config.nu
#
# Installed by:
# version = "0.107.0"
#
# This file is used to override default Nushell settings, define
# (or import) custom commands, or run any other startup tasks.
# See https://www.nushell.sh/book/configuration.html
#
# Nushell sets "sensible defaults" for most configuration settings, 
# so your `config.nu` only needs to override these defaults if desired.
#
# You can open this file in your default editor using:
#     config nu
#
# You can also pretty-print and page through the documentation for configuration
# options using:
#     config nu --doc | nu-highlight | less -R

mkdir ($nu.data-dir | path join "vendor/autoload")
starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")

$env.config.buffer_editor = "nvim"

# Nushell's built-in `start` percent-encodes non-ASCII Windows paths before
# passing them to cmd.exe. Use PowerShell's ShellExecute path instead.
alias nu-start = start
def start [target: string] {
  ^pwsh.exe -NoProfile -ExecutionPolicy Bypass -File 'C:\Users\kawasaki\powershell_scripts\nu-start.ps1' $target
}

# Keep the original structured `ls` available for scripts and pipelines.
alias core-ls = ls

# Display file names as explicit nuopen links. The Windows protocol handler
# decodes Japanese and other non-ASCII paths before opening them.
def ls [
  --all (-a),
  --long (-l),
  --short-names (-s),
  --full-paths (-f),
  --du (-d),
  --directory (-D),
  --mime-type (-m),
  --threads (-t),
  ...pattern: glob,
]: [nothing -> table] {
  let patterns = if ($pattern | is-empty) { [ '.' ] } else { $pattern }

  (core-ls
    --all=$all
    --long=$long
    --short-names=$short_names
    --full-paths=$full_paths
    --du=$du
    --directory=$directory
    --mime-type=$mime_type
    --threads=$threads
    ...$patterns
  ) | each {|entry|
    let display_name = ($entry.name | into string)
    let absolute_path = ($display_name | path expand)
    let uri = $"nuopen://open?path=($absolute_path | url encode)"
    $entry | update name ($uri | ansi link --text $display_name)
  }
}

def --env cdd [dir] {
  cd ($dir)
  ls
}


# 環境に影響を与える（cdが有効になる）
def --env cdl [n] {
    let entries = (ls | enumerate)
    # $entries | each {|x| print $"($x.index + 1): ($x.item.name)" }
    # let n = (input "Enter number: " | into int)
    # let path = ($entries | where index == ($n - 1) | get item.name | first)
    let path = ($entries | where index == ($n) | get item.name | first)
    if $path != null {
        cd $path
        ls
    } else {
        print "番号が無効です"
    }
}

def ols [] {
    let selected = (
        ls
        | where type == file
        | get name
        | input list --fuzzy
    )

    if $selected != null {
        start $selected
    }
}


def mdls [] {
    ls *.md
    | each {|file|
        let fm = try {
            let lines = open --raw $file.name | lines

            if ($lines | is-not-empty) and (($lines | first) == "---") {
                let end = (
                    $lines
                    | skip 1
                    | enumerate
                    | where item == "---"
                    | first
                    | get index
                )

                $lines
                | skip 1
                | take $end
                | str join "\n"
                | from yaml
            } else {
                {}
            }
        } catch {
            {}
        }

        $file
        | merge {
            title: ($fm.title? | default "")
            status: ($fm.status? | default "")
            tags: ($fm.tags? | default [])
        }
    }
    | select name size modified title status tags
}



oh-my-posh init nu --config 'C:\Users\kawasaki\AppData\Local\omp-manager\themes\paradox.omp.json'  # [omp-manager]

use 'C:\Users\kawasaki\AppData\Roaming\dystroy\broot\config\launcher\nushell\br' *
