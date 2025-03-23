<div align="center">
  <h1>
    <img width="100" src="docs/nixos-unstable.png" /><br />
    Add's Nix-Config
  </h1>
</div>

<div align="center">
  <table>
    <tr>
      <td align="center">
        <strong>Where am I?</strong><br><br>
        <em>You're in a rabbit hole.</em><br><br>
        <strong>How did I get here?</strong><br><br>
        <em>The door opened; you got in.</em>
      </td>
    </tr>
  </table>
</div>

---

## 🚀 Highlights

- **Flake-based** multi-host, multi-user NixOS and Home-Manager configuration
- **Modular & Composable** configs for both system and user layers
- **Secrets Management** via `sops-nix` and a private `nix-secrets` repo
- **Remote Bootstrapping** and ISO generation with `nixos-anywhere`
- **YubiKey Support** for login, sudo, SSH, git commit signing, and LUKS2 decryption
- **Automation Recipes** to streamline setup and rebuilds

---

## 📦 Requirements

- NixOS 23.11 or later
- Strong understanding of Nix and NixOS concepts
- Experience with flakes and home-manager
- Familiarity with system administration and Linux
- Patience and persistence
- A good chunk of disk space

This is my personal NixOS configuration that I use to manage my systems. It's not designed to be a drop-in solution - you'll need to understand the code to adapt it for your needs. The configuration assumes you're comfortable with Nix expressions, flakes, and system administration.

---

## 🗺️ Project Structure

```sh
.
├── flake.nix          # Just holds the inputs
├── outputs/           # Flake outputs and system configurations
│   ├── default.nix    # Main flake outputs, system configs, and overlays
│   └── devshell.nix   # Development environment and tools
├── hosts/             # Per-host NixOS configurations
│   ├── common/        # Shared configs (core, disks, optional, users)
│   └── <hostname>/    # Individual host configurations
├── home/<user>/       # Per-user home-manager configurations
│   └── common/        # Core and optional modules
├── modules/           # Custom reusable Nix or HM modules
├── lib/               # Path utilities and shared helpers
├── nixos-installer/   # Minimal install flake for ISO/bootstrap
├── overlays/          # Package overrides
├── pkgs/              # Custom packages
├── scripts/           # Automation helpers (remote install, etc.)
└── vars/              # Centralized shared variables
```

---

## 🧪 Setup & Installation

See:
- [Install Notes](docs/installnotes.md)
- [Adding a New Host](docs/addnewhost.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)

---

## 🔐 Secrets Management

Secrets are pulled from a private flake input (`nix-secrets`) and decrypted using [sops-nix](https://github.com/Mic92/sops-nix). For more, read the [Secrets Management Guide](https://unmovedcentre.com/posts/secrets-management/).

---

## 🧭 Roadmap & TODOs

Ongoing improvements are tracked in [docs/TODO.md](docs/TODO.md).

Completed features are noted in their respective stages.

---

## 📚 Resources

- [Nix.dev Docs](https://nix.dev)
  - [Best Practices](https://nix.dev/guides/best-practices)
- [Noogle - Nix API Search](https://noogle.dev/)
- [NixOS Wiki](https://wiki.nixos.org/)
- [NixOS & Flakes Book](https://nixos-and-flakes.thiscute.world/) by Ryan Yin
- [Impermanence](https://github.com/nix-community/impermanence)
- YubiKey:
  - <https://wiki.nixos.org/wiki/Yubikey>
  - [DrDuh Guide](https://github.com/drduh/YubiKey-Guide)

---

## 🙏 Acknowledgements

- [Ryan Yin](https://github.com/ryan4yin/nix-config) — Clear, well-documented structure and ideas.
- [EmergentMind](https://github.com/EmergentMind) — Original inspiration and project foundation.

---

<div align="center">
  <sub>
    [Back to Top](#nix-config)
  </sub>
</div>
