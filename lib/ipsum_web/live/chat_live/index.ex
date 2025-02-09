defmodule IpsumWeb.ChatLive.Index do
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
    <div class="w-full h-[100dvh] p-5 md:p-10 lg:px-24 xl:px-36 overflow-hidden flex flex-col bg-[--background]">
      <div class="h-16 w-full flex items-center justify-between px-4 sm:px-6">
        <.link navigate={~p"/"} class="text-[--secondary] hover:text-[--primary] transition-colors">
          <.icon name="hero-arrow-left" class="w-5 h-5" />
        </.link>
        <div class="flex items-center gap-3">
          <div class="w-3 h-3 bg-[--success] rounded-full animate-pulse"></div>
          <div class="flex flex-col items-center">
            <p class="text-[--text] font-medium text-sm sm:text-base truncate w-36 md:w-full">
              Chat #{@chat_id}
            </p>
          </div>
        </div>
        <div class="w-5"></div>
      </div>
      <div class="flex-1 bg-[--background] overflow-y-auto flex flex-col-reverse" id="chat">
        <div
          id="messages"
          phx-update="stream"
          phx-hook="ScrollToBottom"
          style="scrollbar-none"
          class="px-2 sm:px-3 text-[--text]"
        >
          <div
            :for={{id, msg} <- @streams.messages}
            id={id}
            class={"flex p-2 sm:p-4 mb-2 sm:mb-3 w-fit max-w-[85%] sm:max-w-[80%] #{if msg.user_id == @current_user.id, do: "ml-auto flex-row-reverse"}"}
          >
            <div class={"flex items-center gap-2 sm:gap-3 #{if msg.user_id == @current_user.id, do: "flex-row-reverse"}"}>
              <.link
                navigate={~p"/user/#{msg.user_id}"}
                class={"w-8 sm:w-10 h-8 sm:h-10 rounded-full flex-shrink-0 shadow-xl hover:opacity-80 transition-opacity #{if msg.user_id == @current_user.id, do: "", else: ""}"}
                style={"background: var(--gradient-#{if msg.user_id == @current_user.id, do: @current_user.gradient, else: @user.gradient})"}
              >
              </.link>
              <div class={"px-3 sm:px-4 py-2 rounded-2xl shadow-md #{if msg.user_id == @current_user.id, do: "bg-[--primary] text-[--text]", else: "bg-[--contrast] text-[--text]"}"}>
                <p class="text-sm sm:text-base leading-relaxed">{msg.content}</p>
              </div>
            </div>
          </div>
        </div>
      </div>
      <div id="is_typing">
        <%= if @is_typing && @typing_user_id != @current_user.id do %>
          <p class="text-[--secondary] text-[10px] animate-pulse font-medium tracking-wide px-4 py-2 rounded-lg bg-[--contrast] backdrop-blur-sm">
            {@user.id} is typing...
          </p>
        <% end %>
      </div>
      <div class="h-fit w-full mb-4">
        <form phx-submit="submit">
          <input
            placeholder="Message..."
            class="input bg-[--contrast] w-full py-3 sm:py-4 px-4 sm:px-5 resize-none h-12 sm:h-14 text-sm sm:text-base"
            name="message"
            value={@input}
            phx-keyup="update_input"
            autocomplete="off"
          />
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
