# nix-darwin 設定構造

```mermaid
graph TD
    FL["<b>flake.nix</b><br/><i>エントリーポイント</i>"]

    subgraph inputs["外部 inputs"]
        NP["nixpkgs<br/>(nixpkgs-unstable)"]
        ND["nix-darwin<br/>(master)"]
        NH["nix-homebrew"]
    end

    subgraph helper["mkDarwinSystem ヘルパー"]
        direction TB
        CM["<b>modules/common.nix</b><br/>─────────────────<br/>systemPackages (36 pkgs)<br/>homebrew 設定<br/>fonts (Maple Mono)<br/>nix experimental-features"]
        HB["nix-homebrew.darwinModules<br/>.nix-homebrew"]
        HO["<b>hosts/mtn-mba-m5.nix</b><br/>─────────────────<br/>platform: aarch64-darwin<br/>primaryUser: mitani<br/>enableRosetta: true"]
    end

    OUT["darwinConfigurations<br/><b>mtn-mba-m5</b>"]

    NP --> FL
    ND --> FL
    NH --> FL

    FL --> CM
    FL --> HB
    FL --> HO

    CM --> OUT
    HB --> OUT
    HO --> OUT
```

## 構造のポイント

- **`flake.nix`** — `mkDarwinSystem` ヘルパーで3つのモジュールをまとめてホスト設定を生成
- **`modules/common.nix`** — どのホストにも共通するパッケージ・設定 (今後ホストが増えても再利用可能)
- **`hosts/mtn-mba-m5.nix`** — `mtn-mba-m5` 固有の設定 (platform / user / Rosetta)
- **`nix-homebrew` モジュール** — 外部 input から直接注入され、`common.nix` の `homebrew` 設定と連携
