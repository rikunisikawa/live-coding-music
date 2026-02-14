#!/bin/bash

# このスクリプトは、WSLからWindowsへperformance/ディレクトリとdocs/ディレクトリを同期します。
# WINDOWS_PROJECT_ROOTをご自身のWindows上のFoxDotプロジェクトのルートパスに更新してください。

# 例: /mnt/c/Users/YourUser/Documents/FoxDotProject/
WINDOWS_PROJECT_ROOT="/path/to/your/windows/foxdot/project"

echo "performance/ を Windows へ同期中..."
rsync -av --delete performance/ "${WINDOWS_PROJECT_ROOT}/performance/"

echo "docs/ を Windows へ同期中..."
rsync -av --delete docs/ "${WINDOWS_PROJECT_ROOT}/docs/"

echo "同期が完了しました。"