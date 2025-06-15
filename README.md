# TopicDanmaku（话题弹幕）

## 项目简介
TopicDanmaku 是一款帮助用户积攒话题关键词的应用，旨在解决聊天时找不到话题的问题。通过气泡弹幕的形式展示话题关键词，用户可以增删查话题，增删改查话题对应的备注。

## 功能列表
### 基础功能
- 话题关键字录入界面
- 气泡弹幕动画引擎
- 本地存储用户数据
- 气泡交互反馈系统

## 更新功能
1. **侧边栏菜单**
   - 支持通过滑动手势呼出和隐藏。
   - 动态生成菜单项，点击菜单项可执行相应操作。

2. **气泡交互**
   - 点击气泡可查看备注。
   - 长按气泡可进入编辑或删除模式。

3. **夜间模式**
   - 添加夜间模式切换按钮，支持一键切换背景颜色。

4. **弹幕控制**
   - 支持调整气泡密度、速度和大小。
   - 支持筛选特定分类的话题气泡显示。

5. **个性化设置**
   - 支持调整弹幕显示区域。
   - 支持选择字体样式。

## 使用说明
- **呼出侧边栏**：从屏幕左侧向右滑动或者点击界面左上角的“≡”按钮。
- **气泡操作**：
  - 点击气泡：查看备注。
- **夜间模式**：点击菜单栏的暗色模式按钮切换夜间模式，或者双击主界面。
- **弹幕控制**：通过界面右上角的刷新按钮和暂停按钮，重置话题气泡和暂停弹幕。

## 开发环境
- 平台：Adobe AIR for Android，Adobe AIR for Desktop

- 开发环境：Adobe Animate 2021

- 尺寸：Android：720x1280

  ​            Windows：1280x720

- 主程序：`TopicDanmaku.as`

## 文件结构
```ActionScript3.0
TopicDanmaku/
├── Android/
│   ├── TopicDanmaku-app.xml
│   ├── TopicDanmaku.apk
│   ├── TopicDanmaku.as
│   ├── TopicDanmaku.fla
│   ├── TopicDanmaku.html
│   ├── TopicDanmaku.swf
│   ├── components/
│   │   ├── Bubble.as
│   │   ├── BubbleManager.as
│   │   └── topicsManager.as
│   ├── icos/
│   │   ├── 36.png
│   │   ├── 48.png
│   │   ├── 72.png
│   │   ├── 96.png
│   │   ├── 144.png
│   │   └── 192.png
│   └── td.p12
├── Windows/
│   ├── TopicDanmaku-app.xml
│   ├── TopicDanmaku.as
│   ├── TopicDanmaku.fla
│   ├── TopicDanmaku.html
│   ├── TopicDanmaku.swf
│   ├── components/
│   │   ├── Bubble.as
│   │   ├── BubbleManager.as
│   │   └── topicsManager.as
│   ├── icos/
│   │   ├── 16.png
│   │   ├── 32.png
│   │   ├── 48.png
│   │   └── 128.png
│   └── td.p12
├── 策划书.txt
├── 使用说明.txt
└── README.md
```
