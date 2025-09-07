#!/bin/bash

echo "🎮 启动台湾16张麻将游戏..."
echo ""

# 检查Flutter是否安装
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter未安装，请先安装Flutter"
    exit 1
fi

# 检查依赖
echo "📦 检查依赖..."
flutter pub get

# 运行项目
echo "🚀 启动游戏..."
echo "选择运行平台："
echo "1) Chrome浏览器 (推荐)"
echo "2) Android模拟器"
echo "3) iOS模拟器"
echo "4) 桌面应用"

read -p "请输入选择 (1-4): " choice

case $choice in
    1)
        echo "🌐 在Chrome浏览器中启动..."
        flutter run -d chrome --web-port=8080
        ;;
    2)
        echo "📱 在Android模拟器中启动..."
        flutter run -d android
        ;;
    3)
        echo "🍎 在iOS模拟器中启动..."
        flutter run -d ios
        ;;
    4)
        echo "🖥️ 在桌面应用中启动..."
        flutter run -d macos
        ;;
    *)
        echo "❌ 无效选择，默认使用Chrome浏览器"
        flutter run -d chrome --web-port=8080
        ;;
esac
