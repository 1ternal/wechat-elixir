defmodule Wechat.Message do
  defmodule Incoming do
    def types, do: [
      #normal message
      :image,
      :link,
      :location,
      :shortvideo,
      :text,
      :video,
      :voice,
      # events
      :event_subscribe,
      :event_unsubscribe,
      :event_scan,
      :event_location,
      :event_click,
      :event_view,
      # todo not impl
      :batch_job,
    ]
    @moduledoc """

    received message
    ref: https://mp.weixin.qq.com/wiki?t=resource/res_main&id=mp1421140453

    shared
    <xml>
      <ToUserName><![CDATA[toUser]]></ToUserName>
      <FromUserName><![CDATA[fromUser]]></FromUserName>
      <CreateTime>1348831860</CreateTime>
      <MsgType><![CDATA[text]]></MsgType>
      <MsgId>1234567890123456</MsgId>
    </xml>

    text
    <xml>
      <MsgType><![CDATA[text]]></MsgType>
      <Content><![CDATA[this is a test]]></Content>
    </xml>

    image
    <xml>
      <MsgType><![CDATA[image]]></MsgType>
      <PicUrl><![CDATA[this is a url]]></PicUrl>
      <MediaId><![CDATA[media_id]]></MediaId>
    </xml>

    voice
    <xml>
      <MsgType><![CDATA[voice]]></MsgType>
      <MediaId><![CDATA[media_id]]></MediaId>
      <Format><![CDATA[Format]]></Format>
      <Recognition><![CDATA[腾讯微信团队]]></Recognition> ## Optional
    </xml>

    video
    <xml>
      <MsgType><![CDATA[video]]></MsgType>
      <MediaId><![CDATA[media_id]]></MediaId>
      <ThumbMediaId><![CDATA[thumb_media_id]]></ThumbMediaId>
    </xml>

    shortvideo
    <xml>
      <MsgType><![CDATA[shortvideo]]></MsgType>
      <MediaId><![CDATA[media_id]]></MediaId>
      <ThumbMediaId><![CDATA[thumb_media_id]]></ThumbMediaId>
    </xml>

    location
    <xml>
      <MsgType><![CDATA[location]]></MsgType>
      <Location_X>23.134521</Location_X>
      <Location_Y>113.358803</Location_Y>
      <Scale>20</Scale>
      <Label><![CDATA[位置信息]]></Label>
    </xml>

    link
    <xml>
      <MsgType><![CDATA[link]]></MsgType>
      <Title><![CDATA[公众平台官网链接]]></Title>
      <Description><![CDATA[公众平台官网链接]]></Description>
      <Url><![CDATA[url]]></Url>
    </xml>

    events
    ref: https://mp.weixin.qq.com/wiki?t=resource/res_main&id=mp1421140454

    subsribe/unsubsribe
    <xml>
      <MsgType><![CDATA[event]]></MsgType>
      <Event><![CDATA[subscribe]]></Event>
    </xml>

    subscribe with scene
    <xml>
      <MsgType><![CDATA[event]]></MsgType>
      <Event><![CDATA[subscribe]]></Event>
      <EventKey><![CDATA[qrscene_123123]]></EventKey>
      <Ticket><![CDATA[TICKET]]></Ticket>
    </xml>

    scan event
    <xml>
      <MsgType><![CDATA[event]]></MsgType>
      <Event><![CDATA[SCAN]]></Event>
      <EventKey><![CDATA[SCENE_VALUE]]></EventKey>
      <Ticket><![CDATA[TICKET]]></Ticket>
    </xml>

    location event
    <xml>
      <MsgType><![CDATA[event]]></MsgType>
      <Event><![CDATA[LOCATION]]></Event>
      <Latitude>23.137466</Latitude>
      <Longitude>113.352425</Longitude>
      <Precision>119.385040</Precision>
    </xml>

    custom menu click event
    <xml>
      <MsgType><![CDATA[event]]></MsgType>
      <Event><![CDATA[CLICK]]></Event>
      <EventKey><![CDATA[EVENTKEY]]></EventKey>
    </xml>

    custom menu link event
    <xml>
      <MsgType><![CDATA[event]]></MsgType>
      <Event><![CDATA[VIEW]]></Event>
      <EventKey><![CDATA[www.qq.com]]></EventKey>
    </xml>
    """
  end

  defmodule Reply do
    def types, do: ~W(text image voice video music news)a
    @moduledoc """
    Reply message

    Message Types ref: https://mp.weixin.qq.com/wiki?t=resource/res_main&id=mp1421140543

    shared body

    ToUserName
    FromUserName
    CreateTime
    MsgType

    text specific
    <xml>
      <Content><![CDATA[你好]]></Content>
    </xml>

    image specific
    <xml>
      <Image>
        <MediaId><![CDATA[media_id]]></MediaId>
      </Image>
    </xml>

    voice
    <xml>
      <Voice>
        <MediaId><![CDATA[media_id]]></MediaId>
      </Voice>
    </xml>

    video
    <xml>
      <Video>
        <MediaId><![CDATA[media_id]]></MediaId>
        <Title><![CDATA[title]]></Title>
        <Description><![CDATA[description]]></Description>
      </Video>
    </xml>

    music
    <xml>
      <Music>
        <Title><![CDATA[TITLE]]></Title>
        <Description><![CDATA[DESCRIPTION]]></Description>
        <MusicUrl><![CDATA[MUSIC_Url]]></MusicUrl>
        <HQMusicUrl><![CDATA[HQ_MUSIC_Url]]></HQMusicUrl>
        <ThumbMediaId><![CDATA[media_id]]></ThumbMediaId>
      </Music>
    </xml>

    news
    <xml>
      <ArticleCount>2</ArticleCount>
      <Articles>
        <item>
        <Title><![CDATA[title1]]></Title>
        <Description><![CDATA[description1]]></Description>
        <PicUrl><![CDATA[picurl]]></PicUrl>
        <Url><![CDATA[url]]></Url>
        </item>
        <item>
        <Title><![CDATA[title]]></Title>
        <Description><![CDATA[description]]></Description>
        <PicUrl><![CDATA[picurl]]></PicUrl>
        <Url><![CDATA[url]]></Url>
        </item>
      </Articles>
    </xml>
    """
  end
end
