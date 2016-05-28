defmodule EditorServer.Router do
  use Plug.Router

  plug :match
  plug :dispatch

  get "/hello" do
    send_resp(conn, 200, "Hello, world")
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end
end
