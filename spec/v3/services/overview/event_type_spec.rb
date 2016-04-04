require 'spec_helper'

describe Travis::API::V3::Services::Overview::EventType do
  let(:repo) { Travis::API::V3::Models::Repository.where(owner_name: 'svenfuchs', name: 'minimal').first }

  describe "fetching event_type on a public repository" do
    before  { get("/v3/repo/#{repo.id}/overview/event_type") }
    example { expect(last_response).to be_ok                 }
  end

  describe "fetching event_type from non-existing repo" do
    before  { get("/v3/repo/1231987129387218/overview/event_type") }
    example { expect(last_response).to be_not_found                }
    example { expect(parsed_body).to be == {
      "@type"         => "error",
      "error_type"    => "not_found",
      "error_message" => "repository not found (or insufficient access)",
      "resource_type" => "repository"
    }}
  end

  describe "event_type on public repository" do
    before  {
      Travis::API::V3::Models::Build.where(repository_id: repo.id).each do |build| build.destroy end

      Travis::API::V3::Models::Build.create(repository_id: repo.id, event_type: 'push', state: 'passed', branch_name: repo.default_branch.name)
      Travis::API::V3::Models::Build.create(repository_id: repo.id, event_type: 'push', state: 'failed', branch_name: repo.default_branch.name)
      Travis::API::V3::Models::Build.create(repository_id: repo.id, event_type: 'push', state: 'errored', branch_name: repo.default_branch.name)

      Travis::API::V3::Models::Build.create(repository_id: repo.id, event_type: 'pull_request', state: 'passed', branch_name: repo.default_branch.name)
      Travis::API::V3::Models::Build.create(repository_id: repo.id, event_type: 'pull_request', state: 'failed', branch_name: repo.default_branch.name)
      Travis::API::V3::Models::Build.create(repository_id: repo.id, event_type: 'pull_request', state: 'failed', branch_name: repo.default_branch.name)
      Travis::API::V3::Models::Build.create(repository_id: repo.id, event_type: 'pull_request', state: 'errored', branch_name: repo.default_branch.name)

      Travis::API::V3::Models::Build.create(repository_id: repo.id, event_type: 'cron', state: 'passed',   branch_name: repo.default_branch.name)
      Travis::API::V3::Models::Build.create(repository_id: repo.id, event_type: 'cron', state: 'failed',   branch_name: repo.default_branch.name)
      Travis::API::V3::Models::Build.create(repository_id: repo.id, event_type: 'cron', state: 'canceled', branch_name: repo.default_branch.name)
      Travis::API::V3::Models::Build.create(repository_id: repo.id, event_type: 'cron', state: 'started',  branch_name: repo.default_branch.name)
      Travis::API::V3::Models::Build.create(repository_id: repo.id, event_type: 'cron', state: 'passed',   branch_name: repo.default_branch.name)
      get("/v3/repo/#{repo.id}/overview/event_type") }
    example { expect(last_response).to be_ok         }
    example { expect(parsed_body).to be == {
      "@type"           => "overview",
      "@href"           => "/v3/repo/#{repo.id}/overview/event_type",
      "@representation" => "standard",
      "event_type"      => {
        'push'         => {
          'errored' => 1,
          'passed'  => 1,
          'failed'  => 1
        },
        'pull_request' => {
          'errored' => 1,
          'passed'  => 1,
          'failed'  => 2
        },
        'cron'         => {
          'canceled' => 1,
          'started'  => 1,
          'passed'   => 2,
          'failed'   => 1
        }
      }
    }}
  end

  describe "event_type on public repository with no existing cron jobs" do
    before  {
      Travis::API::V3::Models::Build.where(repository_id: repo.id).each do |build| build.destroy end
      Travis::API::V3::Models::Build.create(repository_id: repo.id, event_type: 'push', state: 'passed', branch_name: repo.default_branch.name)
      Travis::API::V3::Models::Build.create(repository_id: repo.id, event_type: 'push', state: 'failed', branch_name: repo.default_branch.name)
      Travis::API::V3::Models::Build.create(repository_id: repo.id, event_type: 'push', state: 'errored', branch_name: repo.default_branch.name)

      Travis::API::V3::Models::Build.create(repository_id: repo.id, event_type: 'pull_request', state: 'failed', branch_name: repo.default_branch.name)
      Travis::API::V3::Models::Build.create(repository_id: repo.id, event_type: 'pull_request', state: 'failed', branch_name: repo.default_branch.name)
      Travis::API::V3::Models::Build.create(repository_id: repo.id, event_type: 'pull_request', state: 'failed', branch_name: repo.default_branch.name)
      Travis::API::V3::Models::Build.create(repository_id: repo.id, event_type: 'pull_request', state: 'errored', branch_name: repo.default_branch.name)

      get("/v3/repo/#{repo.id}/overview/event_type") }
    example { expect(last_response).to be_ok         }
    example { expect(parsed_body).to be == {
      "@type"           => "overview",
      "@href"           => "/v3/repo/#{repo.id}/overview/event_type",
      "@representation" => "standard",
      "event_type"      => {
        'push'         => {
          'passed'  => 1,
          'errored' => 1,
          'failed'  => 1
        },
        'pull_request' => {
          'errored' => 1,
          'failed'  => 3
        }
      }
    }}
  end

  describe "event_type on public empty repository" do
    before  {
      Travis::API::V3::Models::Build.where(repository_id: repo.id).each do |build| build.destroy end
      get("/v3/repo/#{repo.id}/overview/event_type") }
    example { expect(last_response).to be_ok         }
    example { expect(parsed_body).to be == {
      "@type"           => "overview",
      "@href"           => "/v3/repo/#{repo.id}/overview/event_type",
      "@representation" => "standard",
      "event_type"      => {}
    }}
  end

  describe "private repository, not authenticated" do
    before  { repo.update_attribute(:private, true)          }
    before  { get("/v3/repo/#{repo.id}/overview/event_type") }
    before  { repo.update_attribute(:private, false)         }
    example { expect(last_response).to be_not_found          }
    example { expect(parsed_body).to be == {
      "@type"         => "error",
      "error_type"    => "not_found",
      "error_message" => "repository not found (or insufficient access)",
      "resource_type" => "repository"
    }}
  end

  describe "private repository, authenticated as user with access" do
    let(:token)   { Travis::Api::App::AccessToken.create(user: repo.owner, app_id: 1) }
    let(:headers) {{ 'HTTP_AUTHORIZATION' => "token #{token}"}                        }
    before        { Travis::API::V3::Models::Build.where(repository_id: repo).each do |build| build.destroy end
                    Travis::API::V3::Models::Permission.create(repository: repo, user: repo.owner, pull: true) }
    before        { repo.update_attribute(:private, true)                             }
    before        { get("/v3/repo/#{repo.id}/overview/event_type", {}, headers)       }
    after         { repo.update_attribute(:private, false)                            }
    example       { expect(last_response).to be_ok                                    }
    example       { expect(parsed_body).to be == {
      "@type"           => "overview",
      "@href"           => "/v3/repo/#{repo.id}/overview/event_type",
      "@representation" => "standard",
      "event_type"      => {}
    }}
  end
end