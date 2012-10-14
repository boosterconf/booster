module Roles
  def self.all
    [:developer, :tester, :project_manager, :architect, :ux_specialist, :security_professional]
  end

  def self.label
    {:developer => "Developer",
     :tester => "Tester/test lead",
     :project_manager => "Project manager",
     :architect => "Architect",
     :ux_specialist => "UX specialist",
     :security_professional => "Security professional"}
  end
end