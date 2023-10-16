defmodule PentoWeb.WrongLive do
  use PentoWeb, :live_view
  alias Pento.Accounts

  def mount(_params, session, socket) do
    user = Accounts.get_user_by_session_token(session["user_token"])

    {:ok,
     assign(socket,
       score: 0,
       message: "Make a guess:",
       time: time(),
       number: Enum.random(1..10),
       is_right?: false,
       session_id: session["live_socket_id"],
       current_user: user
     )}
  end

  def handle_event("guess", %{"number" => guess} = _data, socket) do
    is_right? = check_guess(socket.assigns.number, String.to_integer(guess))

    message =
      case(is_right?) do
        true -> "Your guess: #{guess}. Right!"
        false -> "Your guess: #{guess}. Wrong. Guess again. "
      end

    score =
      case(is_right?) do
        true -> socket.assigns.score + 1
        false -> socket.assigns.score - 1
      end

    {
      :noreply,
      assign(
        socket,
        message: message,
        score: score,
        is_right?: is_right?
      )
    }
  end

  def render(assigns) do
    ~H"""
    <h1>Your score: <%= @score %></h1>
    <h2>
      <%= @message %>
    </h2>
    <h2>
      <%= for n <- 1..10 do %>
        <a href="#" phx-click="guess" phx-value-number={n}><%= n %></a>
      <% end %>
    </h2>
    <%= if @is_right? do %>
    <.link href="/guess">Restart</.link>
    <% end %>
    <pre>
    <%= @current_user.email %>
    <%= @session_id %>
    </pre>
    """
  end

  defp check_guess(number, guess) do
    number == guess
  end

  defp time do
    DateTime.utc_now() |> to_string
  end
end
