class SplitSponsorContactPersonNameIntoFirstNameAndLastName < ActiveRecord::Migration[4.2]
  def up
    add_column :sponsors, :contact_person_first_name, :string
    add_column :sponsors, :contact_person_last_name, :string

    Sponsor.all.each { |sponsor|

      unless sponsor.contact_person == nil
        first, last = sponsor.contact_person.split(" ", 2)

        sponsor.contact_person_first_name = first
        sponsor.contact_person_last_name = last
        sponsor.save!
      end
    }
  end

  def down
    remove_column :sponsors, :first_name
    remove_column :sponsors, :last_name
  end
end
