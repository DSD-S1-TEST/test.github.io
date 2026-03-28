#!/bin/bash
mkdir -p src/content/home src/content/progress src/content/news src/content/members src/components src/utils

cat << 'INNER_EOF' > vite.config.ts
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  base: '/test.github.io/',
})
INNER_EOF

cat << 'INNER_EOF' > src/utils/mdParser.ts
import fm from 'front-matter';

export interface NewsAttributes {
  title: string;
  date: string;
  author: string;
  summary: string;
}

export interface MemberAttributes {
  name: string;
  role: string;
  avatar: string;
  skills: string;
}

export function parseFrontMatter<T>(raw: string) {
  return fm<T>(raw);
}
INNER_EOF

cat << 'INNER_EOF' > src/vite-env.d.ts
/// <reference types="vite/client" />

declare module 'front-matter' {
    function fm<T>(content: string): { attributes: T; body: string; frontmatter: string };
    export = fm;
}
INNER_EOF

cat << 'INNER_EOF' > src/content/home/index.md
# SYSTEM INITIALIZED : DSD-S1-TEST

欢迎进入 **DSD-S1-TEST** 组织的开发中心控制台。
本站点采用纯文本 Markdown 架构，专为高效协作设计。

## SYSTEM FEATURES 核心机制
- 🚀 **完全静态化**：Vite + React，极致加载速度。
- 📝 **Markdown 驱动**：组织内任何人只需提交 `.md` 文件，即可发布新闻或更新进度。
- 📊 **图表即代码**：内置 Mermaid 解析器，轻松输出甘特图。
- 🤖 **自动部署**：一键 Push，GitHub Actions 自动构建无服务器后台。

## ACCESS GRANTED 终端指南
请使用上方导航栏查阅各项数据档案：
* `[news]` - 项目周期内的公告与更新日志。
* `[progress]` - 整个架构的进度状态图表。
* `[members]` - 系统开发组成员及职责档案。
INNER_EOF

cat << 'INNER_EOF' > src/content/progress/gantt.md
gantt
    title DSD-S1-TEST 整体研发进度表
    dateFormat  YYYY-MM-DD
    axisFormat  %m-%d

    section 第一阶段：基础设施
    技术选型规划           :done,    task1, 2026-03-25, 2026-03-26
    静态服务器与基础路由     :done,    task2, 2026-03-27, 2d
    科技风UI重构           :active,  task3, 2026-03-29, 2d
    Markdown解析引擎       :         task4, after task3, 3d

    section 第二阶段：功能扩展
    自动化部署流水线       :         task5, 2026-04-02, 3d
    测试与联调           :         task6, after task5, 4d
INNER_EOF

cat << 'INNER_EOF' > src/content/news/2026-03-28-init.md
---
title: "控制台及协作展示终端 V1.0 初始化"
date: "2026-03-28"
author: "Admin"
summary: "我们确立了全新科技风架构，并上线了 Markdown 自动化构建系统。"
---

# 控制台及协作展示终端 V1.0 初始化

今日，DSD-S1-TEST 的前端系统迎来了重大重构。

为了保证各位成员在不触碰复杂前端代码的情况下能够自如地更新网站，我们将整个内容库迁移到了 `src/content/` 目录下。

## 更新指南
1. **添加新闻**：在 `src/content/news/` 新建一个 `.md` 文件，填入 Title 等 Frontmatter 信息。
2. **记录甘特图**：修改 `src/content/progress/gantt.md`。
3. **新增成员名片**：在 `src/content/members/` 中添加文件。

请各位探员享受这顺滑的使用体验。
INNER_EOF

cat << 'INNER_EOF' > src/content/members/alice.md
---
name: "Alice"
role: "前端工程师 / UI设计"
avatar: "👩‍💻"
skills: "React, Tailwind, CSS Animation"
---
# Alice 探员履历

负责 DSD-S1-TEST 的视觉体验与交互设计。
将枯燥的代码转化为赛博控制台。
INNER_EOF

cat << 'INNER_EOF' > src/content/members/bob.md
---
name: "Bob"
role: "系统架构 / DevOps"
avatar: "👨‍🔧"
skills: "GitHub Actions, Node.js, Vite"
---
# Bob 探员履历

专注于流程自动化与工程基建。
维护着这个项目的血液和呼吸。
INNER_EOF

chmod +x generate_structure.sh
