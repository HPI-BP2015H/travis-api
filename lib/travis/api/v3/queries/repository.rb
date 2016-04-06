module Travis::API::V3
  class Queries::Repository < Query
    params :id, :slug

    def find
      @find ||= find!
    end

    def star(current_user)
      repository = find
      starred = Models::Star.where(repository_id: repository.id, user_id: current_user.id).first
      Models::Star.create(repository_id: repository.id, user_id: current_user.id) unless starred
      repository
    end

    def unstar(current_user)
      repository = find
      starred = Models::Star.where(repository_id: repository.id, user_id: current_user.id).first
      starred.delete if starred
      repository
    end

    def find_by_slug_or_id(slug, id)
      return by_slug(slug) if slug
      return Models::Repository.find_by_id(id) if id
      raise WrongParams, 'missing repository.id'.freeze
    end

    private

    def find!
      find_by_slug_or_id(slug, id)
    end

    def by_slug(slug)
      owner_name, name = slug.split('/')
      Models::Repository.where(owner_name: owner_name, name: name, invalidated_at: nil).first
    end
  end
end
