# Finder で Cmd+C したのと同じ状態でファイルをクリップボードにコピーする
#
# 使い方:
#   cpf foo.png                # 1ファイル
#   cpf a.png b.png            # 複数ファイル
#   cpf *.png                  # グロブ (シェルが展開)
#   cpf **/*.md                # 再帰グロブ
#   cpf *.(png|jpg)            # zsh の拡張グロブ
#   cpf ${(f)"$(fd -e png 'screenshot_\d+')"}   # 正規表現で絞る (fd の出力を渡す)
function cpf() {
  if (( $# == 0 )); then
    echo "usage: cpf <file>..." >&2
    return 1
  fi

  local f
  for f in "$@"; do
    if [[ ! -e "$f" ]]; then
      echo "cpf: $f: No such file or directory" >&2
      return 1
    fi
  done

  osascript -l JavaScript - "${@:A}" <<'EOF'
ObjC.import("AppKit");
ObjC.import("Foundation");
function run(argv) {
  const pb = $.NSPasteboard.generalPasteboard;
  pb.clearContents;
  const urls = $.NSMutableArray.array;
  argv.forEach(p => urls.addObject($.NSURL.fileURLWithPath(p)));
  pb.writeObjects(urls);
  // プロセス終了前にペーストボードへ反映させるため少し待つ
  $.NSThread.sleepForTimeInterval(0.3);
}
EOF
}
