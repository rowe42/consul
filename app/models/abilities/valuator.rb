module Abilities
  class Valuator
    include CanCan::Ability

    def initialize(user)
      valuator = user.valuator
      can [:read, :update, :valuate], SpendingProposal
      can [:update, :valuate], Budget::Investment, id: valuator.investment_ids, budget: { valuating: true }
    end
  end
end
