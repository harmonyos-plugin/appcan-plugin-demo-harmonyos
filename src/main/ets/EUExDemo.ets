import { EUExBase, EBrowserView, BDebug } from '@appcan/engine';
import { router } from '@kit.ArkUI';
import { FirstInterfaceCBO } from './vo/CallbackDataVO';

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

  public testFirstInterface(...params: string[]): void {
    BDebug.info(this.LogTag, 'testFirstInterface: ' + JSON.stringify(params));
    const cbData: FirstInterfaceCBO = {
      data: 'finish',
      status: 0
    } as FirstInterfaceCBO;
    const cbFunc: Object = params[3] as Object;
    // 匿名方法的方式回调
    this.callbackJsFunction(cbFunc, cbData);
    // 命名方法的方式回调
    this.callbackJsObject(this.CALLBACK_NAME_ON_FINISH_FIRST_INTERFACE, cbData);
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
}