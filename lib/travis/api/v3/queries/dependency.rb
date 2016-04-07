module Travis::API::V3
  class Queries::Dependency < Query

    def find(dependency, dependant)
      Models::Dependency.where(dependency_id: dependency.id, dependant_id: dependant.id).first
    end

    def create(dependency, dependant)
      Models::Dependency.create(dependency_id: dependency.id, dependant_id: dependant.id)
    end

    def startChildren(repository)
      repository.dependants.each do |dependant|
        start(dependant)
      end
      repository.dependants
    end

    def start(dependant)
      raise ServerError, 'repository does not have a github_id'.freeze unless dependant.github_id

      user_id = dependant.users.detect { |u| u.github_oauth_token }.id

      payload = {
        repository: { id: dependant.github_id, owner_name: dependant.owner_name, name: dependant.name },
        branch:     dependant.default_branch.name,
        user:       { id: user_id }
      }

      class_name, queue = Query.sidekiq_queue(:build_request)
      ::Sidekiq::Client.push('queue'.freeze => queue, 'class'.freeze => class_name, 'args'.freeze => [{type: 'api'.freeze, payload: JSON.dump(payload), credentials: {}}])
      payload
    end
  end
end
