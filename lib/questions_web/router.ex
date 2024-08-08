defmodule QuestionsWeb.Router do
  use QuestionsWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :jwt_authentication do
    plug(QuestionsWeb.AuthenticationPipeline)
  end

  scope "/", QuestionsWeb do
    pipe_through(:api)

    post("/users/sign_in", UserController, :sign_in)
  end

  scope "/students", QuestionsWeb do
    pipe_through :api

    post("/", StudentController, :create)
  end

  scope "/admin", QuestionsWeb do
    pipe_through([:api, :jwt_authentication])

    # User and Accounts
    resources("/accounts", AccountController, only: [:index, :create])
  end

  scope "/", QuestionsWeb do
    pipe_through([:api, :jwt_authentication])

    # Questions
    resources("/questions", QuestionController, only: [:index, :create, :show, :delete]) do
      patch("/complete", QuestionController, :complete)
    end

    # Answers
    resources("/answers", AnswerController, only: [:create, :delete]) do
      patch("/favorite", AnswerController, :favorite)
      patch("/unfavorite", AnswerController, :unfavorite)
    end
  end

  # Swagger
  def swagger_info do
    %{
      info: %{
        version: "1.0",
        title: "Questions"
      }
    }
  end

  scope "/api/swagger" do
    forward "/", PhoenixSwagger.Plug.SwaggerUI, otp_app: :questions, swagger_file: "swagger.json"
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
