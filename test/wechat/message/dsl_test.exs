defmodule Wechat.Message.DSLTest do
  use ExUnit.Case, async: true

  describe "#message and #event params" do
    test "function must with one or two arity" do
      defmodule EXP do
        use Wechat.Message.DSL
        message :text, [with: "two"], fn -> IO.inspect("hello") end
        message :text, [with: "three"], fn _, _, _ -> IO.inspect("hello") end
      end

      assert_raise RuntimeError, fn ->
        :text |> message |> Map.put(:content, "two") |> EXP.reply
      end

      assert_raise RuntimeError, fn ->
        :text |> message |> Map.put(:content, "three") |> EXP.reply
      end
    end

    test "options are optinal" do
      defmodule OPT do
        use Wechat.Message.DSL
        message :text, [with: "hell"], fn _, reply -> Map.put(reply, :content, "with option") end
        message :text, & Map.put(&1, :content, "blank option")
      end

      msg = :text |> message |> Map.put(:content, "hell")
      result = OPT.reply(msg)
      assert result[:content] == "with option"

      msg = :text |> message |> Map.put(:content, "not match")
      result = OPT.reply(msg)
      assert result[:content] == "blank option"
    end

    test "with option" do
      defmodule WithOPT do
        use Wechat.Message.DSL
        message :text, [with: "with"], & Map.put(&1, :content, "with match")
        message :text, [], & Map.put(&1, :content, "no with")
      end

      msg = :text |> message |> Map.put(:content, "with")
      result = WithOPT.reply(msg)
      assert result[:content] == "with match"

      msg = :text |> message |> Map.put(:content, "lorem")
      result = WithOPT.reply(msg)
      assert result[:content] == "no with"
    end

    test "to option" do
      defmodule ToOpt do
        use Wechat.Message.DSL
        message :text, [with: "image", to: :image], & &1
        message :text, [with: "lorem"], & &1
      end

      msg = :text |> message |> Map.put(:content, "image")
      result = ToOpt.reply(msg)
      assert result[:msg_type] == "image"
    end

    test "fallback to reply text message" do
      defmodule FallbackMod do
        use Wechat.Message.DSL
      end

      msg = :text |> message |> Map.put(:content, "will fallback")
      result = FallbackMod.reply(msg)

      assert result[:create_time]
      assert result[:to_user_name]
      assert result[:from_user_name]
      assert result[:msg_type] == "text"
      assert result[:content] == "fallback"
    end
  end

  describe "#message :text" do
    defmodule TextMod do
      use Wechat.Message.DSL
      message :text, [with: "hello"], & make_reply(&1, "hello reply")
      message :text, [with: "world"], & make_reply(&1, "world reply")
      message :text, [], & make_reply(&1, "default reply")

      defp make_reply(msg, content), do: Map.put(msg, :content, content)
    end

    test "text with match" do
      msg = :text |> message |> Map.put(:content, "hello")
      result = TextMod.reply(msg)

      assert result[:create_time]
      assert result[:to_user_name]
      assert result[:from_user_name]
      assert result[:content] == "hello reply"

      msg = :text |> message |> Map.put(:content, "world")
      result = TextMod.reply(msg)

      assert result[:create_time]
      assert result[:to_user_name]
      assert result[:from_user_name]
      assert result[:content] == "world reply"
    end

    test "text without match" do
      msg = :text |> message |> Map.put(:content, "no any match")
      result = TextMod.reply(msg)

      assert result[:create_time]
      assert result[:to_user_name]
      assert result[:from_user_name]
      assert result[:content] == "default reply"
    end
  end

  describe "#message image/voice/video/location to option" do
    defmodule WithoutWithMod do
      use Wechat.Message.DSL

      message :image,    [to: :voice], & &1
      message :voice,    [to: :image], & &1
      message :video,    [to: :music], & &1
      message :location, [to: :news], & &1
    end

    test "image to voice" do
      result = WithoutWithMod.reply(message(:image))
      assert result[:msg_type] == "voice"
    end

    test "voice to image" do
      result = WithoutWithMod.reply(message(:voice))
      assert result[:msg_type] == "image"
    end

    test "video to image" do
      result = WithoutWithMod.reply(message(:video))
      assert result[:msg_type] == "music"
    end

    test "location to news" do
      result = WithoutWithMod.reply(message(:location))
      assert result[:msg_type] == "news"
    end
  end

  describe "event" do
    defmodule EventMod do
      use Wechat.Message.DSL
      event :subscribe,   & text(&1, "user subscribed")
      event :unsubscribe, & text(&1, "user unsubscribed")

      event :subscribe, [with: "qrscene_123123"], & text(&1, "qrscene scan event")
      event :scan,      [with: "scene_id_54321"], & text(&1, "scene_id scan event")
      event :scan, fn recv, rep ->
        text(rep, recv[:event_key])
      end

      event :location, fn recv, rep ->
        text(rep, recv[:latitude])
      end

      event :click, [with: "BOOK_LUNCH"], fn rep ->
        text(rep, "book lunch clicked")
      end

      event :view, [with: "http://wechat.somewhere.com/view_url"], fn rep ->
        text(rep, "menu viewed")
      end
    end

    test "subscribe" do
      msg = with_event_message(event: "subscribe")
      reply = EventMod.reply(msg)
      assert reply[:content] == "user subscribed"

      assert reply[:msg_type]
      assert reply[:to_user_name]
      assert reply[:from_user_name]
      assert reply[:create_time]
    end

    test "unsubscribe" do
      msg = with_event_message(event: "unsubscribe")
      reply = EventMod.reply(msg)
      assert reply[:content] == "user unsubscribed"
    end

    test "unsubscriber scan with qrcode" do
      msg =
        with_event_message(event: "subscribe",event_key: "qrscene_123123", ticket: "qrscene_123123_ticket")

      reply = EventMod.reply(msg)
      assert reply[:content] == "qrscene scan event"
    end

    test "subscriber scan with qrcode" do
      msg = with_event_message(event: "SCAN", event_key: "scene_id_54321", ticket: "TICKET")
      reply = EventMod.reply(msg)
      assert reply[:content] == "scene_id scan event"
    end

    test "without specific scan with will get `EventKey`" do
      msg = with_event_message([
        msg_type:  "event",
        event:     "SCAN",
        event_key: "some event",
        ticket:    "TICKET"
      ])
      reply = EventMod.reply(msg)
      assert reply[:content] == "some event"
    end

    test "location" do
      loc_msg = with_event_message([
        msg_type:  "event",
        event:     "LOCATION",
        latitude:  "23.137466",
        longitude: "113.352425",
        precision: "119.385040",
      ])
      reply = EventMod.reply(loc_msg)
      assert reply[:content] == "23.137466"
    end

    test "user click menu" do
      click_msg = with_event_message([
        msg_type:  "event",
        event:     "CLICK",
        event_key: "BOOK_LUNCH",
      ])
      reply = EventMod.reply(click_msg)
      assert reply[:content] == "book lunch clicked"
    end

    test "user view menu" do
      view_msg = with_event_message([
        msg_type:  "event",
        event:     "VIEW",
        event_key: "http://wechat.somewhere.com/view_url",
      ])
      reply = EventMod.reply(view_msg)
      assert reply[:content] == "menu viewed"
    end
  end

  msg_tpl = %{
    text: %{
      msg_type:       "text",
      content:        "this is a test",
    },

    image: %{
      msg_type:       "image",
      pic_url:        "this is url",
      media_id:       "media_id",
    },

    voice: %{
      msg_type:       "voice",
      media_id:       "media_id",
      format:         "Format",
      recognition:    "腾讯微信团队",
    },

    video: %{
      msg_type:       "video",
      media_id:       "media_id",
      thumb_media_id: "thumb_media_id",
    },

    shortvideo: %{
      msg_type:       "shortvideo",
      media_id:       "media_id",
      thumb_media_id: "thumb_media_id",
    },

    location: %{
      msg_type:       "location",
      location_x:     "23.134521",
      location_y:     "113.358803",
      scale:          "20",
      label:          "位置信息",
    },

    link: %{
      msg_type:       "link",
      title:          "公众平台官网链接",
      description:    "公众平台官网链接",
      url:            "url",
    },
  }
  for {type, tpl} <- msg_tpl do
    map = Macro.escape(tpl)
    def message(unquote(type)) do
      Map.merge(%{
        to_user_name:   "toUser",
        from_user_name: "fromUser",
        create_time:    1348831860,
        msg_id:         "1234567890123456",
      }, unquote(map))
    end
  end

  defp with_event_message(msg) when is_list(msg) do
    Map.merge(%{
      msg_type:       "event",
      to_user_name:   "toUser",
      from_user_name: "fromUser",
      create_time:    1348831860,
    }, Enum.into(msg, %{}))
  end
end
