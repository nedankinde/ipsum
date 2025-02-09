defmodule Ipsum.Repo do
  use Ecto.Repo,
    otp_app: :ipsum,
    adapter: Ecto.Adapters.SQLite3
end
