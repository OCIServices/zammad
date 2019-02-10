FactoryBot.define do
  factory :type_lookup do
    name do
      # The following line ensures that the name generated by Faker
      # does not conflict with any existing names in the DB.
      # There's a special syntax for this
      # (Faker::Verb.unique.exclude(:past_participle, [], Ticket::StateType.pluck(:name)),
      # but it's not available yet in the current release of Faker (1.9.1).
      Faker::Verb.unique
                 .instance_variable_get(:@previous_results)
                 .dig([:base, []])
                 .merge(TypeLookup.pluck(:name))

      Faker::Verb.unique.base
    end
  end
end