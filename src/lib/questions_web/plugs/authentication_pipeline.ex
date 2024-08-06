defmodule QuestionsWeb.AuthenticationPipeline do
  @moduledoc false
  use Guardian.Plug.Pipeline,
    otp_app: :questions,
    module: Questions.AccessControl.Guardian,
    error_handler: Questions.AccessControl.AuthErrorHandler

  plug Guardian.Plug.VerifyHeader, schema: "Bearer"
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
