> 提醒： 滥用可能导致账户被BAN！！！

* 使用v2ray+caddy同时部署通过ws传输的vmess vless trojan shadowsocks socks NaiveProxy等协议
* 支持tor网络，且可通过自定义网络配置文件启动v2ray和caddy来按需配置各种功能
* 支持存储自定义文件,目录及账号密码均为AUUID,客户端务必使用TLS连接

[![Deploy](https://www.herokucdn.com/deploy/button.png)](https://dashboard.heroku.com/new?template=https://github.com/tssvv/xr)

### 服务端
点击上面紫色`Deploy to Heroku`，会跳转到heroku app创建页面，填上app的名字、选择节点、按需修改部分参数和AUUID后点击下面deploy创建app即可开始部署
如出现错误，可以多尝试几次，待部署完成后页面底部会显示Your app was successfully deployed
  * 点击Manage App可在Settings下的Config Vars项**查看和重新设置参数**
  * 点击Open app跳转[欢迎页面](/etc/CADDYIndexPage.md)域名即为heroku分配域名，格式为`app.herokuapp.com`，用于客户端
  * 默认协议密码为`$UUID`，WS路径为`$UUID-[vmess|vless|trojan|ss|socks]`格式

### 客户端
* **务必替换所有的app.herokuapp.com为heroku分配的项目域名**
* **务必替换所有的8f91b6a0-e8ee-11ea-adc1-0242ac120002为部署时设置的AUUID**

<details>
<summary>v2ray</summary>

```bash
* 客户端下载：https://github.com/v2fly/v2ray-core/releases
* 代理协议：vless 或 vmess
* 地址：app.herokuapp.com
* 端口：443
* 默认UUID：8f91b6a0-e8ee-11ea-adc1-0242ac120002
* 加密：none
* 传输协议：ws
* 伪装类型：none
* 路径：/8f91b6a0-e8ee-11ea-adc1-0242ac120002-vless // 默认vless使用/$uuid-vless，vmess使用/$uuid-vmess
* 底层传输安全：tls

vmess://{"add":"104.16.195.36","aid":0,"host":"seanhero.seanz.workers.dev","id":"8f91b6a0-e8ee-11ea-adc1-0242ac120002","net":"ws","path":"/8f91b6a0-e8ee-11ea-adc1-0242ac120002-vmess","port":443,"ps":"hero-vmess","tls":"tls","type":"none","v":2}

vmess://base64({json})
```
</details>

<details>
<summary>trojan-go</summary>

```bash
* 客户端下载: https://github.com/p4gefau1t/trojan-go/releases
{
    "run_type": "client",
    "local_addr": "127.0.0.1",
    "local_port": 1080,
    "remote_addr": "app.herokuapp.com",
    "remote_port": 443,
    "password": [
        "8f91b6a0-e8ee-11ea-adc1-0242ac120002"
    ],
    "websocket": {
        "enabled": true,
        "path": "/8f91b6a0-e8ee-11ea-adc1-0242ac120002-trojan",
        "host": "app.herokuapp.com"
    }
}
trojan-go://8f91b6a0-e8ee-11ea-adc1-0242ac120002@104.16.195.36:443/?sni=seanhero.seanz.workers.dev&type=ws&host=seanhero.seanz.workers.dev&path=%2F8f91b6a0-e8ee-11ea-adc1-0242ac120002-trojan#hero-go
```
</details>

<details>
<summary>shadowsocks</summary>

```bash
* 客户端下载：https://github.com/shadowsocks/shadowsocks-windows/releases/
* 服务器地址: app.herokuapp.com
* 端口: 443
* 密码：8f91b6a0-e8ee-11ea-adc1-0242ac120002
* 加密：chacha20-ietf-poly1305
```
</details>

<details>
<summary>shadowsocks-R</summary>

```bash
* 客户端下载：https://github.com/shadowsocks/shadowsocks-windows/releases/
* 服务器地址: app.herokuapp.com
* 端口: 443
* 密码：8f91b6a0-e8ee-11ea-adc1-0242ac120002
* 加密：chacha20-ietf-poly1305
* 传输协议：ws
* 路径：/8f91b6a0-e8ee-11ea-adc1-0242ac120002-ss
* 请求头：Host|app.seanz.workers.dev
* TLS：开启
* TLS域名：app.seanz.workers.dev

* 插件程序：v2ray-plugin_windows_amd64.exe  //需将插件https://github.com/shadowsocks/v2ray-plugin/releases下载解压后放至shadowsocks同目录
* 插件选项: tls;host=app.herokuapp.com;path=/8f91b6a0-e8ee-11ea-adc1-0242ac120002-ss
```
</details>

<details>
<summary>NaïveProxy</summary>

* 客户端下载：https://github.com/klzgrad/naiveproxy/releases

Locally run `./naive` with the following `config.json` to get a SOCKS5 proxy at local port 1080.
```json
{
  "listen": "socks://127.0.0.1:1080",
  "proxy": "https://naive:$UUID@app.herokuapp.com"
}
```
</details>

### Cloudflare worker

* 部署一个Heroku的App，使用Cloudflaer的CDN加速，Worker代码：

```js
addEventListener(
    "fetch",event => {
        let url=new URL(event.request.url);
        url.hostname="app.herokuapp.com";
        let request=new Request(url,event.request);
        event.respondWith(
            fetch(request)
        )
    }
)
```

### Cloudflare workers 单双号轮换

* 在Heroku部署2个相同UUID的App，Cloudflare的Worker单双号轮换，避免一个Heroku的App免费计算资源不够用。
* 一个Heroku的App免费计算资源有250小时/月，如果不是时刻不停在用，一个App足够用了。

```js
addEventListener(
    "fetch",event => {

        let nd = new Date();
        if (nd.getDate()%2) {
            host = 'app1.herokuapp.com'
        } else {
            host = 'app2.herokuapp.com'
        }

        let url=new URL(event.request.url);
        url.hostname=host;
        let request=new Request(url,event.request);
        event.respondWith(
            fetch(request)
        )
    }
)
```
