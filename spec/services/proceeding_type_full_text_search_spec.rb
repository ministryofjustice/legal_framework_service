require "rails_helper"
require_relative "full_text_search_query_transformer_examples"

RSpec.describe ProceedingTypeFullTextSearch do
  it_behaves_like "full text search query transformer"

  describe ".call" do
    subject(:proceeding_type_full_text_search_results) { described_class.call(search_term) }

    let(:excluded_codes) { [] }

    context "when searching for a non-existent term" do
      let(:search_term) { "animals" }

      it "returns an empty array" do
        expect(proceeding_type_full_text_search_results).to eq []
      end
    end

    context "when searching for a category of law" do
      let(:search_term) { "Family" }

      it "returns everything" do
        result_set = proceeding_type_full_text_search_results
        expect(result_set.count).to eq ProceedingType.count
      end
    end

    context "when searching for a term that only exists on one record" do
      let(:search_term) { "mutilation" }

      it "returns one result row" do
        result_set = proceeding_type_full_text_search_results
        expect(result_set.size).to eq 1
      end

      it "returns an instance of Result" do
        result = proceeding_type_full_text_search_results.first
        expect(result).to be_an_instance_of(ProceedingTypeFullTextSearch::Result)
      end

      it "returns FGM Protection order" do
        result = proceeding_type_full_text_search_results.first
        expect(result.meaning).to eq "FGM Protection Order"
        expect(result.description).to eq "To be represented on an application for a Female Genital Mutilation Protection Order under the Female Genital Mutilation Act."
        expect(result.full_s8_only).to be false
      end
    end

    context "when the search term only exists in additional_search_terms" do
      let(:search_term) { "cao" }

      it "returns twelve records" do
        result_set = proceeding_type_full_text_search_results
        expect(result_set.map(&:ccms_code).sort).to eq %w[SE013 SE013A SE013E SE014 SE014A SE014E SE015 SE015A SE015E SE016 SE016A SE016E]
      end
    end

    context "when searching for a term which occurs in more than one proceeding" do
      let(:search_term) { "injunction" }

      it "returns three results" do
        result_set = proceeding_type_full_text_search_results
        expect(result_set.size).to eq 3
      end

      it "returns the ones in which the search term appears first; and additional terms matches are last" do
        result_set = proceeding_type_full_text_search_results
        expect(result_set.map(&:meaning)).to contain_exactly("Harassment - injunction", "Inherent jurisdiction high court injunction", "Non-molestation order")
        expect(result_set.map(&:meaning)[2]).to eq "Non-molestation order"
      end

      context "when you send one of the codes as an excluded_term" do
        subject(:proceeding_type_full_text_search_results) { described_class.call(search_term, excluded_codes) }

        let(:excluded_codes) { "DA001" }

        it "returns two results" do
          result_set = proceeding_type_full_text_search_results
          expect(result_set.size).to eq 2
        end

        it "returns the one with the search term in meaning first and excludes the second result" do
          result_set = proceeding_type_full_text_search_results
          expect(result_set.map(&:meaning)).to eq ["Harassment - injunction", "Non-molestation order"]
        end
      end
    end

    context "with multiple term searches" do
      let(:search_term) { "protection order" }

      it "returns results matching either term" do
        result_set = proceeding_type_full_text_search_results
        expect(result_set.map(&:meaning)).to contain_exactly("FGM Protection Order",
                                                             "Forced marriage protection order",
                                                             "Variation or discharge under section 5 protection from harassment act 1997",
                                                             "Emergency protection order",
                                                             "Emergency protection order - discharge",
                                                             "Emergency protection order - extend")
      end
    end
  end
end
