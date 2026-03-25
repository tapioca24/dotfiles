# 全ホスト共通の設定モジュール
# specialArgs で注入された inputs と、nixpkgs が提供する pkgs を受け取る
{ pkgs, inputs, ... }:

{
  # Nix で管理するシステム共通パッケージ
  environment.systemPackages = with pkgs; [
    aerospace
    bat
    btop
    codex
    chezmoi
    delta
    dust
    eza
    fastfetch
    fd
    fzf
    gh
    ghq
    gibo
    git
    helix
    httpie
    jankyborders
    jaq
    just
    just-lsp
    # mise
    ripgrep
    sd
    sheldon
    starship
    uv
    vim
    xdg-ninja
    zoxide
  ];

  # Homebrew で管理するパッケージの設定
  # nix-homebrew モジュールが有効化した homebrew.* オプションを使用
  homebrew = {
    enable = true;
    # Nix 管理外の brew パッケージを削除
    onActivation.cleanup = "zap";
    # darwin-rebuild 時に brew update を実行
    onActivation.autoUpdate = true;
    # darwin-rebuild 時に brew upgrade を実行
    onActivation.upgrade = true;
    taps = [
    ];
    brews = [
      "mise"
    ];
  };

  # フォントのインストール
  fonts.packages = with pkgs; [
    maple-mono.NormalNL-NF-unhinted
    moralerspace
    hackgen-nf-font
  ];

  # flakes と nix コマンドを有効化
  nix.settings.experimental-features = "nix-command flakes";
  # システムの nix デーモンは外部（Determinate Nix など）に任せる
  nix.enable = false;

  # 現在適用中の設定のコミットハッシュを記録（未コミットの場合は dirtyRev）
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

  # Touch ID で sudo を許可
  # security.pam.services.sudo_local.touchIdAuth = true;
}
