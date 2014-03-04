module Roles
  def self.all
    [:developer, :tester, :project_manager, :architect, :ux_specialist, :security_professional, :product, :manager, :scrum_master, :agile_coach, :designer, :other]
  end  

  def self.label
    {
        developer: 'Developer',
        tester: 'Tester/test lead',
        project_manager: 'Project manager',
        architect: 'Architect',
        ux_specialist: 'UX specialist',
        security_professional: 'Security professional',
        product: 'Product developer',
        scrum_master: 'Scrum master',
        agile_coach: 'Agile coach',
        designer: 'Designer',
        manager: 'Manager',
        other: 'Other'
    }
  end
end