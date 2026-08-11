# setup-bqvalid

A GitHub Action that installs [bqvalid](https://github.com/hirosassa/bqvalid) — a
SQL validator for BigQuery standard SQL — and adds it to `PATH` so later steps can
run `bqvalid` directly.

## Usage

```yaml
- uses: hirosassa/setup-bqvalid@v1
- run: bqvalid path/to/queries/**/*.sql
```

### Pin a specific version

```yaml
- uses: hirosassa/setup-bqvalid@v1
  with:
    version: 0.3.0
- run: bqvalid path/to/queries/**/*.sql
```

## Inputs

| Name           | Required | Default              | Description                                                                 |
| -------------- | -------- | -------------------- | --------------------------------------------------------------------------- |
| `version`      | no       | `latest`             | Version of bqvalid to install. Accepts `0.3.0`, `v0.3.0`, or `latest`.      |
| `github-token` | no       | `${{ github.token }}`| Token used to query the GitHub API when resolving the `latest` release.     |

## Outputs

| Name      | Description                                                        |
| --------- | ------------------------------------------------------------------ |
| `version` | The resolved bqvalid version that was installed (without leading `v`). |

```yaml
- uses: hirosassa/setup-bqvalid@v1
  id: bqvalid
- run: echo "Installed bqvalid ${{ steps.bqvalid.outputs.version }}"
```

## License

[MIT](./LICENSE)
