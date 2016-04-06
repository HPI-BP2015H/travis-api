require 'spec_helper'

describe Travis::API::V3::Services::Dependencies::FindDependants do
  let(:repo) { Travis::API::V3::Models::Repository.where(owner_name: 'svenfuchs', name: 'enginex').first }
  let(:repo2) { Travis::API::V3::Models::Repository.where(owner_name: 'svenfuchs', name: 'minimal').first }
  let(:dependency_relations) { Travis::API::V3::Models::Dependency.where(dependency_id: repo.id, dependant_id: repo2.id) }
  let(:token)   { Travis::Api::App::AccessToken.create(user: repo.owner, app_id: 1) }
  let(:headers) {{ 'HTTP_AUTHORIZATION' => "token #{token}", "Content-Type" => "application/json" }}
  let(:options) {{ "dependency_slug" => "svenfuchs/minimal" }}
  let(:wrong_options) {{ "dependency_slug" => "svenfuchs/notExistingRepo" }}
  let(:parsed_body) { JSON.load(body) }


end
