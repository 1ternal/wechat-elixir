defmodule Wechat.Message.DSL do
  @moduledoc """
  This module is use to define message dsl.
  expose `message` macro to handle received messages and `event` macro to handle received events

  those two macro both transform to function `reply(message)`
  """

  alias Wechat.Message.ReplyBuilder

  defmacro __using__(_opt) do
    quote do
      import Wechat.Message.ReplyBuilder
      import unquote(__MODULE__), only: [message: 2, message: 3, event: 2, event: 3]
      @before_compile(unquote(__MODULE__))
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def reply(msg) do
        msg
        |> ReplyBuilder.type(:text)
        |> ReplyBuilder.content("fallback")
      end
    end
  end

  defmacro message(msg_type, opts \\ [], func) do
    check_message_params!(msg_type, opts)

    reply_type = Keyword.get(opts, :to, :text)

    msg_type
    |> message_matcher(opts)
    |> match_reply(reply_type, func)
  end

  defmacro event(event_type, opts \\ [], func) do
    check_event_params!(event_type, opts)
    reply_type = Keyword.get(opts, :to, :text)

    event_type
    |> event_matcher(opts)
    |> match_reply(reply_type, func)
  end

  defp check_message_params!(msg_type, opts) when is_atom(msg_type) and is_list(opts) do
    with_val = Keyword.get(opts, :with)
    check_with_val!(with_val)
    check_allow_with_val!(msg_type, with_val, [:text, :event, :click, :view, :scan])
  end

  defp check_event_params!(event_type, opts) when is_atom(event_type) and is_list(opts) do
    with_val = Keyword.get(opts, :with)
    check_with_val!(with_val)
    check_allow_with_val!(event_type, with_val, [:subscribe, :scan, :click, :view])
  end

  defp check_with_val!(nil), do: :ok
  defp check_with_val!(val) when is_binary(val), do: :ok
  defp check_with_val!(_) do
    raise RuntimeError, "with matcher must be binary"
  end

  defp check_allow_with_val!(_, nil, _), do: :ok
  defp check_allow_with_val!(current_type, _, allowed_types) do
    unless current_type in allowed_types do
      type_name = current_type |> to_string |> String.capitalize
      raise ~s(#{type_name} CANNOT use `with` in options.Only text, event, click, view, and scan can having :with parameters.)
    end
  end

  defp message_matcher(msg_type, opts) do
    match_val = Keyword.get(opts, :with)
    if match_val do
      %{msg_type: "text", content: match_val}
    else
      %{msg_type: to_string(msg_type)}
    end
  end

  @sub_and_unsub_mapsize 5
  defp event_matcher(event_type, opts) do
    with_val = Keyword.get(opts, :with)

    case {event_type, with_val} do
      {t, nil} when t in [:subscribe, :unsubscribe] ->
        {
          %{msg_type: "event", event: to_string(t)},
          @sub_and_unsub_mapsize
        }
      {:subscribe, val} when is_binary(val) -> %{msg_type: "event", event: "subscribe", event_key: val}
      {:scan, val} when is_binary(val)      -> %{msg_type: "event", event: "SCAN", event_key: val}
      {:scan, nil}                          -> %{msg_type: "event", event: "SCAN"}
      {:location, nil}                      -> %{msg_type: "event", event: "LOCATION"}
      {:click, val} when is_binary(val)     -> %{msg_type: "event", event: "CLICK", event_key: val}
      {:click, nil}                         -> %{msg_type: "event", event: "CLICK"}
      {:view, val} when is_binary(val)      -> %{msg_type: "event", event: "VIEW", event_key: val}
      {:view, nil}                          -> %{msg_type: "event", event: "VIEW"}
    end
  end

  defp match_reply({message_spec, size_restrict}, reply_type, func) do
    ms = Macro.escape(message_spec)
    quote do
      def reply(unquote(ms) = msg) when map_size(msg) == unquote(size_restrict),
        do: Wechat.Message.DSL.generic_handle(msg, unquote(reply_type), unquote(func))
    end
  end
  defp match_reply(message_spec, reply_type, func) when is_map(message_spec) do
    ms = Macro.escape(message_spec)
    quote do
      def reply(unquote(ms) = msg),
        do: Wechat.Message.DSL.generic_handle(msg, unquote(reply_type), unquote(func))
    end
  end

  def generic_handle(msg, reply_type, func) do
    reply = ReplyBuilder.type(msg, reply_type)
    case :erlang.fun_info(func)[:arity] do
      1 -> func.(reply)
      2 -> func.(msg, reply)
      _ -> raise(RuntimeError, "Function deal with message must have 1 or 2 arity")
    end
  end
end
