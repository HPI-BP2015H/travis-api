module Travis::API::V3
  class Queries::Dependency < Query

    def find(dependency, dependant)
      Models::Dependency.where(dependency_id: dependency.id, dependant_id: dependant.id).first
    end

    def create(dependency, dependant)
      Models::Dependency.create(dependency_id: dependency.id, dependant_id: dependant.id)
    end

  end
end
