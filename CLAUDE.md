# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

chezmoi ドットファイル管理リポジトリ。macOS (Apple Silicon) 向けの nix-darwin + chezmoi 構成。

## ファイル命名規則

chezmoi の規則に従う:
- `dot_` prefix → `~/.` に展開 (例: `dot_zshrc` → `~/.zshrc`)
- `dot_config/` → `~/.config/` に展開
- `.tmpl` suffix → テンプレートとして処理
- `run_` prefix → `chezmoi apply` 時に実行されるスクリプト
- `.chezmoiignore` に列挙されたファイルは apply 対象外 (README.md, lefthook.yml, mise.toml など)

## アーキテクチャ

### システム設定 (Nix)
`dot_config/nix-darwin/` が中心:
- `flake.nix` — エントリポイント。`mkDarwinSystem` ヘルパーでホスト定義を組み立てる
- `modules/common.nix` — 全ホスト共通パッケージ・Homebrew 設定
- `hosts/mtn-mba-m5.nix` — 現ホスト

パッケージ管理方針: Nix 優先 → Nix にないものは Homebrew → ランタイム版管理は mise → GUI アプリは手動。

### シェル設定
- `dot_zshrc` — メイン設定。XDG 環境変数、ツール初期化 (sheldon/starship/zoxide/mise/fzf)
- `dot_zprofile` — mise shims の有効化
- `dot_config/sheldon/` — プラグイン管理 (zsh-abbr, autosuggestions, syntax-highlighting など)
- `dot_config/zsh-abbr/` — 55+ の abbreviation 定義 (git, docker, chezmoi, just など)
- `dot_config/zsh/` — カスタムスクリプト (path.zsh, just.zsh, zbell.zsh)

### テーマ統一
Catppuccin Macchiato を全ツールで統一:
Ghostty / Helix / delta / bat / eza / btop

## Pre-commit フック

`lefthook` + `betterleaks` でシークレット検出。コミット前に自動実行される。
mise で管理: `mise.toml` に lefthook と betterleaks を定義。
