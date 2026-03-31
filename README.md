<div align="center">
  <img src="musicdl_image.png" width="200" alt="Music Hunters" />
  <h1>Music Hunters</h1>
  <p>一个跨平台音乐搜索与播放的 Android 应用，支持网易云、QQ音乐、酷我、咪咕等多个音乐平台。</p>
  <p>
    <strong>基于 <a href="https://github.com/CharlesPikachu/musicdl">CharlesPikachu/musicdl</a> 项目开发</strong>
  </p>
</div>

---

## 项目简介

Music Hunters 将 [musicdl](https://github.com/CharlesPikachu/musicdl) 的强大音乐搜索能力封装为 Android 移动应用。用户可以通过一个界面搜索并播放来自多个音乐平台的歌曲，无需在不同App之间切换。

### 架构

```
┌─────────────┐        ┌──────────────────┐        ┌──────────┐
│  Android App │ ──────▶│  FastAPI Backend  │ ──────▶│  CDN 直播 │
│  (Flutter)   │◀────── │  (Python/musicdl) │        │  (音频流) │
└─────────────┘  搜索+  └──────────────────┘        └──────────┘
                resolve                                    ▲
                                                           │
                                              手机直接播放 CDN URL
```

- **前端**: Flutter Android 应用
- **后端**: Python FastAPI，复用 musicdl 的搜索引擎
- **播放**: 手机直接从 CDN 播放音频（不经过后端代理）
- **缓存**: 播放过的歌曲自动缓存到本地，再次播放零流量

## 支持的音乐平台

| 平台 | 搜索 | 播放 | 来源 |
| :-- | :--: | :--: | :-- |
| 网易云音乐 | ✅ | ✅ | [netease.py](musicdl/modules/sources/netease.py) |
| QQ音乐 | ✅ | ✅ | [qq.py](musicdl/modules/sources/qq.py) |
| 酷我音乐 | ✅ | ✅ | [kuwo.py](musicdl/modules/sources/kuwo.py) |
| 咪咕音乐 | ✅ | ✅ | [migu.py](musicdl/modules/sources/migu.py) |

> 原项目 [musicdl](https://github.com/CharlesPikachu/musicdl) 支持 21+ 音乐平台（Spotify、YouTube、Apple Music、Tidal、Qobuz、Deezer 等），本项目后端可按需启用更多源。

## 功能特性

- **多平台聚合搜索** — 一次搜索，多个平台结果
- **即点即播** — 搜索结果直接播放，秒级响应
- **智能缓存** — 播放过的歌曲自动缓存，再次播放不消耗流量
- **后台播放** — 支持后台音乐播放
- **本地歌单** — SQLite 本地存储，管理个人歌单
- **歌曲下载** — 支持下载到本地离线收听

## 快速开始

### 1. 部署后端

```bash
# 克隆项目
git clone https://github.com/anciea/music-hunters.git
cd music-hunters

# 创建虚拟环境并安装依赖
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
pip install uvicorn fastapi httpx cachetools pydantic pycryptodomex

# 设置 API 密钥并启动
export MUSICDL_API_KEY=your-secret-key
uvicorn api.main:app --host 0.0.0.0 --port 8000
```

### 2. 构建 Android App

```bash
cd mobile

# 修改 lib/core/config/app_config.dart 中的 API 地址和密钥
# defaultValue: 'http://your-server-ip'
# defaultValue: 'your-secret-key'

# 构建 APK
flutter build apk --release
```

### 3. 安装到手机

```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

## 技术栈

| 组件 | 技术 |
| :-- | :-- |
| Android 前端 | Flutter / Dart |
| 状态管理 | Riverpod |
| 音频播放 | just_audio + audio_service |
| 后端 API | Python FastAPI |
| 音乐搜索引擎 | [musicdl](https://github.com/CharlesPikachu/musicdl) |
| 本地存储 | SQLite (sqflite) |
| 网络请求 | Dio (前端) / requests + httpx (后端) |

## 项目结构

```
music-hunters/
├── api/                    # FastAPI 后端
│   ├── main.py             # 应用入口
│   ├── patches.py          # API 模式搜索优化
│   └── routers/
│       ├── search.py       # 搜索端点
│       └── stream.py       # CDN URL 解析端点
├── mobile/                 # Flutter Android 应用
│   └── lib/
│       ├── core/           # 音频、API、配置
│       └── features/       # 搜索、播放器、歌单
├── musicdl/                # 原项目核心搜索引擎
└── musicdl-api.service     # systemd 部署配置
```

## 致谢

本项目基于 [CharlesPikachu/musicdl](https://github.com/CharlesPikachu/musicdl) 开发，感谢原作者提供的强大音乐搜索引擎。

## 声明

本项目仅供学习和研究使用，禁止商业用途。软件仅与公开可访问的网络端点交互，不托管、存储或分发任何受版权保护的内容。
