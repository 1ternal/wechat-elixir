# defmodule Wechat.Message.BuilderTest do
#   use ExUnit.Case, asyc: true

#   describe "Module behaviour" do
#     test "reply any message" do
#       recv_msg = :text |> message |> Map.put(:content, "whatever")
#       reply = Wechat.Message.Builder.reply(recv_msg)

#       # reply backbone
#       assert reply[:from_user_name]
#       assert reply[:to_user_name]
#       assert reply[:msg_type]
#       assert reply[:create_time]

#       # switch user
#       assert reply[:from_user_name] == recv_msg[:to_user_name]
#       assert reply[:to_user_name]   == recv_msg[:from_user_name]

#       # default reply with text message
#       assert reply[:msg_type] == "text"
#       assert reply[:create_time] != recv_msg[:create_time]
#     end
#   end

#   describe "DSL params" do
#     defmodule ModDSLParam do
#       use Wechat.Message.Builder

#       from :text, fn reply ->
#         Map.put(reply, :content, "from accept two ariry")
#       end
#     end

#     test "text with 2 arity" do
#       txt = message(:text)
#       result= ModDSLParam.reply(txt)
#       assert result[:content] == "from accept two ariry"
#     end
#   end

#   describe "DSL exception" do
#     unsupport_with_param_types = ~W(image voice video shortvideo location link)a
#     for t <- unsupport_with_param_types do
#       mod = "with_invalid_#{t}" |> Macro.camelize |> String.to_atom
#       test "#{t} is not support `with` parameters" do
#         assert_raise RuntimeError, fn ->
#           defmodule unquote(mod) do
#             use Wechat.Message.Builder
#             from unquote(t), [with: "something"], & &1
#           end
#         end
#       end
#     end

#     support_with_param_types = ~W(text)a
#     for t <- support_with_param_types do
#       mod = "with_valid_#{t}" |> Macro.camelize |> String.to_atom
#       test "#{t} is support `with` parameters" do
#         defmodule unquote(mod) do
#           use Wechat.Message.Builder
#           from unquote(t), [with: "something"], & &1
#         end
#       end
#     end

#     support_to_param_types = ~W(text image voice video music news)a
#     for t <- support_to_param_types do
#       mod = "to_valid_#{t}" |> Macro.camelize |> String.to_atom
#       test "#{t} was support `to` parameters" do
#         defmodule unquote(mod) do
#           use Wechat.Message.Builder
#           from :text, [to: unquote(t)], & &1
#         end
#       end
#     end

#     unsupport_to_param_types = ~W(other not_suppo)a
#     for t <- unsupport_to_param_types do
#       mod = "to_invalid_#{t}" |> Macro.camelize |> String.to_atom
#       test "#{t} was support `to` parameters" do
#         assert_raise RuntimeError, fn ->
#           defmodule unquote(mod) do
#             use Wechat.Message.Builder
#             from :link, [to: unquote(t)], & &1
#           end
#         end
#       end
#     end

#     test "func with one arity" do
#       defmodule SingleAFuncMod do
#         use Wechat.Message.Builder
#         from :link, [to: :image], & &1
#       end
#     end

#     test "func with two arity" do
#       defmodule TwoAFuncMod do
#         use Wechat.Message.Builder
#         from :link, [to: :music], fn _, rep -> rep end
#       end
#     end

#     test "func with zero arity" do
#       assert_raise RuntimeError, fn ->
#         defmodule ZeroAFuncMod do
#           use Wechat.Message.Builder
#           from :link, [to: :news], fn -> :ok end
#         end
#       end
#     end

#     test "func with three arity" do
#       assert_raise RuntimeError, fn ->
#         defmodule ThreeAFuncMod do
#           use Wechat.Message.Builder
#           from :link, [to: :news], fn _, _, _ -> :ok end
#         end
#       end
#     end
#   end

#   describe "DSL basic bahaviour" do
#     defmodule ModB do
#       use Wechat.Message.Builder

#       from :text, fn msg ->
#         Map.put(msg, :content, "upper")
#       end

#       from :text, fn _, msg ->
#         Map.put(msg, :content, "lower")
#       end
#     end

#     test "function match order" do
#       txt = message(:text)
#       hello_msg = Map.put(txt, :content, "whaa")

#       result = ModB.reply(hello_msg)
#       assert result[:content] == "upper"
#     end
#   end

#   describe "DSL receive normal type message" do
#     defmodule ModRecv do
#       use Wechat.Message.Builder

#       from :image, fn reply ->
#         Map.put(reply, :content, "mod_recv image")
#       end
#       from :link, fn reply ->
#         Map.put(reply, :content, "mod_recv link")
#       end
#       from :location, fn reply ->
#         Map.put(reply, :content, "mod_recv location")
#       end
#       from :shortvideo, fn reply ->
#         Map.put(reply, :content, "mod_recv shortvideo")
#       end
#       from :text, fn reply ->
#         Map.put(reply, :content, "mod_recv text")
#       end
#       from :video, fn reply ->
#         Map.put(reply, :content, "mod_recv video")
#       end
#       from :voice, fn reply ->
#         Map.put(reply, :content, "mod_recv voice")
#       end
#     end

#     test "image" do
#       recv_msg = message(:image)
#       reply = ModRecv.reply(recv_msg)
#       assert reply[:content] == "mod_recv image"
#     end

#     test "link" do
#       recv_msg = message(:link)
#       reply = ModRecv.reply(recv_msg)
#       assert reply[:content] == "mod_recv link"
#     end

#     test "location" do
#       recv_msg = message(:location)
#       reply = ModRecv.reply(recv_msg)
#       assert reply[:content] == "mod_recv location"
#     end

#     test "shortvideo" do
#       recv_msg = message(:shortvideo)
#       reply = ModRecv.reply(recv_msg)
#       assert reply[:content] == "mod_recv shortvideo"
#     end

#     test "text" do
#       recv_msg = message(:text)
#       reply = ModRecv.reply(recv_msg)
#       assert reply[:content] == "mod_recv text"
#     end

#     test "video" do
#       recv_msg = message(:video)
#       reply = ModRecv.reply(recv_msg)
#       assert reply[:content] == "mod_recv video"
#     end

#     test "voice" do
#       recv_msg = message(:voice)
#       reply = ModRecv.reply(recv_msg)
#       assert reply[:content] == "mod_recv voice"
#     end
#   end

#   describe "DSL receive event type message" do
#     defmodule EventMessageA do
#       use Wechat.Message.Builder

#       # user subscibe event
#       from :event_subscribe, fn reply ->
#         Map.put(reply, :content, "user subscibe event")
#       end

#       # user unsubscribe event
#       from :event_unsubscribe, fn reply ->
#         Map.put(reply, :content, "user unsubscribe event")
#       end

#       # unsubscriber scan with qrcode"
#       from :event_scan, [with: "qrscene_123123"], fn reply ->
#         Map.put(reply, :content, "unsubscriber scan with qrcode")
#       end

#       # subscriber scan with qrcode"
#       from :event_scan, [with: "fake_qr_id_1234"], fn _recv, reply ->
#         Map.put(reply, :content, "subscriber scan with qrcode")
#       end

#       # without specific scan with will get `EventKey`
#       from :event_scan, fn recv, reply ->
#         reply
#         |> Map.put(:content, Map.get(recv, :event_key))
#       end

#       # label location
#       from :event_location, fn _recv, rep ->
#         Map.put(rep, :content, "label location")
#       end

#       # user click menu
#       from :event_click, [with: "BOOK_LUNCH"], fn _recv, rep ->
#         Map.put(rep, :content, "user click menu")
#       end

#       # user view menu
#       from :event_view, [with: "http://wechat.somewhere.com/view_url"], fn _recv, rep ->
#         Map.put(rep, :content, "user view menu")
#       end
#     end

#     test "subscribe" do
#       sub_msg = with_event_message(%{
#         msg_type: "event",
#         event:    "subscribe"
#       })
#       reply = EventMessageA.reply(sub_msg)
#       assert reply[:content] == "user subscibe event"
#     end

#     test "unsubscribe" do
#       unsub_msg = with_event_message(%{
#         msg_type:  "event",
#         event:     "unsubscribe"
#       })
#       reply = EventMessageA.reply(unsub_msg)
#       assert reply[:content] == "user unsubscribe event"
#     end

#     test "unsubscriber scan with qrcode" do
#       qr_message =
#         with_event_message(%{
#           msg_type:   "event",
#           event:      "subscribe",
#           event_key:  "qrscene_123123",
#           ticket:     "qrscene_123123_ticket",
#         })
#       reply = EventMessageA.reply(qr_message)
#       assert reply[:content] == "unsubscriber scan with qrcode"
#     end

#     test "subscriber scan with qrcode" do
#       scan_msg = with_event_message(%{
#         msg_type:  "event",
#         event:     "SCAN",
#         event_key: "fake_qr_id_1234",
#         ticket:    "TICKET",
#       })
#       reply = EventMessageA.reply(scan_msg)
#       assert reply[:content] == "subscriber scan with qrcode"
#     end

#     test "without specific scan with will get `EventKey`" do
#       scan_msg = with_event_message(%{
#         msg_type:  "event",
#         event:     "SCAN",
#         event_key: "some event",
#         ticket:    "TICKET",
#       })
#       reply = EventMessageA.reply(scan_msg)
#       assert reply[:content] == "some event"
#     end

#     test "label location" do
#       loc_msg = with_event_message(%{
#         msg_type:  "event",
#         event:     "LOCATION",
#         latitude:  "23.137466",
#         longitude: "113.352425",
#         precision: "119.385040",
#       })
#       reply = EventMessageA.reply(loc_msg)
#       assert reply[:content] == "label location"
#     end

#     test "user click menu" do
#       click_msg = with_event_message(%{
#         msg_type:  "event",
#         event:     "CLICK",
#         event_key: "BOOK_LUNCH",
#       })
#       reply = EventMessageA.reply(click_msg)
#       assert reply[:content] == "user click menu"
#     end

#     test "user view menu" do
#       view_msg = with_event_message(%{
#         msg_type:  "event",
#         event:     "VIEW",
#         event_key: "http://wechat.somewhere.com/view_url",
#       })
#       reply = EventMessageA.reply(view_msg)
#       assert reply[:content] == "user view menu"
#     end
#   end

#   describe "DSL param `with` normal message" do
#     defmodule Remote do
#       def deal(msg) do
#         Map.put(msg, :content, "message from remote")
#       end
#     end

#     defmodule ModA do
#       use Wechat.Message.Builder

#       from :text, [with: "hello"], fn msg ->
#         Map.put(msg, :content, "hello world")
#       end

#       from :text, [with: "world"], fn _, msg ->
#         Map.put(msg, :content, "world hello")
#       end

#       from :text, [with: "get_recv"], fn recv, _ ->
#         recv
#       end

#       from :text, [with: "remote"], &Remote.deal/1
#     end

#     test "text message reply with basic info" do
#       txt = :text |> message |> Map.put(:content, "message not match")
#       reply = ModA.reply(txt)

#       assert reply[:from_user_name]
#       assert reply[:to_user_name]
#       assert reply[:msg_type]
#       assert reply[:create_time]

#       # use switched
#       assert reply[:from_user_name] == txt[:to_user_name]
#       assert reply[:to_user_name]   == txt[:from_user_name]
#       assert reply[:msg_type]      == "text"
#       # CreateTime refreshed
#       assert reply[:create_time]   != txt[:create_time]
#     end

#     test "text message fallback" do
#       msg = :text |> message |> Map.put(:content, "message not match")
#       result = ModA.reply(msg)
#       assert result[:content] == "wechat handler fallback message"
#     end

#     test "text message with &func/1" do
#       txt = :text |> message |> Map.put(:content, "hello")

#       reply = ModA.reply(txt)
#       assert reply[:content] == "hello world"
#     end

#     test "text message with &func/2" do
#       txt = :text |> message |> Map.put(:content, "world")
#       reply = ModA.reply(txt)
#       assert reply[:content] == "world hello"
#     end

#     test "text message with remote func" do
#       txt = :text |> message |> Map.put(:content, "remote")
#       reply = ModA.reply(txt)
#       assert reply[:content] == "message from remote"
#     end

#     test "text message with &func/2 get back receive message" do
#       txt = :text |> message |> Map.put(:content, "get_recv")

#       reply = ModA.reply(txt)
#       assert reply[:create_time] == txt[:create_time]
#     end
#   end

#   describe "DSL param `to` normal message" do
#     message_types = ~W(text)a
#     reply_types   = ~W(text image voice video music news)a
#     for rep_t <- reply_types do
#       for recv_t <- message_types do
#         mod_name = "#{recv_t}_#{rep_t}_mod" |> Macro.camelize |> String.to_atom
#         test "from #{recv_t} to #{rep_t}" do
#           defmodule unquote(mod_name) do
#             use Wechat.Message.Builder
#             from unquote(recv_t), [to: unquote(rep_t)], & &1
#           end

#           mod_name = unquote(mod_name)
#           recv_t   = unquote(recv_t)
#           rep_t    = unquote(rep_t)
#           reply = apply(mod_name, :reply, [message(recv_t)])
#           assert reply[:msg_type] == to_string(rep_t)
#         end
#       end
#     end
#   end

#   describe "reply func" do

#     defmodule RepMod do
#       use Wechat.Message.Builder

#       from :text, fn message ->
#         message
#         |> __MODULE__.text("Content")
#       end
#     end

#     test "#text/2" do
#       result = RepMod.reply(message(:text))
#     end
#   end

#   msg_tpl = %{
#     text: %{
#       msg_type:       "text",
#       content:        "this is a test",
#     },

#     image: %{
#       msg_type:       "image",
#       pic_url:        "this is url",
#       media_id:       "media_id",
#     },

#     voice: %{
#       msg_type:       "voice",
#       media_id:       "media_id",
#       format:         "Format",
#       recognition:    "腾讯微信团队",
#     },

#     video: %{
#       msg_type:       "video",
#       media_id:       "media_id",
#       thumb_media_id: "thumb_media_id",
#     },

#     shortvideo: %{
#       msg_type:       "shortvideo",
#       media_id:       "media_id",
#       thumb_media_id: "thumb_media_id",
#     },

#     location: %{
#       msg_type:       "location",
#       location_x:     "23.134521",
#       location_y:     "113.358803",
#       scale:          "20",
#       label:          "位置信息",
#     },

#     link: %{
#       msg_type:       "link",
#       title:          "公众平台官网链接",
#       description:    "公众平台官网链接",
#       url:            "url",
#     },
#   }
#   for {type, tpl} <- msg_tpl do
#     map = Macro.escape(tpl)
#     def message(unquote(type)) do
#       Map.merge(%{
#         to_user_name:   "toUser",
#         from_user_name: "fromUser",
#         create_time:    1348831860,
#         msg_id:         "1234567890123456",
#       }, unquote(map))
#     end
#   end

#   defp with_event_message(msg) do
#     Map.merge(%{
#       to_user_name:   "toUser",
#       from_user_name: "fromUser",
#       create_time:    1348831860,
#     }, msg)
#   end
# end
