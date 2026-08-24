# VLC 432 Hz Tuning

A desktop extension for VLC media player that retunes playback referenced to A = 440 Hz down to A = 432 Hz.

The extension sets the playback rate to `432 / 440` and disables VLC's pitch-preserving time-stretch filter. Pitch and tempo change together, as they would when slowing an analogue recording.

> **Statement of intent:** This project does not claim that 432 Hz opens portals, repairs houseplants, or reveals the universe's source code. It observes that `4 + 3 + 2 = 9`, finds that arithmetic pleasing, and supplies a button for people who prefer a world where such numbers are allowed to matter. Choose your reference frequency, or at least use headphones that can resolve the difference.

## Contents

- [Features](#features)
- [Requirements and compatibility](#requirements-and-compatibility)
- [Installation](#installation)
- [Release package contents](#release-package-contents)
- [Usage](#usage)
- [Controls](#controls)
- [Why 432?](#why-432)
- [Technical explanation](#technical-explanation)
- [Configuration changes](#configuration-changes)
- [Limitations](#limitations)
- [Troubleshooting](#troubleshooting)
- [GitHub Actions and releases](#github-actions-and-releases)
- [Development and validation](#development-and-validation)
- [Privacy](#privacy)
- [References](#references)

## Features

- Applies the exact playback rate `0.9818181818181818x`.
- Disables VLC's pitch correction so the rate change also changes pitch.
- Refreshes the selected audio track so the new audio-filter configuration takes effect during current playback.
- Displays the current playback rate and pitch-correction state.
- Restores normal `1.0x` playback independently of the pitch-correction setting.
- Re-enables VLC's normal pitch correction on request.
- Includes installers for Windows, Linux, and macOS.
- Includes a GitHub Actions workflow that builds and validates a genuine ZIP archive.
- Supports VLC 3 and includes a compatibility path for the VLC 4 Lua player API.
- Uses only VLC's built-in Lua API; no external dependencies are required.

## Requirements and compatibility

- VLC media player for desktop with Lua extension support.
- Tested with VLC `3.0.23` on Windows.
- The VLC 4 compatibility path is implemented but has not been verified against a production VLC 4 release.

The requested rate may not be supported by every network protocol, renderer, or output mode. Local audio and video files are the intended use case.

## Installation

Download the ZIP from the repository's **Releases** page, extract it, and run the installer for your operating system. The ZIP is a regular ZIP archive, not a renamed TAR file or a Gzip archive with a different extension.

You can also download [`VLC-432Hz-tuning.lua`](VLC-432Hz-tuning.lua) and copy it manually into VLC's per-user Lua extension directory.

### Quick path reference

| Platform | VLC user folder | Complete extension folder |
| --- | --- | --- |
| Windows | `%APPDATA%\vlc\` | `%APPDATA%\vlc\lua\extensions\` |
| Linux | `${XDG_DATA_HOME:-$HOME/.local/share}/vlc/` | `${XDG_DATA_HOME:-$HOME/.local/share}/vlc/lua/extensions/` |
| macOS | `$HOME/Library/Application Support/org.videolan.vlc/` | `$HOME/Library/Application Support/org.videolan.vlc/lua/extensions/` |

Open your **VLC user folder**, create a folder named `lua` inside it, then create a folder named `extensions` inside `lua`. Copy `VLC-432Hz-tuning.lua` into that final `extensions` folder.

> [!NOTE]
> The `lua` and `extensions` folders often do not exist in a standard VLC installation. Create both folders manually when they are missing. The final structure must be `vlc/lua/extensions/VLC-432Hz-tuning.lua`.

### Windows

Automatic installation:

1. Extract the release ZIP.
2. Double-click `install-windows.bat`.
3. Restart VLC.

The batch file creates missing directories and copies the Lua extension to the current user's VLC folder. Administrator rights are not required.

PowerShell users can run the equivalent installer:

```powershell
.\install-windows.ps1
```

Manual installation:

1. Open the VLC user folder by entering `%APPDATA%\vlc` in File Explorer's address bar.
2. Create `lua` inside the VLC folder if it does not exist.
3. Create `extensions` inside the `lua` folder if it does not exist.
4. Copy `VLC-432Hz-tuning.lua` into `extensions`.

Complete destination path:

```text
%APPDATA%\vlc\lua\extensions\VLC-432Hz-tuning.lua
```

`%APPDATA%` expands to the current user's roaming application-data directory. No hard-coded username is required.

PowerShell installation example:

```powershell
$VlcExtensions = Join-Path $env:APPDATA "vlc\lua\extensions"
New-Item -ItemType Directory -Path $VlcExtensions -Force | Out-Null
Copy-Item -LiteralPath ".\VLC-432Hz-tuning.lua" -Destination $VlcExtensions
```

Command Prompt installation example:

```bat
if not exist "%APPDATA%\vlc\lua\extensions" mkdir "%APPDATA%\vlc\lua\extensions"
copy "VLC-432Hz-tuning.lua" "%APPDATA%\vlc\lua\extensions\"
```

### Linux

VLC follows the XDG user-data location. The following shell variable respects `XDG_DATA_HOME` when defined and falls back to the standard path under `$HOME`:

Automatic installation from an extracted release:

```sh
sh ./install-linux.sh
```

Manual installation:

```sh
vlc_extensions="${XDG_DATA_HOME:-$HOME/.local/share}/vlc/lua/extensions"
mkdir -p "$vlc_extensions"
cp ./VLC-432Hz-tuning.lua "$vlc_extensions/"
```

The `mkdir -p` command creates both `lua` and `extensions` when they are missing. The base VLC user folder is:

```sh
${XDG_DATA_HOME:-$HOME/.local/share}/vlc/
```

### macOS

Automatic installation from an extracted release:

```sh
sh ./install-macos.sh
```

The installer creates the following folder when necessary and copies the extension into it:

```text
$HOME/Library/Application Support/org.videolan.vlc/lua/extensions/
```

Manual installation: create `lua/extensions` inside `$HOME/Library/Application Support/org.videolan.vlc/`, then copy `VLC-432Hz-tuning.lua` into `extensions`.

### Other platforms

Use VLC's user data directory for the current account. Place the Lua file directly in that installation's `lua/extensions` directory. Consult the VLC package documentation for the exact path on your platform.

> [!IMPORTANT]
> Copy the Lua file into the extension directory, not the entire repository folder. VLC 3 scans files directly inside `lua/extensions` and does not discover extensions nested in project subdirectories.

Restart VLC after installing or updating the file. The extension appears under **View > 432 Hz Tuning**.

## Release package contents

Every generated release ZIP contains:

| File | Purpose |
| --- | --- |
| `VLC-432Hz-tuning.lua` | VLC extension |
| `install-windows.bat` | Double-clickable Windows installer |
| `install-windows.ps1` | Native PowerShell installer |
| `install-linux.sh` | XDG-aware Linux installer |
| `install-macos.sh` | Per-user macOS installer |
| `README.md` | Documentation |
| `VERSION` | Package version |

All installers copy the same Lua file. They do not download software, request administrator access, edit VLC binaries, or write registry keys.

## Usage

1. Start playing an audio or video file in VLC.
2. Open **View > 432 Hz Tuning**.
3. Leave **Refresh the current audio track so the pitch change takes effect now** selected.
4. Click **Apply 432 Hz tuning**.
5. Confirm that the status area reports that 432 Hz tuning is active.

A short audio interruption occurs when the extension refreshes the selected audio track. Playback position is not changed.

If no media is playing, the extension can still set the player rate and pitch-correction preference. New playback uses those settings.

## Controls

### Apply 432 Hz tuning

1. Disables `audio-time-stretch` in VLC's active configuration.
2. Applies the same setting to the active audio-output object when one exists.
3. Optionally deselects and reselects the current audio track to rebuild its filter chain.
4. Sets the playback rate to `432 / 440`.

### Restore normal rate

Sets the playback rate to `1.0x`. It leaves the pitch-correction preference unchanged.

### Enable pitch correction

Re-enables VLC's `audio-time-stretch` setting. If audio refresh is selected, the current track is restarted so the change takes effect immediately.

### Refresh status

Reads the current rate and time-stretch setting from VLC and updates the dialog.

## Why 432?

Some listeners and musicians want to hear material shifted from an A = 440 Hz reference to A = 432 Hz. This extension provides a precise and reversible way to do that in VLC without modifying the source file.

432 is also an entertaining integer:

- `4 + 3 + 2 = 9`
- `432 = 48 × 9`
- `432 = 2⁴ × 3³`
- A full circle contains 360 degrees, which is unrelated but has been invited to the same arithmetic discussion.

None of this proves an acoustic, medical, historical, metaphysical, agricultural, or interdimensional claim. It shows only that integers can have structure and that software is more enjoyable when it leaves room for harmless curiosity.

If 440 Hz is preferred, use the **Restore normal rate** button. If 432 Hz is preferred, the ratio is already calculated.

## Technical explanation

### Playback rate

To map a recording tuned to A = 440 Hz onto A = 432 Hz, every frequency is multiplied by the same ratio:

```text
rate = 432 / 440
     = 0.9818181818181818
```

Example:

```text
440 Hz * 0.9818181818181818 = 432 Hz
```

The corresponding pitch displacement is:

```text
cents = 1200 * log2(432 / 440)
      = -31.766653633429 cents
```

Playback speed is approximately `1.8182%` slower. Total duration becomes approximately `1.8519%` longer.

### Pitch correction versus audio resampling

VLC calls its pitch-preserving playback-speed feature **time stretching audio**. When `audio-time-stretch` is enabled, VLC inserts the `scaletempo` filter and attempts to keep pitch unchanged while the rate changes.

This extension disables `audio-time-stretch` because the intended result is a real pitch change. It does not disable VLC's general audio resampler. The resampler remains necessary for ordinary sample-rate conversion, device compatibility, synchronization, and rate-dependent audio processing.

### Live audio refresh

Changing `audio-time-stretch` updates VLC's configuration, but an audio filter chain that is already running may retain its previous filter selection. The extension therefore refreshes the selected audio track when requested:

- VLC 3: temporarily sets the input's `audio-es` selection to disabled, then restores the original track ID.
- VLC 4: toggles the selected audio track through the player API.

If the refresh is unavailable or fails, stop and replay the media once. The new filter configuration is used when VLC creates the next audio pipeline.

## Configuration changes

The extension changes two pieces of VLC state:

| State | Value after applying | Restoration |
| --- | ---: | --- |
| Playback rate | `0.9818181818181818x` | Click **Restore normal rate** |
| `audio-time-stretch` | Disabled | Click **Enable pitch correction** |

Closing or deactivating the extension does not undo these changes. Playback should not change merely because the dialog was closed.

Use the restoration controls when you want to return VLC to 1.0x rate and normal pitch correction.

## Limitations

- Audio can briefly drop out while the selected track is refreshed.
- Some live streams, remote renderers, optical media, or demuxers may reject or approximate a custom playback rate.
- Encoded digital pass-through modes such as S/PDIF may prevent VLC from resampling or pitch-shifting the audio.
- The extension cannot refresh audio when the current media has no selected audio track.
- Another extension, remote-control client, or VLC speed command can overwrite the playback rate afterward.
- The extension changes playback globally within the active VLC player; it does not modify the media file.
- This is rate-based retuning. It changes tempo and duration in addition to pitch.
- Results are governed by signal processing, not by the listener's zodiac sign.

## Troubleshooting

### The extension is not listed under View

- Confirm that `VLC-432Hz-tuning.lua` is directly inside the platform's `lua/extensions` directory.
- Do not leave the Lua file only inside a nested repository folder.
- Restart VLC completely after copying the file.
- On Windows, confirm that the file extension is `.lua`, not `.lua.txt`.

### The speed changes but the pitch does not

- Apply the tuning with the audio-refresh option selected.
- If VLC reports that it could not refresh the track, stop and replay the media.
- Disable digital audio pass-through and use decoded PCM output.
- Confirm that the dialog reports **Pitch correction: disabled**.

### The pitch changes but playback is unstable

- Test with a local media file rather than a network stream.
- Return VLC's audio output and resampler selections to their automatic defaults.
- Disable unrelated audio filters temporarily to identify filter-chain conflicts.

### Normal playback still has altered pitch

Click **Restore normal rate**. A `1.0x` rate produces normal pitch regardless of whether time stretching is enabled.

## GitHub Actions and releases

The workflow at [`.github/workflows/build-release.yml`](.github/workflows/build-release.yml) builds `vlc-432hz-tuning-<version>.zip`, extracts it again to verify its contents, calculates a SHA-256 checksum, and uploads both files.

### Put the project on GitHub

1. Create an empty GitHub repository.
2. Put the **contents** of this project folder at the repository root. `README.md`, `VERSION`, `VLC-432Hz-tuning.lua`, and the hidden `.github` directory must all be at the top level.
3. Commit and push the files to the `main` branch.
4. Open the repository's **Actions** tab and select **Build release package**.

The workflow runs automatically for pushes to `main`, pull requests, and tags beginning with `v`. It can also be started manually with **Run workflow**.

### Download a package from a normal workflow run

1. Open **Actions > Build release package**.
2. Select a completed run.
3. Download the package from the **Artifacts** section.

GitHub wraps workflow artifacts in its own download container. Inside it are the genuine release ZIP and its `.sha256` checksum file.

### Publish a GitHub Release

Set the desired version in `VERSION`, commit it, then create and push a matching tag:

```sh
git tag v1.0.0
git push origin v1.0.0
```

For a `v1.0.0` tag, the workflow publishes:

```text
vlc-432hz-tuning-1.0.0.zip
vlc-432hz-tuning-1.0.0.zip.sha256
```

Tagged runs automatically create a GitHub Release with generated release notes. If the release already exists, rerunning the workflow replaces its two downloadable assets.

The workflow uses GitHub's automatically provided token. If release publication reports a permission error, open **Settings > Actions > General > Workflow permissions**, select **Read and write permissions**, and rerun the tagged workflow. Repository or organization policy may control whether this option is available.

The `.sha256` file lets users verify that their download matches the archive built by GitHub. On Windows, display the downloaded ZIP's hash with:

```powershell
Get-FileHash .\vlc-432hz-tuning-1.0.0.zip -Algorithm SHA256
```

On Linux or macOS, verify it from the directory containing both release files with:

```sh
sha256sum -c vlc-432hz-tuning-1.0.0.zip.sha256
```

macOS provides `shasum -a 256` by default if `sha256sum` is unavailable.

### Manual workflow run

Manual runs use the version stored in `VERSION` and upload a workflow artifact without creating a GitHub Release. A tag is required for publication.

## Development and validation

Project layout:

```text
vlc-432hz-tuning/
|-- .github/
|   `-- workflows/
|       `-- build-release.yml
|-- .gitattributes
|-- .gitignore
|-- README.md
|-- VERSION
|-- VLC-432Hz-tuning.lua
|-- install-linux.sh
|-- install-macos.sh
|-- install-windows.bat
`-- install-windows.ps1
```

The extension is written for VLC's Lua 5.1 environment. Its public entry points are:

- `descriptor()`
- `activate()`
- `deactivate()`
- `close()`
- `menu()`
- `trigger_menu(id)`

The rate abstraction uses `vlc.var` and the playlist object on VLC 3, then selects `vlc.player.get_rate()` and `vlc.player.set_rate()` when the VLC 4 player API is available.

The numerical constants are precomputed at the script's top level. VLC 3 evaluates extension descriptors in a restricted scanner environment where the standard `math` table is not available during discovery.

Version `1.0.0` was validated by the VLC 3.0.23 extension loader on Windows. VLC detected the script and its menu capability without Lua warnings or load errors.

## Privacy

The extension performs no network requests, telemetry, analytics, media scanning, or file modification. It communicates only with the active VLC instance through VLC's built-in Lua API.

It does not transmit the number 9 to a remote numerology service. Such a service does not exist, and if it did, this extension would remain offline.

## References

- [VLC Lua 3.0 API documentation](https://raw.githubusercontent.com/videolan/vlc/3.0.x/share/lua/README.txt)
- [VLC Lua current API documentation](https://raw.githubusercontent.com/videolan/vlc/master/share/lua/README.txt)
- [VLC audio filter-chain implementation](https://github.com/videolan/vlc/blob/master/src/audio_output/filters.c)
- [VLC `scaletempo` implementation](https://github.com/videolan/vlc/blob/master/modules/audio_filter/scaletempo.c)

## License

No open-source license has been selected for this project. Add a license file before accepting third-party contributions or redistributing modified versions under explicit license terms.