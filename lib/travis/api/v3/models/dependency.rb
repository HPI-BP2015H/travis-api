module Travis::API::V3
  class Models::Dependency < Model
    belongs_to :dependency, class_name: "Repository"
    belongs_to :dependant, class_name: "Repository"
  end
end
