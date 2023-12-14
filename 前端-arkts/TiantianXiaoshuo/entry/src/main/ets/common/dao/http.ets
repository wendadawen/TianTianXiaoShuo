

// 引入包名
import http from '@ohos.net.http';

export function RequestPost(url: string, obj: Object, callback?:Function) {
  // 每一个httpRequest对应一个HTTP请求任务，不可复用
  let httpRequest = http.createHttp();
  // 用于订阅HTTP响应头，此接口会比request请求先返回。可以根据业务需要订阅此消息
  httpRequest.on('headersReceive', (header) => {
  });
  httpRequest.request(
    // 填写HTTP请求的URL地址，可以带参数也可以不带参数。URL地址需要开发者自定义。请求的参数可以在extraData中指定
    url,
    {
      method: http.RequestMethod.POST, // 可选，默认为http.RequestMethod.GET
      // 开发者根据自身业务需要添加header字段
      header: {
        'Content-Type': 'application/json'
      },
      // 当使用POST请求时此字段用于传递内容
      extraData: obj,
      expectDataType: http.HttpDataType.STRING, // 可选，指定返回数据的类型
      usingCache: true, // 可选，默认为true
      priority: 1, // 可选，默认为1
      connectTimeout: 10000, // 可选，默认为60000ms
      readTimeout: 10000, // 可选，默认为60000ms
      usingProtocol: http.HttpProtocol.HTTP1_1, // 可选，协议类型默认值由系统自动指定
    }, (err, data) => {
      if (!err) {
        callback(JSON.parse(data.result as string))
      } else {
        // 取消订阅HTTP响应头事件
        httpRequest.off('headersReceive');
        // 当该请求使用完毕时，调用destroy方法主动销毁
        httpRequest.destroy();
      }
    }
  );
}
