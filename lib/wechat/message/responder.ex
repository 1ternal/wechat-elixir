defmodule Wechat.Message.Responder do
  @moduledoc """
  wechat message responder

  use Wechat.Message.Responder
  """

  defmacro __using__(_opt) do
    quote do
      import Wechat.Message.ReplyBuilder
      def reply(msg, type), do: Wechat.Message.Responder.reply(msg, type)

      @before_compile(unquote(__MODULE__))
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def handle_message(_t, msg) do
        msg
        |> Wechat.Message.Responder.reply(:text)
        |> Map.put(:content, "fallback")
      end
      def handle_event(_t, msg) do
        msg
        |> Wechat.Message.Responder.reply(:text)
        |> Map.put(:content, "fallback")
      end
    end
  end

  def reply(msg, type \\ :text)
  def reply(msg, type) do
    msg
    |> switch_user
    |> required_attrs
    |> reply_type(type)
  end

  defp switch_user(%{from_user_name: from, to_user_name: to}) do
    %{from_user_name: to, to_user_name: from}
  end

  defp required_attrs(params)  do
    params
    |> Map.put(:create_time, DateTime.utc_now |> DateTime.to_unix)
    |> Map.put(:msg_type, "text")
  end

  defp reply_type(msg, type) do
    msg
    |> Map.put(:msg_type, String.downcase(to_string(type)))
    |> populate_message(type)
  end

  defp populate_message(message, :text) do
    Map.merge(message,  %{content: nil})
  end
  defp populate_message(message, :image) do
    Map.merge(message, %{image: %{media_id: nil}})
  end
  defp populate_message(message, :voice) do
    Map.merge(message, %{voice: %{media_id: nil}})
  end
  defp populate_message(message, :video) do
    Map.merge(message, %{video: %{media_id: nil, title: nil, description: nil}})
  end
  defp populate_message(message, :music) do
    Map.merge(message, %{music: %{title: nil, description: nil, music_url: nil, hq_music_url: nil, thumb_media_id: nil}})
  end
  defp populate_message(message, :news) do
    Map.merge(message, %{
      article_count: nil,
      articles: []
    })
  end
end
