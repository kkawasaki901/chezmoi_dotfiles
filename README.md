# chezmoi 管理ドットファイル・設定ファイル一覧

このリポジトリは `chezmoi` による Windows 環境（`C:\Users\kawasaki`）のドットファイルおよびアプリケーション設定ファイルの管理リポジトリです。
詳細な一覧ドキュメントは [`C:\Users\kawasaki\chezmoi_dotfiles.md`](file:///C:/Users/kawasaki/chezmoi_dotfiles.md) にも出力されています。

## 基本コマンド

```powershell
# 状態確認（差分があるファイルの確認）
chezmoi status

# 変更内容の差分表示
chezmoi diff

# ローカル環境の変更を chezmoi ソースへ取り込む
chezmoi re-add

# 新しい設定ファイルを追加する
chezmoi add <ファイルパス>

# 管理しているファイル一覧を表示する
chezmoi managed
```

## セキュリティ・除外ポリシー

- [`.gitignore`](file:///C:/Users/kawasaki/.local/share/chezmoi/.gitignore) および [`.chezmoiignore`](file:///C:/Users/kawasaki/.local/share/chezmoi/.chezmoiignore) により、API キー・OAuth トークン・認証情報・秘密鍵・ログファイル・キャッシュ・SQLite/DB・会話履歴・一時バックアップ（`.bak*`）を自動的に除外しています。
- 機密情報を含むため除外している主な個別設定ファイル:
  - `AppData/Roaming/rclone/rclone.conf`
  - `.clasprc.json`
  - `.commandcode/providers.json`
  - `.vimgolf/config.yaml`
  - `.config/joplin-desktop/settings.json`
  - `.config/yasb/presets/`, `.config/yasb/yasb-themes/`
  - `AppData/Roaming/spotify-cli/config.toml`
  - `AppData/Roaming/GitHub CLI/hosts.yml`
  - `AppData/Roaming/himalaya/*.dpapi`
  - `AppData/Local/gcalcli/**/oauth*`
