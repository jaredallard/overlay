# ebuild-updater

An automated ebuild updating system.

## Usage

**Requirements**: `docker`.

Create an `updater.yml` file in the root of your repository. Create a
key for each package that should be managed by the updater.

```yaml
dev-util/mise:
  resolver: git
  options:
    # url where the git repository lives. HTTPS is recommended.
    url: https://github.com/jdx/mise
```

By default, if the only change that needs to be done during an upgrade
is a rename of the ebuild and regenerating the manifest, you're done!

However, if you require custom logic (e.g., running `pycargoebuild`),
you can specify steps to be ran during the upgrade process. An example
for `mise` (a rust ebuild) is shown below.

```yaml
dev-util/mise:
  resolver: git
  options:
    url: https://github.com/jdx/mise
  
  steps:
    - command: git clone https://github.com/jdx/mise .
    - original_ebuild: mise.ebuild
    - command: pycargoebuild -i mise.ebuild
    - ebuild: mise.ebuild
```

**Note**: All steps are ran inside of a Gentoo based docker image.

## Configuration File

| Key | Description |
| --- | --- |
| `resolver` | The resolver to use for the package. Valid options are `git` or `apt`. |
| `options` | Options for the resolver. |
| `steps` | Steps to be ran during the upgrade process. |

### **git** `options`

| Key | Description |
| --- | --- |
| `url` | The URL where the git repository lives. HTTPS is recommended. |

### **apt** `options`

| Key | Description |
| --- | --- |
| `repository` | Sources list entry for the APT repository |
| `package` | The package name as it appears in the repository |

### `steps`

| Key | Description |
| --- | --- |
| `command` | A command to be ran. |
| `original_ebuild` | Path to write an ebuild |
| `ebuild` | Path to read modified ebuild from |

## License

GPL-2.0
