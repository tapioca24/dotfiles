# macOS システム設定モジュール
{ ... }:

{
  system.defaults = {
    NSGlobalDomain = {
      # 外観
      AppleInterfaceStyle = "Dark";                 # 外観モード: ダーク
      AppleIconAppearanceTheme = "RegularDark";     # アイコンとウィジェットのスタイル: ダーク
      # キーボード
      KeyRepeat = 2;                                # キーのリピート速度
      InitialKeyRepeat = 15;                        # リピート入力認識までの時間
      NSAutomaticSpellingCorrectionEnabled = false; # 英字入力中にスペルを自動変換: オフ
      NSAutomaticCapitalizationEnabled = false;     # 文頭を自動的に大文字にする: オフ
      NSAutomaticPeriodSubstitutionEnabled = false; # スペースバーを2回押してピリオドを入力: オフ
      ApplePressAndHoldEnabled = false;             # キーを押し続けたときの特殊文字の入力: オフ
      # トラックパッド
      "com.apple.trackpad.scaling" = 1.5;           # 軌跡の速さ（トラックパッド）
    };

    ".GlobalPreferences" = {
      "com.apple.mouse.scaling" = 0.875;        # 軌跡の速さ（マウス）
    };

    # Finder
    finder = {
      AppleShowAllFiles = true;                 # 隠しファイルを表示
      FXDefaultSearchScope = "SCcf";            # 検索範囲をカレントフォルダに設定
      ShowPathbar = true;                       # パスバーを表示
      FXEnableExtensionChangeWarning = false;   # ファイル拡張子変更の警告を無効化
      FXPreferredViewStyle = "Nlsv";            # デフォルトの表示方法をリストビューに設定
    };

    # Dock 設定
    dock = {
      tilesize = 64;                            # サイズ
      magnification = false;                    # 拡大: オフ
      autohide = true;                          # 自動的に表示/非表示: オン
      show-recents = false;                     # アプリの提案と最近使用したアプリ: オフ
      expose-group-apps = true;                 # Mission Control: アプリごとにグループ化
      showAppExposeGestureEnabled = true;       # アプリ Exposé: オン
    };

    # 画面キャプチャ
    screencapture = {
      disable-shadow = true;                    # ウィンドウの影をキャプチャに含めない
      show-thumbnail = true;                    # キャプチャ後のサムネイルを表示
    };

    # キーボード設定
    hitoolbox = {
      AppleFnUsageType = "Do Nothing";          # 🌐キーを押して: 何もしない
    };

    # コントロールセンター設定（nix-darwin ネイティブ対応項目）
    controlcenter = {
      AirDrop = false;                          # AirDrop: オフ
      BatteryShowPercentage = true;             # バッテリー: 割合(%)を表示
      Bluetooth = true;                         # Bluetooth: オン
      Display = false;                          # ディスプレイ: オフ
      FocusModes = false;                       # 集中モード: オフ
      NowPlaying = false;                       # 再生中: オフ
      Sound = false;                            # サウンド: オフ
    };

    # ウインドウマネージャ設定
    WindowManager = {
      EnableTilingByEdgeDrag = false;           # 端にドラッグでタイル表示: オフ
      EnableTopTilingByEdgeDrag = false;        # メニューバーにドラッグでフルスクリーン: オフ
      EnableTilingOptionAccelerator = false;    # ⌥キーでタイル表示: オフ
      EnableTiledWindowMargins = false;         # 隙間を入れて配置: オフ
    };

    # トラックパッド設定
    trackpad = {
      # ポイントとクリック
      FirstClickThreshold = 0;                  # クリック: 弱い
      SecondClickThreshold = 0;                 # 強めのクリック: 弱い
    };

    # nix-darwin 未対応項目
    CustomUserPreferences = {
      # マウス
      NSGlobalDomain."com.apple.scrollwheel.scaling" = 0; # スクロールの速さ: 遅い

      # メニューバー
      "com.apple.Siri".StatusMenuVisible = false; # Siri: オフ
      "com.apple.TextInputMenu".visible = true;   # テキスト入力: オン
      # 以下の項目の表示/非表示はうまく設定できない
      # - Spotlight
      # - Wi-Fi
      # - バッテリー
      # - 画面ミラーリング
      # - ファストユーザスイッチ
      # - Time Machine
      # - キーボードの輝度
      # - タイマー
    };
  };
}
