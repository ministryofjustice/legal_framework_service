require "swagger_helper"

RSpec.describe "threshold_waivers", type: :request, swagger: true do
  path "/threshold_waivers" do
    post("Return details of threshold waivers for specified proceeding type and client involvement type pairs identified by CCMS codes") do
      description "POST a JSON payload containing a request-id (a UUID generated by the client) and an array of
                   proceeding type and client involvement type CCMS code pairs to recieve a payload containing
                   the same request-id, and an array for each ccms_code pair submitted.<br/><br/>
                   Each item in the array will contain a list of Financial Eligibility assessment thresholds, and a value of true or false,
                   true meaning that the threshold is waived for this proceeding type and client involvement type (i.e unlimited) or false
                   to indicate that the threshold should be applied.  The matter type to which the proceeding belongs is also returned."

      request_id = "ff9679d7-ca3e-40b8-a47e-5006895d9026"
      values = [
        {
          ccms_code: "DA005",
          client_involvement_type: "A",
        },
        {
          ccms_code: "SE004",
          client_involvement_type: "D",
        },
      ]

      tags "Threshold waivers"
      response(200, "successful") do
        consumes "application/json"
        produces "application/json"
        parameter name: "threshold_waiver_query",
                  in: :body,
                  schema: {
                    type: :object,
                    properties: {
                      request_id: { type: :string,
                                    example: request_id,
                                    description: "Client generated request id that will be echoed back in the response" },
                      proceedings: { type: :array,
                                     items: [
                                       { type: :string, description: "CCMS codes of proceedings to be queried" },
                                       { type: :string, description: "CCMS codes of client involvement types to be queried" },
                                     ],
                                     example: values },
                    },
                    required: %w[request_id values],
                  }
        response(200, "success") do
          seed_live_data
          response = ThresholdWaiverService.call(request_id, values)

          examples "application/json" => response
          run_test!
        end
      end
    end
  end
end
