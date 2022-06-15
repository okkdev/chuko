defmodule Chuko.Repo do
  use Ecto.Repo,
    otp_app: :chuko,
    adapter: Ecto.Adapters.SQLite3
end
