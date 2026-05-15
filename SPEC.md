# Vue3 + TypeScript 基础模板规范

## 1. 项目概述

- **项目名称**: vue3-ts-starter
- **项目类型**: Vue 3 + TypeScript Web 应用模板
- **核心功能**: 预配置 Vue3 + TS 开发环境，集成 UnoCSS 和 Element Plus 按需加载
- **目标用户**: 需要快速启动 Vue3 项目的开发者

## 2. 技术栈

- **框架**: Vue 3.4+ (Composition API)
- **语言**: TypeScript 5.x
- **构建工具**: Vite 5.x
- **CSS 框架**: UnoCSS (原子化 CSS)
- **UI 组件库**: Element Plus (按需加载)
- **路由**: Vue Router 4.x

## 3. 项目结构

```
vue3-ts-starter/
├── src/
│   ├── components/      # 业务组件
│   ├── views/           # 页面视图
│   ├── router/         # 路由配置
│   ├── App.vue
│   └── main.ts
├── uno.config.ts        # UnoCSS 配置
├── element-plus.ts     # Element Plus 按需导入配置
├── tsconfig.json
├── vite.config.ts
└── package.json
```

## 4. 配置要求

### UnoCSS
- 支持 presetUno、presetAttributify、presetIcons
- 配置常用工具类

### Element Plus
- 按需加载（unplugin-vue-components + unplugin-auto-import）
- 自动导入组件样式

## 5. 验收标准

- [ ] 项目可正常启动 `npm run dev`
- [ ] TypeScript 类型检查通过
- [ ] UnoCSS 样式生效
- [ ] Element Plus 组件可用且按需加载