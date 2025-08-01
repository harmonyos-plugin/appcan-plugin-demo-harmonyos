## 创建并初始化插件开发工程

假设需要创建的插件名称为uexDemo，以下为具体步骤：

1. 新建一个module，命名为uexDemo（如果是在引擎调试工程内，则右键点击plugins目录，在其中新建module）。
2. 插件配置文件：在插件工程目录（例如：plugins/uexDemo）下，再创建一个与插件名同名的目录（例如：plugins/uexDemo/uexDemo），作为插件包压缩为zip之前的目录，其中存放插件的版本信息info.xml以及插件的接口声明json文件plugin.json，其中plugin.json对应的是Android中的plugin.xml，只是在鸿蒙版本中采用了json格式。
3. 配置插件工程对engine模块的依赖，在插件工程的oh-package.json5文件的dependencies中增加```"@appcan/engine": "file:../../engine"```
4. 在src/main/ets中新建一个ArkTS File，命名为EUExDemo，作为插件入口类，继承EUExBase
5. 在module内的Index.ets中导出EUExDemo入口类

## 插件配置文件实例

### plugin.json示例

```
{
  "plugins": [
    {
      "className": "EUExBase",
      "uexName": "uexDemo",
      "methods": [
        "open"
      ]
    }
  ]
} 
```

### info.xml示例

```
<?xml version="1.0" encoding="utf-8"?>
<uexplugins>
    <plugin
        uexName="uexDemo" version="1.0.0" build="2024072301">
        <info>0:示例插件改动</info>
        <build>0:AppCan示例插件</build>
    </plugin>
</uexplugins> 
```

## 手动配置与引擎基础工程关联调试

1. 打开引擎基础工程内的entry/oh-package.json5，dependencies内添加uexDemo的module，示例如下：

```
  "dependencies": {
    "@appcan/engine": "file:../engine",
    "@appcan/uexDemo": "file:../plugins/uexDemo"
  }
```

2. 打开引擎基础工程内的entry/src/main/resources/base/profile/appcan\_extend\_plugins.json，在plugins节点内，增加uexDemo插件的名称并注册对外开放的JS方法名，示例如下：

```
{
  "plugins": [
    {
      "uexName": "uexDemo",
      "methods": [
        "openMainPage",
        "testFirstInterface",
        "testHandleFileProtocolPath"
      ]
    }
  ]
}
```

3. 打开引擎基础工程内的entry/src/main/ets/AppCanExPluginProvider.ets，导入EUExDemo，并在obtainInitializedPlugins方法内增加uexDemo插件的注册代码，示例如下：

```
import { EUExDemo } from '@appcan/uexDemo';
```

```
  obtainInitializedPlugins(context: Context, brwView: EBrowserView): Map<string, EUExBase> {
    const pluginsClassMap: Map<string, EUExBase> = new Map();
    // TODO 在此声明插件实例化对象
    pluginsClassMap.set("uexDemo", new EUExDemo(context, brwView));
    return pluginsClassMap;
  }
```

4. 特殊场景下，如果需要声明EngineEventListener监听，则需要在obtainInitializedEventListeners方法内插入对应的初始化代码，示例如下：

```
  obtainInitializedEventListeners(context: Context, brwView: EBrowserView): EngineEventListener[] {
    const pluginsEventListenerList: EngineEventListener[] = [];
    // TODO 在此声明插件事件监听对象
    pluginsEventListenerList.push(new EMMEngineEventListener());
    return pluginsEventListenerList;
  }
```

5. 这样即可在entry/src/main/resources/resfile/widget内修改对应的测试用例来测试插件了。

## EUExBase入口类详解

- AppCan插件入口类都应当继承自EUExBase，EUExBase提供了很多上下文相关实例以及回调方法等，用于插件与JS端的通信和数据交互。 
- 下面给出部分示例代码，完整部分请直接参考uexDemo示例工程。

### 入口类方法传入参数处理标准模式

鸿蒙版与Android版的入口类API方法入参定义是不一样的。
**鸿蒙版**，JS方法调用的入参是JS传入的真实的参数类型和参数列表，所以最终入口类接收到的是JS传入的真实参数，为了统一为数组形式处理，需要使用...语法来进行参数合并定义，内部元素类型则统一定义为Object；
**Android版**，JS方法调用的入参是字符串，而且统一进行了参数合并，所以最终入口类接收到的是字符串数组。

鸿蒙版的入口类API方法入参推荐定义如下：

```typescript
public methodName(...params: Array<Object>): void
```
或者也可以是：

```typescript
public methodName(...params: Object[]): void
```

甚至或者，也可以是（可用，但不推荐）：

```typescript
public methodName(...params: string[]): void
```

但即使定义了string数组，形似Android版，且运行不会报错，但也不代表JS实际传入的参数就一定是string类型，所以需要结合代码逻辑来判断，否则会发生类型错误。


### 入口类示例

```
import { EUExBase, EBrowserView, CallbackConstant } from '@appcan/engine';

/**
 * uexDemo插件
 *
 * 插件的入口类，继承自EUExBase
 */
export default class EUExDemo extends EUExBase {
  private static readonly TAG: string = 'uexDemo';

  public constructor(context: Context, brwView: EBrowserView) {
    super(context, brwView);
  }

  /**
   * 打开
   * @param params [opId, method, url, timeout]
   */
  public open(...params: Object[]): void {
    // TODO: 实现具体逻辑
  }

  protected clean(): boolean {
    return false;
  }
} 
```

### 与JS交互方法详解

EUExBase中提供了多种与JS交互的方法，可以根据不同场景选择使用。以下是所有可用的JS交互方法：

#### 1. callbackJs(inScript: string)
**作用**: 直接执行JS代码，一般用于监听式持续回调网页JS函数或对象的接口
**参数**:
- `inScript`: 要执行的JavaScript代码字符串
**使用场景**: 需要执行自定义JS代码时使用，灵活性最高
**示例**:
```typescript
this.callbackJs("console.log('Hello from native');");
this.callbackJs("if(window.myCallback){window.myCallback('data');}");
```

#### 2. callbackJsFunction(functionObj: Object, ...cbData: Object[])
**作用**: 使用调用者提供的JS Function进行数据回调（v4版本API推荐使用）
**参数**:
- `functionObj`: JS Function对象
- `cbData`: 要传递给函数的参数（可变参数）
**使用场景**: 当JS端传递Function对象作为回调时使用，是v4版本API的标准回调方式
**示例**:
```typescript
// JS端调用: uexDemo.test('param', (result) => { console.log(result); });
public test(param: string, callback: Function): void {
    // 执行业务逻辑后回调
    this.callbackJsFunction(callback, {status: 'success', data: 'result'});
}
```

#### 3. callbackJsObject(methodName: string, objectValue: object | number | string)
**作用**: 给指定方法名回调单个参数数据（多用于v3版本API使用，v4也可用）
**参数**:
- `methodName`: 要调用的JS方法名
- `objectValue`: 要传递的数据，支持object、number、string类型
**使用场景**: v3版本API的标准回调方式，方法名通常以插件名开头，也可用于持续回调或传递监听事件的场景
**示例**:
```typescript
// 回调到 uexDemo.onResult 方法
this.callbackJsObject('uexDemo.onResult', {code: 0, message: 'success'});
this.callbackJsObject('uexDemo.onResult', 'simple string');
this.callbackJsObject('uexDemo.onResult', 123);
```

#### 4. callbackJsObjectWithMultiParams(methodName: string, ...objectValue: (object | number | string)[])
**作用**: 给指定方法名回调多个参数数据（多用于v3版本API使用，v4也可用）
**参数**:
- `methodName`: 要调用的JS方法名
- `objectValue`: 要传递的多个参数（可变参数）
**使用场景**: 需要传递多个参数给JS方法时使用，也可用于持续回调或传递监听事件的场景
**示例**:
```typescript
// 回调到 uexDemo.onMultiResult(param1, param2, param3)
this.callbackJsObjectWithMultiParams('uexDemo.onMultiResult',
    {status: 'success'},
    'additional info',
    123
);
```

#### 5. callbackJsLegacy(inCallbackName: string, inOpCode: number, inDataType: number, inData: object | string | number | undefined)
**作用**: 早期插件API使用的回调方式，按照固定格式回调（多用于v3或v2版本API使用，不推荐使用）
**参数**:
- `inCallbackName`: 将要被调用的页面JS函数名
- `inOpCode`: 操作码
- `inDataType`: 数据类型
- `inData`: 回调数据
**使用场景**: 兼容早期插件API，新插件不推荐使用
**示例**:
```typescript
this.callbackJsLegacy('uexDemo.cbResult', 0, 1, 'callback data');
```

#### 6. errorCallback(inOpCode: number, inErrorCode: number, inErrorInfo: string)
**作用**: 错误回调，用于一般错误以及旧插件使用（多用于v3或v2版本API使用，不推荐使用）
**参数**:
- `inOpCode`: 操作码
- `inErrorCode`: 错误码
- `inErrorInfo`: 错误信息
**使用场景**: 统一的错误回调处理，兼容早期插件API，新插件不推荐使用
**示例**:
```typescript
this.errorCallback(1001, -1, 'Parameter validation failed');
```

#### 静态方法

EUExBase还提供了两个静态方法，仅在没有实例的情况下使用：

- `EUExBase.callbackJsObject(mBrwView, methodName, objectValue)`
- `EUExBase.callbackJsObjectWithMultiParams(mBrwView, methodName, ...objectValue)`

#### 使用建议

1. **v4版本API**: 优先使用 `callbackJsFunction`，配合Function对象回调
2. **v3版本API**: 使用 `callbackJsObject` 或 `callbackJsObjectWithMultiParams`
3. **自定义场景**: 使用 `callbackJs` 执行自定义JS代码
4. **兼容性**: 避免使用 `callbackJsLegacy` 和 `errorCallback`，仅在兼容旧版本时使用

#### 回调方法命名规范

使用JS方法名的回调方法名应该遵循以下规范：
- 一次性回调: `uex插件名.cb方法名`
- 持续监听回调: `uex插件名.on方法名`

**示例**:
```typescript
// 在入口类中定义回调方法名常量
private static readonly CALLBACK_FUNCTION_CB_RESULT = 'uexDemo.cbResult';
private static readonly CALLBACK_FUNCTION_ON_CLICK = 'uexDemo.onClick';

// 使用常量进行回调
this.callbackJsObject(EUExDemo.CALLBACK_FUNCTION_CB_RESULT, result);
```

### `clean()`必须实现

1. 此方法内应当执行一些必要的清理操作，将入口类实例中储存的变量资源释放，并重置为初始状态，引擎可能会在页面复用时调用此方法并进行复用。
2. return true表示已进行清理，return false表示未进行清理。引擎会根据结果进行相应的处理。
3. 由于入口类实例每个WebView都会有一个单独的实例，因此clean()方法内只需要清理本实例内的资源，不应当清理全局或跨实例的资源，否则会导致每次关闭WebView时全局资源都会被提前释放造成错误。
4. 全局或者跨实例的资源，如果必须清理，可以考虑提供类似close的接口由JS端调用进行清理，或者监听应用整体的某些生命周期事件进行清理。

## 开发中常用API列举

- 获取当前入口类所在Widget的WWidgetData实例，其中包含了appId等信息

```
const widgetData = this.getWidgetData();
```

- 获取当前入口类所属WebView包装类EBrowserView实例

```
const brwView = this.mBrwView;
```

- 获取当前入口类所属UIContext实例

```
const uiContext = this.mBrwView.getUIContext();
```

- 获取当前入口类所属Context实例

```
const context = this.mBrwView.getUIContext().getHostContext();
```

- 转换AppCan协议路径为真实路径

```
const realPath = BUtility.makeRealPath(inPath, this.mBrwView);
```

## BUtility工具类常用方法

BUtility是engine模块提供的实用工具类，包含路径处理、目录管理、设备信息等常用功能：

### 路径处理相关

- `BUtility.makeUrl(inBaseUrl: string, inUrl: string): string` - 将路径转换为可以加载Web的url
- `BUtility.uriHasSchema(inUri: string): boolean` - 判断路径是否含有协议头
- `BUtility.handleRelativePath(inUrl: string): string` - 处理相对路径中的../逻辑
- `BUtility.makeRealPath(inPath: string, brwView: EBrowserView): string` - 将传入路径根据协议头等进行转换，返回实际路径

### 目录路径获取
- `BUtility.getMainWidgetSrcParentPath(): string` - 获取主widget的资源所在的父目录路径
- `BUtility.getMainWidgetSrcLocalPath(): string` - 获取主widget的资源所在的本地路径
- `BUtility.getSubWidgetSrcParentPath(): string` - 获取子widget的代码资源所在的父目录路径
- `BUtility.getSubWidgetSrcLocalPath(widgetAppId: string): string` - 获取指定子widget的代码资源所在的本地路径
- `BUtility.getWidgetBoxPath(widgetData: WWidgetData): string` - 获取指定widget的用户数据存储空间路径
- `BUtility.getPluginCacheDir(context: Context, pluginName: string): string` - 根据插件名称获取缓存目录路径

### 设备信息和标识
- `BUtility.getUniqueIDLikeIMEI(): string` - 获取设备唯一标识（类似IMEI）
- `BUtility.getDeviceToken(): string` - 获取设备唯一标识token
- `BUtility.getSoftToken(): string` - 获取主应用softToken
- `BUtility.generateWidgetSoftToken(appkey: string): string` - 生成结合了appkey和设备标识的token
- `BUtility.getMQTTUniqueClientId(): string` - 获取MQTT推送使用的唯一标识

### 应用配置
- `BUtility.getMainWidgetAppkey(): string` - 获取主widget的appkey

### 初始化和调试
- `BUtility.initWidgetOneFile(widgetData: WWidgetData): void` - 初始化widget应用数据的存放目录
- `BUtility.printBoxDirs(context: Context): void` - 打印调试信息：app沙箱路径

### 使用示例

```typescript
import { BUtility } from '@appcan/engine';

// 获取插件缓存目录
const cacheDir = BUtility.getPluginCacheDir(this.mContext, 'uexDemo');

// 处理文件路径
const realPath = BUtility.makeRealPath('res://image.png', this.mBrwView);

// 获取设备标识
const deviceToken = BUtility.getDeviceToken();

// 检查路径是否有协议头
const hasSchema = BUtility.uriHasSchema('https://example.com/file.txt');
```

## 其余开发建议（仅供参考）

以下开发建议仅供参考，如与实际情况或者开发规范冲突，请以实际情况为准。

### 日志工具类

- 日志输出可以创建一个LogUtils类，其中引用引擎的Index.ets中导出的BDebug来输出，LogUtils作为一个包装供插件内部使用。

### JS参数处理VO设计模式

当入口类需要处理JS传入的JSON对象参数时，建议定义专门的VO类来规范类型和验证必传字段。

#### 设计要点

1. **类型安全**: 明确定义每个参数的类型
2. **参数验证**: 提供验证方法检查必传字段
3. **解析封装**: 提供静态方法从JS对象解析参数
4. **默认值**: 为可选参数提供合理的默认值

#### 什么情况下需要用class定义，什么情况下用interface定义？

1. **VO类，CBO类**: 用于封装和验证JS传入的参数，需要提供解析方法和验证逻辑，且字段固定，适合使用class定义。特殊情况下，如果存在字段数量不固定的情况，可以使用interface定义。
2. **DTO类**: 用于与后端交互的数据传输对象，只需要定义字段和类型，且后端数据需要透传给前端时，适合使用interface定义，若需要定义相关数据转换或者校验行为，则搭配Utils工具类来定义。

#### 典型范例

以用户注册接口为例：

```typescript
/**
 * 用户注册参数VO
 */
export default class UserRegisterVO {
  public username: string = "";     // 用户名（必传）
  public password: string = "";     // 密码（必传）
  public email: string = "";        // 邮箱（必传）
  public phone: string = "";        // 手机号（可选）
  public nickname: string = "";     // 昵称（可选）

  /**
   * 从JS对象解析参数
   */
  public static fromJSObject(obj: object): UserRegisterVO {
    const vo = new UserRegisterVO();
    if (obj["username"]) vo.username = String(obj["username"]);
    if (obj["password"]) vo.password = String(obj["password"]);
    if (obj["email"]) vo.email = String(obj["email"]);
    if (obj["phone"]) vo.phone = String(obj["phone"]);
    if (obj["nickname"]) vo.nickname = String(obj["nickname"]);
    return vo;
  }

  /**
   * 验证参数有效性
   */
  public isValid(): boolean {
    return this.username.trim().length > 0 &&
           this.password.trim().length > 0 &&
           this.email.trim().length > 0;
  }

  /**
   * 获取验证错误信息
   */
  public getValidationError(): string {
    if (this.username.trim().length === 0) return "用户名不能为空";
    if (this.password.trim().length === 0) return "密码不能为空";
    if (this.email.trim().length === 0) return "邮箱不能为空";
    return "";
  }
}
```

#### 在入口类中使用

```typescript
export default class EUExDemo extends EUExBase {

  public register(params: string): void {
    try {
      const paramObj = JSON.parse(params);
      const registerVO = UserRegisterVO.fromJSObject(paramObj);

      if (!registerVO.isValid()) {
        const error = registerVO.getValidationError();
        this.callbackJs("uexDemo.cbRegister", { result: false, error: error });
        return;
      }

      // 执行注册逻辑
      this.doRegister(registerVO);
    } catch (error) {
      this.callbackJs("uexDemo.cbRegister", { result: false, error: "参数格式错误" });
    }
  }
}
```

#### 优势

- **类型安全**: 避免直接使用`object`类型
- **集中验证**: 统一处理参数验证逻辑
- **易于维护**: 参数变更只需修改VO类
- **代码复用**: VO类可在插件内部多处使用

