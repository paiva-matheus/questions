defmodule QuestionsWeb.QuestionsSwagger do
  @moduledoc false
  use PhoenixSwagger

  alias QuestionsWeb.Swagger.CommonParameters

  defmacro __using__(_opts) do
    quote do
      swagger_path :index do
        get("/questions")
        description("List Questions")
        CommonParameters.question()
        response(200, "OK", Schema.ref(:Questions))
        response(403, "Forbidden")
        response(401, "Unauthorized")
      end

      swagger_path :show do
        get("/questions/{question_id}")
        description("Get Question")
        parameter("question_id", :path, :string, "ID of question to return", required: true)
        response(200, "OK", Schema.ref(:Question))
        response(404, "Question Not Found")
        response(403, "Forbidden")
        response(401, "Unauthorized")
      end

      swagger_path :create do
        post("/questions")
        description("Add a new question")

        parameters do
          tracker(
            :body,
            Schema.ref(:CreateQuestionBody),
            "Question object that needs to create",
            required: true
          )
        end

        response(201, "Created", Schema.ref(:Question))
        response(403, "Forbidden")
        response(401, "Unauthorized")
      end

      swagger_path :complete do
        patch("/questions/{question_id}/complete")
        description("Complete a question")
        parameter("question_id", :path, :string, "ID of question to complete", required: true)
        response(200, "OK", Schema.ref(:Question))
        response(404, "Question Not Found")
        response(403, "Forbidden")
        response(401, "Unauthorized")
      end

      swagger_path :delete do
        PhoenixSwagger.Path.delete("/questions/{question_id}")
        description("Delete a question")
        parameter("question_id", :path, :string, "ID of question to delete", required: true)
        response(204, "No content")
        response(404, "Question Not Found")
        response(403, "Forbidden")
        response(401, "Unauthorized")
      end

      ## Schemas
      def swagger_definitions do
        %{
          Question:
            swagger_schema do
              title("Question")
              description("A single question")

              properties do
                id(:string, "Unique identifier")
                title(:string, "Question title", required: true)
                description(:string, "Question description", required: true)
                category(:string, "Question category", required: true)
                status(:string, "Question status")

                user(
                  Schema.new do
                    properties do
                      id(:string, "Unique identifier", required: true)
                      name(:string, "User name")
                      email(:string, "User email")
                      role(:string, "User role")
                    end
                  end
                )

                answers(:list, "List of answers")
              end

              example(%{
                id: "uuid",
                title: "Elixir",
                description: "What is elixir?",
                category: "technology",
                user: %{
                  id: "uuid",
                  name: "Dwight",
                  email: "dwight@mail.com",
                  role: "admin"
                },
                answers: []
              })
            end,
          Questions:
            swagger_schema do
              title("Questions")
              description("A collection of Questions")
              type(:array)
              items(Schema.ref(:Question))
            end,
          CreateQuestionBody:
            swagger_schema do
              title("Create Question Model")
              description("Template for creating questions")

              properties do
                user_id(:string, "Unique identifier")
                title(:string, "Question title", required: true)
                description(:string, "Question description", required: true)
                category(:string, "Question category", required: true)
              end
            end
        }
      end
    end
  end
end
