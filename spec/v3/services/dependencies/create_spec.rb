require 'spec_helper'

describe Travis::API::V3::Services::Dependencies::Create do
  let(:repo) { Travis::API::V3::Models::Repository.create(owner_name: 'svenfuchs', name: 'newRepo', owner_id: 1, owner_type: "User")       }
  let(:repo2) { Travis::API::V3::Models::Repository.where(owner_name: 'svenfuchs', name: 'minimal').first }
  let(:dependency_relations) { Travis::API::V3::Models::Dependency.where(dependency_id: repo2.id, dependant_id: repo.id) }
  let(:token)   { Travis::Api::App::AccessToken.create(user: repo.owner, app_id: 1) }
  let(:headers) {{ 'HTTP_AUTHORIZATION' => "token #{token}", "Content-Type" => "application/json" }}
  let(:options) {{ "dependency_slug" => "svenfuchs/minimal" }}
  let(:wrong_options) {{ "dependency_slug" => "svenfuchs/notExistingRepo" }}
  let(:parsed_body) { JSON.load(body) }

  describe "creating a dependencies" do
    before     { Travis::API::V3::Models::Permission.create(repository: repo, user: repo.owner, push: true) }
    before     { post("/v3/repo/#{repo.id}/dependencies", options, headers) }
    example    { expect(dependency_relations).not_to be_empty }
    example    { expect(last_response).to be_ok }
    example    { expect(parsed_body).to be == {
      "@type"              => "repository",
      "@href"              => "/v3/repo/#{repo.id}",
      "@representation"    => "standard",
      "@permissions"       => {
        "read"             => true,
        "enable"           => false,
        "disable"          => false,
        "star"             => false,
        "unstar"           => false,
        "create_request"   => false,
        "create_dependency"=> false},
      "id"                 =>  repo.id,
      "name"               =>  "minimal",
      "slug"               =>  "svenfuchs/minimal",
      "description"        => nil,
      "github_language"    => nil,
      "active"             => true,
      "private"            => false,
      "owner"              => {
        "id"               => repo.owner_id,
        "login"            => "svenfuchs",
        "@type"            => "user",
        "@href"            => "/v3/user/#{repo.owner_id}"},
      "default_branch"     => {
        "@type"            => "branch",
        "@href"            => "/v3/repo/#{repo.id}/branch/master",
        "@representation"  => "minimal",
        "name"             => "master"},
      "starred"            => false
    }}
  end

  describe "creating multiple dependencies between to repos" do
    before     { Travis::API::V3::Models::Permission.create(repository: repo, user: repo.owner, push: true) }
    before     { post("/v3/repo/#{repo.id}/dependencies", options, headers) }
    before     { post("/v3/repo/#{repo.id}/dependencies", options, headers) }
    it "only stores one" do
      expect(dependency_relations.size).to eq(1)
    end
  end

  describe "creating a dependency with a wrong dependency_slug" do
    before     { last_cron }
    before     { Travis::API::V3::Models::Permission.create(repository: repo, user: repo.owner, push: true) }
    before     { post("/v3/repo/#{repo.id}/dependencies", wrong_options, headers) }
    example    { expect(parsed_body).to be == {
      "@type"         => "error",
      "error_type"    => "error",
      "error_message" => "Invalid value for interval. Interval must be \"daily\", \"weekly\" or \"monthly\"!"
    }}
  end

  describe "try creating a dependency without login" do
    before     { post("/v3/repo/#{repo.id}/dependencies", options) }
    example { expect(parsed_body).to be == {
      "@type"         => "error",
      "error_type"    => "login_required",
      "error_message" => "login required"
    }}
  end

  describe "try creating a dependency with a user without permissions" do
    before     { Travis::API::V3::Models::Permission.create(repository: repo, user: repo.owner, push: false) }
    before     { post("/v3/repo/#{repo.id}/dependencies", options, headers) }
    example    { expect(parsed_body).to be == {
        "@type"               => "error",
        "error_type"          => "insufficient_access",
        "error_message"       => "operation requires create_dependency access to repository",
        "resource_type"       => "repository",
        "permission"          => "create_dependency",
        "repository"          => {
            "@type"           => "repository",
            "@href"           => "/repo/#{repo.id}", # should be /v3/repo/#{repo.id}
            "@representation" => "minimal",
            "id"              => repo.id,
            "name"            => "minimal",
            "slug"            => "svenfuchs/minimal" }
    }}
  end

  describe "creating dependency on a non-existing repository by slug" do
    before     { Travis::API::V3::Models::Permission.create(repository: repo, user: repo.owner, push: false) }
    before     { post("/v3/repo/svenfuchs%2FnotExisting/dependencies", options, headers)     }
    example { expect(last_response).to be_not_found }
    example { expect(parsed_body).to be == {
      "@type"         => "error",
      "error_type"    => "not_found",
      "error_message" => "repository not found (or insufficient access)",
      "resource_type" => "repository"
    }}
  end


end
