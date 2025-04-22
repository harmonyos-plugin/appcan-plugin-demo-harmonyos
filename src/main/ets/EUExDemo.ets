import { fileIo as fs } from '@kit.CoreFileKit';

import { EUExBase, EBrowserView, BDebug, BUtility } from '@appcan/engine';
import { router } from '@kit.ArkUI';
import { FirstInterfaceCBO } from './vo/CallbackDataVO';
import { BusinessError } from '@kit.BasicServicesKit';

/**
 * 插件入口类，继承自EUExBase
 */
export default class EUExDemo extends EUExBase {
  private readonly LogTag: string = 'uexDemo';
  private readonly CALLBACK_NAME_ON_FINISH_FIRST_INTERFACE: string = 'uexDemo.onFinishFirstInterface';

  public constructor(context: Context, brwView: EBrowserView) {
    super(context, brwView);
  }

  protected clean(): boolean {
    return false;
  }

  /**
   * 示例接口，与native端交换数据
   * @param params 数据类型根据接口定义的需要，一般为string数组，如果传入json，也可以定义为object类型的数组，这里引擎插件机制不做限制
   * @note 如果前端传入的是一个json对象，那么实际上插件接口收到的参数会是一个object。
   *       不过因为arkts这个地方不会强制检查类型，所以不报错。但是用的时候要注意区分。
   *       或者也可以根据具体传参类型，如果限制死了就是json，直接定义为object数组来接收也可以。
   * @returns
   */
  public testFirstInterface(...params: object[]): string {
    BDebug.info(this.LogTag, 'testFirstInterface: ' + JSON.stringify(params), params[2]['bbb']);
    const cbData: FirstInterfaceCBO = {
      data: 'finish',
      status: 0
    } as FirstInterfaceCBO;
    const cbFunc: Object = params[3] as Object;
    // 匿名方法的方式回调
    this.callbackJsFunction(cbFunc, cbData, "extra infomation example");
    // 命名方法的方式回调
    this.callbackJsObject(this.CALLBACK_NAME_ON_FINISH_FIRST_INTERFACE, cbData);
    // 同步方式回调。如果不需要return回调，则上面的方法返回类型应设置为void，下面的return就不需要了。
    return "testFirstInterface result";
  }

  public openMainPage(...params: string[]): void {
    BDebug.info(this.LogTag, 'openMainPage');

    import('./components/MainPage');

    router.pushNamedRoute({
      name: 'uexDemoMainPage'
    },
      router.RouterMode.Standard,
      (error) => {
        if (error) {
          BDebug.error(this.LogTag, 'openMainPage error: ' + error);
          return;
        }
        BDebug.info(this.LogTag, 'openMainPage success');
      })
  }

  public testHandleFileProtocolPath(...params: string[]): void {
    BDebug.info(this.LogTag, 'testHandleFileProtocolPath');
    // 示例：读取res://中的图片，拷贝到wgt://中
    const inputPath1: string = 'res://girl.jpg';
    const inputPath2: string = 'wgt://photo/girl.jpg';

    // 转换为真实路径
    const realPath1: string = BUtility.makeRealPath(inputPath1, this.mBrwView);
    const realPath2: string = BUtility.makeRealPath(inputPath2, this.mBrwView);
    BDebug.info(this.LogTag, 'testHandleFileProtocolPath', 'realPath1', realPath1);
    BDebug.info(this.LogTag, 'testHandleFileProtocolPath', 'realPath2', realPath2);

    // 拷贝文件
    fs.copyFile(realPath1, realPath2).then(() => {
      BDebug.info(this.LogTag, 'testHandleFileProtocolPath', "copy file succeed");
    }).catch((err: BusinessError) => {
      BDebug.error(this.LogTag, "testHandleFileProtocolPath", "copy file failed with error message: " + "code: " + err.code + ", message: " + err.message);
    });
  }
}