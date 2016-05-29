defmodule EditorServer.Router do
  require Logger

  use Plug.Router
  plug Plug.Parsers, parsers: [:urlencoded]

  plug :match
  plug :dispatch

  get "/" do
    conn 
    |> put_resp_content_type("text/html")
    |> send_resp(200, form)
  end

  post "/send" do
    output = inspect Code.eval_string(conn.params["code"])
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, output)
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end

  def form do
    "<form action='send' method='post'><textarea name='code'></textarea><input type=submit></form>"
  end
end
