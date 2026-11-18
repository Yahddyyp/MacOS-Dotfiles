{ pkgs, pass-tomb-osx, ... }:
let
  pass-tomb = pass-tomb-osx.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  programs.password-store = {
    enable = true;

    package = pkgs.pass.withExtensions (exts: with exts; [
      pass-otp
      pass-audit
      pass-update
      pass-tomb
    ]);

    settings = {
      PASSWORD_STORE_EXTENSIONS_DIR = "$HOME/.local/share/pass-extensions";
      PASSWORD_STORE_ENABLE_EXTENSIONS = "true";
    };
  };

  home.file = {
    ".local/share/pass-extensions/tomb.bash" = {
       executable = true;
       text = ''
        #!/bin/bash
        exec ${pass-tomb}/bin/pass-tomb "$@"
      '';
     };

    ".local/share/pass-extensions/open.bash" = {
      executable = true;
      text = ''
        #!/bin/bash
        exec ${pass-tomb}/bin/pass-open "$@"
      '';
    };

    ".local/share/pass-extensions/close.bash" = {
      executable = true;
      text = ''
        #!/bin/bash
        exec ${pass-tomb}/bin/pass-close "$@"
      '';
    };

    ".local/share/pass-extensions/timer.bash" = {
      executable = true;
      text = ''
        #!/bin/bash
        exec ${pass-tomb}/bin/pass-timer "$@"
      '';
    };

    ".local/share/pass-extensions/rg.bash" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        set -o pipefail

        cmd_rg() {
          local -a rg_opts=()
          local pattern=""

          while [[ $# -gt 0 ]]; do
            case "$1" in
              -*)
                rg_opts+=("$1")
                ;;
              *)
                pattern="$1"
                ;;
            esac
            shift
          done

          if [[ -z "$pattern" ]]; then
            echo "Usage: $PROGRAM rg [ripgrep-options] <pattern>" >&2
            exit 1
          fi

          if ! command -v rg >/dev/null 2>&1; then
            echo "Error: ripgrep (rg) is not installed or not in PATH" >&2
            exit 1
          fi

          local file
          find "$PREFIX" -iname '*.gpg' -print0 | while IFS= read -r -d "" file; do
            local passfile="''${file%.gpg}"
            passfile="''${passfile#"$PREFIX"/}"

            local out
            out="$("$GPG" -d "''${GPG_OPTS[@]}" "$file" 2>/dev/null | rg --color=always "''${rg_opts[@]}" -- "$pattern")"

            if [[ -n "$out" ]]; then
              printf '\033[1;34m%s\033[0m:\n' "$passfile"
              echo "$out" | sed 's/^/  /'
            fi
          done
        }

        cmd_rg "$@"
      '';
    };

    ".local/share/pass-extensions/lazygit.bash" = {
      executable = true;
      text = ''
        #!/bin/bash
        set -o pipefail

        cmd_lazygit() {
          if ! command -v lazygit >/dev/null 2>&1; then
            echo "Error: lazygit is not installed or not in PATH" >&2
            exit 1
          fi

          if [[ ! -d "$PREFIX/.git" ]]; then
            echo "Error: $PREFIX is not a git repository (run 'pass git init' first baka)" >&2
            exit 1
          fi

          cd "$PREFIX" && lazygit "$@"
        }

        cmd_lazygit "$@"
      '';
    };

    
    ".local/share/pass-extensions/alias.bash" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        set -eo pipefail

        PROGRAM="''${PROGRAM:-pass}"
        CMD="$1"
        shift || true

        alias_die() {
          echo "pass-alias: $*" >&2
          exit 1
        }

        require_jq() {
          command -v jq >/dev/null || alias_die "jq is required"
        }

        get_token() {
          local provider="$1"
          cmd_show "alias-providers/''${provider}" 2>/dev/null | sed -n '1p'
        }

        cmd_alias_mailboxes() {
          require_jq
          local provider="simplelogin"

          while [[ $# -gt 0 ]]; do
            case "$1" in
              --provider)
                provider="$2"
                shift 2
                ;;
              *)
                alias_die "unknown arg: $1"
                ;;
            esac
          done

          local token
          token="$(get_token "$provider")" ||
            alias_die "no token at alias-providers/''${provider}"

          case "$provider" in
            simplelogin)
              curl -sf "https://app.simplelogin.io/api/mailboxes" \
                -H "Authentication: ''${token}" |
                jq -r '.mailboxes[] | "\(.id)\t\(.email)\t\(if .default then "(default)" else "" end)"'
              ;;
            addyio)
              curl -sf "https://app.addy.io/api/v1/recipients" \
                -H "Authorization: Bearer ''${token}" \
                -H "Accept: application/json" |
                jq -r '.data[] | "\(.id)\t\(.email)\t\(if .email_verified_at then "" else "(unverified)" end)"'
              ;;
            *)
              alias_die "unknown provider: ''${provider}"
              ;;
          esac
        }

        cmd_alias_generate() {
          require_jq
          local entry="" provider="simplelogin" note="" mailbox_id="" recipient_id=""
          entry="$1"
          shift || alias_die "usage: alias generate <entry-name> [options]"

          while [[ $# -gt 0 ]]; do
            case "$1" in
              --provider)
                provider="$2"
                shift 2
                ;;
              --note)
                note="$2"
                shift 2
                ;;
              --mailbox-id)
                mailbox_id="$2"
                shift 2
                ;;
              --recipient-id)
                recipient_id="$2"
                shift 2
                ;;
              *)
                alias_die "unknown arg: $1"
                ;;
            esac
          done

          [[ -z "$entry" ]] && alias_die "entry name required"

          local token
          token="$(get_token "$provider")" ||
            alias_die "no token found at alias-providers/''${provider} — run: pass insert alias-providers/''${provider}"

          local alias_address="" alias_id="" forwards_to="" response payload

          case "$provider" in
            simplelogin)
              payload="$(jq -n --arg note "$note" --arg mid "$mailbox_id" \
                '{note: $note} + (if $mid != "" then {mailbox_ids: [($mid | tonumber)]} else {} end)')"

              response="$(curl -sf -X POST "https://app.simplelogin.io/api/alias/random/new" \
                -H "Authentication: ''${token}" \
                -H "Content-Type: application/json" \
                -d "$payload")" || alias_die "SimpleLogin API request failed"

              alias_address="$(jq -r '.alias' <<<"$response")"
              alias_id="$(jq -r '.id' <<<"$response")"
              forwards_to="$(jq -r '.mailbox.email // "account default"' <<<"$response")"
              ;;
            addyio)
              payload="$(jq -n --arg note "$note" --arg rid "$recipient_id" \
                '{domain: "aleeas.com", format: "random_characters", description: $note} + (if $rid != "" then {recipient_ids: [$rid]} else {} end)')"

              response="$(curl -sf -X POST "https://app.addy.io/api/v1/aliases" \
                -H "Authorization: Bearer ''${token}" \
                -H "Content-Type: application/json" \
                -H "Accept: application/json" -d "$payload")" ||
                alias_die "addy.io API request failed"

              alias_address="$(jq -r '.data.email' <<<"$response")"
              alias_id="$(jq -r '.data.id' <<<"$response")"
              forwards_to="$(jq -r '(.data.recipients[0].email) // "account default"' <<<"$response")"
              ;;
            *)
              alias_die "unknown provider: ''${provider} (use simplelogin or addyio)"
              ;;
          esac

          [[ -z "$alias_address" || "$alias_address" == "null" ]] &&
            alias_die "provider returned no alias address — raw response: ''${response}"

          local block
          block="$(printf 'provider: %s\nalias_id: %s\nforwards_to: %s\nnote: %s\ncreated: %s\nstatus: enabled\n' \
            "$provider" "$alias_id" "$forwards_to" "$note" "$(date -u +%Y-%m-%dT%H:%M:%SZ)")"

          local body
          if cmd_show "$entry" >/dev/null 2>&1; then
            local existing
            existing="$(cmd_show "$entry")"
            body="$(printf '%s\nalias: %s\n%s' "$existing" "$alias_address" "$block")"
          else
            body="$(printf '%s\n%s' "$alias_address" "$block")"
          fi

          echo "$body" | cmd_insert -m -f "$entry" >/dev/null

          echo "Created alias for ''${entry}: ''${alias_address} -> ''${forwards_to}"
        }

        entry_field() {
          local entry="$1" key="$2"
          cmd_show "$entry" 2>/dev/null |
            awk -F': ' -v k="$key" '$1==k {print $2; exit}'
        }

        set_entry_status() {
          local entry="$1" new_status="$2"
          local full
          full="$(cmd_show "$entry")"
          full="$(echo "$full" | awk -v s="$new_status" '{ if ($1=="status:") print "status: " s; else print }')"
          echo "$full" | cmd_insert -m -f "$entry" >/dev/null
        }

        cmd_alias_toggle() {
          require_jq
          local entry="$1" target_enabled="$2"
          [[ -z "$entry" ]] && alias_die "usage: alias enable|disable <entry-name>"

          local provider alias_id token
          provider="$(entry_field "$entry" provider)"
          alias_id="$(entry_field "$entry" alias_id)"

          [[ -z "$provider" || -z "$alias_id" ]] &&
            alias_die "couldn't find provider/alias_id on ''${entry} — was it created with this extension?"

          token="$(get_token "$provider")" ||
            alias_die "no token at alias-providers/''${provider}"

          case "$provider" in
            simplelogin)
              curl -sf -X PATCH "https://app.simplelogin.io/api/aliases/''${alias_id}" \
                -H "Authentication: ''${token}" \
                -H "Content-Type: application/json" \
                -d "{\"enabled\": ''${target_enabled}}" >/dev/null ||
                alias_die "SimpleLogin toggle request failed"
              ;;
            addyio)
              local action
              [[ "$target_enabled" == "true" ]] && action="activate" || action="deactivate"

              curl -sf -X PUT "https://app.addy.io/api/v1/aliases/''${alias_id}/''${action}" \
                -H "Authorization: Bearer ''${token}" \
                -H "Accept: application/json" >/dev/null ||
                alias_die "addy.io ''${action} request failed"
              ;;
            *)
              alias_die "unknown provider: ''${provider}"
              ;;
          esac

          local status_word
          [[ "$target_enabled" == "true" ]] && status_word="enabled" || status_word="disabled"
          set_entry_status "$entry" "$status_word"
          echo "''${entry}: ''${status_word}"
        }

        cmd_alias_delete() {
          local entry="$1"
          [[ -z "$entry" ]] && alias_die "usage: alias delete <entry-name>"

          local provider alias_id token
          provider="$(entry_field "$entry" provider)"
          alias_id="$(entry_field "$entry" alias_id)"

          [[ -z "$provider" || -z "$alias_id" ]] &&
            alias_die "couldn't find provider/alias_id on ''${entry} — was it created with this extension?"

          token="$(get_token "$provider")" ||
            alias_die "no token at alias-providers/''${provider}"

          case "$provider" in
            simplelogin)
              curl -sf -X DELETE "https://app.simplelogin.io/api/aliases/''${alias_id}" \
                -H "Authentication: ''${token}" >/dev/null ||
                alias_die "SimpleLogin delete request failed"
              ;;
            addyio)
              curl -sf -X DELETE "https://app.addy.io/api/v1/aliases/''${alias_id}" \
                -H "Authorization: Bearer ''${token}" \
                -H "Accept: application/json" >/dev/null ||
                alias_die "addy.io delete request failed"
              ;;
            *)
              alias_die "unknown provider: ''${provider}"
              ;;
          esac

          cmd_delete "$entry" >/dev/null
          echo "Deleted ''${entry} (provider alias permanently removed)"
        }

        cmd_alias_add_mailbox() {
          require_jq
          local email="$1" provider="simplelogin"
          shift || alias_die "usage: alias add-mailbox <email> [--provider simplelogin|addyio]"

          while [[ $# -gt 0 ]]; do
            case "$1" in
              --provider)
                provider="$2"
                shift 2
                ;;
              *)
                alias_die "unknown arg: $1"
                ;;
            esac
          done

          [[ -z "$email" ]] && alias_die "email required"

          local token
          token="$(get_token "$provider")" ||
            alias_die "no token at alias-providers/''${provider}"

          case "$provider" in
            simplelogin)
              curl -sf -X POST "https://app.simplelogin.io/api/mailboxes" \
                -H "Authentication: ''${token}" \
                -H "Content-Type: application/json" \
                -d "{\"email\": \"''${email}\"}" >/dev/null ||
                alias_die "SimpleLogin add-mailbox request failed"

              echo "Requested mailbox ''${email} on SimpleLogin — check that inbox for a verification email before using it."
              ;;
            addyio)
              curl -sf -X POST "https://app.addy.io/api/v1/recipients" \
                -H "Authorization: Bearer ''${token}" \
                -H "Content-Type: application/json" \
                -H "Accept: application/json" \
                -d "{\"email\": \"''${email}\"}" >/dev/null ||
                alias_die "addy.io add-recipient request failed"

              echo "Requested recipient ''${email} on addy.io — check that inbox for a verification email before using it."
              ;;
            *)
              alias_die "unknown provider: ''${provider}"
              ;;
          esac
        }

        case "$CMD" in
          generate) cmd_alias_generate "$@" ;;
          mailboxes) cmd_alias_mailboxes "$@" ;;
          add-mailbox) cmd_alias_add_mailbox "$@" ;;
          disable) cmd_alias_toggle "$1" "false" ;;
          enable) cmd_alias_toggle "$1" "true" ;;
          delete) cmd_alias_delete "$1" ;;
          *) alias_die "usage: alias {generate|mailboxes|add-mailbox|enable|disable|delete} ..." ;;
        esac
      '';
    };
  };
}
