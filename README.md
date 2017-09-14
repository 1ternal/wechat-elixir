# Wechat

Wechat API wrapper in Elixir.

[![Build Status](https://travis-ci.org/goofansu/wechat-elixir.svg?branch=master)](https://travis-ci.org/goofansu/wechat-elixir)
[![codebeat badge](https://codebeat.co/badges/60f20da5-c961-4100-a19e-135ad79c8457)](https://codebeat.co/projects/github-com-goofansu-wechat-elixir-master)
[![Coverage Status](https://coveralls.io/repos/github/goofansu/wechat-elixir/badge.svg)](https://coveralls.io/github/goofansu/wechat-elixir)

## Installation

### stable

  ```elixir
  def deps do
    [{:wechat, "~> 0.2.0"}]
  end
  ```

### development

  ```elixir
  def deps do
    [{:wechat, github: "goofansu/wechat-elixir"}]
  end
  ```

## Config

* Add config in `config.exs`

    ```elixir
    config :wechat, Wechat,
      appid: "wechat app id",
      secret: "wechat app secret",
      token: "wechat token",
      encoding_aes_key: "32bits key" # 只有"兼容模式"和"安全模式"才需要配置这个值
      message_handler:  YourHandler, # 可选。 可通过 `HandleReply` option 设置，且覆盖此处设置
    ```

## Usage

* access_token

    ```elixir
    iex> Wechat.access_token
    "Bgw6_cMvFrE3hY3J8U6oglhvlzHhMpAQma0Wjam4XsLx8F6XP4pfZzsezBdpfth2BNAdUK6wA23S7D3fSePt7meG9a1gf9LhEmXjxGelnTjJLaIQMYumrCHE_9gcFVXaHIHcAGACDC"
    ```

* user

    ```elixir
    iex> Wechat.User.get
    %{count: 4,
    data: %{openid: ["oi00OuFrmNEC-QMa0Kikycq6A7ys",
     "oi00OuKAhA8bm5okpaIDs7WmUZr4", "oi00OuOdjK0TicVUmovudbSP5Zq4",
     "oi00OuBgG2mko_pOukCy00EYCwo4"]},
    next_openid: "oi00OuBgG2mko_pOukCy00EYCwo4", total: 4}

    iex> Wechat.User.info("oi00OuKAhA8bm5okpaIDs7WmUZr4")
    %{city: "宝山", country: "中国", groupid: 0,
    headimgurl: "http://wx.qlogo.cn/mmopen/7raJSSs9gLVJibia6sAXRvr8jajXfQFWiagrLwrRIZjMHCEXOxYf6nflxcpl4WkT7gz8Sa4tO32avnI0dlNLn24yA/0",
    language: "zh_CN", nickname: "小爆炸的爸爸",
    openid: "oi00OuKAhA8bm5okpaIDs7WmUZr4", province: "上海", remark: "",
    sex: 1, subscribe: 1, subscribe_time: 1449812483, tagid_list: [],
    unionid: "o2oUsuOUzgNL-JSLtIp8b3FzkI-M"}
    ```

* media

    ```elixir
    iex> file = Wechat.Media.download("GuSq91L0FXQFOIFtKwX2i5UPXH9QKnnu63_z4JHZwIw3TMIn1C-xm8hX3nPWCA")
   iex> File.write!('/tmp/file', file)
    ```

## Plug

* `Wechat.Plugs.CheckUrlSignature`

  * Check url signature
  * [接入指南](http://mp.weixin.qq.com/wiki?t=resource/res_main&id=mp1421135319&token=&lang=zh_CN)

* `Wechat.Plugs.CheckMsgSignature`

  * Parse xml message (support decrypt msg)
  * [消息加密解密技术方案](http://mp.weixin.qq.com/wiki/2/3478f69c0d0bbe8deb48d66a3111ff6e.html)

## Plug Usage (in Phonenix controller)

* router.ex

    ```elixir
    defmodule MyApp.Router do
      pipeline :api do
        plug :accepts, ["json"]
      end

      scope "/wechat", MyApp do
        pipe_through :api

        # validate wechat server config
        get "/", WechatController, :index

        # receive wechat push message
        post "/", WechatController, :create
      end
    end
    ```

* wechat_controller.ex

    ```elixir
    defmodule MyApp.WechatController do
      use MyApp.Web, :controller

      plug Wechat.Plugs.CheckUrlSignature
      plug Wechat.Plugs.CheckMsgSignature when action in [:create]
      plug Wechat.Plugs.HandleReply, [handler: YourHanlder] when action in [:create]

      def index(conn, %{"echostr" => echostr}) do
        text conn, echostr
      end

      def create(conn, _params) do
        YourHanlder.send_reply(conn)
      end
    end
    ```

* your_handler.ex

    ```elixir
    defmodule YourHandler do
      use Wechat.Message.DSL

      # send back what you received
      # `to_user_name` and `from_user_name` was switched, you don't have to manual do this switch operation.
      message :text, fn received, reply ->
        recv_content = received[:content]
        reply
        |> type(:text)
        |> content(recv_content)
      end

      # using `with` option to pattern match the message `content` and reply with `text/2`
      message :text, [with: "help"], & text(&1, "what can I do for you?")

      # using `to` option will setup reply type to text, also support other reply format
      message :voice, [to: :text], & content(&1, "fallback voice")

      # most reply message attributes like `content`, `media_id`, `title` are all supported.
      # be sure the reply type was set when using those functions.
      message :video, [to: :image], & media_id(&1, "awesome media_id")

      # the option is optional
      message :location, & text(&1, "greate!")

      # you can use single call to reply
      message :image, fn reply ->
        video(reply, media_id: "hello world", title: "hello title", description: "hello description")
      end
      # or pipelien oprator
      message :link, [to: :music] fn reply ->
        reply
        |> title("awesome title")
        |> description("awesome description")
        |> music_url("awesome musicurl")
        |> hq_music_url("awesome hqmusicurl")
        |> thumb_media_id("awesome thumbmediaid")
      end

      # define the event responder :D
      event :subscribe, fn reply ->
        text(reply, "thx :D")
      end

      # new user scan with qrcode
      event :scan, [with: "qr_scene_xxx"], fn received, reply ->
        text(reply, "we just receive your ticket #{received[:ticket]}")
      end

      # subscriber scan with qrcode
      event :scan, [with: "scene_id"], fn received, reply ->
        text(reply, "we just receive your ticket #{received[:ticket]}")
      end

      # deal with location event
      event :location, fn received, reply ->
        text(reply, received[:latitude])
      end

      # click with match
      event :click, [with: "BOOK_LUNCH"], fn reply ->
        text(reply, "book lunch clicked")
      end

      # deal with view event
      event :view, [with: "http://wechat.somewhere.com/view_url"], fn reply ->
        text(reply, "menu viewed")
      end
    end
    ```

* your_handler.ex(the function way)

    ```elixir
    defmodule YourHandler do
      use Wechat.Message.Responder

      # handle message like `text`, `image` and others
      def handle_message(:text, %{content: "help"} = msg) do
        text(msg, "what can I do for you?")
      end
      def handle_message(:text, msg) do
        msg
        |> type(:music)
        |> title("awesome title")
        |> description("awesome description")
        |> music_url("awesome musicurl")
        |> hq_music_url("awesome hqmusicurl")
        |> thumb_media_id("awesome thumbmediaid")
      end

      # handle event
      def handle_message(:image, %{pic_url: "www.qq.com/lorem"} = msg) do
        first_article = [
          title:       "hello title 1",
          description: "hello description 1",
          pic_url:     "hello pic_url 1",
          url:         "hello url 1",
        ]
        second_article = %{
          title:       "hello title 2",
          description: "hello description 2",
          pic_url:     "hello pic_url 2",
          url:         "hello url 2",
        }
        reply
        |> type(:news)
        |> article(first_article)
        |> article(second_article)
      end

      def handle_message(:image, msg) do
        text(msg, "www.qq.com/lorem not matched")
      end
    end
    ```
