{
  description = "My Mac configuration";

  # 外部依存関係の宣言（flake.lock でコミットハッシュが固定される）
  inputs = {
    # パッケージ集
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    # macOS 設定フレームワーク
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    # nix-darwin が使う nixpkgs をこのflakeのものに統一（二重管理を防ぐ）
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    # Homebrew 自体を Nix で管理するツール
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
  };

  # inputs 全体を inputs という名前でも参照しつつ、よく使う nix-darwin・nix-homebrew を分解して受け取る
  outputs = inputs@{ nix-darwin, nix-homebrew, ... }:
  let
    # ホスト固有モジュールを受け取り、共通モジュールと合わせてシステム設定を生成するヘルパー関数
    # ホストを追加するときはこの関数を呼ぶだけでよい
    mkDarwinSystem = hostModule:
      nix-darwin.lib.darwinSystem {
        # inputs を全モジュールで参照できるように注入
        specialArgs = { inherit inputs; };
        modules = [
          # 全ホスト共通の設定
          ./modules/common.nix
          # homebrew.* オプションを使えるようにする
          nix-homebrew.darwinModules.nix-homebrew
          # ホスト固有の設定
          hostModule
        ];
      };
  in
  {
    # `darwin-rebuild switch --flake .#mtn-mba-m5` で適用するシステム設定
    darwinConfigurations."mtn-mba-m5" = mkDarwinSystem ./hosts/mtn-mba-m5.nix;
  };
}
