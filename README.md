# 台湾16张麻将游戏

一个使用Flutter开发的台湾16张麻将游戏，支持单机多人游戏，包含完整的麻将规则和美观的用户界面。

## 功能特性

### 🎮 游戏功能
- **完整的麻将规则**: 支持台湾16张麻将的所有基本规则
- **多种胡牌类型**: 平胡、七对、十三幺、九莲宝灯等
- **碰杠吃操作**: 支持碰牌、杠牌、吃牌等基本操作
- **番型计算**: 清一色、混一色、字一色等多种番型
- **单机多人**: 支持1人+3个AI玩家的游戏模式

### 🎨 界面设计
- **现代化UI**: 采用Material Design设计语言
- **响应式布局**: 适配不同屏幕尺寸
- **动画效果**: 丰富的动画效果提升用户体验
- **音效支持**: 完整的音效系统（需要添加音效文件）

### 🛠 技术特性
- **Flutter框架**: 跨平台开发，支持iOS、Android、Web等
- **状态管理**: 使用Provider进行状态管理
- **模块化设计**: 清晰的代码结构，易于维护和扩展
- **类型安全**: 使用Dart的强类型系统

## 项目结构

```
lib/
├── models/                 # 数据模型
│   ├── tile.dart          # 麻将牌模型
│   ├── player.dart        # 玩家模型
│   └── game_state.dart    # 游戏状态模型
├── game_logic/            # 游戏逻辑
│   └── mahjong_rules.dart # 麻将规则判断
├── providers/             # 状态管理
│   └── game_provider.dart # 游戏控制器
├── screens/               # 界面
│   ├── home_screen.dart   # 主界面
│   └── game_screen.dart   # 游戏界面
├── widgets/               # 组件
│   ├── tile_widget.dart   # 麻将牌组件
│   ├── player_hand_widget.dart # 玩家手牌组件
│   ├── discard_pile_widget.dart # 弃牌堆组件
│   └── game_info_widget.dart   # 游戏信息组件
├── services/              # 服务
│   ├── audio_service.dart # 音效服务
│   └── animation_service.dart # 动画服务
└── main.dart              # 应用入口
```

## 安装和运行

### 环境要求
- Flutter SDK 3.7.2 或更高版本
- Dart SDK 3.0.0 或更高版本
- Android Studio / VS Code
- iOS Simulator / Android Emulator 或真机

### 安装步骤

1. **克隆项目**
   ```bash
   git clone <repository-url>
   cd tw16_mahjong
   ```

2. **安装依赖**
   ```bash
   flutter pub get
   ```

3. **运行项目**
   ```bash
   flutter run
   ```

### 构建发布版本

**Android APK**
```bash
flutter build apk --release
```

**iOS IPA**
```bash
flutter build ios --release
```

**Web版本**
```bash
flutter build web --release
```

## 游戏规则

### 基本规则
- 每人16张手牌
- 支持万子、条子、筒子、字牌四种牌型
- 目标：组成4个顺子/刻子 + 1个对子，或者特殊牌型

### 胡牌类型
- **平胡**: 4个顺子/刻子 + 1个对子
- **七对**: 7个对子
- **十三幺**: 1-9万条筒各一张 + 东南西北中发白各一张 + 其中一张成对
- **九莲宝灯**: 同花色1112345678999 + 任意一张同花色

### 番型计算
- **清一色**: 全部为同一种花色的数字牌
- **混一色**: 全部为同一种花色的数字牌 + 字牌
- **字一色**: 全部为字牌
- **大三元**: 中发白各一刻
- **小三元**: 中发白中两个刻子一个对子

## 开发说明

### 添加新功能
1. 在相应的模块中添加代码
2. 更新游戏状态管理
3. 添加UI组件
4. 测试功能

### 自定义音效
1. 将音效文件放入 `assets/sounds/` 目录
2. 支持的格式：MP3, WAV, OGG
3. 文件名对应音效类型：
   - `draw_tile.mp3` - 摸牌音效
   - `discard_tile.mp3` - 打牌音效
   - `win.mp3` - 胡牌音效
   - `peng.mp3` - 碰牌音效
   - `gang.mp3` - 杠牌音效
   - `chi.mp3` - 吃牌音效
   - `button_click.mp3` - 按钮点击音效
   - `background_music.mp3` - 背景音乐

### 自定义麻将牌图片
1. 将图片文件放入 `assets/images/tiles/` 目录
2. 命名规则：
   - 万子：`wan_1.png` 到 `wan_9.png`
   - 条子：`tiao_1.png` 到 `tiao_9.png`
   - 筒子：`tong_1.png` 到 `tong_9.png`
   - 字牌：`zi_东.png`, `zi_南.png`, `zi_西.png`, `zi_北.png`, `zi_中.png`, `zi_发.png`, `zi_白.png`

## 贡献指南

1. Fork 项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 打开 Pull Request

## 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情

## 联系方式

如有问题或建议，请通过以下方式联系：
- 创建 Issue
- 发送邮件至 [your-email@example.com]

## 更新日志

### v1.0.0 (2024-01-XX)
- 初始版本发布
- 实现基本麻将游戏功能
- 添加UI界面和动画效果
- 支持音效系统

## 致谢

感谢所有为这个项目做出贡献的开发者和测试者。

---

**享受游戏！** 🀄️