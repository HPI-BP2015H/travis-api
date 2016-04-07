require 'spec_helper'

describe Travis::API::V3::Services::Dependencies::Delete do
  let(:repo)                  { Travis::API::V3::Models::Repository.create(owner_name: 'svenfuchs', name: 'newRepo', owner_id: 1, owner_type: "User") }
  let(:repo2)                 { Travis::API::V3::Models::Repository.where(owner_name: 'svenfuchs', name: 'minimal').first }
  let(:dependency_relations)  { Travis::API::V3::Models::Dependency.where(dependency_id: repo2.id, dependant_id: repo.id) }
  let(:token)                 { Travis::Api::App::AccessToken.create(user: repo.owner, app_id: 1) }
  let(:headers)               {{ 'HTTP_AUTHORIZATION' => "token #{token}", "Content-Type" => "application/json" }}
  let(:options)               {{ "dependency_slug" => "svenfuchs/minimal" }}
  let(:wrong_options)         {{ "dependency_slug" => "svenfuchs/notExistingRepo" }}
  let(:parsed_body)           { JSON.load(body) }

  before do
    Travis::API::V3::Models::Dependency.create(dependency_id: repo2.id, dependant_id: repo.id)
  end

  describe "deleting a dependency" do
    before  { Travis::API::V3::Models::Permission.create(repository: repo, user: repo.owner, push: true) }
    before  { delete("/v3/repo/#{repo.id}/dependencies", options, headers)                               }
    example { expect(dependency_relations).to be_empty                                                   }
    example { expect(last_response).to be_ok                                                             }
    example { expect(parsed_body).to be == {
      "@type"               => "dependency",
      "@representation"     => "standard",
      "@permissions"        => {
        "read"              => false,
        "delete"            => true },
      "id"                  => 7,
      "dependency"          => {
        "@type"             => "repository",
        "@href"             => "/v3/repo/#{repo2.id}",
        "@representation"   => "minimal",
        "id"                => repo2.id,
        "name"              => "minimal",
        "slug"              => "svenfuchs/minimal"},
      "dependant"           => {
        "@type"             => "repository",
        "@href"             => "/v3/repo/#{repo.id}",
        "@representation"   => "minimal",
        "id"                => repo.id,
        "name"              => "newRepo",
        "slug"              => "svenfuchs/newRepo"
      }}}
  end

  describe "deleting a dependency twice" do
    before  { Travis::API::V3::Models::Permission.create(repository: repo, user: repo.owner, push: true) }
    before  { delete("/v3/repo/#{repo.id}/dependencies", options, headers)                               }
    before  { delete("/v3/repo/#{repo.id}/dependencies", options, headers)                               }
    example { expect(dependency_relations).to be_empty                                                   }
    example { expect(parsed_body).to be == {
      "@type"         => "error",
      "error_type"    => "not_found",
      "error_message" => "dependency not found (or insufficient access)",
      "resource_type" => "dependency"
    }}
  end

  describe "try deleting a dependency with a wrong dependency_slug" do
    before  { Travis::API::V3::Models::Permission.create(repository: repo, user: repo.owner, push: true) }
    before  { delete("/v3/repo/#{repo.id}/dependencies", wrong_options, headers)                         }
    example { expect(parsed_body).to be == {
      "@type"         => "error",
      "error_type"    => "not_found",
      "error_message" => "dependency_repo not found"
    }}
  end

  describe "try deleting a dependency without login" do
    before  { delete("/v3/repo/#{repo.id}/dependencies", options)  }
    example { expect(dependency_relations).not_to be_empty         }
    example { expect(parsed_body).to be == {
      "@type"         => "error",
      "error_type"    => "login_required",
      "error_message" => "login required"
    }}
  end

  describe "try deleting a dependency with a user without permissions" do
    before  { Travis::API::V3::Models::Permission.create(repository: repo, user: repo.owner, push: false)  }
    before  { delete("/v3/repo/#{repo.id}/dependencies", options, headers)                                 }
    example { expect(dependency_relations).not_to be_empty                                                 }
    example { expect(parsed_body).to be == {
      "@type"               => "error",
      "error_type"          => "insufficient_access",
      "error_message"       => "operation requires delete access to dependency",
      "resource_type"       => "dependency",
      "permission"          => "delete"
    }}
  end

  describe "deleting dependency on a non-existing repository by slug" do
    before  { Travis::API::V3::Models::Permission.create(repository: repo, user: repo.owner, push: false)  }
    before  { delete("/v3/repo/svenfuchs%2FnotExisting/dependencies", options, headers)                    }
    example { expect(last_response).to be_not_found                                                        }
    example { expect(parsed_body).to be == {
      "@type"         => "error",
      "error_type"    => "not_found",
      "error_message" => "repository not found (or insufficient access)",
      "resource_type" => "repository"
    }}
  end
end
