defmodule IpsumWeb.ChatLive.Retro do
  alias Ipsum.Chats
  use IpsumWeb, :live_view
  alias Ipsum.Chats

  def mount(%{"id" => id}, session, socket) do
    chat = Ipsum.Chats.get_chat!(id)
    messages = Ipsum.Chats.list_messages(id)
    message_changeset = Chats.change_message(%Chats.Message{})

    if connected?(socket) do
      Phoenix.PubSub.subscribe(Ipsum.PubSub, "chat:#{id}")
    end

    socket =
      socket
      |> assign_new(:current_user, fn ->
        Ipsum.Accounts.get_user_by_session_token(session["user_token"])
      end)
      |> assign_new(:user, fn ->
        if socket.assigns.current_user.id == chat.user_1_id do
          Ipsum.Accounts.get_user!(chat.user_2_id)
        else
          Ipsum.Accounts.get_user!(chat.user_1_id)
        end
      end)

    {:ok,
     socket
     |> stream(:messages, messages)
     |> assign(
       message_changeset: message_changeset,
       input: "",
       chat_id: id,
       typing_timer_ref: nil,
       is_typing: false
     )}
  end

  def handle_event("submit", _params, socket) do
    case socket.assigns.input do
      "" ->
        {:noreply, socket}

      message ->
        message_params = %{
          content: message,
          chat_id: socket.assigns.chat_id,
          user_id: socket.assigns.current_user.id
        }

        case Chats.create_message(message_params) do
          {:ok, message} ->
            Phoenix.PubSub.broadcast!(
              Ipsum.PubSub,
              "chat:#{socket.assigns.chat_id}",
              {:new_message, message}
            )

            if socket.assigns.typing_timer_ref do
              Process.cancel_timer(socket.assigns.typing_timer_ref)

              Phoenix.PubSub.broadcast!(
                Ipsum.PubSub,
                "chat:#{socket.assigns.chat_id}",
                {:typing_status, socket.assigns.current_user.id, false}
              )
            end

            {:noreply,
             socket
             |> stream_insert(:messages, message)
             |> assign(
               input: "",
               typing_timer_ref: nil,
               message_changeset: Chats.change_message(%Chats.Message{})
             )}

          {:error, %Ecto.Changeset{} = changeset} ->
            {:noreply, assign(socket, message_changeset: changeset)}
        end
    end
  end

  def handle_event("update_input", %{"value" => value}, socket) do
    if socket.assigns.typing_timer_ref do
      Process.cancel_timer(socket.assigns.typing_timer_ref)
    end

    timer_ref =
      if value != "" do
        Phoenix.PubSub.broadcast!(
          Ipsum.PubSub,
          "chat:#{socket.assigns.chat_id}",
          {:typing_status, socket.assigns.current_user.id, true}
        )

        Process.send_after(self(), {:stop_typing, socket.assigns.current_user.id}, 3000)
      else
        Phoenix.PubSub.broadcast!(
          Ipsum.PubSub,
          "chat:#{socket.assigns.chat_id}",
          {:typing_status, socket.assigns.current_user.id, false}
        )

        nil
      end

    {:noreply, assign(socket, input: value, typing_timer_ref: timer_ref)}
  end

  def render(assigns) do
    ~H"""
    <div class="w-full h-[100dvh] overflow-hidden flex flex-col bg-[#282c34]">
      <div class="h-6 w-full flex items-center justify-between bg-[#21252b] px-2 border-b border-[#181a1f]">
        <div class="flex items-center gap-2">
          <.link
            navigate={~p"/"}
            class="text-[#abb2bf] hover:text-white transition-all font-mono text-xs"
          >
            <.icon name="hero-arrow-left" class="w-3 h-3" />
          </.link>
          <span class="text-[#98c379] text-xs font-mono">[0]</span>
          <span class="text-[#abb2bf] text-xs font-mono">chat</span>
        </div>
        <div class="flex items-center gap-2">
          <span class="text-[#61afef] text-xs font-mono">#{String.slice(@chat_id, 0..7)}</span>
          <span class="text-[#abb2bf] text-xs font-mono">|</span>
          <span class="text-[#98c379] text-xs font-mono">online</span>
          <span class="text-[#abb2bf] text-xs font-mono">|</span>
          <span class="text-[#c678dd] text-xs font-mono">
            #{DateTime.utc_now() |> Calendar.strftime("%H:%M")}
          </span>
        </div>
      </div>

      <div class="flex-1 overflow-y-auto flex flex-col-reverse" id="chat">
        <div
          id="messages"
          phx-update="stream"
          phx-hook="ScrollToBottom"
          class="px-2 py-1 text-[#abb2bf] space-y-1 font-mono text-xs"
        >
          <div :for={{id, msg} <- @streams.messages} id={id}>
            <div class="flex items-start">
              <div>
                <%= if msg.user_id == @current_user.id do %>
                  <span class="text-[#61afef] opacity-80">
                    [arch@localhost]$
                  </span>
                <% else %>
                  <span class="text-[#61afef]">
                    [doctor@nasa]$
                  </span>
                <% end %>
                <span class={
                  if msg.user_id == @current_user.id, do: "text-[#abb2bf]", else: "text-[#98c379]"
                }>
                  {msg.content}
                </span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div id="is_typing">
        <%= if @is_typing && @typing_user_id != @current_user.id do %>
          <p class="text-[#5c6370] text-xs px-2 py-1 font-mono">
            [doctor@nasa] is typing...
          </p>
        <% end %>
      </div>

      <div class="px-2 py-1 bg-[#282c34] border-t border-[#181a1f]">
        <div class="text-[#5c6370] text-xs font-mono mb-1">
          [#{String.slice(@chat_id, 0..7)}] 1:chat* 2:zsh
        </div>
        <form phx-submit="submit">
          <div class="flex items-center">
            <span class="text-[#61afef] font-mono text-xs">[arch@localhost]$ </span>
            <input
              placeholder=""
              class="w-full outline-none focus:ring-0 border-0 py-1 px-1 bg-[#282c34] text-[#abb2bf] placeholder-[#5c6370] font-mono text-xs"
              name="message"
              value={@input}
              phx-keyup="update_input"
              autocomplete="off"
            />
            <button class="text-[#5c6370] hover:text-[#abb2bf]">
              <.icon name="hero-paper-airplane-solid" class="w-3 h-3 transform -rotate-45" />
            </button>
          </div>
        </form>
      </div>
    </div>
    """
  end

  def handle_info({:new_message, message}, socket) do
    {:noreply, stream_insert(socket, :messages, message)}
  end

  def handle_info({:typing_status, user_id, is_typing}, socket) do
    if user_id != socket.assigns.current_user.id do
      {:noreply, assign(socket, is_typing: is_typing, typing_user_id: user_id)}
    else
      {:noreply, socket}
    end
  end

  def handle_info({:stop_typing, user_id}, socket) do
    Phoenix.PubSub.broadcast!(
      Ipsum.PubSub,
      "chat:#{socket.assigns.chat_id}",
      {:typing_status, user_id, false}
    )

    {:noreply, assign(socket, typing_timer_ref: nil)}
  end
end
