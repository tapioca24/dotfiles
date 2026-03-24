# ホスト "mtn-mba-m5" 固有の設定モジュール
{ ... }:

let
  user = "mitani";
in
{
  # Apple Silicon (M シリーズ) 向けにビルド
  nixpkgs.hostPlatform = "aarch64-darwin";

  # システムの主ユーザー（nix-darwin が権限管理に使用）
  system.primaryUser = user;
  # nix-darwin の設定スキーマバージョン（変更時は移行が必要）
  system.stateVersion = 6;

  # Homebrew 自体のインストール設定（nix-homebrew モジュールが提供するオプション）
  nix-homebrew = {
    # Homebrew を Nix で管理する
    enable = true;
    # Apple Silicon 上で x86_64 用 Homebrew も使えるようにする
    enableRosetta = true;
    # Homebrew をインストール・管理するユーザー
    inherit user;
  };
}
