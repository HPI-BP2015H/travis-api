require 'spec_helper'

describe Travis::API::V3::Services::Dependencies::FindDependencies do
  let(:repo)        { Travis::API::V3::Models::Repository.create(owner_name: 'svenfuchs', name: 'enginex') }
  let(:repo2)       { Travis::API::V3::Models::Repository.where(owner_name: 'svenfuchs', name: 'minimal').first }
  let(:parsed_body) { JSON.load(body) }

  before do
    Travis::API::V3::Models::Dependency.create(dependency_id: repo2.id, dependant_id: repo.id)
  end

  describe "fetching dependencies" do
    before  { get("/v3/repo/#{repo.id}/dependencies")  }
    example { expect(last_response).to be_ok           }
    example { expect(parsed_body).to be == {
      "@type"           => "repositories",
      "@href"           => "/v3/repo/#{repo.id}/dependencies",
      "@representation" => "minimal",
      "repositories"    => [{
        "@type"           => "repository",
        "@href"           => "/v3/repo/1",
        "@representation" => "minimal",
        "id"              => repo2.id,
        "name"            => "minimal",
        "slug"            => "svenfuchs/minimal"
    }]}}
  end

  describe "fetching dependencies on a non-existing repo" do
    before  { get("/v3/repo/2345678/dependencies")   }
    example { expect(last_response).to be_not_found  }
    example { expect(parsed_body).to be == {
      "@type"         => "error",
      "error_type"    => "not_found",
      "error_message" => "repository not found (or insufficient access)",
      "resource_type" => "repository"
    }}
  end
end
