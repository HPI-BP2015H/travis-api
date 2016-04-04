require 'spec_helper'

describe Travis::API::V3::Services::Overview::BuildDuration do
  let(:repo) { Travis::API::V3::Models::Repository.where(owner_name: 'svenfuchs', name: 'minimal').first }

  describe "fetching build_duration data on a public repository" do
    before  { get("/v3/repo/#{repo.id}/overview/build_duration")  }
    example { expect(last_response).to be_ok                      }
  end

  describe "fetching build_duration from non-existing repo" do
    before  { get("/v3/repo/1231987129387218/overview/build_duration") }
    example { expect(last_response).to be_not_found                    }
    example { expect(parsed_body).to be == {
      "@type"         => "error",
      "error_type"    => "not_found",
      "error_message" => "repository not found (or insufficient access)",
      "resource_type" => "repository"
    }}
  end

  describe "build_duration on public repository" do
    builds = []
    before  {
      Travis::API::V3::Models::Build.where(repository_id: repo.id).each do |build| build.destroy end
      builds.push Travis::API::V3::Models::Build.create(repository_id: repo.id, created_at: DateTime.now - 5, duration: 600,  number: 1, state: 'passed',   branch_name: repo.default_branch.name)
      builds.push Travis::API::V3::Models::Build.create(repository_id: repo.id, created_at: DateTime.now - 4, duration: 1200, number: 2, state: 'failed',   branch_name: repo.default_branch.name)
      builds.push Travis::API::V3::Models::Build.create(repository_id: repo.id, created_at: DateTime.now - 2, duration: 10,   number: 3, state: 'passed',   branch_name: repo.default_branch.name)
      builds.push Travis::API::V3::Models::Build.create(repository_id: repo.id, created_at: DateTime.now - 1, duration: 0,    number: 4, state: 'canceled', branch_name: repo.default_branch.name)
      builds.push Travis::API::V3::Models::Build.create(repository_id: repo.id, created_at: DateTime.now,     duration: 6000, number: 4, state: 'failed',   branch_name: repo.default_branch.name)
      get("/v3/repo/#{repo.id}/overview/build_duration") }
    example { expect(last_response).to be_ok }
    example { expect(parsed_body).to be == {
      "@type"           => "overview",
      "@href"           => "/v3/repo/#{repo.id}/overview/build_duration",
      "@representation" => "standard",
      "build_duration"  => [
        { "id"       => builds[-1].id,
          "number"   => "4",
          "state"    => "failed",
          "duration" => 6000
        },
        { "id"       => builds[-3].id,
          "number"   => "3",
          "state"    => "passed",
          "duration" => 10
        },
        { "id"       => builds[-4].id,
          "number"   => "2",
          "state"    => "failed",
          "duration" => 1200
        },
        { "id"       => builds[-5].id,
          "number"   => "1",
          "state"    => "passed",
          "duration" => 600
        }
      ]
    }}
  end

  describe "build_duration returns last 20 builds" do
    builds = []
    before  {
      Travis::API::V3::Models::Build.where(repository_id: repo.id).each do |build| build.destroy end
      builds.push Travis::API::V3::Models::Build.create(repository_id: repo.id, duration: 1,  number: 1,  state: 'passed', branch_name: repo.default_branch.name)
      builds.push Travis::API::V3::Models::Build.create(repository_id: repo.id, duration: 1,  number: 2,  state: 'passed', branch_name: repo.default_branch.name)
      builds.push Travis::API::V3::Models::Build.create(repository_id: repo.id, duration: 1,  number: 3,  state: 'passed', branch_name: repo.default_branch.name)
      builds.push Travis::API::V3::Models::Build.create(repository_id: repo.id, duration: 1,  number: 4,  state: 'passed', branch_name: repo.default_branch.name)
      builds.push Travis::API::V3::Models::Build.create(repository_id: repo.id, duration: 1,  number: 5,  state: 'passed', branch_name: repo.default_branch.name)
      builds.push Travis::API::V3::Models::Build.create(repository_id: repo.id, duration: 1,  number: 6,  state: 'passed', branch_name: repo.default_branch.name)
      builds.push Travis::API::V3::Models::Build.create(repository_id: repo.id, duration: 1,  number: 7,  state: 'passed', branch_name: repo.default_branch.name)
      builds.push Travis::API::V3::Models::Build.create(repository_id: repo.id, duration: 1,  number: 8,  state: 'passed', branch_name: repo.default_branch.name)
      builds.push Travis::API::V3::Models::Build.create(repository_id: repo.id, duration: 1,  number: 9,  state: 'passed', branch_name: repo.default_branch.name)
      builds.push Travis::API::V3::Models::Build.create(repository_id: repo.id, duration: 1,  number: 10, state: 'passed', branch_name: repo.default_branch.name)
      builds.push Travis::API::V3::Models::Build.create(repository_id: repo.id, duration: 1,  number: 11, state: 'passed', branch_name: repo.default_branch.name)
      builds.push Travis::API::V3::Models::Build.create(repository_id: repo.id, duration: 1,  number: 12, state: 'passed', branch_name: repo.default_branch.name)
      builds.push Travis::API::V3::Models::Build.create(repository_id: repo.id, duration: 1,  number: 13, state: 'passed', branch_name: repo.default_branch.name)
      builds.push Travis::API::V3::Models::Build.create(repository_id: repo.id, duration: 1,  number: 14, state: 'passed', branch_name: repo.default_branch.name)
      builds.push Travis::API::V3::Models::Build.create(repository_id: repo.id, duration: 1,  number: 15, state: 'passed', branch_name: repo.default_branch.name)
      builds.push Travis::API::V3::Models::Build.create(repository_id: repo.id, duration: 1,  number: 16, state: 'passed', branch_name: repo.default_branch.name)
      builds.push Travis::API::V3::Models::Build.create(repository_id: repo.id, duration: 1,  number: 17, state: 'passed', branch_name: repo.default_branch.name)
      builds.push Travis::API::V3::Models::Build.create(repository_id: repo.id, duration: 1,  number: 18, state: 'passed', branch_name: repo.default_branch.name)
      builds.push Travis::API::V3::Models::Build.create(repository_id: repo.id, duration: 1,  number: 19, state: 'passed', branch_name: repo.default_branch.name)
      builds.push Travis::API::V3::Models::Build.create(repository_id: repo.id, duration: 1,  number: 20, state: 'passed', branch_name: repo.default_branch.name)
      builds.push Travis::API::V3::Models::Build.create(repository_id: repo.id, duration: 1,  number: 21, state: 'passed', branch_name: repo.default_branch.name)

      get("/v3/repo/#{repo.id}/overview/build_duration") }
    example { expect(last_response).to be_ok }
    example { expect(parsed_body).to be == {
      "@type"           => "overview",
      "@href"           => "/v3/repo/#{repo.id}/overview/build_duration",
      "@representation" => "standard",
      "build_duration"  => [
        { "id"       => builds[-1].id,
          "number"   => "21",
          "state"    => "passed",
          "duration" => 1
        },
        { "id"       => builds[-2].id,
          "number"   => "20",
          "state"    => "passed",
          "duration" => 1
        },
        { "id"       => builds[-3].id,
          "number"   => "19",
          "state"    => "passed",
          "duration" => 1
        },
        { "id"       => builds[-4].id,
          "number"   => "18",
          "state"    => "passed",
          "duration" => 1
        },
        { "id"       => builds[-5].id,
          "number"   => "17",
          "state"    => "passed",
          "duration" => 1
        },
        { "id"       => builds[-6].id,
          "number"   => "16",
          "state"    => "passed",
          "duration" => 1
        },
        { "id"       => builds[-7].id,
          "number"   => "15",
          "state"    => "passed",
          "duration" => 1
        },
        { "id"       => builds[-8].id,
          "number"   => "14",
          "state"    => "passed",
          "duration" => 1
        },
        { "id"       => builds[-9].id,
          "number"   => "13",
          "state"    => "passed",
          "duration" => 1
        },
        { "id"       => builds[-10].id,
          "number"   => "12",
          "state"    => "passed",
          "duration" => 1
        },
        { "id"       => builds[-11].id,
          "number"   => "11",
          "state"    => "passed",
          "duration" => 1
        },
        { "id"       => builds[-12].id,
          "number"   => "10",
          "state"    => "passed",
          "duration" => 1
        },
        { "id"       => builds[-13].id,
          "number"   => "9",
          "state"    => "passed",
          "duration" => 1
        },
        { "id"       => builds[-14].id,
          "number"   => "8",
          "state"    => "passed",
          "duration" => 1
        },
        { "id"       => builds[-15].id,
          "number"   => "7",
          "state"    => "passed",
          "duration" => 1
        },
        { "id"       => builds[-16].id,
          "number"   => "6",
          "state"    => "passed",
          "duration" => 1
        },
        { "id"       => builds[-17].id,
          "number"   => "5",
          "state"    => "passed",
          "duration" => 1
        },
        { "id"       => builds[-18].id,
          "number"   => "4",
          "state"    => "passed",
          "duration" => 1
        },
        { "id"       => builds[-19].id,
          "number"   => "3",
          "state"    => "passed",
          "duration" => 1
        },
        { "id"       => builds[-20].id,
          "number"   => "2",
          "state"    => "passed",
          "duration" => 1
        },
      ]
    }}
  end

  describe "build_duration on public empty repository" do
    before  {
      Travis::API::V3::Models::Build.where(repository_id: repo.id).each do |build| build.destroy end
      get("/v3/repo/#{repo.id}/overview/build_duration") }
    example { expect(last_response).to be_ok             }
    example { expect(parsed_body).to be == {
      "@type"           => "overview",
      "@href"           => "/v3/repo/#{repo.id}/overview/build_duration",
      "@representation" => "standard",
      "build_duration"  => []
    }}
  end

  describe "private repository, not authenticated" do
    before  { repo.update_attribute(:private, true)              }
    before  { get("/v3/repo/#{repo.id}/overview/build_duration") }
    before  { repo.update_attribute(:private, false)             }
    example { expect(last_response).to be_not_found              }
    example { expect(parsed_body).to be == {
      "@type"         => "error",
      "error_type"    => "not_found",
      "error_message" => "repository not found (or insufficient access)",
      "resource_type" => "repository"
    }}
  end

  describe "private repository, authenticated as user with access" do
    let(:token)   { Travis::Api::App::AccessToken.create(user: repo.owner, app_id: 1)  }
    let(:headers) {{ 'HTTP_AUTHORIZATION' => "token #{token}"}                         }
    before        { Travis::API::V3::Models::Build.where(repository_id: repo).each do |build| build.destroy end
                    Travis::API::V3::Models::Permission.create(repository: repo, user: repo.owner, pull: true) }
    before        { repo.update_attribute(:private, true)                              }
    before        { get("/v3/repo/#{repo.id}/overview/build_duration", {}, headers)    }
    after         { repo.update_attribute(:private, false)                             }
    example       { expect(last_response).to be_ok                                     }
    example       { expect(parsed_body).to be == {
      "@type"           => "overview",
      "@href"           => "/v3/repo/#{repo.id}/overview/build_duration",
      "@representation" => "standard",
      "build_duration"  => []
    }}
  end
end