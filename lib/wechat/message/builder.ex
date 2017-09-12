defmodule Wechat.Message.Builder do
  @moduledoc """
  Default MessageHandler implements
  """

  defmacro __using__(_opt) do
    quote do
      Module.register_attribute __MODULE__, :functions, accumulate: true, persist: false
      import unquote(__MODULE__), only: [from: 2, from: 3]
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(env) do
    compile(Module.get_attribute(env.module, :functions))
  end

  defmacro from(receive_type, opt \\ [], fun) do
    reply_type = Keyword.get(opt, :to, :text)
    with_val = Keyword.get(opt, :with)

    check_receive_type!(receive_type)
    check_reply_type!(reply_type)
    check_with_param!(receive_type, with_val)
    check_function!(fun, __ENV__)

    func = Macro.escape(fun)
    quote bind_quoted: [receive_type: receive_type, reply_type: reply_type, with_val: with_val, func: func] do
      @functions {receive_type, reply_type, with_val, func}
    end
  end

  def compile(functions) do
    reply_fun_ast =
      for {receive_type, reply_type, with_guard, func} <- functions do
        defreply(receive_type, reply_type, with_guard, func)
      end

    quote do
      unquote(Enum.reverse(reply_fun_ast))
      def reply(msg), do: Wechat.Message.Builder.reply_fallback(msg)
      defoverridable [reply: 1]
    end
  end

  defp defreply(receive_type, reply_type, nil, func) do
    case receive_type do
      :event_subscribe        -> match_reply(%{"MsgType" => "event", "Event" => "subscribe"}, 5,   {reply_type, func})
      :event_unsubscribe      -> match_reply(%{"MsgType" => "event", "Event" => "unsubscribe"}, 5, {reply_type, func})
      :event_location         -> match_reply(%{"MsgType" => "event", "Event" => "LOCATION"},       {reply_type, func})
      :event_scan             -> match_reply(%{"MsgType" => "event", "Event" => "SCAN"},           {reply_type, func})
      type when is_atom(type) -> match_reply(%{"MsgType" => to_string(type)},                 {reply_type, func})
    end
  end

  defp defreply(receive_type, reply_type, matcher, func) when is_binary(matcher) do
    case receive_type do
      :event_scan  -> match_reply(%{"MsgType" => "event", "EventKey" => matcher},                     {reply_type, func})
      :event_click -> match_reply(%{"MsgType" => "event", "Event" => "CLICK", "EventKey" => matcher}, {reply_type, func})
      :event_view  -> match_reply(%{"MsgType" => "event", "Event" => "VIEW", "EventKey" => matcher},  {reply_type, func})
      :text        -> match_reply(%{"MsgType" => "text", "Content" => matcher},                      {reply_type, func})
    end
  end

  defp match_reply(match_msg, {reply_type, func}) do
    escaped = Macro.escape(match_msg)
    quote do
      def reply(unquote(escaped) = msg),
        do: Wechat.Message.Builder.reply(msg, unquote(reply_type), unquote(func))
    end
  end
  defp match_reply(match_msg, map_size, {reply_type, func}) do
    escaped = Macro.escape(match_msg)
    quote do
      def reply(unquote(escaped) = msg) when map_size(msg) == unquote(map_size),
        do: Wechat.Message.Builder.reply(msg, unquote(reply_type), unquote(func))
    end
  end

  def reply(msg, type \\ :text)
  def reply(msg, type) do
    msg
    |> switch_user
    |> required_attrs
    |> reply_type(type)
  end
  def reply(msg, type, func) do
    reply = reply(msg, type)
    case :erlang.fun_info(func)[:arity] do
      1 -> func.(reply)
      2 -> func.(msg, reply)
      _ -> raise "Function arity error"
    end
  end

  def reply_fallback(msg) do
    msg
    |> reply(:text)
    |> Map.put("Content", "wechat handler fallback message")
  end

  defp reply_type(msg, type) do
    msg
    |> Map.put("MsgType", String.downcase(to_string(type)))
    |> populate_message(type)
  end

  defp check_receive_type!(type) do
    unless type in Wechat.Message.Incoming.types() do
      raise "#{type} type message action not supported"
    end
  end

  defp check_reply_type!(type) do
    unless type in Wechat.Message.Reply.types() do
      raise "#{type} type reply message not supported"
    end
  end

  defp check_with_param!(type, with_guard) do
    if with_guard && !Wechat.Message.Builder.allow_with_param?(type) do
      type_name = type |> to_string |> String.capitalize
      raise ~s(
        #{type_name} message defination error.
        Only text, event, click, view, scan and batch_job can having :with parameters
      )
    end

    if !with_guard && Wechat.Message.Builder.must_have_with_params?(type) do
      type_name = type |> to_string |> String.capitalize
      raise ~s(
        #{type_name} message defination error.
        click, view, scan and batch_job must specify :with parameters
      )
    end
  end

  defp check_function!(function, env) do
    {fun_def, _} = Code.eval_quoted(function, [], file: env.file, line: env.line)
    case :erlang.fun_info(fun_def)[:arity] do
      n when n in [1, 2] -> :ok
      _ ->
        raise ~s(
          Opps, callback func must be one or two arity.
          just like `recv, reply` or `reply`
        )
    end
  end

  # message
  def allow_with_param?(:text),            do: true
  def allow_with_param?(:image),           do: false
  def allow_with_param?(:voice),           do: false
  def allow_with_param?(:video),           do: false
  def allow_with_param?(:shortvideo),      do: false
  def allow_with_param?(:location),        do: false
  def allow_with_param?(:link),            do: false
  # events
  def allow_with_param?(:event_subscribe), do: true
  def allow_with_param?(:event_scan),      do: true
  def allow_with_param?(:event_click),     do: true
  def allow_with_param?(:event_view),      do: true

  def must_have_with_params?(:click),     do: true
  def must_have_with_params?(:view),      do: true
  def must_have_with_params?(:scan),      do: true
  def must_have_with_params?(:batch_job), do: true
  def must_have_with_params?(_),          do: false

  defp switch_user(%{"FromUserName" => from, "ToUserName" => to}) do
    %{"FromUserName" => to, "ToUserName" => from}
  end

  defp required_attrs(params)  do
    params
    |> Map.put("CreateTime", DateTime.utc_now |> DateTime.to_unix)
    |> Map.put("MsgType", "text")
  end

  defp populate_message(message, :text) do
    Map.merge(message,  %{"Content" => nil})
  end
  defp populate_message(message, :image) do
    Map.merge(message, %{"Image" => %{"MediaId" => nil}})
  end
  defp populate_message(message, :voice) do
    Map.merge(message, %{"Voice" => %{"MediaId" => nil}})
  end
  defp populate_message(message, :video) do
    Map.merge(message, %{"Video" => %{"MediaId" => nil, "Title" => nil, "Description" => nil}})
  end
  defp populate_message(message, :music) do
    Map.merge(message, %{"Music" => %{"Title" => nil, "Description" => nil, "MusicUrl" => nil, "HQMusicUrl" => nil, "ThumbMediaId" => nil}})
  end
  defp populate_message(message, :news) do
    Map.merge(message, %{
      "ArticleCount" => nil,
      "Articles" => [
        item: %{
          "Title" => nil,
          "Description" => nil,
          "PicUrl" => nil,
          "Url" => nil
        }
      ]
      })
  end
end
