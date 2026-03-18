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

### 主なセットアップの流れ
1. **Bootstrap**: 必要なベース環境へのパス通しなど。
2. **op-wrapper setup**: 環境に合わせた 1Password CLI (`op.exe`) のラッパーを作成し、クレデンシャル管理を準備。
3. **mise install**: `mise.toml` に定義された最新のRust製ツール群を並行インストール（GitHub APIの制限回避機構付き）。

### 適用方法
```bash
# chezmoiの初期化と適用
chezmoi init --apply <your-github-username>
```

## 📜 License

MIT License
