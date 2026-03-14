# setup-gpc

GitHub Action that installs [`gpc`](https://github.com/leszko11/google-play-console-cli) and optionally initializes a local auth profile from raw service-account JSON.

## Usage

```yaml
- uses: leszko11/setup-gpc@v1
  with:
    version: latest
    service-account-json: ${{ secrets.GOOGLE_PLAY_SERVICE_ACCOUNT_JSON }}
    profile: default
```

After the action runs, `gpc` is available on `PATH` for subsequent steps.

```yaml
- run: gpc apps list --output json
```

## Inputs

| Name | Required | Default | Description |
| --- | --- | --- | --- |
| `version` | No | `latest` | Release version to install, for example `v1.2.3` or `1.2.3`. |
| `repository` | No | `leszko11/google-play-console-cli` | Repository that publishes `gpc` release assets. |
| `service-account-json` | No | `""` | Raw service-account JSON content to persist and pass to `gpc auth init`. |
| `profile` | No | `default` | Auth profile name used by `gpc auth init`. |
| `developer-id` | No | `""` | Optional Play developer account ID to save with the profile. |

## Outputs

| Name | Description |
| --- | --- |
| `version` | Resolved `gpc` version that was installed. |
| `binary-path` | Full path to the installed `gpc` binary. |
| `service-account-path` | Path to the persisted service-account file when auth was configured. |
| `auth-configured` | `true` when `gpc auth init` was executed. |

## Notes

- The action sets `GPC_BYPASS_KEYCHAIN=1` before running `gpc auth init`, which keeps CI runners out of platform keychain prompts.
- `service-account-json` is optional. If omitted, the action only installs `gpc`.
- Linux, macOS, and Windows GitHub-hosted runners are covered by CI.
