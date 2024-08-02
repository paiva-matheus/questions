defmodule QuestionsWeb.Router do
  use QuestionsWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :jwt_authentication do
    plug(QuestionsWeb.AuthenticationPipeline)
  end

  scope "/", QuestionsWeb do
    pipe_through :api
  end

  scope "/", QuestionsWeb do
    pipe_through(:api)

    post("/users/sign_in", UserController, :sign_in)
  end

  scope "/", QuestionsWeb do
    pipe_through([:api, :jwt_authentication])

    # User and Accounts
    resources("/accounts", AccountController, only: [:index, :create])

    # Questions
    resources("/questions", QuestionController, only: [:create, :show])
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:questions, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: QuestionsWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
