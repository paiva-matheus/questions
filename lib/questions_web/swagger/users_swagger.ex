defmodule QuestionsWeb.UsersSwagger do
  @moduledoc false
  use PhoenixSwagger

  defmacro __using__(_opts) do
    quote do
      swagger_path :sign_in do
        post("/users/sign_in")
        description("User sign in")

        parameters do
          tracker(
            :body,
            Schema.ref(:SignInBody),
            "Params that needs to sign in",
            required: true
          )
        end

        response(200, "OK", Schema.ref(:SignInResponse))
      end

      ## Schemas
      def swagger_definitions do
        %{
          SignInResponse:
            swagger_schema do
              title("SignInResponse")
              description("Sign in response")

              properties do
                user(:User, Schema.ref(:User))
                token(:string, "token")
              end

              example(%{
                user: %{
                  id: "uuid",
                  name: "Dwight",
                  email: "dwight@mail.com",
                  role: "student"
                },
                token:
                  "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJxdWVzdGlvbnMiLCJleHAiOjE3MjM3NTU4NzMsImlhdCI6MTcyMzE1MTA3MywiaXNzIjoicXVlc3Rpb25zIiwianRpIjoiNjRiYmQ5OGItZGE0NS00YWNhLWFlZTgtODcxNGQwMjFhYzBhIiwibmJmIjoxNzIzMTUxMDcyLCJzdWIiOiI4MWI1YmY3NS1jNGRjLTRhMTctYjMwYi1lMmQ4YzIxNGU1MTMiLCJ0eXAiOiJhY2Nlc3MifQ.ejOem2Uq-GiDAVpI-jwPUWH_wAkXsLZAtV_MIkxZyW2dxVKrECH1ub6TvJadpucWJynBtxrBlUFisCYjWfdAhQ"
              })
            end,
          SignInBody:
            swagger_schema do
              title("SignInBody")
              description("Body to sign in")

              properties do
                email(:string, "User email")
                password(:string, "password")
              end

              example(%{
                email: "dwight@mail.com",
                password: "password"
              })
            end
        }
      end
    end
  end
end
