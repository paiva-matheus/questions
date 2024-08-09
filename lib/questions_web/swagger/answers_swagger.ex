defmodule QuestionsWeb.AnswersSwagger do
  @moduledoc false
  use PhoenixSwagger

  defmacro __using__(_opts) do
    quote do
      swagger_path :create do
        post("/answers")
        description("Add a new answer")

        parameters do
          tracker(
            :body,
            Schema.ref(:CreateAnswerBody),
            "Answer object that needs to create",
            required: true
          )
        end

        response(201, "Created", Schema.ref(:Answer))
        response(403, "Forbidden")
        response(401, "Unauthorized")
      end

      swagger_path :delete do
        PhoenixSwagger.Path.delete("/answers/{answer_id}")
        description("Delete a answer")
        parameter("answer_id", :path, :string, "ID of answer to delete", required: true)
        response(204, "No content")
        response(404, "Answer Not Found")
        response(403, "Forbidden")
        response(401, "Unauthorized")
      end

      swagger_path :favorite do
        patch("/answers/{answer_id}/favorite")
        description("Favorite a answer")
        parameter("answer_id", :path, :string, "ID of question to favorite", required: true)
        response(200, "OK", Schema.ref(:Question))
        response(404, "Answer Not Found")
        response(403, "Forbidden")
        response(401, "Unauthorized")
      end

      swagger_path :unfavorite do
        patch("/answers/{answer_id}/unfavorite")
        description("Unfavorite a answer")
        parameter("answer_id", :path, :string, "ID of question to unfavorite", required: true)
        response(200, "OK", Schema.ref(:Question))
        response(404, "Answer Not Found")
        response(403, "Forbidden")
        response(401, "Unauthorized")
      end

      ## Schemas
      def swagger_definitions do
        %{
          Answer:
            swagger_schema do
              title("Answer")
              description("A single answer")

              properties do
                id(:string, "Unique identifier")
                content(:string, "Answer content", required: true)
                favorite(:string, "Answer favorite", required: false)
                monitor_id(:string, "Monitor id", required: true)
                question_id(:string, "Question id")
              end

              example(%{
                id: "uuid",
                content: "Can't connect to WSL2 localhost server from WSL2 docker container",
                favorite: false,
                monitor_id: "uuid",
                question_id: "uuid"
              })
            end,
          CreateAnswerBody:
            swagger_schema do
              title("Create Answer Model")
              description("Template for creating answers")

              properties do
                content(:string, "Answer content", required: true)
                monitor_id(:string, "Monitor id", required: true)
                question_id(:string, "Question id", required: true)
              end
            end
        }
      end
    end
  end
end
