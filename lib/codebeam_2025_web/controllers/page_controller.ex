defmodule Codebeam2025Web.PageController do
  use Codebeam2025Web, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    redirect(conn, to: "/slides.html")
  end
end
