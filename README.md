# uexDemo 示例插件

## 📖 项目简介

uexDemo是AppCan插件开发的示例项目，展示了如何在HarmonyOS平台上开发AppCan插件。该插件包含了插件开发的基本功能和最佳实践，是开发者学习AppCan插件开发的理想起点。

## AppCan鸿蒙插件开发指南

详情请参考本工程内的:[AppCan鸿蒙版插件开发指南](./docs/AppCan鸿蒙插件开发指南.md)

## 🚀 快速开始

### 集成方法

1. 将uexDemo模块添加到AppCan引擎工程的plugins目录下。
2. 在entry模块的oh-package.json5的dependencies中添加`"@appcan/uexDemo": "file:../plugins/uexDemo"`。
3. 在entry模块的src/main/ets/AppCanExPluginProvider.ets中导入插件配置（配置内容查看插件工程目录下/uexDemo/plugin.config.ts）。
4. 在entry模块的src/main/ets/AppCanExPluginProvider.ets中导入EUExDemo并注册插件实例。

### 功能特性

- ✅ **基础接口示例**: 展示插件与前端JS的数据交互方式
- ✅ **页面跳转**: 演示如何在插件中打开原生页面
- ✅ **文件操作**: 展示AppCan文件协议的使用方法
- ✅ **回调机制**: 演示同步回调、异步回调和命名回调的使用
- ✅ **参数处理**: 展示如何处理前端传入的各种类型参数
- ✅ **日志记录**: 演示插件开发中的日志记录最佳实践

### 开发状态

- 🎯 **基础功能**: ✅ 已完成 - 核心示例功能 (3/3个接口完成)
- 📚 **文档示例**: ✅ 已完成 - 完整的开发示例和说明

**当前完成度**: 100% | **功能**: 完整的插件开发示例

## 📚 API接口

### 核心接口

| 接口名称 | 功能描述 | 参数说明 | 返回值 |
|---------|---------|---------|--------|
| `testFirstInterface` | 基础接口示例 | string, number, object, function | string |
| `openMainPage` | 打开插件页面 | 无 | void |
| `testHandleFileProtocolPath` | 文件协议示例 | 无 | void |

### 接口详情

#### testFirstInterface
```javascript
// 调用示例
const result = uexDemo.testFirstInterface('abc', 123, {bbb: 'ccc'}, (data, extraInfo) => {
    console.log('回调数据:', data, extraInfo);
});
console.log('同步返回:', result);
```

**功能**: 演示插件接口的基本用法，包括参数传递、同步返回、异步回调和命名回调。

**参数**:
- `param1` (string): 字符串参数示例
- `param2` (number): 数字参数示例  
- `param3` (object): 对象参数示例
- `param4` (function): 回调函数参数示例

**返回值**: 
- 同步返回字符串结果
- 异步回调传递处理结果
- 命名回调 `uexDemo.onFinishFirstInterface`

#### openMainPage
```javascript
// 调用示例
uexDemo.openMainPage();
```

**功能**: 打开插件内置的原生页面，演示页面跳转功能。

#### testHandleFileProtocolPath
```javascript
// 调用示例
uexDemo.testHandleFileProtocolPath();
```

**功能**: 演示AppCan文件协议的使用，包括res://和wgt://协议的路径转换和文件操作。

## 🛠️ 开发指南

### 项目结构

```
plugins/uexDemo/
├── src/main/ets/           # 插件源代码
│   ├── EUExDemo.ets       # 插件入口类
│   ├── components/        # 原生页面组件
│   │   └── MainPage.ets   # 示例页面
│   └── vo/                # 数据模型
│       └── CallbackDataVO.ets # 回调数据模型
├── uexDemo/               # 插件配置
│   ├── plugin.config.ts   # 插件元数据
│   └── info.xml           # 插件信息
├── oh-package.json5       # 依赖配置
└── README.md              # 项目说明
```

### 核心组件

#### 🎯 入口层
- **EUExDemo**: 插件入口类，继承EUExBase，实现所有对外API接口

#### 🖥️ 页面层  
- **MainPage**: 示例原生页面，演示插件内页面开发

#### 📦 数据模型层
- **FirstInterfaceCBO**: 回调数据模型，定义接口回调的数据结构

### 开发要点

#### 1. 插件入口类开发
```typescript
export default class EUExDemo extends EUExBase {
  // 继承EUExBase，实现插件基础功能
  
  public testFirstInterface(...params: object[]): string {
    // 实现具体业务逻辑
    // 支持同步返回和异步回调
  }
  
  protected clean(): boolean {
    // 实现资源清理逻辑
    return false;
  }
}
```

#### 2. 回调机制使用
```typescript
// 匿名函数回调
this.callbackJsFunction(cbFunc, cbData, "extra info");

// 命名方法回调  
this.callbackJsObject(this.CALLBACK_NAME, cbData);

// 同步返回
return "result data";
```

#### 3. 文件协议处理
```typescript
// 协议路径转换
const realPath = BUtility.makeRealPath(protocolPath, this.mBrwView);

// 文件操作
fs.copyFile(sourcePath, targetPath);
```

#### 4. 页面跳转
```typescript
// 导入页面组件
import('./components/MainPage');

// 路由跳转
router.pushNamedRoute({name: 'pageName'});
```

### 配置文件

#### plugin.config.ts
```typescript
export const pluginConfig = {
  "plugins": [
    {
      "uexName": "uexDemo",
      "methods": [
        "testFirstInterface",
        "openMainPage", 
        "testHandleFileProtocolPath"
      ]
    }
  ]
}
```

#### info.xml
```xml
<?xml version="1.0" encoding="utf-8"?>
<uexplugins>
    <plugin uexName="uexDemo" version="1.0.0" build="2024072301">
        <info>0:示例插件改动</info>
        <build>0:AppCan示例插件</build>
    </plugin>
</uexplugins>
```

### 测试页面

插件提供了完整的测试页面 `entry/src/main/resources/resfile/widget/uexDemo/uexDemo.html`，包含：

- 🧪 **接口测试**: 测试所有API接口功能
- 📝 **日志输出**: 实时显示接口调用结果
- 🎯 **交互示例**: 演示各种参数传递和回调方式

### 开发环境

- **平台**: HarmonyOS NEXT
- **语言**: ArkTS (TypeScript)  
- **框架**: AppCan Engine
- **构建**: DevEco Studio

## 📖 学习指南

### 适用人群

- AppCan插件开发初学者
- HarmonyOS应用开发者
- 需要了解AppCan插件机制的开发者

### 学习路径

1. **基础概念**: 了解AppCan插件架构和开发流程
2. **环境搭建**: 配置HarmonyOS开发环境和AppCan引擎
3. **代码学习**: 研究uexDemo源码，理解插件开发模式
4. **实践开发**: 基于示例代码开发自己的插件功能
5. **测试验证**: 使用测试页面验证插件功能

### 关键知识点

- **插件生命周期**: 插件的初始化、调用和清理过程
- **数据交互**: 前端JS与原生代码的数据传递机制
- **回调模式**: 同步回调、异步回调和命名回调的使用场景
- **文件系统**: AppCan文件协议和路径处理方式
- **页面管理**: 原生页面的创建和跳转方法

## 🔗 相关链接

- [AppCan官网](https://www.appcan.cn/)
- [AppCan插件开发文档](https://newdocx.appcan.cn/)
- [HarmonyOS开发文档](https://developer.huawei.com/consumer/cn/harmonyos/)
- [ArkTS语言参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/arkts-syntax)

## 📋 开发规范

### 命名规范
- 插件名称: uex + 功能名称 (如: uexDemo)
- 入口类名: EUEx + 功能名称 (如: EUExDemo)
- 方法命名: 驼峰命名法，语义清晰

### 代码规范
- 继承EUExBase基类
- 实现clean()方法进行资源清理
- 使用BDebug进行日志记录
- 合理使用回调机制
- 遵循ArkTS编码规范

### 文档规范
- 提供完整的README.md说明
- API接口文档要详细清晰
- 包含使用示例和测试用例
- 说明插件的功能特性和适用场景

## 💡 开发技巧

### 参数处理最佳实践
```typescript
// 处理可选参数
public someMethod(...params: object[]): void {
  const param1 = params[0] as string || '';
  const param2 = params[1] as number || 0;
  const callback = params[2] as Function;

  // 参数验证
  if (!param1) {
    BDebug.error(this.LogTag, 'param1 is required');
    return;
  }
}
```

### 错误处理模式
```typescript
// 统一错误处理
try {
  // 业务逻辑
} catch (error) {
  BDebug.error(this.LogTag, 'method error:', error);
  // 错误回调
  this.callbackJsFunction(callback, {
    status: -1,
    error: error.message
  });
}
```

### 资源管理
```typescript
// 在clean方法中清理资源
protected clean(): boolean {
  // 清理定时器
  if (this.timer) {
    clearInterval(this.timer);
    this.timer = undefined;
  }

  // 清理回调引用
  this.callbacks.clear();

  return true;
}
```

## 🚨 常见问题

### Q: 插件接口调用失败？
**A**: 检查以下几点：
1. plugin.config.ts中是否正确声明了方法名
2. AppCanExPluginProvider.ets中是否正确导入和加载配置
3. AppCanExPluginProvider.ets中是否正确实例化
4. 方法签名是否与声明一致

### Q: 回调函数不执行？
**A**: 确认：
1. 回调函数参数是否正确传递
2. 使用正确的回调方法（callbackJsFunction vs callbackJsObject）
3. 回调数据格式是否正确

### Q: 文件路径转换失败？
**A**: 注意：
1. 使用BUtility.makeRealPath进行路径转换
2. 确保文件协议格式正确（res://, wgt://等）
3. 检查文件是否存在

### Q: 页面跳转不成功？
**A**: 检查：
1. 页面组件是否正确导入
2. 路由名称是否正确配置
3. 页面组件是否正确实现

## 📈 扩展建议

### 功能扩展方向
- 添加更多文件操作示例
- 增加网络请求示例
- 添加数据库操作示例
- 实现更复杂的页面交互

### 性能优化建议
- 合理使用异步操作
- 避免内存泄漏
- 优化大数据处理
- 减少不必要的回调

---

📧 如有问题，请参考AppCan官方文档或提交Issue。

> **提示**: 这是一个完整的插件开发示例，建议开发者在此基础上进行功能扩展和定制化开发。
