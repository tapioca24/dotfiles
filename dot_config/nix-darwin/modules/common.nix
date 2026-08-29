# 全ホスト共通の設定モジュール
# specialArgs で注入された inputs と、nixpkgs が提供する pkgs を受け取る
{ pkgs, inputs, ... }:

{
  # Nix で管理するシステム共通パッケージ
  environment.systemPackages = with pkgs; [
    aerospace
    age
    awscli2
    inputs.ax.packages.${pkgs.system}.default
    bat
    btop
    ccusage
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
    glab
    helix
    herdr
    httpie
    hunk
    hyperfine
    jankyborders
    just
    just-lsp
    lazygit
    mise
    ni
    pure-prompt
    ripgrep
    rtk
    sd
    sheldon
    ssm-session-manager-plugin
    typescript
    typescript-language-server
    uv
    vim
    xdg-ninja
    yazi
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
      "k1LoW/tap"
    ];
    brews = [
      "k1LoW/tap/mo"
      "crit"
    ];
  };

  # フォントのインストール
  fonts.packages = with pkgs; [
    maple-mono.NormalNL-NF-unhinted
    hackgen-font
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
