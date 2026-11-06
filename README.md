# 🌌 Dotfiles

洗練されたTUI環境と、モダンかつセキュアなアーキテクチャを目指して構築された個人的なDotfilesです。

## ✨ Features

本構成は、以下の4つのコアコンセプトをベースに設計されています。

### 1. 🛠️ chezmoi × mise × 1Password (op)
セキュアで再現性の高い環境構築を実現するための強力なスタックです。
- **[chezmoi](https://chezmoi.io/)**: 柔軟で堅牢なドットファイルマネージャ。
- **[mise](https://mise.jdx.dev/)**: 従来のバージョン管理ツールを置き換える、Rust製の超高速なツール＆環境変数マネージャ。
- **[1Password CLI (op)](https://developer.1password.com/docs/cli/)**: クレデンシャルの安全な管理と、透過的な環境変数への注入。Windows環境の `op.exe` をシームレスにラップして呼び出す仕組みを組み込んでいます。

### 2. 🎨 洗練された美しいTUI
ターミナル上での作業をより快適に、そして美しくするためのTUI（Terminal User Interface）環境を構築しています。
Waylandコンポジタである **Hyprland** の世界観を意識し、スタイリッシュなビジュアルと無駄のない操作感、全体的なデザインの統一性を目指しています。

### 3. 🦀 徹底したRust製ツールの採用
システムの基盤となるコマンドラインツールは、パフォーマンスと安全性に優れた **Rust製** のモダンツールを中心に固めています。
これにより、ターミナルでの日常的なファイル操作や検索、テキスト処理などの動作速度を極限まで高めています。

**主な導入ツール:**
- **helix (hx)**: 操作性に優れたモダンなRust製テキストエディタ
- **eza**: `ls` 代替（モダンでカラフルな表示・アイコン対応）
- **bat**: `cat` 代替（Git連携・シンタックスハイライト付き）
- **ripgrep (rg)**: `grep` 代替（超高速なテキスト検索）
- **fd**: `find` 代替（直感的で高速なファイル検索）
- **starship**: 高速でカスタマイズ自在なクロスシェルプロンプト
- **zellij**: `tmux` 代替となるモダンなターミナルマルチプレクサ
- **zoxide**: `cd` 代替（学習型の高速ディレクトリジャンプ）
- **delta**: Gitやdiffの差分出力を美しくハイライトするページャー
- **atuin**: シェル履歴をSQLiteで保存・同期・検索する強力な履歴ツール
- **fzf**: コマンドラインのファジーファインダー（※Go製ですが環境構築に不可欠な強力なツール）

### 4. 🐳 Docker lessなコンテナ環境 (nerdctl + containerd)
従来のDocker Engine（dockerd）に依存せず、より軽量でモダンなコンテナランタイムである **containerd** と、Docker互換の使いやすいCLI **nerdctl** を採用しています。
これにより、リソース消費を抑えつつスマートなコンテナ開発環境を実現しています。

---

## 🚀 Directory Structure & Setup

環境構築は chezmoi のスクリプト（`.chezmoiscripts`）によって自動化されています。
Linux (`*.sh`) と Windows (`*.ps1`) で同じ番号のスクリプトが同じ役割を担います。

### 主なセットアップの流れ
| # | 役割 | Linux / WSL | Windows |
|---|---|---|---|
| 00 / 10 | Bootstrap・1Password CLI (`op.exe`) ラッパー | ✅ | — |
| 01 | セキュリティツール (safe-chain) | ✅ | ✅ |
| 05 | コアパッケージ | apt | winget |
| 20 | mise 本体のインストール | `mise.run` | winget + shims を User PATH に追加 |
| 40-53 / 90 | コンテナ環境 (nerdctl / k3s / BuildKit)・クリーンアップ | ✅ | — |
| after 06 | フォント (Moralerspace HW, `.chezmoiexternal` で取得) | `fc-cache` | ユーザーフォントとして登録 |
| after 91 | **mise install**: `config.toml` のツール群をインストール（GitHub APIの制限回避機構付き） | ✅ | ✅ |

Windows のスクリプトは Windows PowerShell 5.1 で実行されるため、ASCII のみ・5.1 互換で記述し、
共通処理は `.chezmoitemplates/windows/prelude.ps1` にまとめています。

### シェルと WezTerm
- **bash 系**: `.profile` は環境変数のみ、対話用の初期化（starship / atuin / zoxide / fzf / エイリアス）は `.bashrc` に集約。Windows では Git Bash にも配置されます（mise は shims 経由）。
- **atuin**: 履歴の記録に bash-preexec（`.chezmoiexternal` で取得）を使用。検索は **Ctrl+R のみ**で、↑キーは通常の「1つ前のコマンド」のままです（bash / PowerShell 共通）。
- **WezTerm の起動シェル**: WSL の Ubuntu が登録済みなら WSL、無ければ pwsh。いずれも zellij があれば自動で attach し、無ければ素のシェルを開きます。
  Ctrl+Shift+L のランチャーから pwsh / Git Bash / WSL（存在するものだけ）を選べます。テーマは常に Catppuccin Mocha です。

### 適用方法
```bash
# chezmoiの初期化と適用
chezmoi init --apply <your-github-username>
```

## 📜 License

MIT License
